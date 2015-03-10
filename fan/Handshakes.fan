using inet
using concurrent

/**
 * Handshakes between Client and Server
 */
class Handshakes {
  /**
  * Handshake to be called by client
  *
  */
  public static TcpSocket clientShake(Str username, TcpSocket server){
    echo("starting handshake with username: " + username)

    // Send our username
    server.out.writeChars(username + "\n")
    server.out.flush

    echo("sent username")
    // Get a list of used ports
    Int[] usedPorts := [,]
    while(server.in.avail <= 0){
      echo("avail: " + server.in.avail)
      Actor.sleep(50.toDuration)
    }
    inStr := server.in.readLine
    echo("reading: " + inStr)
    if(inStr.size > 0) inStr.split(",".chars[0],true).each |Str x| { 
      if(x != "") usedPorts.add(x.toInt)
    }
    
    // Generate a randomly not used one.
    Int portToUse := Int.random(1025..65000)
    while(usedPorts.contains(portToUse)){
      portToUse = Int.random(1025..65000)
    }
    
    server.out.writeChars(portToUse.toStr + "\n")
    server.out.flush
    address := server.remoteAddr
    
    server.close
    
    echo("connecting to " + address +":"+ portToUse)

    Actor.sleep(50.toDuration)
    


    return TcpSocket().connect(address, portToUse)
  }
}
