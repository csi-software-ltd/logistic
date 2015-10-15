class Guestbook {

  static constraints = {
    name(maxSize:255,nullable:true)
    email(maxSize:250,nullable:true)
    tel(nullable:true)
    user_id(nullable:true)
    ip(nullable:true)
  }

  Long id
  Long user_id

  Integer modstatus

  String name
  String tel
  String email
  String message
  String ip
  Date inputdate = new Date()

  ///////////////////////////////////////////////////////////////////////////
  static def csiGetIpCount(ip){
    Calendar oCalendar=Calendar.getInstance();
    oCalendar.set(Calendar.HOUR_OF_DAY,0)
    oCalendar.set(Calendar.MINUTE,0)
    oCalendar.set(Calendar.SECOND,0)

    Guestbook.countByIpAndInputdateGreaterThan(ip,oCalendar.getTime())
  }

  Guestbook setData(lUId,_request,sIp) {
    user_id = lUId?:0
    name = _request.name?:''
    tel = _request.tel?:''
    email = _request.email?:''
    message = _request.message
    modstatus = 0
    ip = sIp
    this
  }

  Guestbook readmessage() {
    modstatus = 1
    this
  }

}