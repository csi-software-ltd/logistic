import org.codehaus.groovy.grails.commons.ConfigurationHolder
import grails.converters.JSON
import pl.touk.excel.export.WebXlsxExporter
class CarrierController {
  def requestService
  def mailerService
  def smsService
  def imageService
  def zakazService

  def checkUser(hsRes) {
    if(!hsRes?.user){
      redirect(controller:'index', action:'index')
      return false
    } else if(hsRes?.user.type_id!=2){
      redirect(controller:'shipper', action:'profile')
      return false
    }
    session.attention_message = Client.get(hsRes?.user?.client_id)?.isblocked?Temp_notification.get(4)?.text:null
    session.attention_message = Temp_notification.findWhere(id:1,status:1)?.text?:session.attention_message

    return true
  }

  def checkUserAJAX(hsRes) {
    if(!hsRes?.user){
      render(contentType:"application/json"){[error:true]}
      return false
    }
    return true
  }

  def profile = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return    
    hsRes.user = User.get(hsRes.user?.id)
    
    if(hsRes.user.email.matches('\\d+'))
      hsRes.user_internal=1
    
    hsRes.isSMSsend = Sms.isSMSsend(hsRes.user?.tel?:'')

    hsRes.from_reg=requestService.getLongDef('from_reg',0)
    return hsRes
  }

  def saveUserProfile={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user?.id)

    hsRes+=requestService.getParams(['is_news','is_changepass','is_zayavka','is_noticeemail','is_noticeSMS'],null,
                                    ['nickname','name','tel','tel1','password1','password2'])

    def result = [:]
    result.errorcode = []
    if (!hsRes.inrequest.nickname)
      result.errorcode << 1
    if (!hsRes.inrequest.name)
      result.errorcode << 2
    if(hsRes.user.is_needtochangepassword||hsRes.inrequest.is_changepass){
      if((hsRes.inrequest?.password1?:'')!=(hsRes.inrequest?.password2?:''))
        result.errorcode << 4
      else if((hsRes.inrequest?.password2?:'').size()<Tools.getIntVal(ConfigurationHolder.config.user.passwordlength,6))
        result.errorcode << 5
      else if(!(hsRes.inrequest?.password2?:'').matches('.*(?=.*[0-9])(?=.*[A-Za-z])(?!.*[\\W_А-я]).*'))
        result.errorcode << 6
    }
    if (hsRes.inrequest.tel&&!hsRes.inrequest.tel.matches('\\+\\d{11}'))
      result.errorcode << 9
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      hsRes.user.setProfileData(hsRes.inrequest).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Carrier/saveUserProfile\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }
    
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
  }

  def sendUserConfirmMail = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    hsRes.user = User.get(hsRes.user?.id)

    if(hsRes.user){
      mailerService.sendUserConfirmMailAsync(hsRes.user)
    }
    render(contentType:"application/json"){[error:false]}
    return
  }

  def sendVerifyTel={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUserAJAX(hsRes)) return

    hsRes.user = User.get(hsRes.user.id)
    def isSMSsend = Sms.isSMSsend(hsRes.user?.tel?:'')
    def readyToSms = false
    if (!isSMSsend) {
      readyToSms = hsRes.user.validateTelNumber()
    }

    if (readyToSms && !isSMSsend)
      render(contentType:"application/json"){[error:(smsService.sendVerifySms(hsRes.user) as boolean)]}
    else
      render(contentType:"application/json"){[error:true]}
    return
  }
  def verifySms={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    def oUser = User.get(hsRes.user.id)
    def error=false
    def errorcode=[]
    if(requestService.getStr('smscode')==oUser?.smscode){
      try {
        oUser.confirmTel()?.save(failOnError:true)
      } catch(Exception e) {
        log.debug("Error save data in Carrier/verifySms \n"+e.toString());
        error=true
        errorcode<<100
      }
    }else{
      error=true
      errorcode<<1
    }
    render(contentType:"application/json"){[error:error,errorcode:errorcode]}
    return
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Clients >>>/////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def company={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'carrier', action:'profile')
      return
    }
    hsRes.requisites = Clientrequisites.findByClient_idAndModstatus(hsRes.client.id,1)

    return hsRes
  }

  def driverlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    hsRes.drivers = Driver.findAllByClient_idAndModstatus(hsRes.client.id,1)

    return hsRes
  }

  def driverdetail = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def lId=requestService.getLongDef('driver_id',0)
    hsRes.driver = Driver.findByClient_idAndId(hsRes.client.id,lId)

    return hsRes
  }

  def saveDriverDetail={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def lId=requestService.getLongDef('driver_id',0)
    hsRes+=requestService.getParams(['document_id'],null,['name','fullname','tel','docseria','docnumber','docuch'])
    hsRes.inrequest.docdata = requestService.getDate('docdata')

    hsRes.driver = Driver.findByClient_idAndId(hsRes.client.id,lId)
    if (!hsRes.driver&&lId) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    def result = [:]
    result.errorcode = []
    if (!hsRes.inrequest.name)
      result.errorcode << 1
    if (hsRes.inrequest.tel&&!hsRes.inrequest.tel.matches('\\+\\d{11}'))
      result.errorcode << 3
    if (!hsRes.inrequest.fullname)
      result.errorcode << 4

    if(!lId&&result.errorcode.size()==0){
      hsRes.driver = new Driver([name:hsRes.inrequest.name,client_id:hsRes.client.id])
      if (!hsRes.driver) {
        result.errorcode << 100
      }
    }
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      hsRes.driver.setData(hsRes.inrequest).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Carrier/saveDriverDetail\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
  }

  def driverstatus={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def lId = requestService.getLongDef('id',0)
    def iStatus = requestService.getIntDef('status',0)

    if(lId>0){
      Driver.findByClient_idAndId(hsRes.client.id,lId)?.csiSetModstatus(iStatus)?.save(flush:true)
    }

    render(contentType:"application/json"){[error:false]}
  }

  def savescandriver={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    def lId = requestService.getLongDef('id',0)
    hsRes.driver = Driver.findByClient_idAndId(hsRes.client?.id,lId)
    if (!hsRes.client||!hsRes.driver) {
      render(contentType:"application/json"){[error:true]}
    }
    def docname = params.passport1?'passport1':params.passport2?'passport2':params.prava?'prava':'none'

    imageService.init(this,ConfigurationHolder.config.pathtophoto+hsRes.client.id+File.separatorChar+'drivers'+File.separatorChar+hsRes.driver.id+File.separatorChar)
    def hsData = imageService.rawUpload(docname) // 3
    hsData['num'] = docname

    if (!hsData.error) {
      try {
        hsRes.driver.updatescanstatus("is_$hsData.num",hsData.fileid).save(failOnError:true)
      } catch(Exception e) {
        hsData.error = 4
        log.debug('Carrier:savescandriver. Error on save driver:'+hsRes.driver.id+'\n'+e.toString())
      }
    }

    render(view:'savepictureresult',model:hsData)
    return
  }

  def deletedriverscan={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    def lId = requestService.getLongDef('id',0)
    hsRes.driver = Driver.findByClient_idAndId(hsRes.client?.id,lId)
    if (!hsRes.client||!hsRes.driver) {
      render(contentType:"application/json"){[error:true]}
    }
    def docname = requestService.getStr('file')
    try {
      Picture.get(hsRes.driver."is_$docname")?.delete(flush:true)
      hsRes.driver.updatescanstatus("is_$docname",0).save(failOnError:true)
    } catch(Exception e) {
      log.debug('Carrier:deletedriverscan. Error on save driver:'+hsRes.driver.id+'\n'+e.toString())
    }

    render(contentType:"application/json"){[error:false]}
  }

  def carlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    hsRes.cars = Car.findAllByClient_idAndModstatus(hsRes.client.id,1)
    hsRes.carDrivers_id = hsRes.cars.collect{it.id}.inject([:]){map,car_id -> map[car_id]=Cartodriver.findAllByCar_id(car_id).collect{it.driver_id};map}
    hsRes.drivers = Driver.findAllByClient_idAndModstatus(hsRes.client.id,1)
    hsRes.carmodel = Carmodel.list()

    return hsRes
  }

  def cardetail = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def lCar_id=requestService.getLongDef('car_id',0)

    hsRes.car = Car.findByClient_idAndId(hsRes.client.id,lCar_id)
    hsRes.carmodel = Carmodel.list([sort:'name'])
    hsRes.drivers = Driver.findAllByClient_idAndModstatus(hsRes.client.id,1)
    hsRes.carDrivers_id = Cartodriver.findAllByCar_id(lCar_id).collect{it.driver_id}

    return hsRes
  }

  def saveCarDetail={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def lId=requestService.getIntDef('car_id',0)
    hsRes+=requestService.getParams(['car_trailer','car_model_id','car_is_platform'],null,['car_gosnomer'])
    def lsDrivers = requestService.getIds('drivers')

    hsRes.car = Car.findByClient_idAndId(hsRes.client.id,lId)
    if (!hsRes.car&&lId) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    def result = [:]
    result.errorcode = []
    if (!hsRes.inrequest.car_gosnomer)
      result.errorcode << 1

    if(!lId&&result.errorcode.size()==0){
      hsRes.car = new Car([gosnomer:hsRes.inrequest.car_gosnomer,client_id:hsRes.client.id])
      if (!hsRes.car) {
        result.errorcode << 100
      }
    }
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      def carDrivers = Cartodriver.findAllByCar_id(lId)
      def lsOldDrivers = carDrivers.collect{it.driver_id} - lsDrivers
      def lsNewDrivers = (lsDrivers?:[]) - carDrivers.collect{it.driver_id}
      hsRes.car.setData(hsRes.inrequest).save(failOnError:true)
      carDrivers.each{ if (lsOldDrivers.contains(it.driver_id)) it.delete(); }
      lsNewDrivers.each{ new Cartodriver([car_id:hsRes.car.id,driver_id:it]).save(failOnError:true) }
    } catch(Exception e) {
      log.debug("Error save data in Carrier/saveCarDetail\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }
    
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
  }

  def carstatus={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def lId = requestService.getIntDef('id',0)
    def iStatus = requestService.getIntDef('status',0)

    if(lId>0){
      Car.findByClient_idAndId(hsRes.client.id,lId)?.csiSetModstatus(iStatus)?.save(flush:true)?.computeCarCount()
    }

    render(contentType:"application/json"){[error:false]}
  }

  def savescancar={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    def lId = requestService.getLongDef('id',0)
    hsRes.car = Car.findByClient_idAndId(hsRes.client?.id,lId)
    if (!hsRes.client||!hsRes.car) {
      render(contentType:"application/json"){[error:true]}
    }
    def docname = params.passport1?'passport1':params.passport2?'passport2':'none'

    imageService.init(this,ConfigurationHolder.config.pathtophoto+hsRes.client.id+File.separatorChar+'cars'+File.separatorChar+hsRes.car.id+File.separatorChar)
    def hsData = imageService.rawUpload(docname) // 3
    hsData['num'] = docname

    if (!hsData.error) {
      try {
        hsRes.car.updatescanstatus("is_$hsData.num",hsData.fileid).save(failOnError:true)
      } catch(Exception e) {
        hsData.error = 4
        log.debug('Carrier:savescancar. Error on save car:'+hsRes.car.id+'\n'+e.toString())
      }
    }

    render(view:'savepictureresult',model:hsData)
    return
  }

  def deletecarscan={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    def lId = requestService.getLongDef('id',0)
    hsRes.car = Car.findByClient_idAndId(hsRes.client?.id,lId)
    if (!hsRes.client||!hsRes.car) {
      render(contentType:"application/json"){[error:true]}
    }
    def docname = requestService.getStr('file')
    try {
      Picture.get(hsRes.car."is_$docname")?.delete(flush:true)
      hsRes.car.updatescanstatus("is_$docname",0).save(failOnError:true)
    } catch(Exception e) {
      log.debug('Carrier:deletecarscan. Error on save car:'+hsRes.car.id+'\n'+e.toString())
    }

    render(contentType:"application/json"){[error:false]}
  }

  def trailerlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    hsRes.trailers = Trailer.findAllByClient_idAndModstatus(hsRes.client.id,1)
    hsRes.cars = Car.findAllByClient_idAndModstatus(hsRes.client.id,1)
    hsRes.carTrailers_id = hsRes.trailers.collect{it.id}.inject([:]){map,trailer_id -> map[trailer_id]=Cartotrailer.findAllByTrailer_id(trailer_id).collect{it.car_id};map}

    return hsRes
  }

  def trailerdetail = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def lTrailer_id=requestService.getLongDef('trailer_id',0)

    hsRes.trailer = Trailer.findByClient_idAndId(hsRes.client.id,lTrailer_id)
    hsRes.cars = Car.findAllByClient_idAndModstatus(hsRes.client.id,1)
    hsRes.carTrailers_id = Cartotrailer.findAllByTrailer_id(lTrailer_id).collect{it.car_id}

    return hsRes
  }

  def saveTrailerDetail={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def lId=requestService.getIntDef('trailer_id',0)
    hsRes+=requestService.getParams(['trailer_trailertype_id'],null,['trailnumber'])
    def lsCars = requestService.getIds('cars')

    hsRes.trailer = Trailer.findByClient_idAndId(hsRes.client.id,lId)
    if (!hsRes.trailer&&lId) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    def result = [:]
    result.errorcode = []
    if (!hsRes.inrequest.trailnumber)
      result.errorcode << 1

    if(!lId&&result.errorcode.size()==0){
      hsRes.trailer = new Trailer([trailnumber:hsRes.inrequest.trailnumber,client_id:hsRes.client.id])
      if (!hsRes.trailer) {
        result.errorcode << 100
      }
    }
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      def carTrailers = Cartotrailer.findAllByTrailer_id(lId)
      def lsOldCars = carTrailers.collect{it.car_id} - lsCars
      def lsNewCars = (lsCars?:[]) - carTrailers.collect{it.car_id}
      hsRes.trailer.setData(hsRes.inrequest).save(failOnError:true)
      carTrailers.each{ if (lsOldCars.contains(it.car_id)) it.delete(); }
      lsNewCars.each{ new Cartotrailer([trailer_id:hsRes.trailer.id,car_id:it]).save(failOnError:true) }
    } catch(Exception e) {
      log.debug("Error save data in Carrier/saveTrailerDetail\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }
    
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
  }

  def trailerstatus={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def lId = requestService.getIntDef('id',0)
    def iStatus = requestService.getIntDef('status',0)

    if(lId>0){
      Trailer.findByClient_idAndId(hsRes.client.id,lId)?.csiSetModstatus(iStatus)?.save(flush:true)
    }

    render(contentType:"application/json"){[error:false]}
  }

  def savescantrailer={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    def lId = requestService.getLongDef('id',0)
    hsRes.trailer = Trailer.findByClient_idAndId(hsRes.client?.id,lId)
    if (!hsRes.client||!hsRes.trailer) {
      render(contentType:"application/json"){[error:true]}
    }
    def docname = params.passport1?'passport1':params.passport2?'passport2':'none'

    imageService.init(this,ConfigurationHolder.config.pathtophoto+hsRes.client.id+File.separatorChar+'trailers'+File.separatorChar+hsRes.trailer.id+File.separatorChar)
    def hsData = imageService.rawUpload(docname) // 3
    hsData['num'] = docname

    if (!hsData.error) {
      try {
        hsRes.trailer.updatescanstatus("is_$hsData.num",hsData.fileid).save(failOnError:true)
      } catch(Exception e) {
        hsData.error = 4
        log.debug('Carrier:savescantrailer. Error on save trailer:'+hsRes.trailer.id+'\n'+e.toString())
      }
    }

    render(view:'savepictureresult',model:hsData)
    return
  }

  def deletetrailerscan={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    def lId = requestService.getLongDef('id',0)
    hsRes.trailer = Trailer.findByClient_idAndId(hsRes.client?.id,lId)
    if (!hsRes.client||!hsRes.trailer) {
      render(contentType:"application/json"){[error:true]}
    }
    def docname = requestService.getStr('file')
    try {
      Picture.get(hsRes.trailer."is_$docname")?.delete(flush:true)
      hsRes.trailer.updatescanstatus("is_$docname",0).save(failOnError:true)
    } catch(Exception e) {
      log.debug('Carrier:deletetrailerscan. Error on save trailer:'+hsRes.trailer.id+'\n'+e.toString())
    }

    render(contentType:"application/json"){[error:false]}
  }

  def geoexceptionlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    hsRes.regions = Clienttoregion.findAllByClient_id(hsRes.client.id).collect{Region.get(it.region_id)}?.sort { it.name }
    hsRes.fullexclude = (hsRes.regions.size()==Region.count())

    return hsRes
  }

  def regionsforexc = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    hsRes.excludedregions = Clienttoregion.findAllByClient_id(hsRes.client.id).collect{it.region_id}
    hsRes.regions = []
    Region.list().each{ region -> if (!hsRes.excludedregions.contains(region.id)) hsRes.regions << region }

    return hsRes
  }

  def saveexcludedregion={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def lsRegions = requestService.getIds('regions')

    def result = [:]
    result.errorcode = []

    try {
      lsRegions.each{ new Clienttoregion([client_id:hsRes.client.id,region_id:it]).save(failOnError:true) }
    } catch(Exception e) {
      log.debug("Error save data in Carrier/saveexcludedregion\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }
    
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
  }

  def removeexcludedregion={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def lId = requestService.getIntDef('id',0)

    if(lId>0){
      Clienttoregion.findByClient_idAndRegion_id(hsRes.client.id,lId)?.delete(flush:true)
    }

    render(contentType:"application/json"){[error:false]}
  }

  def removeallexcludedregion={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    Clienttoregion.findAllByClient_id(hsRes.client.id).each{ it.delete(flush:true) }

    render(contentType:"application/json"){[error:false]}
  }

  def savelimitingparams={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def iShipdistance = requestService.getIntDef('shipdistance',0)
    def iShipweight = requestService.getIntDef('shipweight',0)
    def iShipprice = requestService.getIntDef('shipprice',0)

    def result = [:]
    result.errorcode = []
    if (Math.abs(iShipweight)>60)
      result.errorcode << 1

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }

    try {
      hsRes.client.updateLimitingParams([distance:iShipdistance,weight:iShipweight,price:iShipprice]).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Carrier/savelimitingparams\n"+e.toString());
      render(contentType:"application/json"){[error:true]}
    }

    render(contentType:"application/json"){[error:false]}
  }

  def acceptablecontlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    hsRes.containers = Clienttocontainer.findAllByClient_id(hsRes.client.id).collect{Container.get(it.container_id)}
    hsRes.fullaccept = (hsRes.containers.size()==Container.count())

    return hsRes
  }

  def contforaccept = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    hsRes.acceptablecont = Clienttocontainer.findAllByClient_id(hsRes.client.id).collect{it.container_id}
    hsRes.containers = []
    Container.list().each{ container -> if (!hsRes.acceptablecont.contains(container.id)) hsRes.containers << container }

    return hsRes
  }

  def saveacceptedcont = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def lsCont = requestService.getIds('containers')

    def result = [:]
    result.errorcode = []

    try {
      lsCont.each{ new Clienttocontainer([client_id:hsRes.client.id,container_id:it]).save(failOnError:true) }
    } catch(Exception e) {
      log.debug("Error save data in Carrier/saveacceptedcont\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }
    
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
  }

  def removacceptablecont={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def lId = requestService.getIntDef('id',0)

    if(lId>0){
      Clienttocontainer.findByClient_idAndContainer_id(hsRes.client.id,lId)?.delete(flush:true)
    }

    render(contentType:"application/json"){[error:false]}
  }

  def removeallacceptablecont={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    Clienttocontainer.findAllByClient_id(hsRes.client.id).each{ it.delete(flush:true) }

    render(contentType:"application/json"){[error:false]}
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Clients <<</////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Zakaz >>>///////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def orders = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'carrier', action:'profile')
      return
    }

    def fromDetails = requestService.getIntDef('fromDetails',0)
    if (fromDetails&&session.lastRequest){
      session.lastRequest.fromDetails = fromDetails
      hsRes.inrequest = session.lastRequest
    }

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def orderlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    if (session.lastRequest?.fromDetails?:0) {
      hsRes.inrequest = session.lastRequest
      session.lastRequest.fromDetails = 0
    } else {
      hsRes+=requestService.getParams(null,['zakaz_id'])
      hsRes.inrequest.modstatus = requestService.getIntDef('modstatus',0)
      hsRes.inrequest.offset = requestService.getOffset()
      session.lastRequest = [:]
      session.lastRequest = hsRes.inrequest
    }

    def oSearchObj = new ZakaztocarrierSearch()
    hsRes.searchresult = oSearchObj.csiSelectZakaz(hsRes.client.id,hsRes.inrequest.zakaz_id?:0l,hsRes.inrequest.modstatus?:0,20,hsRes.inrequest.offset)

    hsRes.terminals = Terminal.list().inject([:]){map, terminal -> map[terminal.id]=terminal.name;map}
    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=[shortname:container.shortname,name:container.name];map}    

    return hsRes
  }

  def freecarlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    hsRes.freecars = Freecars.findAllByClient_idAndModstatus(hsRes.client.id,1)

    hsRes.drivers = Driver.findAllByClient_id(hsRes.client.id).inject([:]){map, driver -> map[driver.id]=driver.name;map}
    hsRes.cars = Car.findAllByClient_id(hsRes.client.id).inject([:]){map, car -> map[car.id]=car.gosnomer;map}
    hsRes.trailers = Trailer.findAllByClient_id(hsRes.client.id).inject([:]){map, trailer -> map[trailer.id]=trailer.trailnumber;map}
    def timelimit = Tools.getIntVal(Dynconfig.findByName('freecar.default.timelimit')?.value,4)
    hsRes.actualtimes = hsRes.freecars.inject([:]){map, freecar ->
      map[freecar.id] = freecar.inputdate.getTime()+timelimit*60*60*1000-new Date().getTime()
      map
    }

    return hsRes
  }

  def freecar = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client||hsRes.client?.isblocked) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    hsRes.driverId = requestService.getLongDef('driver_id',0)
    hsRes.carId = requestService.getIntDef('car_id',0)
    hsRes.trailerId = requestService.getIntDef('trailer_id',0)
    def selectedDriver = Driver.get(hsRes.driverId)
    def selectedCar = Car.get(hsRes.carId)

    hsRes.drivers = []
    Driver.findAllByClient_idAndModstatus(hsRes.client.id,1).each{
      if (!Freecars.findByDriver_idAndModstatus(it.id,1)) hsRes.drivers << it
    }
    hsRes.cars = []
    Cartodriver.findAllByDriver_id(selectedDriver?.id?:hsRes.drivers[0]?.id?:0).each{
      def car = Car.get(it.car_id)
      if (car?.modstatus&&!Freecars.findByCar_idAndModstatus(car?.id,1)) hsRes.cars << car
    }
    hsRes.trailers = []
    if (selectedCar?.is_platform||(!selectedCar&&hsRes.cars[0]?.is_platform)) {
      hsRes.trailers << [id:0,trailnumber:'без прицепа']
    }
    Cartotrailer.findAllByCar_id(selectedCar?.id?:hsRes.cars[0]?.id?:0).each{
      def trailer = Trailer.get(it.trailer_id)
      if (trailer?.modstatus&&!Freecars.findByTrailer_idAndModstatus(trailer?.id,1)) hsRes.trailers << trailer
    }

    def contlist = Clienttocontainer.findAllByClient_id(hsRes.client.id).collect{it.container_id}
    def regionlist = Region.findAllByIdNotInList(Clienttoregion.findAllByClient_id(hsRes.client.id).collect{it.region_id}?:[0]).name+''
    hsRes.routes = Standartroute.findAll{
        modstatus == 1 &&
        weight1 < (hsRes.client.shipweight?:100) &&
        price_basic > hsRes.client.shipprice &&
        container in contlist &&
        region_start in regionlist &&
        region_end in regionlist &&
        region_cust in regionlist &&
        region_zat in regionlist
    }

    return hsRes
  }

  def addFreecar={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('zakaz_id',0)
    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    hsRes+=requestService.getParams(['car_id','trailer_id','timestart','timeend'],['driver_id'])
    def lsRoutes = requestService.getIds('routes')

    def result = [:]
    result.errorcode = []
    if (!hsRes.inrequest.driver_id||Freecars.findByDriver_idAndModstatus(hsRes.inrequest.driver_id,1))
      result.errorcode << 1
    if (!hsRes.inrequest.car_id||Freecars.findByCar_idAndModstatus(hsRes.inrequest.car_id,1))
      result.errorcode << 2
    if ((!hsRes.inrequest.trailer_id&&!Car.get(hsRes.inrequest.car_id)?.is_platform)||Freecars.findByTrailer_idAndModstatus(hsRes.inrequest.trailer_id,1))
      result.errorcode << 3
    if(!lsRoutes)
      result.errorcode << 4
    if(hsRes.inrequest.timestart&&(hsRes.inrequest.timestart<0||hsRes.inrequest.timestart>23))
      result.errorcode << 5
    if(hsRes.inrequest.timeend&&(hsRes.inrequest.timeend<=0||hsRes.inrequest.timeend>24||(hsRes.inrequest.timestart&&hsRes.inrequest.timestart>=hsRes.inrequest.timeend)))
      result.errorcode << 6

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      new Freecars(client_id:hsRes.client.id).setMainData(hsRes.inrequest,lsRoutes).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Carrier/addFreecar\n"+e.toString());
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
  }

  def removefreecar={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def lId = requestService.getLongDef('id',0)

    if(lId>0){
      Freecars.findByClient_idAndId(hsRes.client.id,lId)?.csiSetModstatus(-1)?.save(flush:true)
    }

    render(contentType:"application/json"){[error:false]}
  }

  def orderdetails = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'carrier', action:'profile')
      return
    }

    def lId = requestService.getIntDef('id',0)

    hsRes.zakaztocarrier = Zakaztocarrier.findByClient_idAndId(hsRes.client.id,lId)
    hsRes.zakaz = Zakaz.get(hsRes.zakaztocarrier?.zakaz_id?:0)
    if (!hsRes.zakaztocarrier||!hsRes.zakaz) {
      response.sendError(404)
      return
    }

    hsRes.ztype = Ztype.list()
    hsRes.container = Container.list()
    hsRes.terminal = Terminal.list()
    hsRes.maxweight = hsRes.zakaz.collect{[it.weight1,it.weight2,it.weight3,it.weight4,it.weight5]}?.max()?.max()?.toInteger()?:0
    def terminalstart = Terminal.get(hsRes.zakaz.terminal?:0)
    hsRes.timestart = terminalstart?.is_slot?(hsRes.zakaz.slotlist.split(',').collect{Slot.get(it.isInteger()?it.toInteger():0)?.name}-null).join(', '):hsRes.zakaz.timestart.toString()
    hsRes.timeend = terminalstart?.is_slot?-1:hsRes.zakaz.timeend
    hsRes.confirmedTrailertypes = hsRes.zakaz.trailertype_id?hsRes.zakaz.trailertype_id.split(',').collect{Trailertype.get(it)}:null
    hsRes.manager = Admin.get(hsRes.zakaz.admin_id?:0)
    try {
      hsRes.zakaztocarrier.carrierread().save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Carrier/orderdetails\n"+e.toString());
    }

    return hsRes
  }

  def saveoffer = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def lId = requestService.getIntDef('id',0)

    hsRes.zakaztocarrier = Zakaztocarrier.findByClient_idAndId(hsRes.client.id,lId)
    hsRes.zakaz = Zakaz.get(hsRes.zakaztocarrier?.zakaz_id?:0)
    if (!hsRes.zakaztocarrier||!hsRes.zakaz) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    hsRes+=requestService.getParams(['zcol','cprice','is_confirm'])

    def result = [:]
    result.errorcode = []
    if (hsRes.inrequest.zcol>hsRes.zakaztocarrier.zcol)
      result.errorcode << 1
    if (hsRes.zakaztocarrier.is_debate&&hsRes.inrequest.cprice<0)
      result.errorcode << 2
    if (hsRes.inrequest.is_confirm==1&&(!(hsRes.zakaztocarrier.modstatus==0&&hsRes.zakaz.modstatus==1)||(hsRes.zakaztocarrier.deadline.getTime()-new Date().getTime()<=0)||(hsRes.client.isblocked)))
      result.errorcode << 3
    if (hsRes.inrequest.is_confirm==-1&&(hsRes.zakaztocarrier.modstatus==2||hsRes.zakaztocarrier.modstatus==-1))
      result.errorcode << 4
    if (hsRes.inrequest.is_confirm==1&&!Zakaztodriver.findAllByClient_idAndZakaz_id(hsRes.client.id,hsRes.zakaz.id))
      result.errorcode << 5
    else if (hsRes.inrequest.is_confirm==1&&(Zakaztodriver.findAllByClient_idAndZakaz_id(hsRes.client.id,hsRes.zakaz.id)?.sum{it.zcol}?:0)<hsRes.inrequest.zcol)
      result.errorcode << 6
    else if (hsRes.inrequest.is_confirm==1&&(Zakaztodriver.findAllByClient_idAndZakaz_id(hsRes.client.id,hsRes.zakaz.id)?.sum{it.zcol}?:0)>hsRes.inrequest.zcol)
      result.errorcode << 7

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }

    try {
      hsRes.zakaztocarrier.setCarrierOffer(hsRes.inrequest).csiSetModstatus(hsRes.inrequest.is_confirm?:0).save(failOnError:true)
      if (hsRes.inrequest.is_confirm==1&&!Zakaztocarrier.findAllByZakaz_idAndModstatusInList(hsRes.zakaz.id,[1,2])){
        mailerService.sendAdminNotice('#firstoffer',hsRes.zakaz.id)
        if (hsRes.zakaz.manager_id) mailerService.sendManagerNotice(hsRes.zakaz.manager_id,'#firstoffer',hsRes.zakaz.id)
      }
    } catch(Exception e) {
      log.debug("Error save data in Carrier/saveoffer\n"+e.toString());
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
  }

  def driversforzakazlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)
    def lZtoCId = requestService.getIntDef('zakaztocarrier_id',0)
    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.zakaz = Zakaz.get(lId)
    hsRes.zakaztocarrier = Zakaztocarrier.findByClient_idAndId(hsRes.client?.id,lZtoCId)
    if (!hsRes.client||!hsRes.zakaz||!hsRes.zakaztocarrier) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    hsRes.zakaztodriver = Zakaztodriver.findAllByClient_idAndZakaz_id(hsRes.client.id,hsRes.zakaz.id)
    hsRes.drivercol = hsRes.zakaztodriver?.sum{it.zcol}?:0

    hsRes.drivers = Driver.findAllByClient_id(hsRes.client.id).inject([:]){map, driver -> map[driver.id]=driver.name;map}
    hsRes.cars = Car.findAllByClient_id(hsRes.client.id).inject([:]){map, car -> map[car.id]=car.gosnomer;map}
    hsRes.trailers = Trailer.findAllByClient_id(hsRes.client.id).inject([:]){map, trailer -> map[trailer.id]=trailer.trailnumber;map}

    return hsRes
  }

  def zakaztodriver = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('zakaz_id',0)
    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.zakaz = Zakaz.get(lId)
    if (!hsRes.client||!hsRes.zakaz) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    hsRes.driverId = requestService.getLongDef('driver_id',0)
    hsRes.carId = requestService.getIntDef('car_id',0)
    hsRes.trailerId = requestService.getIntDef('trailer_id',0)
    def selectedDriver = Driver.get(hsRes.driverId)
    def selectedCar = Car.get(hsRes.carId)

    hsRes.zcol = Container.get(hsRes.zakaz.container)?.ctype_id==1?1:hsRes.zakaz.zcol-(Zakaztodriver.findAllByClient_idAndZakaz_id(hsRes.client.id,hsRes.zakaz.id)?.sum{it.zcol}?:0)
    hsRes.drivers = []
    Driver.findAllByClient_idAndModstatus(hsRes.client.id,1).each{
      if (!Zakaztodriver.findByDriver_idAndZakaz_id(it.id,hsRes.zakaz.id)) hsRes.drivers << it
    }
    hsRes.cars = []
    Cartodriver.findAllByDriver_id(selectedDriver?.id?:hsRes.drivers[0]?.id?:0).each{
      def car = Car.get(it.car_id)
      if (car?.modstatus&&!Zakaztodriver.findByCar_idAndZakaz_id(car?.id,hsRes.zakaz.id)) hsRes.cars << car
    }
    hsRes.trailers = []
    if (Container.get(hsRes.zakaz.container)?.is_vartrailer&&(selectedCar?.is_platform||(!selectedCar&&hsRes.cars[0]?.is_platform))) {
      hsRes.trailers << [id:0,trailnumber:'без прицепа']
      if (!hsRes.trailerId) hsRes.zcol = 1
    }
    Cartotrailer.findAllByCar_id(selectedCar?.id?:hsRes.cars[0]?.id?:0).each{
      def trailer = Trailer.get(it.trailer_id)
      if (trailer?.modstatus&&!Zakaztodriver.findByTrailer_idAndZakaz_id(trailer?.id,hsRes.zakaz.id)) hsRes.trailers << trailer
    }

    return hsRes
  }

  def addDriverToZakaz={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('zakaz_id',0)
    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.zakaz = Zakaz.get(lId)
    if (!hsRes.client||!hsRes.zakaz||(Zakaztodriver.findAllByClient_idAndZakaz_id(hsRes.client?.id,hsRes.zakaz?.id)?.sum{it.zcol}?:0)>=(hsRes.zakaz?.zcol?:1)) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    hsRes+=requestService.getParams(['car_id','trailer_id','zcol'],['driver_id'])

    def result = [:]
    result.errorcode = []
    if (!hsRes.inrequest.driver_id||Zakaztodriver.findByDriver_idAndZakaz_id(hsRes.inrequest.driver_id,hsRes.zakaz.id))
      result.errorcode << 1
    if (!hsRes.inrequest.car_id||Zakaztodriver.findByCar_idAndZakaz_id(hsRes.inrequest.car_id,hsRes.zakaz.id))
      result.errorcode << 2
    if ((!hsRes.inrequest.trailer_id&&!(Car.get(hsRes.inrequest.car_id)?.is_platform&&Container.get(hsRes.zakaz.container)?.is_vartrailer))||Zakaztodriver.findByTrailer_idAndZakaz_id(hsRes.inrequest.trailer_id,hsRes.zakaz.id))
      result.errorcode << 3
    if (!hsRes.inrequest.trailer_id&&hsRes.inrequest.zcol>1)
      result.errorcode << 4

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      new Zakaztodriver(zakaz_id:hsRes.zakaz.id,client_id:hsRes.client.id).setMainData(hsRes.inrequest).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Carrier/addDriverToZakaz\n"+e.toString());
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
  }

  def removedriverfromzakaz={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def lId = requestService.getLongDef('id',0)
    def ztocId = requestService.getLongDef('zakaztocarrier_id',0)

    if(lId>0&&Zakaztocarrier.get(ztocId)?.modstatus==0){
      Zakaztodriver.findByClient_idAndId(hsRes.client.id,lId)?.delete(flush:true)
    }

    render(contentType:"application/json"){[error:false]}
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Zakaz <<<///////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Monitoring <<<//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def monitoring = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'carrier', action:'profile')
      return
    }

    def fromDetails = requestService.getIntDef('fromDetails',0)
    hsRes.type = requestService.getIntDef('type',0)
    if (fromDetails&&session.lastRequest){
      session.lastRequest.fromDetails = fromDetails
      hsRes.inrequest = session.lastRequest
    }
    hsRes.tripstatus = Tripstatus.list()
    hsRes.tripeventtype = Tripeventtype.list()
    hsRes.cars=Car.findAllWhere(client_id:hsRes.client.id?:0)

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def triplist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    if (session.lastRequest?.fromDetails?:0) {
      hsRes.inrequest = session.lastRequest
      session.lastRequest.fromDetails = 0
    } else {
      hsRes+=requestService.getParams(null,['zakaz_id','trip_id'],['container'])
      hsRes.inrequest.trip_modstatus = requestService.getIntDef('trip_modstatus',0)
      hsRes.inrequest.offset = requestService.getOffset()
      session.lastRequest = [:]
      session.lastRequest = hsRes.inrequest
    }

    def oSearchObj = new TripSearch()
    hsRes.searchresult = oSearchObj.csiSelectTrip(true,hsRes.client.id,hsRes.inrequest.zakaz_id?:0l,hsRes.inrequest.trip_id?:0l,hsRes.inrequest.trip_modstatus,hsRes.inrequest.container?:'',20,hsRes.inrequest.offset)

    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=[shortname:container.shortname,name:container.name];map}
    hsRes.tripstatus = Tripstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.taskstatus = Taskstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.terminals = Terminal.list().inject([:]){map, terminal -> map[terminal.id]=terminal.name;map}

    return hsRes
  }

  def eventlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    if (session.lastRequest?.fromDetails?:0) {
      hsRes.inrequest = session.lastRequest
      session.lastRequest.fromDetails = 0
    } else {
      hsRes+=requestService.getParams(null,['trip_id'])
      hsRes.inrequest.trip_modstatus = requestService.getIntDef('trip_modstatus',0)
      hsRes.inrequest.eventtype = requestService.getIntDef('eventtype',-100)
      hsRes.inrequest.offset = requestService.getOffset()
      session.lastRequest = [:]
      session.lastRequest = hsRes.inrequest
    }

    def oSearchObj = new TripEventSearchAdmin()
    hsRes.searchresult = oSearchObj.csiSelectTripEvent(hsRes.inrequest.trip_id?:0l,0l,hsRes.client.id,
                                      0l,'',hsRes.inrequest.trip_modstatus?:0,hsRes.inrequest.eventtype?:-100,
                                      '','',20,hsRes.inrequest.offset)
    hsRes.tripeventtype = Tripeventtype.list().inject([:]){map, type -> map[type.id]=[descr:type.name,icon:type.icon,significance:type.levelcur];map}
    Trip.findAllByCarrierAndIs_readeventcurrier(hsRes.user.client_id,0).each{it.csiSetReadEvent(1).save()}

    return hsRes
  }

  def tripdetails = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'carrier', action:'profile')
      return
    }

    def lId = requestService.getIntDef('id',0)

    hsRes.trip = Trip.findByCarrierAndId(hsRes.client.id,lId)
    if (!hsRes.trip) {
      response.sendError(404)
      return
    }

    hsRes.ztype = Ztype.list()
    hsRes.container = Container.list()
    hsRes.zakaztodriver = Zakaztodriver.get(hsRes.trip.zakaztodriver_id)
    hsRes.tripstatus = Tripstatus.get(hsRes.trip.modstatus)
    def oTriproute = new Triproute()
    hsRes.route = oTriproute.csiSelectRoute(hsRes.trip.id)

    return hsRes
  }

  def tripeventlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.trip = Trip.findByCarrierAndId(hsRes.client.id,lId)
    if (!hsRes.client||!hsRes.trip) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    hsRes.events = Tripevent.findAllByTrip_id(hsRes.trip.id)
    hsRes.eventtypes = Tripeventtype.list().inject([:]){map, type -> map[type.id]=[descr:type.name,icon:type.icon];map}

    return hsRes
  }

  def saveTripDetail = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.trip = Trip.findByCarrierAndId(hsRes.client.id,lId)
    if (!hsRes.client||!hsRes.trip) {
      render(contentType:"application/json"){[error:true]}
    }
    hsRes+=requestService.getParams(['timestartE','timeendE','timeeditE'],null,['containernumber1','containernumber2'])
    hsRes.inrequest.dateE = requestService.getDate('dateE')
    hsRes.inrequest.timestartEstr = requestService.getStr('timestartE')
    hsRes.inrequest.timeendEstr = requestService.getStr('timeendE')

    def result = [:]
    result.errorcode = zakazService.checkDateForTripEdit(hsRes.inrequest)

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      hsRes.trip.setDeliveryRequestData(hsRes.inrequest).save(failOnError:true)
      if (hsRes.trip.isDirty('taskstatus'))
        zakazService.sendDeliveryRequestForShipper(hsRes.trip)

    } catch(Exception e) {
      log.debug("Error save data in Carrier/saveTripDetail\n"+e.toString());
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}

  }
  def trackermap = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)

    hsRes.client = Client.get(hsRes.user.client_id)    
    hsRes.cars=Car.findAllWhere(client_id:hsRes.client.id?:0)
    hsRes.tracking=[]    
   
    def i=0
    def tmp=[:]
    for(oCar in hsRes.cars){    
      tmp=Trackingdata.findByImei(oCar?.imei?:'',[sort: "tracktime", order: "desc"])  
      hsRes.tracking<<tmp        
      if(tmp)  
        i++
    }
    hsRes.trackers_count=i
    return hsRes
  }
  def car_route={
    requestService.init(this)
    def lId=requestService.getIntDef('id',0)  
    def DateStart=requestService.getDate('date')        
    def hsRes=[:]       
    hsRes.tracker_route=[]
    hsRes.current=requestService.getIntDef('current',0)
    if(hsRes.current){
      def dateStartTmp=new Date()
      def date1= new GregorianCalendar()
      date1.setTime(dateStartTmp)
      date1.set(Calendar.HOUR_OF_DAY ,0)
      date1.set(Calendar.MINUTE ,0)
      date1.set(Calendar.SECOND,0)
      date1.set(Calendar.MILLISECOND,0)
      DateStart=date1.getTime()
    }  
    def oCar=Car.get(lId)    
    if(oCar)
      if(hsRes.current)
        hsRes.tracker_route=Trackingdata.findAllByImeiAndTracktimeBetween(oCar.imei,DateStart,DateStart+1,[sort: "tracktime", order: "desc"])     
      else  
        hsRes.tracker_route=Trackingdata.findAllByImeiAndTracktimeBetween(oCar.imei,DateStart,DateStart+1)//because points better draw from start to end
    return hsRes
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////// Monitoring <<<//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Instruction >>>/////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def instructions = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'carrier', action:'profile')
      return
    }

    def fromDetails = requestService.getIntDef('fromDetails',0)
    if (fromDetails&&session.lastRequest){
      session.lastRequest.fromDetails = fromDetails
      hsRes.inrequest = session.lastRequest
    }
    hsRes.tripstatus = Tripstatus.list()
    hsRes.taskstatus = Taskstatus.list()

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def instructionlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    if (session.lastRequest?.fromDetails?:0) {
      hsRes.inrequest = session.lastRequest
      session.lastRequest.fromDetails = 0
    } else {
      hsRes+=requestService.getParams(null,['zakaz_id','trip_id'])
      hsRes.inrequest.trip_modstatus = requestService.getIntDef('trip_modstatus',0)
      hsRes.inrequest.trip_taskstatus = requestService.getIntDef('trip_taskstatus',0)
      hsRes.inrequest.offset = requestService.getOffset()
      session.lastRequest = [:]
      session.lastRequest = hsRes.inrequest
    }

    def oSearchObj = new DeliverySearch()
    hsRes.searchresult = oSearchObj.csiSelectTrip(true,hsRes.client.id,hsRes.inrequest.zakaz_id?:0l,hsRes.inrequest.trip_id?:0l,hsRes.inrequest.trip_modstatus,hsRes.inrequest.trip_taskstatus,20,hsRes.inrequest.offset)

    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=[shortname:container.shortname,name:container.name];map}
    hsRes.tripstatus = Tripstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.taskstatus = Taskstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.terminals = Terminal.list().inject([:]){map, terminal -> map[terminal.id]=terminal.name;map}

    return hsRes
  }

  def instructiondetails = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'carrier', action:'profile')
      return
    }

    def lId = requestService.getIntDef('id',0)
    hsRes.forward = requestService.getIntDef('forward',0)

    hsRes.trip = Trip.findByCarrierAndId(hsRes.client.id,lId)
    hsRes.zakaztodriver = Zakaztodriver.get(hsRes.trip?.zakaztodriver_id)
    if (!hsRes.trip||!hsRes.zakaztodriver) {
      response.sendError(404)
      return
    }

    hsRes.terminal = Terminal.get(hsRes.trip.taskterminal)
    if (hsRes.forward) {
      hsRes.terminal_main = Terminal.findAllByIs_main(1)
      hsRes.terminal_dop = Terminal.findAllByIs_main(0)
      hsRes.slot = Slot.findAllByTerminal_idAndModstatus(hsRes.trip.taskterminal,1)
    }
    hsRes.region = Region.findAll('from Region where modstatus = 1 order by regorder desc, name asc')
    hsRes.drivers = Driver.findAllByClient_idAndModstatus(hsRes.client.id,1)
    hsRes.cars = Cartodriver.findAllByDriver_id(hsRes.trip.returndriver_id).collect{
      Car.findByModstatusAndId(1,it.car_id)
    }-null
    try {
      hsRes.trip.readDelivery().save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Carrier/instructiondetails\n"+e.toString());
    }

    return hsRes
  }

  def driversfordelivery={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)
    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    hsRes.driverId = requestService.getLongDef('id',0)

    if(hsRes.driverId>=0){
      hsRes.drivers = Driver.findAllByClient_idAndModstatus(hsRes.client.id,1)
      hsRes.cars = Cartodriver.findAllByDriver_id(hsRes.driverId).collect{
        Car.findByModstatusAndId(1,it.car_id)
      }-null
    }
    return hsRes
  }

  def saveTripInstructionDetail = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.trip = Trip.findByCarrierAndId(hsRes.client.id,lId)
    if (!hsRes.client||!hsRes.trip||hsRes.trip?.taskstatus>3||!(hsRes.trip.modstatus in 0..1)) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    hsRes+=requestService.getParams(['timestartE','timeendE','timeeditE','driveredit','car_id'],['driver_id'])
    hsRes.inrequest.dateE = requestService.getDate('dateE')
    hsRes.inrequest.timestartEstr = requestService.getStr('timestartE')
    hsRes.inrequest.timeendEstr = requestService.getStr('timeendE')

    def result = [:]
    result.errorcode = zakazService.checkDateForTripEdit(hsRes.inrequest,false)

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      hsRes.trip.setDeliveryRequestData(hsRes.inrequest).save(failOnError:true)
      if (hsRes.trip.isDirty('taskstatus'))
        zakazService.sendDeliveryRequestForShipper(hsRes.trip)
    } catch(Exception e) {
      log.debug("Error save data in Carrier/saveTripInstructionDetail\n"+e.toString());
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}

  }

  def getslot={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUserAJAX(hsRes)) return
    def iId=requestService.getIntDef('id',0)

    if(iId>=0){
      hsRes.slot = Slot.findAllByTerminal_idAndModstatus(iId,1)
      hsRes.terminal = Terminal.get(iId)
    }
    return hsRes
  }

  def saveTripForwardDetail = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.trip = Trip.findByCarrierAndId(hsRes.client.id,lId)
    if (!hsRes.client||!hsRes.trip||!(hsRes.trip?.taskstatus in [2,4])||!(hsRes.trip.modstatus in 0..1)) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    hsRes+=requestService.getParams(['terminalh','taskstart','taskend','taskslot','is_mark'],null,['taskaddress','taskprim','stockbooking'])
    hsRes.inrequest.dateE = requestService.getDate('dateE')

    def result = [:]
    result.errorcode = zakazService.checkDataForTripDelivery(hsRes.inrequest)

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      hsRes.trip.setDeliveryData(hsRes.inrequest).csiSetTaskstatus(4).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Carrier/saveTripForwardDetail\n"+e.toString());
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}

  }

  def deliveryconfirm = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.trip = Trip.findByCarrierAndId(hsRes.client.id,lId)
    if (!hsRes.client||!hsRes.trip||hsRes.trip?.taskstatus!=2) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    try {
      hsRes.trip.csiSetTaskstatus(5).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Carrier/deliveryconfirm\n"+e.toString());
    }

    render(contentType:"application/json"){[error:false]}
  }

  def canceltrip = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.trip = Trip.findByCarrierAndId(hsRes.client.id,lId)
    if (!hsRes.client||!hsRes.trip||!(hsRes.trip.modstatus in 0..1)) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    try {
      hsRes.trip.csiSetModstatus(-3).save(failOnError:true)
      mailerService.sendAdminNotice('#tripcancel_carrier')
      mailerService.sendManagerNotice(Zakaz.get(hsRes.trip.zakaz_id)?.manager_id?:0,'#tripcancel_carrier')
    } catch(Exception e) {
      log.debug("Error save data in Carrier/canceltrip\n"+e.toString());
    }

    render(contentType:"application/json"){[error:false]}
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////// Instructions <<</////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////// Reports >>>////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def reports = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'carrier', action:'profile')
      return
    }

    return hsRes
  }

  def contreport = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'carrier', action:'profile')
      return
    }

    hsRes.contreport_date = requestService.getRaw('contreport_date')

    def oObject = new TripSearchAdmin()
    hsRes.report = oObject.csiSelectTrip(0l,0l,hsRes.client.id,0l,'','',0l,-100,-100,-1,0,false,hsRes.contreport_date)
    hsRes.pricesum = hsRes.contcol = 0
    hsRes.report.records.each{
      hsRes.pricesum += it.price
      hsRes.contcol++
      if (it.containernumber2) {
        hsRes.pricesum += it.price
        hsRes.contcol++
      }
    }
    hsRes.reportMonth = message(code:'calendar.monthName').split(',')[requestService.getIntDef('contreport_date_month',1)]
    hsRes.reportYear = requestService.getIntDef('contreport_date_year',2013)

    renderPdf(template: 'contreport', model: hsRes, filename: "contreport.pdf")
    return
  }

  def contreportXLS = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'carrier', action:'profile')
      return
    }

    hsRes.contreport_date = requestService.getRaw('contreport_date')

    def oObject = new TripSearchAdmin()
    hsRes.report = oObject.csiSelectTrip(0l,0l,hsRes.client.id,0l,'','',0l,-100,-100,-1,0,false,hsRes.contreport_date)
    hsRes.pricesum = hsRes.contcol = 0
    hsRes.report.records.each{
      hsRes.pricesum += it.price
      hsRes.contcol++
      if (it.containernumber2) {
        hsRes.pricesum += it.price
        hsRes.contcol++
      }
    }
    hsRes.reportMonth = message(code:'calendar.monthName').split(',')[requestService.getIntDef('contreport_date_month',1)]
    hsRes.reportYear = requestService.getIntDef('contreport_date_year',2013)

    if (hsRes.report.records.size()==0) {
      new WebXlsxExporter().with {
        setResponseHeaders(response)
        putCellValue(0, 4, "Нет данных за указанный период")
        save(response.outputStream)
      }
    } else {
      def reportsize = hsRes.report.records.size()
      def rowCounter = 4
      new WebXlsxExporter().with {
        setResponseHeaders(response)
        putCellValue(0, 5, "Отчет по доставленным контейнерам за ${hsRes.reportMonth} ${hsRes.reportYear}г.")
        fillRow(['Код поездки','ФИО водителя','Госномер автомобиля','Номер контейнера','Дата отправления','Дата сдачи контейнера','Маршрут','Ставка','Дата сдачи документов'],3,false)
        (0..<reportsize).eachWithIndex{ rowNumber, idx ->
          fillRow([hsRes.report.records[idx].id,hsRes.report.records[idx].driver_fullname, hsRes.report.records[idx].cargosnomer,
            hsRes.report.records[idx].containernumber1,String.format('%td/%<tm/%<tY',hsRes.report.records[idx].dateA),
            hsRes.report.records[idx].taskstatus>4?String.format('%td/%<tm/%<tY',hsRes.report.records[idx].taskdate):'не сдан',
            hsRes.report.records[idx].addressA+" "+(hsRes.report.records[idx].addressB?:"")+" "+(hsRes.report.records[idx].addressC?:"")+" "+(hsRes.report.records[idx].addressD?:""),
            hsRes.report.records[idx].price,
            hsRes.report.records[idx].docdate?String.format('%td/%<tm/%<tY',hsRes.report.records[idx].docdate):'не сданы'], rowCounter++, false)
          if (hsRes.report.records[idx].containernumber2) {
            fillRow([hsRes.report.records[idx].id,hsRes.report.records[idx].driver_fullname, hsRes.report.records[idx].cargosnomer,
              hsRes.report.records[idx].containernumber2,String.format('%td/%<tm/%<tY',hsRes.report.records[idx].dateA),
              hsRes.report.records[idx].taskstatus>4?String.format('%td/%<tm/%<tY',hsRes.report.records[idx].taskdate):'не сдан',
              hsRes.report.records[idx].addressA+" "+(hsRes.report.records[idx].addressB?:"")+" "+(hsRes.report.records[idx].addressC?:"")+" "+(hsRes.report.records[idx].addressD?:""),
              hsRes.report.records[idx].price,
              hsRes.report.records[idx].docdate?String.format('%td/%<tm/%<tY',hsRes.report.records[idx].docdate):'не сданы'], rowCounter++, false)
          }
        }
        fillRow(["ИТОГО", "", "", hsRes.contcol, "", "", "", hsRes.pricesum,""], rowCounter++, false)
        save(response.outputStream)
      }
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////// Reports <<<////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////// Shipment <<<///////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def shipment = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'carrier', action:'profile')
      return
    }

    hsRes.type = requestService.getIntDef('type',0)

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def shipmentlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    hsRes+=requestService.getParams(['type'])

    def oSearchObj = new TripSearch()
    hsRes.searchresult = oSearchObj.csiSelectTrip(true,hsRes.client.id,0l,0l,-100,'',20,requestService.getOffset(),false,hsRes.inrequest.type?:0)

    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=[shortname:container.shortname,name:container.name];map}
    hsRes.terminals = Terminal.list().inject([:]){map, terminal -> map[terminal.id]=terminal.name;map}

    return hsRes
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////// Shipment <<<///////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Financial >>>///////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def settlements = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'carrier', action:'profile')
      return
    }

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////

  def carriersettlements = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    hsRes+=requestService.getParams(['debt','driver_id','year'],['trip_id'],['contnumber'])

    def oSearchObj = new PayorderSearchCarrier()
    hsRes.searchresult = oSearchObj.findOrdersForCarrierSettlements(hsRes.inrequest.trip_id?:0,hsRes.client.id,hsRes.inrequest.year?:(new Date().getYear()+1900),
                                                hsRes.inrequest.contnumber?:'',hsRes.inrequest.driver_id?:0,20,requestService.getOffset())
    hsRes.payments = hsRes.searchresult.records.inject([:]){map, trip -> map[trip.id]=Payment.findAllByTrip_idAndIs_active(trip.id,1);map}

    return hsRes
  }

  def settlpdf = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'carrier', action:'profile')
      return
    }

    hsRes+=requestService.getParams(['debt','driver_id','year'],['trip_id'],['contnumber'])

    def oSearchObj = new PayorderSearchCarrier()
    hsRes.searchresult = oSearchObj.findOrdersForCarrierSettlements(hsRes.inrequest.trip_id?:0,hsRes.client.id,hsRes.inrequest.year?:(new Date().getYear()+1900),
                                                hsRes.inrequest.contnumber?:'',hsRes.inrequest.driver_id?:0,0,0)
    hsRes.payments = hsRes.searchresult.records.inject([:]){map, trip -> map[trip.id]=Payment.findAllByTrip_idAndIs_active(trip.id,1);map}

    hsRes.pricesum = hsRes.paidsum = hsRes.debtsum = 0
    hsRes.searchresult.records.each{
      hsRes.pricesum += it.ca_price+(it.cont2?it.ca_price:0)+it.ca_idlesum+it.ca_forwardsum
      hsRes.paidsum += it.ca_paid
      if(it.debt>0&&it.ca_maxpaydate?.before(new Date().clearTime()))
        hsRes.debtsum += it.debt
    }
    hsRes.taxsum = Paytax.findAll{client_id==hsRes.client.id && year(paydate)==(hsRes.inrequest.year?:(new Date().getYear()+1900))}.sum{it.summa}?:0

    renderPdf(template: 'settlpdf', model: hsRes, filename: "settlpdf.pdf")
    return
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Financial <<<///////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
}