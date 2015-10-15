class Car {

  static mapping = {
    version false
  }

  static constraints = {
    client_id(nullable:false)
    gosnomer(unique:true)
  }

  Integer id
  String gosnomer
  String imei = ''
  Long client_id
  Integer trailer = 0
  Integer is_platform = 0
  Integer model_id
  Integer modstatus = 1
  Integer is_passport1 = 0
  Integer is_passport2 = 0

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def afterInsert() {
    Client.get(client_id)?.computeCarCount()?.save(failOnError:true)
  }

  void computeCarCount() {
    Client.get(client_id)?.computeCarCount()?.save(failOnError:true)
  }

  Car setData(lsRequest){
    gosnomer = lsRequest.car_gosnomer?:gosnomer
    trailer = lsRequest.car_trailer?:0
    is_platform = lsRequest.car_is_platform?:0
    model_id = lsRequest.car_model_id?:model_id
    this
  }

  Car csiSetModstatus(iStatus){
    modstatus = iStatus?:0
    this
  }

  Car csiSetImei(sImei){
    imei = sImei?:''
    if (sImei) Client.get(client_id)?.updatetrackerstatus(true)?.save(failOnError:true)
    else Client.get(client_id)?.updatetrackerstatus(Car.findAllByClient_idAndImeiNotEqualAndIdNotEqual(client_id,'',id)?true:false)?.save(failOnError:true)
    save(failOnError:true)
  }

  Car updatescanstatus(sName,iStatus){
    this."$sName" = iStatus?:0
    this
  }

}