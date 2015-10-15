class Clienttoregion {
  static mapping = {
    version false
  }
  static constraints = {
    client_id(nullable:false)
    region_id(nullable:false)
  }

  Long id
  Long client_id
  Integer region_id

}