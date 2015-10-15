class Cartotrailer {
  static mapping = {
    version false
  }
  static constraints = {
    car_id(nullable:false)
    trailer_id(nullable:false)
  }

  Long id
  Integer car_id
  Integer trailer_id

}