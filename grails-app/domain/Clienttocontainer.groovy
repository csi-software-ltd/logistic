class Clienttocontainer {
  static mapping = {
    version false
  }
  static constraints = {
    client_id(nullable:false)
    container_id(nullable:false)
  }

  Long id
  Long client_id
  Integer container_id

}