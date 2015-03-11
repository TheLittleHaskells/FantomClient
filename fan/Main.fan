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
        processCommand(command.get)
        command = listener.send("~>")
      }
      Actor.sleep(250.toDuration);
    }
  }
  
  /**
   * Processes a message sent by the server
   **/
  public static Void readMessage(Str payload){
    echo("readMessage got: " + payload + " but not implemented.")
  }
  
  /**
   * Processes a command entered by the user.
   **/
  public static Void processCommand(Str command){
    echo("processCommand got: " + command + " but not yet implemented.")
  }
}