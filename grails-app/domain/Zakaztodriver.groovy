class Zakaztodriver {
  static mapping = {
    version false
  }
  static constraints = {
  }

  Long id
  Long zakaz_id
  Long client_id
  Long driver_id
  Integer car_id
  Integer trailer_id
  String containernumber1 = ''
  String containernumber2 = ''
  Integer contpaid1 = 0
  Integer contpaid2 = 0
  Integer modstatus = 0
  Integer timestart = 0
  Integer timeend = 0
  String slotlist = ''
  Integer zcol = 1

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def beforeDelete() {
    def ncar = Zakaztodriver.findAllByClient_idAndZakaz_id(client_id,zakaz_id).size()-1
    Zakaztocarrier.findByClient_idAndZakaz_id(client_id,zakaz_id)?.csiSetNcar(ncar>0?ncar:0)?.csiSetCarInfo(ncar>0?1:0)?.save()
  }

  def beforeInsert() {
    Zakaztocarrier.findByClient_idAndZakaz_id(client_id,zakaz_id)?.csiSetNcar(Zakaztodriver.findAllByClient_idAndZakaz_id(client_id,zakaz_id).size()+1)?.csiSetCarInfo(1)?.save()
  }

  Zakaztodriver setMainData(_request){
    driver_id = _request.driver_id
    car_id = _request.car_id
    trailer_id = _request.trailer_id?:0
    zcol = _request.zcol?:1
    this
  }

  Zakaztodriver setShipperData(_request){
    containernumber1 = (_request.('cont1_'+id)?:_request.('containernumber1')?:'').toUpperCase()
    containernumber2 = (_request.('cont2_'+id)?:_request.('containernumber2')?:'').toUpperCase()
    if (Zakaz.get(zakaz_id)?.slotlist) {
      slotlist = _request.('timestart_'+id)?:slotlist
      timestart = Slot.get(_request.('timestart_'+id))?.getTimeStart()?:timestart
      timeend = Slot.get(_request.('timestart_'+id))?.getTimeEnd()?:timeend
    } else {
      timestart = _request.('timestart_'+id)?.toInteger()?:timestart
      timeend = _request.('timeend_'+id)?.toInteger()?:timeend
    }
    this
  }

  Zakaztodriver createTrip(_zakaz){
    Trip.findOrCreateByZakaztodriver_id(this.id).createFromZakaz(_zakaz,this,Zakaztocarrier.findByClient_idAndZakaz_id(client_id,zakaz_id)?.cprice?:0).save(failOnError:true)
    this
  }

  Zakaztodriver csiSetModstatus(iStatus){
    modstatus = iStatus?:0
    this
  }

  Zakaztodriver assign(){
    Freecars.findByClient_idAndModstatusAndDriver_id(client_id,1,driver_id)?.csiSetModstatus(2)?.save()
    csiSetModstatus(1)
  }

  Zakaztodriver updatecontnumbers(_request){
    containernumber1 = _request.containernumber1.toUpperCase()
    containernumber2 = containernumber2?_request.containernumber2.toUpperCase():''
    this
  }

  Zakaztodriver csiSetContpaid(bIsSecond){
    if (bIsSecond) contpaid2 = 1
    else contpaid1 = 1
    this
  }

  Zakaztodriver csiRemoveContpaid(sContname){
    if (containernumber1==sContname) contpaid1 = 0
    else if(containernumber2==sContname) contpaid2 = 0
    this
  }

}