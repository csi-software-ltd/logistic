class Paytax {
  static mapping = {
    version false
    sort paydate: "desc"
  }
  static constraints = {
  }

  Integer id
  Long client_id
  Long trip_id = 0
  Date paydate
  Integer summa

///////////////////////////////////////////////////////////////////////////////////////////////////

  Paytax setMainData(_request){
    summa = _request.summa
    paydate = _request.paydate
    trip_id = trip_id?:_request.trip_id?:0
    this
  }

}