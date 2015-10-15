class Trackingdata_archive {
  static constraints = {
  	tracktime(nullable:true)
  }
  static mapping = {
    version false
  }

	Long id
	String imei
	Long x
	Long y
	Integer kurs
	Integer speed
	Integer status = 1
	Integer distance = 0
	Integer car_id = 0
	Date tracktime
	Date inputdate = new Date()

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
}