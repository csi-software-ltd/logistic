import org.codehaus.groovy.grails.commons.ConfigurationHolder
class Sms {
  
  static constraints = {
  }
  
  static mapping = {
    version false
  }
  
  Long id
  Long user_id
  Integer status
  String server_id
  Date inputdate
  String tel
  String smscode
/////////////////////////////////constructor//////////////////////////////////////////////////////////////////////
  Sms(){}
  Sms(oUser){
	user_id = oUser.id
	status = 0
	server_id = ''
	inputdate = new Date()
	tel = oUser.tel
	smscode = oUser.smscode
  }
  Sms(lId, sTel, sSmscode){
	user_id = lId
	status = 0
	server_id = ''
	inputdate = new Date()
	tel = sTel
	smscode = sSmscode
  }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  void updateStatusAndServerId(iStatus,sServerId){
	this.status = iStatus
	this.server_id = sServerId
	this.save(flush:true)
  }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  static Boolean isSMSsend(sTel){
	def today = Calendar.getInstance()
	today.add(Calendar.MINUTE,-Tools.getIntVal(ConfigurationHolder.config.SMSgate.smsDelay,3))
	return Sms.findByTelAndInputdateGreaterThanEquals(sTel,today.getTime())?true:false
  }  
}
