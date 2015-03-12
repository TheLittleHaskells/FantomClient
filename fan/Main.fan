/*  Fantom Client
 *  CMPS112
 *  The Little Haskells
 **/

using concurrent
using inet

class Main{
  
  static Void main(Str[] args){
    /**
     * We start by parsing the configuration file. The configuration file
     * must be specified as an argument on the command line.
     **/
    if(args.size != 1){  // check correct # of args
      echo("Usage: FantomClient <config file>")
      Env.cur.exit(1)
    }
    Str:Str configOpts := [:]
    configFile := Uri(args[0]).toFile
    if(!configFile.exists){  // make sure file exists
      echo("error: Config file doesn't exist.")
      Env.cur.exit(1)
    }
    configFile.readAllLines.each |Str x| { 
      tokens := x.split("=".chars[0], true)
      configOpts.add(tokens[0], tokens[1]) 
    }

    
    /**
     * We then perform the handshake with the server and establish our
     * connection on a random port.
     **/
    server := Handshakes.clientShake(configOpts["USERNAME"], 
      TcpSocket().connect(IpAddr(configOpts["ADDRESS"]), 
        configOpts["PORT"].toInt))
    
    /**
     * We create a new thread to handle input from the user. We will process
     * the result of this thread in the main program loop. The thread expects
     * the prompt to be displayed to the user to be provided as a string sent
     * to the thread. It will return a Future with the user's input.
     **/
    pool := ActorPool()
    listener := Actor(pool) |Str prompt->Str| {
      echo(prompt)
      return Env.cur.in.readLine
    }
    command := listener.send("~>")

    /**
     * Main program loop
     * 
     * We run through as first check if there's anything in the socket buffer
     * for us to read. Once that's done, we check our UI thread to see if the
     * user entered any commands. If they didn't we go to sleep.
     **/
    while(true){
      if(server.in.avail > 0){
        message := server.in.readLine
        readMessage(message.toStr);
      }
      // Here we check if the command thread we started earlier has completed. If
      // it has completed, it means that the user entered something we need to
      // process. We can get that value by using command.get. Once we're done with
      // it, we need to start a new thread to process the user's next command by
      // sending a new prompt to display to the user to the thread, which tells it
      // to start again.
      if(command.isDone){
        message := command.get().toStr;

        // user enters /quit
        if(message.startsWith("/quit")){
          sendMessage("GTFO",configOpts["USERNAME"],server)
          Env.cur.exit();

        // user enters /list
        }else if(message.startsWith("/list")){
          sendMessage("LIST",configOpts["USERNAME"],server);
          
        // otherwise, it's a chat message
        }else{
          sendMessage("CHAT",command.get.toStr,server)
        }
        command = listener.send("~>")
      }
      Actor.sleep(250.toDuration);
    }
  }
 
  public static Void sendMessage(Str type, Str payload, TcpSocket client){
    Str message := type + "@" + payload;
    client.out.writeChars(message + "\n")
    client.out.flush
  } 
  
  /**
   * Processes a message sent by the server
   **/
  public static Void readMessage(Str payload){
    type := payload.getRange(0..3);
    message := payload.getRange(5..payload.size-1);
    if (type.equals("CHAT")){
      displayChat(message);
    } else if (type.equals("LIST")){
      displayList(message);
    } else if (type.equals("GTFO")){
      echo("Server has logged off. Program is shutting down")
      Env.cur.exit();
    } else {
      echo("Invalid message: " + payload)
    }
  }
  
  public static Void displayChat(Str message){
    echo("\t" + message);
    echo("~>")
  }
  
  public static Void displayList(Str message){
    userlist := message.split('@');
    for(Int i:=0; i < userlist.size; i++){
      echo(userlist[i]);
    }
    echo("~>")
  }
}