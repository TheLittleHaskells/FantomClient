/*  Fantom Client
 *  CMPS112
 *  The Little Haskells
 **/

using concurrent

class Main{

  static Void main(Str[] args){
    Str:Str configOpts := [:]
    configFile := Uri(args[0]).toFile
    
    // Parse Config
    configFile.readAllLines.each |Str x| { 
      tokens := x.split("=".chars[0], true)
      configOpts.add(tokens[0], tokens[1]) 
    }
    
    // Start Message Handler
    pool := ActorPool()
    
    
    // Start UI
    
  }
  
}