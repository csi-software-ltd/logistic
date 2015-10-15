class Signature {

  static mapping = {
    table "nametosignature"
    version false
  }

  static constraints = {
  }

  Integer id
  String name
  String filename

}