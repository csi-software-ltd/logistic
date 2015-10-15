class Freecars {
  static mapping = {
    version false
  }
  static constraints = {
  }

  Long id
  Long client_id
  Long driver_id
  Integer car_id
  Integer trailer_id
  String routes
  Integer modstatus = 1
  Integer timestart = -1
  Integer timeend = -1
  Date inputdate = new Date()

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Freecars setMainData(_request,_routes){
    driver_id = _request.driver_id
    car_id = _request.car_id
    trailer_id = _request.trailer_id?:0
    routes = ';'+_routes.join(';')+';'
    timestart = _request.timestart?:-1
    timeend = _request.timeend?:25
    this
  }

  Freecars csiSetModstatus(iStatus){
    modstatus = iStatus?:0
    this
  }

}