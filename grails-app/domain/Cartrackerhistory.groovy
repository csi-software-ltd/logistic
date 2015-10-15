class Cartrackerhistory {
  static mapping = {
    version false
  }
  static constraints = {
  }

  Integer id
  Integer car_id = 0
  String imei
  Date inputdate = new Date()

}