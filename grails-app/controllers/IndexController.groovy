import org.codehaus.groovy.grails.commons.ConfigurationHolder
import grails.converters.JSON

class IndexController {
  def requestService 
  def jcaptchaService  
  def smsService  
  def mailerService
  def zakazService
  
  def index = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)    
    return hsRes
  }
  def about = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)    
    return hsRes
  }
  def howto = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)    
    return hsRes
  }
  def help = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)    
    
    if(!hsRes?.user){
      redirect(controller:'index', action:'index')
      return false
    }
    hsRes.zakazstatus = Zakazstatus.list()
    hsRes.tripstatus = Tripstatus.list()
    hsRes.tripeventtype = Tripeventtype.list()
    hsRes.taskstatus = Taskstatus.list()
    
    return hsRes
  }
  def terms = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)    
    return hsRes
  }
  def carrierterms = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)

    return hsRes
  }
  def termsconfirm = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()

    try{
      User.get(hsRes.user.id)?.confirmterm().save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Index/termsconfirm\n"+e.toString());
    }

    redirect(controller:'carrier', action:'orders')
    return
  }
  def reloadCaptcha={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.Ajax = [:]
    hsRes.Ajax.captcha=jcaptcha.jpeg(name:'image').toString()
    render hsRes.Ajax as JSON
  }
  //////////////////////////////////////////////////////////////////////////////////////////////////  
  def contact={ 
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(false,true)
    if (hsRes.user) hsRes.user = User.get(hsRes.user.id)
    if(requestService.getIntDef('success',0))
      flash.success=1

    return hsRes
  }
  def add = {
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes+=requestService.getParams(null,null,['name','email','tel','message'])

    def result = [:]
    result.errorcode = []
    
    try{
      if (! jcaptchaService.validateResponse("image", session.id, params.captcha)){
        result.errorcode << 99        
      }
    }catch(Exception e){
      result.errorcode<<99 //error in captcha         
    }

    if (hsRes.inrequest.email&&(!Tools.checkEmailString(hsRes.inrequest.email)))
      result.errorcode << 1
    if (!hsRes.inrequest.name)
      result.errorcode << 2
    if (!hsRes.inrequest.tel)
      result.errorcode << 3
    if (!hsRes.inrequest.message)
      result.errorcode << 4
    if (Guestbook.csiGetIpCount(request.getRemoteAddr())>Tools.getIntVal(ConfigurationHolder.config.guestbook.ip_max,10))
      result.errorcode << 5

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try{
      mailerService.sendAdminGbNotice(new Guestbook().setData(hsRes.user?.id?:0,hsRes.inrequest,request.getRemoteAddr()).save(failOnError:true))
    } catch(Exception e) {
      log.debug("Guestbook:add. Error on add Guestbook\n"+e.toString());
      result.errorcode << 100
    }
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
  }
  //////////////////////////////////////////////////////////////////////////////////////////////////  
  def monitoringext={
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(false,true)

    hsRes.trip = Trip.get(requestService.getIntDef('id',0))
    if (!hsRes.trip||!(hsRes.trip.modstatus in [-1,0,1])||requestService.getStr('code')!=Tools.generateModeParam(hsRes.trip.id,hsRes.trip.shipper)||(hsRes.trip.extmonitoringdate?:new Date())<new Date()-1) {
      response.sendError(404)
      return
    }
    def oTriproute = new Triproute()
    hsRes.route = oTriproute.csiSelectRoute(hsRes.trip.id,hsRes.trip.extmonitoringdate?:new Date(new Date().getTime()-(hsRes.trip.trackstatus==2?Tools.getIntVal(ConfigurationHolder.config.monitoring.tracktime.shipperdelay.parking,180):Tools.getIntVal(ConfigurationHolder.config.monitoring.tracktime.shipperdelay.movement,30))*60*1000))

    return hsRes
  }

  def showpicture = {
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(false,true)

    def photo = Picture.get(requestService.getIntDef('id',0))
    if (!photo||(requestService.getStr('code')!=Tools.generateModeParam(photo?.id)&&!session.admin)) {
      response.sendError(404)
      return
    }

    //render file: photo.filedata, contentType: 'image/jpeg' //Only from grails 2.3    
    response.contentType = photo.mimetype?:'image/jpeg'
    response.outputStream << photo.filedata
    response.flushBuffer()
  }

}