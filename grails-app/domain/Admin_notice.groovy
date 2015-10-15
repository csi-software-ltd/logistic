class Admin_notice {

  static mapping = {
    version false
  }

  static constraints = {
  }

  Integer id
  String message
  String contact
  Integer is_read
  Integer type
}