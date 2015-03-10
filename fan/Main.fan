/*  Fantom Client
 *  CMPS112
 *  The Little Haskells
 **/

using concurrent
using inet

class Main{

  static Void main(Str[] args){
    Str:Str configOpts := [:]
    configFile := Uri(args[0]).toFile
    
    // Parse Config
    configFile.readAllLines.each |Str x| { 
      tokens := x.split("=".chars[0], true)
      configOpts.add(tokens[0], tokens[1]) 
    }
    
    echo("finished parsing config")

    server := Handshakes.clientShake(configOpts["USERNAME"], TcpSocket().connect(IpAddr(configOpts["ADDRESS"]), configOpts["PORT"].toInt))
    
    // Start Message Handler
    pool := ActorPool()
    listener := Actor(pool) |Str prompt->Str| {
      echo(prompt)
      return Env.cur.in.readLine
    }
    command := listener.send("~>")
    
    // Start UI
    while(true){
      if(server.in.avail > 0){
        message := server.in.readLine
        echo("got a message...\n")
        readMessage(message.toStr);
      }
      if(command.isDone){
        processCommand(command.get)
        command = listener.send("~>")
      }
      Actor.sleep(250.toDuration);
    }
    echo("finished main")
  }
  
  public static Void readMessage(Str payload){
    echo(payload)
  }
  
  public static Void processCommand(Str command){
    echo("processing " + command)
  }
}