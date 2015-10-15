class Tracker {
  static mapping = {
    version false
  }
  static constraints = {
    moddate(nullable:true)
  }

  Long id
  String imei
  String trackaccount = ''
  String sim = ''
  String tel = ''
  Date inputdate = new Date()
  Date moddate = new Date()
  Integer modstatus = 1

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def beforeUpdate() {
    moddate = new Date()
  }

  Tracker setData(lsRequest){
    imei = lsRequest.imei?:imei
    trackaccount = lsRequest.trackaccount?:''
    sim = lsRequest.sim?:''
    tel = lsRequest.tel?:''
    modstatus = lsRequest.modstatus?:0
    this
  }

  Tracker associate(sCarGosnomer){
    def oldCar = Car.findByImei(imei)
    if ((oldCar?.gosnomer?:'')!=sCarGosnomer) {
      oldCar?.csiSetImei('')
      def newCar = Car.findByGosnomer(sCarGosnomer)
      if (newCar?.imei)
        new Cartrackerhistory(car_id:0,imei:newCar?.imei).save(failOnError:true)
      newCar?.csiSetImei(imei)
      new Cartrackerhistory(car_id:newCar?.id?:0,imei:imei).save(failOnError:true)
    }
    this
  }

}