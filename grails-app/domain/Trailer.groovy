class Trailer {
  static mapping = {
    version false
  }
  static constraints = {
    client_id(nullable:false)
  }

  Integer id
  Long client_id
  Integer trailertype_id = 0
  String trailnumber
  Integer modstatus = 1
  Integer is_passport1 = 0
  Integer is_passport2 = 0

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////

  Trailer setData(lsRequest){
    trailnumber = lsRequest.trailnumber?:trailnumber
    trailertype_id = lsRequest.trailer_trailertype_id?:0
    this
  }

  Trailer csiSetModstatus(iStatus){
    modstatus = iStatus?:0
    this
  }

  Trailer updatescanstatus(sName,iStatus){
    this."$sName" = iStatus?:0
    this
  }

}