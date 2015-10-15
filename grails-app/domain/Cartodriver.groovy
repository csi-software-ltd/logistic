class Cartodriver {
  static mapping = {
    version false
  }
  static constraints = {
    car_id(nullable:false)
    driver_id(nullable:false)
  }

  Long id
  Integer car_id
  Long driver_id

}