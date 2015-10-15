import org.codehaus.groovy.grails.commons.ConfigurationHolder
import grails.converters.JSON
import pl.touk.excel.export.WebXlsxExporter

class ShipperController {
  def requestService
  def mailerService
  def smsService
  def zakazService

  def static final DATE_FORMAT='dd.MM.yyyy'
  def static final DATE_FORMAT_TIME='dd.MM.yyyy HH:mm'
  
  def checkUser(hsRes) {
    if(!hsRes?.user){
      redirect(controller:'index', action:'index')
      return false
    } else if(hsRes?.user.type_id!=1){
      redirect(controller:'carrier', action:'profile')
      return false
    }
    session.attention_message = Client.get(hsRes?.user?.client_id)?.isblocked?Temp_notification.get(4)?.text:null
    session.attention_message = Temp_notification.findWhere(id:1,status:1)?.text?:session.attention_message

    return true
  }
  def checkZakazId(hsRes){
    if(hsRes.order_id)  
      if(!Zakaz.findWhere(id:hsRes.order_id,shipper:hsRes.user.client_id))    
        return false  
    
    return true    
  }  
  def checkUserAJAX(hsRes) {
    if(!hsRes?.user){
      render(contentType:"application/json"){[error:true]}
      return false
    }
    return true
  }
  /////////////////////////////////////////////////////////////////////    
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
      else if((hsRes.inrequest?.password2?:'').size()<Tools.getIntVal(ConfigurationHolder.config.user.passwordlength?:6))
        result.errorcode << 5
      else if(!(hsRes.inrequest?.password2?:'').matches('.*(?=.*[0-9])(?=.*[A-Za-z])(?!.*[\\W_А-я]).*'))
        result.errorcode << 6
    }
    
    if(hsRes.inrequest?.tel && !hsRes.inrequest?.tel.matches('\\+7\\d{10}'))
      result.errorcode << 7
    if(hsRes.inrequest?.tel1 && !hsRes.inrequest?.tel1.matches('\\+7\\d{10}'))
      result.errorcode << 8        
    
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      hsRes.user.setProfileData(hsRes.inrequest).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Shipper/saveUserProfile\n"+e.toString());
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
        log.debug("Error save data in Shipper/verifySms \n"+e.toString());
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
  ///////////////////////////////////////////////////////////////////  
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
      redirect(controller:'shipper', action:'profile')
      return
    }
    hsRes.requisites = Clientrequisites.findByClient_idAndModstatus(hsRes.client.id,1)

    return hsRes
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Clients <<</////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Zayavka >>>/////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def orders={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)
    
    hsRes.modstatus=[[id:100,modstatus:'Активная',icon:'']]    
    
    hsRes.modstatus+=Zakazstatus.list()
    
    def fromEdit = requestService.getIntDef('fromEdit',0)    
    if (fromEdit){
      if(!session.lastRequest)
        session.lastRequest=[:]
      session.lastRequest.fromEdit = fromEdit
      hsRes.inrequest = session.lastRequest
    }
    
    return hsRes
  }
/////////////////////////////////////////////////////////////////////////    
  def orderlist={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id) 

    if (session.lastRequest?.fromEdit?:0){
      hsRes.inrequest = session.lastRequest
      session.lastRequest.fromEdit = 0
    } else {
      hsRes.inrequest=[:]     
      hsRes.inrequest.modstatus = requestService.getIntDef('modstatus',100)
      hsRes.inrequest.offset = requestService.getOffset()
      session.lastRequest = [:]
      session.lastRequest = hsRes.inrequest
    }
//>>
    if(hsRes.inrequest.modstatus==null)
      hsRes.inrequest.modstatus=100  
//<<    
    def oZakaz=new Zakaz()    
    hsRes.data=oZakaz.findZakaz(hsRes.user.id,hsRes.inrequest.modstatus,20,hsRes.inrequest?.offset?:0)    
    hsRes.actualtimes = hsRes.data.records.inject([:]){map, zakaz ->
      if (zakaz.modstatus<3)
        map[zakaz.id] = zakaz.inputdate.getTime()+(Ztime.get(zakaz.ztime_id)?.qtime?:0)*60*1000-new Date().getTime()
      else
        map[zakaz.id] = zakaz.zdate?(zakaz.zdate+1).getTime()-new Date().getTime():0
      map
    }

    return hsRes
  } 
/////////////////////////////////////////////////////////////////////////  
  def order={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)
    hsRes.ztype=Ztype.list() 
    hsRes.order_id=requestService.getLongDef('id',0)

    hsRes.zcol=[[id:'1'],[id:'2'],[id:'3'],[id:'4'],[id:'5']]
    hsRes.dangerclass=Dangerclass.list()
    hsRes.container=Container.findAllWhere(is_main:1)
    hsRes.container_dop=Container.findAllWhere(is_main:0)
    hsRes.ztime=Ztime.list()
    hsRes.trailertype=Trailertype.list()
    hsRes.copy=requestService.getIntDef('copy',0)
    hsRes.edit=requestService.getIntDef('edit',0) 
    hsRes.terminal=Terminal.findAllWhere(is_main:1) 
    //hsRes.terminal_dop=Terminal.findAllWhere(is_main:0)        
    
    if(checkZakazId(hsRes)){          
      hsRes.zakaz=Zakaz.get(hsRes.order_id) 
      if(hsRes.zakaz){
        hsRes.trailertype_id=(hsRes.zakaz.trailertype_id?:'').split(',') 

      if (hsRes.zakaz.modstatus<3)
        hsRes.actualTime = hsRes.zakaz.inputdate.getTime()+(Ztime.get(hsRes.zakaz.ztime_id)?.qtime?:0)*60*1000-new Date().getTime()
      else
        hsRes.actualTime = hsRes.zakaz.zdate?(hsRes.zakaz.zdate+1).getTime()-new Date().getTime():0
      }
    }
    
    return hsRes
  } 
/////////////////////////////////////////////////////////////////////////
  def order_import={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return

    hsRes.terminal=Terminal.findAllWhere(is_main:1)
    hsRes.terminal_dop=Terminal.findAllWhere(is_main:0)
    hsRes.region = Region.findAll('from Region where modstatus = 1 order by regorder desc, name asc')

    hsRes.order_id=requestService.getLongDef('id',0)
    hsRes.copied = requestService.getIntDef('copied',0)

    if(checkZakazId(hsRes)){
      hsRes.zakaz=Zakaz.get(hsRes.order_id)
      if(hsRes.zakaz){
        hsRes.slot=Slot.findAllByTerminal_idAndModstatus(hsRes.zakaz.terminal,1)
        hsRes.slotlist=hsRes.zakaz?.slotlist.split(',')
      }
    }

    return hsRes
  }
/////////////////////////////////////////////////////////////////////////
  def order_export={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    //hsRes.user = User.get(hsRes.user.id)  
    
    hsRes.terminal=Terminal.findAllWhere(is_main:1) 
    hsRes.terminal_dop=Terminal.findAllWhere(is_main:0)
    hsRes.region = Region.findAll('from Region where modstatus = 1 order by regorder desc, name asc')
    
    hsRes.order_id=requestService.getLongDef('id',0)
    hsRes.copied = requestService.getIntDef('copied',0)
    
    if(checkZakazId(hsRes)){    
      hsRes.zakaz=Zakaz.get(hsRes.order_id)
      if(hsRes.zakaz){
        hsRes.slot=Slot.findAllByTerminal_idAndModstatus(hsRes.zakaz.terminal,1)  
        hsRes.slot_end=Slot.findAllByTerminal_idAndModstatus(hsRes.zakaz.terminal_end,1)
        hsRes.slotlist=hsRes.zakaz?.slotlist.split(',')         
        hsRes.slotlistend=hsRes.zakaz?.slotlist_end.split(',')               
      }  
    }
    
    return hsRes
  }
/////////////////////////////////////////////////////////////////////////    
  def order_transit={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    //hsRes.user = User.get(hsRes.user.id)
    
    hsRes.terminal=Terminal.findAllWhere(is_main:1) 
    hsRes.terminal_dop=Terminal.findAllWhere(is_main:0)       
    hsRes.region = Region.findAll('from Region where modstatus = 1 order by regorder desc, name asc')
    
    hsRes.order_id=requestService.getLongDef('id',0)
    hsRes.copied = requestService.getIntDef('copied',0)

    if(checkZakazId(hsRes)){    
      hsRes.zakaz=Zakaz.get(hsRes.order_id)
      if(hsRes.zakaz){      
        hsRes.slot=Slot.findAllByTerminal_idAndModstatus(hsRes.zakaz.terminal,1)
        hsRes.slotlist=hsRes.zakaz?.slotlist.split(',')                       
      }           
    }
    
    return hsRes
  }
/////////////////////////////////////////////////////////////////////////    
  def getslot={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    def iId=requestService.getIntDef('id',0)
    
    if(iId>=0){
      hsRes.slot=Slot.findAllByTerminal_idAndModstatus(iId,1)
      hsRes.terminal=Terminal.get(iId)
      hsRes.end=requestService.getIntDef('end',0)      
    }
    return hsRes
  }
/////////////////////////////////////////////////////////////////////////  
  def saveZakaz={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
     
    switch(requestService.getLongDef('ztype_id',0)){
      case 1: redirect(action:'saveZakazImport',params:params) 
      break;
      case 2: redirect(action:'saveZakazExport',params:params) 
      break;
      case 3: redirect(action:'saveZakazTransit',params:params) 
      break;      
      default: 
      def hsOut=[error_ztype_id:1]
      render hsOut as JSON       
    }  
    return
  }    
///////////////////////////////////////////////////////////////////////////////////  
  def saveZakazImport={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.order_id=requestService.getLongDef('order_id',0)
    if(!checkZakazId(hsRes)) return
    
    hsRes.inrequest = requestService.getParams(['ztype_id','container','zcol','addzcol','price','ztime_id','dangerclass','is_roof','terminal','terminalh','container','containerh','noticetime'],[],['doc','comment','region_start','city_start','address_start','prim_start','region_end','city_end','address_end','prim_end','region_dop','city_dop','address_dop','prim_dop','idle','noticetel'],['zdate','date_start']).inrequest
     
    if(hsRes.inrequest.terminal==-1)
      hsRes.inrequest.terminal=hsRes.inrequest.terminalh              
    
    hsRes.inrequest=findCommon(hsRes.inrequest)     
    
    def hsResReturn=commonError(hsRes)   
    
    //zdate>>    
    try {      
      if (hsRes.inrequest.zdate)
        hsRes.inrequest.zdate=Date.parse(DATE_FORMAT, hsRes.inrequest?.zdate)
    } catch(Exception e) {
      hsResReturn.date_error<<1
    }    
    if(!hsResReturn.date_error.contains(1) && hsRes.inrequest.zdate<curDate())
      hsResReturn.date_error<<3
    if(!hsResReturn.date_error.contains(1) && hsRes.inrequest.zdate<hsRes.inrequest.date_start)
      hsResReturn.date_error<<6  
    //zdate<<

    if(!hsResReturn.error && !hsResReturn.slot_error && !hsResReturn.date_error && !hsResReturn.price_error && !hsResReturn.weight_error && !hsResReturn.container_error && !hsResReturn.time_error){        
      def oZakaz=commonZakaz(hsRes)                                
      if(oZakaz){
        oZakaz.region_end=hsRes.inrequest.region_end?:''
        oZakaz.city_end=hsRes.inrequest.city_end?:''
        oZakaz.address_end=hsRes.inrequest.address_end?:''
        oZakaz.prim_end=hsRes.inrequest.prim_end?:''    

        oZakaz.zdate=hsRes.inrequest.zdate        
           
        //TODO rem hsResReturn???
        oZakaz.timestart=hsResReturn.iSlot_start
        oZakaz.timeend=hsResReturn.iSlot_end
        oZakaz.slotlist=hsResReturn.slotlist
        
        oZakaz.region_dop=hsRes.inrequest.region_dop?:''
        oZakaz.city_dop=hsRes.inrequest.city_dop?:''
        oZakaz.address_dop=hsRes.inrequest.address_dop?:''
        oZakaz.prim_dop=hsRes.inrequest.prim_dop?:''                      

        oZakaz.noticetel = hsRes.inrequest.noticetel?:''
        oZakaz.noticetime = hsRes.inrequest.noticetime>=0?hsRes.inrequest.noticetime:8

        if(!oZakaz.detectroute(null).save(flush:true)) {
          log.debug(" Error on save Zakaz:")
          oZakaz.errors.each{log.debug(it)}	
          hsResReturn.error<<100        
        }
      }
    }

    hsResReturn.ztype_id=1
    render hsResReturn as JSON    
    return
  }
/////////////////////////////////////////////////////////////////////////////////////
  def saveZakazExport={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.order_id=requestService.getLongDef('order_id',0)
    if(!checkZakazId(hsRes)) return
    hsRes.inrequest = requestService.getParams(['ztype_id','container','zcol','addzcol','price','ztime_id','dangerclass','is_roof','terminal','terminal_end','terminalh','terminalh_end','timestart_zat','container','containerh'],[],['doc','comment','region_start','city_start','address_start','prim_start','region_end','city_end','address_end','prim_end','region_zat','city_zat','address_zat','prim_zat','region_cust','city_cust','address_cust','prim_cust','idle'],['date_start','date_zat']).inrequest            

    if(hsRes.inrequest.terminal_end==-1)
      hsRes.inrequest.terminal_end=hsRes.inrequest.terminalh_end
    hsRes.inrequest=findCommon(hsRes.inrequest)      
    
    def hsResReturn=commonError(hsRes)
    
//slot_end>>    
    if((hsRes.inrequest?.terminal_end?:0)>=0){                
    }else{
      hsResReturn.error<<2
    }
//slot_end<<

//time_zat>>    
    hsResReturn.timezat_error=[]                         
    
    if(hsRes.inrequest.timestart_zat){                       
      if(hsRes.inrequest.timestart_zat>23 || hsRes.inrequest.timestart_zat<0)
        hsResReturn.timezat_error<<1       
    }
//time_zat<<              
    
//date>>    
    try {
      if (hsRes.inrequest.date_zat)
        hsRes.inrequest.date_zat=Date.parse(DATE_FORMAT, hsRes.inrequest?.date_zat)           
    } catch(Exception e) {
      hsResReturn.date_error<<1
    }
    if(!hsResReturn.date_error.contains(1) && hsRes.inrequest.date_zat<curDate())
      hsResReturn.date_error<<4
    if(!hsResReturn.date_error.contains(1) && hsRes.inrequest.date_zat<hsRes.inrequest.date_start)
      hsResReturn.date_error<<6  
//date<<      
    if(!hsResReturn.error && !hsResReturn.slot_error && !hsResReturn.date_error && !hsResReturn.price_error && !hsResReturn.weight_error && !hsResReturn.container_error && !hsResReturn.time_error){        
      def oZakaz=commonZakaz(hsRes)
      if(oZakaz){      
        //>>
        oZakaz.terminal_end=hsRes.inrequest.terminal_end?:0
        //<<                  
        oZakaz.region_end=hsRes.inrequest.region_end?:''
        oZakaz.city_end=hsRes.inrequest.city_end?:''
        oZakaz.address_end=hsRes.inrequest.address_end?:''
        oZakaz.prim_end=hsRes.inrequest.prim_end?:''          
        //todo change hsResReturn???
        oZakaz.timestart=hsResReturn.iSlot_start
        oZakaz.timeend=hsResReturn.iSlot_end
        oZakaz.slotlist=hsResReturn.slotlist
  //>>                
        oZakaz.region_zat=hsRes.inrequest.region_zat?:''
        oZakaz.city_zat=hsRes.inrequest.city_zat?:''
        oZakaz.address_zat=hsRes.inrequest.address_zat?:''
        oZakaz.prim_zat=hsRes.inrequest.prim_zat?:''
        oZakaz.date_zat=hsRes.inrequest.date_zat      
        oZakaz.timestart_zat=hsRes.inrequest.timestart_zat        
        
        oZakaz.region_cust=hsRes.inrequest.region_cust?:''
        oZakaz.city_cust=hsRes.inrequest.city_cust?:''
        oZakaz.address_cust=hsRes.inrequest.address_cust?:''
        oZakaz.prim_cust=hsRes.inrequest.prim_cust?:''            
  //<<
        if(!oZakaz.detectroute(null).save(flush:true)) {
          log.debug(" Error on save Zakaz:")
          oZakaz.errors.each{log.debug(it)}
          hsResReturn.error<<100        
        }
      }
    }
    hsResReturn.ztype_id=2
    render hsResReturn as JSON    
    return
  }
////////////////////////////////////////////////////////////////////////////////////////  
  def saveZakazTransit={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.order_id=requestService.getLongDef('order_id',0)
    if(!checkZakazId(hsRes)) return
    hsRes.inrequest = requestService.getParams(['ztype_id','container','zcol','addzcol','price','ztime_id','dangerclass','is_roof','terminal','terminalh','container','containerh'],[],['doc','comment','region_start','city_start','address_start','prim_start','region_end','city_end','address_end','prim_end','region_dop','city_dop','address_dop','prim_dop','region_cust','city_cust','address_cust','prim_cust','idle'],['date_cust','date_start']).inrequest                
    
    hsRes.inrequest=findCommon(hsRes.inrequest)

    def hsResReturn=commonError(hsRes) 
    
    //date>>    
    try {
      if (hsRes.inrequest.date_cust)
        hsRes.inrequest.date_cust=Date.parse(DATE_FORMAT, hsRes.inrequest?.date_cust)           
    } catch(Exception e) {
      hsResReturn.date_error<<1
    }
    if(!hsResReturn.date_error.contains(1) && hsRes.inrequest.date_cust<curDate())
      hsResReturn.date_error<<5
    if(!hsResReturn.date_error.contains(1) && hsRes.inrequest.date_cust<hsRes.inrequest.date_start)
      hsResReturn.date_error<<6   
//date<<
                
    if(!hsResReturn.error && !hsResReturn.slot_error && !hsResReturn.date_error && !hsResReturn.price_error && !hsResReturn.weight_error && !hsResReturn.container_error && !hsResReturn.time_error){        
      def oZakaz=commonZakaz(hsRes)            
      if(oZakaz){
        oZakaz.region_end=hsRes.inrequest.region_end?:''
        oZakaz.city_end=hsRes.inrequest.city_end?:''
        oZakaz.address_end=hsRes.inrequest.address_end?:''
        oZakaz.prim_end=hsRes.inrequest.prim_end?:''                 
        
        //TODO rem hsResReturn???
        oZakaz.timestart=hsResReturn.iSlot_start
        oZakaz.timeend=hsResReturn.iSlot_end
        oZakaz.slotlist=hsResReturn.slotlist
        
        oZakaz.region_dop=hsRes.inrequest.region_dop?:''
        oZakaz.city_dop=hsRes.inrequest.city_dop?:''
        oZakaz.address_dop=hsRes.inrequest.address_dop?:''
        oZakaz.prim_dop=hsRes.inrequest.prim_dop?:'' 

        oZakaz.region_cust=hsRes.inrequest.region_cust?:''
        oZakaz.city_cust=hsRes.inrequest.city_cust?:''
        oZakaz.address_cust=hsRes.inrequest.address_cust?:''
        oZakaz.prim_cust=hsRes.inrequest.prim_cust?:''      
        
        oZakaz.date_cust=hsRes.inrequest.date_cust

        if(!oZakaz.detectroute(null).save(flush:true)) {
          log.debug(" Error on save Zakaz:")
          oZakaz.errors.each{log.debug(it)}	
          hsResReturn.error<<100        
        }
      }
    }
    hsResReturn.ztype_id=3
    render hsResReturn as JSON    
    return
  }
  def remZakaz={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)   
    hsRes.order_id=requestService.getLongDef('id',0)
    
    def error=1
    if(hsRes.order_id){
      if(Zakaz.findWhere(id:hsRes.order_id,shipper:hsRes.user.client_id)){
        def oZakaz=Zakaz.get(hsRes.order_id)
        if(oZakaz){
          def prevModstatus=oZakaz.modstatus
          oZakaz.modstatus=-1
          if(!oZakaz.save(flush:true)) {
            log.debug(" Error on save Zakaz:")
            oZakaz.errors.each{log.debug(it)}	            
          }else{
            error=0
            if(prevModstatus>0)
              mailerService.sendAdminZakazRemMailAsync(hsRes.order_id)

            zakazService.sendOfferDeclineForCarrier(Zakaztocarrier.findAllByZakaz_idAndModstatus(oZakaz.id,2).collect{it.client_id},oZakaz.id)
            Zakaztocarrier.findAllByZakaz_idAndModstatusGreaterThan(oZakaz.id,-1).each{ ztocarr -> ztocarr.csiSetModstatus(-1).carrierread().save(flush:true) }            
          }  
        }      
      }
    }
    def hsOut=[error:error]
    render hsOut as JSON
    return
  }
  
///////////////////////////////////
  def curDate(){
    def dateStart=new Date()
    def date1= new GregorianCalendar()
    date1.setTime(dateStart)
    date1.set(Calendar.HOUR_OF_DAY ,0)
    date1.set(Calendar.MINUTE ,0)
    date1.set(Calendar.SECOND,0)
    date1.set(Calendar.MILLISECOND,0)

    return date1.getTime()
  }  
///////////////////////////////////  
  def commonError(hsRes){
    def hsResReturn=[:]
    hsResReturn.slot_error=[]
    hsResReturn.date_error=[]
    hsResReturn.time_error=[]
    hsResReturn.time_error_slot_ids=[]
    hsResReturn.price_error=[]
    hsResReturn.weight_error=[]
    hsResReturn.error=[]
    hsResReturn.container_error=[]
    hsResReturn.notice_error = []
    
    if((hsRes.inrequest.weight1!=-1 && hsRes.inrequest.weight1!=null && (hsRes.inrequest.weight1<=0 || hsRes.inrequest.weight1>50)) || hsRes.inrequest.weight1==-1)
      hsResReturn.weight_error<<1
    if((hsRes.inrequest.weight2!=-1 && hsRes.inrequest.weight2!=null && (hsRes.inrequest.weight2<=0 || hsRes.inrequest.weight2>50)) || hsRes.inrequest.weight2==-1) 
      hsResReturn.weight_error<<2
    if((hsRes.inrequest.weight3!=-1 && hsRes.inrequest.weight3!=null && (hsRes.inrequest.weight3<=0 || hsRes.inrequest.weight3>50)) || hsRes.inrequest.weight3==-1) 
      hsResReturn.weight_error<<3
    if((hsRes.inrequest.weight4!=-1 && hsRes.inrequest.weight4!=null && (hsRes.inrequest.weight4<=0 || hsRes.inrequest.weight4>50)) || hsRes.inrequest.weight4==-1) 
      hsResReturn.weight_error<<4      
    if((hsRes.inrequest.weight5!=-1 && hsRes.inrequest.weight5!=null && (hsRes.inrequest.weight5<=0 || hsRes.inrequest.weight5>50)) || hsRes.inrequest.weight5==-1)
      hsResReturn.weight_error<<5
    if(!hsRes.inrequest.zcol&&!hsRes.inrequest.addzcol)
      hsResReturn.weight_error << 6
    else if (!hsRes.inrequest.zcol&&hsRes.inrequest.addzcol<6)
      hsResReturn.weight_error << 6

//price>>   
    if((hsRes.inrequest?.price?:-1)<0 || (hsRes.inrequest?.price?:-1)>1000000)
      hsResReturn.price_error << 1
    if(hsRes.inrequest?.idle&&(!hsRes.inrequest.idle.isInteger()||hsRes.inrequest.idle.toInteger()<0||hsRes.inrequest.idle.toInteger()>1000000))
      hsResReturn.price_error << 2
//price<<     
//slot>>
    def iSlot_start=0
    def iSlot_end=0
    def slotlist=''
    if((hsRes.inrequest?.terminal?:0)>=0){          
      if(requestService.getIntDef('is_slotlist',0)){                
        slotlist=requestService.getStr('slotlist')
        if(!slotlist)
          hsResReturn.slot_error<<4
      }else{      
        iSlot_start=requestService.getIntDef('slot_start',-1)
        iSlot_end=requestService.getIntDef('slot_end',-1)                          
          
        if(iSlot_start>=iSlot_end)
          hsResReturn.slot_error<<1
          
        if(iSlot_start>23 || iSlot_start<0)
          hsResReturn.slot_error<<2
        if(iSlot_end>23 || iSlot_end<0)
          hsResReturn.slot_error<<3         
      }
    }else{
      hsResReturn.error<<1
    }
//slot<<

//date>>       
    def date_start=hsRes.inrequest.date_start
    try {
      if (hsRes.inrequest.date_start)          
        hsRes.inrequest.date_start=Date.parse(DATE_FORMAT, hsRes.inrequest?.date_start)            
    } catch(Exception e) {
      hsResReturn.date_error<<1
    }
    if(!hsResReturn.date_error.contains(1) && hsRes.inrequest.date_start<curDate())
      hsResReturn.date_error<<2                   
      
    if(!hsResReturn.date_error.contains(1) && !hsResReturn.date_error.contains(2)){    
      if(hsRes.inrequest.date_start==curDate()){
        if(slotlist){
          for(slot in slotlist.split(',')){ 
            def end=Slot.get(slot?:0)?.end
            
            if(end!="00:00"){        
              def dateTMP=Date.parse(DATE_FORMAT_TIME, date_start +' '+ end) 
              if(dateTMP<new Date()){
                if(!hsResReturn.time_error.contains(1))
                   hsResReturn.time_error<<1   
                hsResReturn.time_error_slot_ids<<slot
              }  
            }
          }
        }else if(iSlot_start>0){        
          def dateTMP=Date.parse(DATE_FORMAT_TIME, date_start +' '+ ((iSlot_start<10)?'0'+iSlot_start:iSlot_start)+':00')
          if(dateTMP<new Date())
            hsResReturn.time_error<<2  
        }        
      }
    }  
//date<<

    if((hsRes.inrequest?.container?:0)<=0)
      hsResReturn.container_error<<1

    hsResReturn.iSlot_start=iSlot_start
    hsResReturn.iSlot_end=iSlot_end
    hsResReturn.slotlist=slotlist

    if (hsRes.inrequest.noticetel&&!hsRes.inrequest.noticetel.matches('\\+\\d{11}')) {
      hsResReturn.notice_error << 1
    }
    if(hsRes.inrequest.noticetime&&(hsRes.inrequest.noticetime<0||hsRes.inrequest.noticetime>23)){
      hsResReturn.notice_error << 2
    }

    return hsResReturn     
  }
///////////////////////////////////////////////////////////////////////////////////////  
  def commonZakaz(hsRes){
    def oZakaz=[:]
    def bNew=0
    if(!(hsRes?.order_id?:0)){//new
      oZakaz=new Zakaz()
      bNew=1      
    }else if(requestService.getIntDef('copy',0)){//copy
      oZakaz=new Zakaz()
      bNew=1
    }else{//edit
      oZakaz=Zakaz.get(hsRes.order_id?:0)
      if(oZakaz.modstatus!=0)
        return null
    }      
    if(bNew){
      def oAdmin=Admin.get(Tools.getIntVal(ConfigurationHolder.config.zakaz.admin.id?:1).toLong())
      mailerService.sendZakazNewAsync(oAdmin)
      if (!Adminmenu.get(15)?.is_on)
        smsService.sendNewZakazAdminNoticeAsync(oAdmin)

      oZakaz.inputdate=new Date()
    }
      
    oZakaz.user_id=hsRes.user.id
    oZakaz.ztype_id=hsRes.inrequest.ztype_id?:0
    oZakaz.container=hsRes.inrequest.container
    oZakaz.zcol=hsRes.inrequest.zcol?:hsRes.inrequest.addzcol?:0
    oZakaz.price=hsRes.inrequest.price
    oZakaz.idle=hsRes.inrequest.idle?:''
    oZakaz.ztime_id=hsRes.inrequest.ztime_id?:0
    oZakaz.dangerclass=hsRes.inrequest.dangerclass?:0
    oZakaz.is_roof=hsRes.inrequest.is_roof?:0            
    oZakaz.weight1=(hsRes.inrequest.weight1!=-1)?hsRes.inrequest.weight1:null
    oZakaz.weight2=(hsRes.inrequest.weight2!=-1)?hsRes.inrequest.weight2:null
    oZakaz.weight3=(hsRes.inrequest.weight3!=-1)?hsRes.inrequest.weight3:null
    oZakaz.weight4=(hsRes.inrequest.weight4!=-1)?hsRes.inrequest.weight4:null
    oZakaz.weight5=(hsRes.inrequest.weight5!=-1)?hsRes.inrequest.weight5:null

    def sTr_ids=''      
    if(Container.get(hsRes.inrequest.container?:0)?.is_vartrailer){     
      sTr_ids=hsRes.inrequest.trailertype_id?.join(',')?:''
    }             
    oZakaz.trailertype_id=sTr_ids      
    
    oZakaz.doc=hsRes.inrequest.doc?:''
    oZakaz.comment=hsRes.inrequest.comment?:''    
    
    oZakaz.moddate=new Date()
//start>>    
    oZakaz.date_start=hsRes.inrequest.date_start
    oZakaz.region_start=hsRes.inrequest.region_start?:''
    oZakaz.city_start=hsRes.inrequest.city_start?:''
    oZakaz.address_start=hsRes.inrequest.address_start?:''
    oZakaz.prim_start=hsRes.inrequest.prim_start?:''
//start<<    
    oZakaz.terminal=hsRes.inrequest.terminal?:0
    oZakaz.shipper=hsRes.user.client_id
    oZakaz.manager_id = oZakaz.manager_id?:Client.get(hsRes.user?.client_id?:0)?.admin_id?:0
    oZakaz.benefit = Clientrequisites.findByModstatusAndClient_id(1,hsRes.user?.client_id?:0)?.getBenefit(oZakaz.price)?:0

    return oZakaz
  }
/////////////////////////////////  
  def findCommon(hsResinrequest){
    switch(hsResinrequest?.zcol?:1){
      case 1:
        hsResinrequest.weight1=requestService.getFloatDef('weight1',-1)
      break;
      case 2:
        hsResinrequest.weight1=requestService.getFloatDef('weight1',-1)
        hsResinrequest.weight2=requestService.getFloatDef('weight2',-1)
      break;
      case 3:
        hsResinrequest.weight1=requestService.getFloatDef('weight1',-1)
        hsResinrequest.weight2=requestService.getFloatDef('weight2',-1)
        hsResinrequest.weight3=requestService.getFloatDef('weight3',-1)
      break;
      case 4:
        hsResinrequest.weight1=requestService.getFloatDef('weight1',-1)
        hsResinrequest.weight2=requestService.getFloatDef('weight2',-1)
        hsResinrequest.weight3=requestService.getFloatDef('weight3',-1)
        hsResinrequest.weight4=requestService.getFloatDef('weight4',-1)   
      break;
      case 5:
        hsResinrequest.weight1=requestService.getFloatDef('weight1',-1)
        hsResinrequest.weight2=requestService.getFloatDef('weight2',-1)
        hsResinrequest.weight3=requestService.getFloatDef('weight3',-1)
        hsResinrequest.weight4=requestService.getFloatDef('weight4',-1)
        hsResinrequest.weight5=requestService.getFloatDef('weight5',-1)
      break;
    }          
    hsResinrequest.trailertype_id=requestService.getIds('trailertype_id')
   
    if(hsResinrequest.container==-1)
      hsResinrequest.container=hsResinrequest.containerh    
    
    if(hsResinrequest.terminal==-1)
      hsResinrequest.terminal=hsResinrequest.terminalh         
    
    return hsResinrequest
  }    
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Zayavka <<</////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Offer >>>///////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def offers = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'shipper', action:'profile')
      return
    }

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def offerlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def oSearchObj = new Zakaz()
    hsRes.searchresult = oSearchObj.findZakaz(hsRes.user.id,2,20,requestService.getOffset())
    hsRes.zakazDrivers = [:]
    def oZakazDrivers = new ZakaztoshipperSearch()
    hsRes.searchresult.records.each {
      hsRes.zakazDrivers[it.id] = oZakazDrivers.getDrivers(it.id)
    }

    hsRes.terminals = Terminal.list().inject([:]){map, terminal -> map[terminal.id]=terminal.name;map}
    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=[shortname:container.shortname,name:container.name];map}

    return hsRes
  }

  def offerdecline={
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
      try {
        def lZakazId = Zakaz.findByShipperAndId(hsRes.client.id,lId)?.csiSetModstatus(-1)?.save(failOnError:true)?.id
        zakazService.sendOfferDeclineForCarrier(Zakaztocarrier.findAllByZakaz_idAndModstatus(lZakazId,2).collect{it.client_id},lZakazId)
        Zakaztocarrier.findAllByZakaz_idAndModstatusGreaterThan(lZakazId,-1).each{ ztocarr -> ztocarr.csiSetModstatus(-1).carrierread().save(flush:true) }
      } catch(Exception e) {
        log.debug("Error save data in Shipper/offerdecline\n"+e.toString());
        render(contentType:"application/json"){[error:true]}
      }
    }

    render(contentType:"application/json"){[error:false]}
  }

  def offerdetails = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'shipper', action:'profile')
      return
    }

    def lId = requestService.getIntDef('id',0)

    hsRes.zakaz = Zakaz.findByShipperAndId(hsRes.client.id,lId)
    if (!hsRes.zakaz) {
      response.sendError(404)
      return
    }

    def oZakazDrivers = new ZakaztoshipperSearch()
    hsRes.zakazDrivers = oZakazDrivers.getDrivers(hsRes.zakaz.id)
    if (hsRes.zakaz.slotlist) {
      hsRes.slot = hsRes.zakaz.slotlist.split(',').collect{Slot.get(it.isInteger()?it.toInteger():0)}-null
    }

    return hsRes
  }

  def confirmoffer={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes+=requestService.getParams(null,['id'])

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.zakaz = Zakaz.findByShipperAndId(hsRes.client?.id,hsRes.inrequest.id)
    if (!hsRes.client||!hsRes.zakaz||hsRes.zakaz.modstatus==3) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    def result = [:]
    result.errorcode = []
    result.errorslotcode = []
    result.errorcontcode = []

    def oZakazDrivers = new ZakaztoshipperSearch()
    hsRes.zakazDrivers = oZakazDrivers.getDrivers(hsRes.zakaz.id)
    hsRes.inrequest.contcount = 0
    hsRes.zakazDrivers.each {
      hsRes.inrequest += zakazService.getContainersAndSlotsFromRequest(requestService,hsRes.inrequest,it.id)
      def errorlist = zakazService.checkDataForZakazdrivers(hsRes.inrequest,it.id,hsRes.zakaz.slotlist?true:false)
      hsRes.zakaz.slotlist?result.errorslotcode += errorlist:(result.errorcode += errorlist)
      result.errorcontcode += zakazService.checkContainerDataForZakazdrivers(hsRes.inrequest,it.id)
    }
    if (hsRes.inrequest.contcount<hsRes.zakaz.zcol) result.notEnoughContainersError = true
    if (hsRes.inrequest.contcount>hsRes.zakaz.zcol) result.moreEnoughContainersError = true

    if (result.errorslotcode.size()>0||result.errorcode.size()>0||result.notEnoughContainersError||result.moreEnoughContainersError||result.errorcontcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }

    try {
      zakazService.sendOfferConfirmForCarrier(hsRes.zakazDrivers.collect{Zakaztodriver.get(it.id)?.setShipperData(hsRes.inrequest).createTrip(hsRes.zakaz).save(failOnError:true)})
      Zakaz.withNewSession{
        hsRes.zakaz.csiSetModstatus(3).updatetotalcost().save(failOnError:true,flush:true)
      }
    } catch(Exception e) {
      log.debug("Error save data in Shipper/confirmoffer\n"+e.toString());
      result.bdError = true
    }

    if (result.bdError) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Offer <<<///////////////////////////////////////////////////////////////////////////
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
      redirect(controller:'shipper', action:'profile')
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
    hsRes.searchresult = oSearchObj.csiSelectTrip(false,hsRes.client.id,hsRes.inrequest.zakaz_id?:0l,hsRes.inrequest.trip_id?:0l,hsRes.inrequest.trip_modstatus,hsRes.inrequest.container?:'',20,hsRes.inrequest.offset)

    hsRes.terminals = Terminal.list().inject([:]){map, terminal -> map[terminal.id]=terminal.name;map}    
    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=[shortname:container.shortname,name:container.name];map}
    hsRes.tripstatus = Tripstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.taskstatus = Taskstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}

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
    hsRes.searchresult = oSearchObj.csiSelectTripEvent(hsRes.inrequest.trip_id?:0l,hsRes.client.id,0l,
                                      0l,'',hsRes.inrequest.trip_modstatus?:0,hsRes.inrequest.eventtype?:-100,
                                      '','',20,hsRes.inrequest.offset)
    hsRes.tripeventtype = Tripeventtype.list().inject([:]){map, type -> map[type.id]=[descr:type.name,icon:type.icon,significance:type.levelship];map}
    Trip.findAllByShipperAndIs_readeventshipper(hsRes.user.client_id,0).each{it.csiSetReadEvent(2).save()}

    return hsRes
  }

  def tripdetails = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'shipper', action:'profile')
      return
    }

    def lId = requestService.getIntDef('id',0)

    hsRes.trip = Trip.findByShipperAndId(hsRes.client.id,lId)
    if (!hsRes.trip) {
      response.sendError(404)
      return
    }

    hsRes.ztype = Ztype.list()
    hsRes.container = Container.list()
    hsRes.zakaztodriver = Zakaztodriver.get(hsRes.trip.zakaztodriver_id)
    hsRes.tripstatus = Tripstatus.get(hsRes.trip.modstatus)
    hsRes.driver = Driver.get(hsRes.trip.driver_id)
    hsRes.car = Car.get(hsRes.trip.car_id)
    hsRes.trailer = Trailer.get(hsRes.trip.trailer_id)
    hsRes.terminal = Terminal.get(hsRes.trip.terminal)
    hsRes.terminal_end = Terminal.get(hsRes.trip.terminal_end)
    def oTriproute = new Triproute()
    hsRes.route = oTriproute.csiSelectRoute(hsRes.trip.id,new Date(new Date().getTime()-(hsRes.trip.trackstatus==2?Tools.getIntVal(ConfigurationHolder.config.monitoring.tracktime.shipperdelay.parking,180):Tools.getIntVal(ConfigurationHolder.config.monitoring.tracktime.shipperdelay.movement,30))*60*1000))

    return hsRes
  }

  def tripeventlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.trip = Trip.findByShipperAndId(hsRes.client.id,lId)
    if (!hsRes.client||!hsRes.trip) {
      render(contentType:"application/json"){[error:true]}
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
    hsRes.trip = Trip.findByShipperAndId(hsRes.client.id,lId)
    if (!hsRes.client||!hsRes.trip) {
      render(contentType:"application/json"){[error:true]}
    }
    hsRes+=requestService.getParams(['timeslotA','timestartA','timeendA','timeeditA','timestartB','timeendB','timeeditB',
                                     'timestartC','timeendC','timeeditC','timeslotD','timestartD','timeendD','timeeditD'],
                                    null,['containernumber1','containernumber2'])
    hsRes.inrequest.dateA = requestService.getDate('dateA')
    hsRes.inrequest.dateB = requestService.getDate('dateB')
    hsRes.inrequest.dateC = requestService.getDate('dateC')
    hsRes.inrequest.dateD = requestService.getDate('dateD')

    def result = [:]
    result.errorcode = zakazService.checkDateForTripEdit(hsRes.inrequest)

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      hsRes.zakaztodriver = Zakaztodriver.get(hsRes.trip.zakaztodriver_id)
      hsRes.trip.setShipperData(hsRes.inrequest).save(failOnError:true)
      hsRes.zakaztodriver.setShipperData(hsRes.inrequest).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Shipper/saveTripDetail\n"+e.toString());
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}

  }

  def canceltrip = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.trip = Trip.findByShipperAndId(hsRes.client.id,lId)
    if (!hsRes.client||!hsRes.trip||!(hsRes.trip.modstatus in 0..1)) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    try {
      hsRes.trip.csiSetModstatus(-2).save(failOnError:true)
      mailerService.sendAdminNotice('#tripcancel_shipper')
      mailerService.sendManagerNotice(Zakaz.get(hsRes.trip.zakaz_id)?.manager_id?:0,'#tripcancel_shipper')
    } catch(Exception e) {
      log.debug("Error save data in Shipper/canceltrip\n"+e.toString());
    }

    render(contentType:"application/json"){[error:false]}
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Monitoring <<<//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////  
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Requests <<<//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def requests = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'shipper', action:'profile')
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
  def requestlist = {
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

    hsRes.searchresult = new DeliverySearch().csiSelectTrip(false,hsRes.client.id,hsRes.inrequest.zakaz_id?:0l,hsRes.inrequest.trip_id?:0l,hsRes.inrequest.trip_modstatus,hsRes.inrequest.trip_taskstatus,20,hsRes.inrequest.offset)

    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=[shortname:container.shortname,name:container.name];map}
    hsRes.tripstatus = Tripstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.taskstatus = Taskstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.terminals = Terminal.list().inject([:]){map, terminal -> map[terminal.id]=terminal.name;map}
    hsRes.norders = hsRes.searchresult.records.inject([:]){map, trip -> map[trip.id]=Payorder.get(trip.payorder_id)?.norder?:null;map}

    return hsRes
  }

  def instructiondetails = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'shipper', action:'profile')
      return
    }

    def lId = requestService.getIntDef('id',0)

    hsRes.trip = Trip.findByShipperAndId(hsRes.client.id,lId)
    hsRes.zakaztodriver = Zakaztodriver.get(hsRes.trip?.zakaztodriver_id)
    if (!hsRes.trip||!hsRes.zakaztodriver) {
      response.sendError(404)
      return
    }

    hsRes.terminal = Terminal.get(hsRes.trip.taskterminal)
    hsRes.terminal_main = Terminal.findAllByIs_main(1)
    hsRes.terminal_dop = Terminal.findAllByIs_main(0)
    hsRes.slot = Slot.findAllByTerminal_idAndModstatus(hsRes.trip.taskterminal,1)
    hsRes.region = Region.findAll('from Region where modstatus = 1 order by regorder desc, name asc')
    hsRes.driver = Driver.get(hsRes.trip.returndriver_id)

    return hsRes
  }

  def getslottask = {
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

  def saveTripDeliveryDetail = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.trip = Trip.findByShipperAndId(hsRes.client.id,lId)
    if (!hsRes.client||!hsRes.trip||!(hsRes.trip?.taskstatus in 0..4)||!(hsRes.trip?.modstatus in 0..1)) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    hsRes+=requestService.getParams(['terminalh','taskstart','taskend','taskslot','is_mark'],null,['taskaddress','taskprim','stockbooking'])
    hsRes.inrequest.dateE = requestService.getDate('dateE')

    def result = [:]
    result.errorcode = zakazService.checkDataForTripDelivery(hsRes.inrequest,false)

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      hsRes.trip.setDeliveryData(hsRes.inrequest).csiSetTaskstatus(2).save(failOnError:true)
      zakazService.sendContDeliveryForCarrier(hsRes.trip)
    } catch(Exception e) {
      log.debug("Error save data in Shipper/saveTripDeliveryDetail\n"+e.toString());
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}

  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Requests <<<//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////// Reports <<<//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def reports = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'shipper', action:'profile')
      return
    }

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def contreport = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'shipper', action:'profile')
      return
    }

    hsRes.contreport_date = requestService.getRaw('contreport_date')

    def oObject = new TripSearchAdmin()
    hsRes.report = oObject.csiSelectTrip(0l,hsRes.client.id,0l,0l,'','',0l,-100,-100,-1,0,false,hsRes.contreport_date)
    hsRes.priceshsum = hsRes.contcol = 0
    hsRes.report.records.each{
      hsRes.priceshsum += it.price_sh
      hsRes.contcol++
      if (it.containernumber2) {
        hsRes.priceshsum += it.price_sh
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
      redirect(controller:'shipper', action:'profile')
      return
    }

    hsRes.contreport_date = requestService.getRaw('contreport_date')

    def oObject = new TripSearchAdmin()
    hsRes.report = oObject.csiSelectTrip(0l,hsRes.client.id,0l,0l,'','',0l,-100,-100,-1,0,false,hsRes.contreport_date)
    hsRes.priceshsum = hsRes.contcol = 0
    hsRes.report.records.each{
      hsRes.priceshsum += it.price_sh
      hsRes.contcol++
      if (it.containernumber2) {
        hsRes.priceshsum += it.price_sh
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
        fillRow(['Код поездки','ФИО водителя','Госномер автомобиля','Номер контейнера','Дата отправления','Дата сдачи контейнера','Маршрут','Ставка'],3,false)
        (0..<reportsize).eachWithIndex{ rowNumber, idx ->
          fillRow([hsRes.report.records[idx].id,hsRes.report.records[idx].driver_fullname, hsRes.report.records[idx].cargosnomer,
            hsRes.report.records[idx].containernumber1,String.format('%td/%<tm/%<tY',hsRes.report.records[idx].dateA),
            hsRes.report.records[idx].taskstatus>4?String.format('%td/%<tm/%<tY',hsRes.report.records[idx].taskdate):'не сдан',
            hsRes.report.records[idx].addressA+" "+(hsRes.report.records[idx].addressB?:"")+" "+(hsRes.report.records[idx].addressC?:"")+" "+(hsRes.report.records[idx].addressD?:""),
            hsRes.report.records[idx].price_sh], rowCounter++, false)
          if (hsRes.report.records[idx].containernumber2) {
            fillRow([hsRes.report.records[idx].id,hsRes.report.records[idx].driver_fullname, hsRes.report.records[idx].cargosnomer,
              hsRes.report.records[idx].containernumber2,String.format('%td/%<tm/%<tY',hsRes.report.records[idx].dateA),
              hsRes.report.records[idx].taskstatus>4?String.format('%td/%<tm/%<tY',hsRes.report.records[idx].taskdate):'не сдан',
              hsRes.report.records[idx].addressA+" "+(hsRes.report.records[idx].addressB?:"")+" "+(hsRes.report.records[idx].addressC?:"")+" "+(hsRes.report.records[idx].addressD?:""),
              hsRes.report.records[idx].price_sh], rowCounter++, false)
          }
        }
        fillRow(["ИТОГО", "", "", hsRes.contcol, "", "", "", hsRes.priceshsum], rowCounter++, false)
        save(response.outputStream)
      }
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////// Reports <<<//////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////////////////////// 
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Contsearch <<<////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def contsearch = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)
    hsRes.cont = requestService.getStr('cont')
    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def contsearchlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    hsRes.cont = requestService.getStr('cont')

    def oSearchObj = new ContSearchAdmin()
    hsRes.searchresult = oSearchObj.csiSelectTrip(0l,hsRes.cont?:'',0l,20,requestService.getOffset(),hsRes.client?.id)

    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=[shortname:container.shortname,name:container.name];map}
    hsRes.tripstatus = Tripstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.taskstatus = Taskstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.zakazstatus = Zakazstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.modstatus,icon:status.icon];map}

    return hsRes
  }

  def cont_autocomplete={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUserAJAX(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)
    hsRes.client = Client.get(hsRes.user.client_id)

    hsRes.returnmap = [:]
    hsRes.returnmap.query = requestService.getStr('query')
    if(hsRes.client&&hsRes.returnmap.query?:''){
      def oObj = new TripSearch()
      hsRes.returnmap.suggestions = oObj.csiSelectTrip(false,hsRes.client.id,0l,0l,-100,hsRes.returnmap.query,-1,0).records.collect{(it.containernumber1.startsWith(hsRes.returnmap.query.toUpperCase())?[it.containernumber1]:[])+(it.containernumber2.startsWith(hsRes.returnmap.query.toUpperCase())?[it.containernumber2]:[])}.flatten().unique().take(10)
    } else {
      hsRes.returnmap.suggestions = []
    }
    render hsRes.returnmap as JSON
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Contsearch <<<////////////////////////////////////////////////////////////////////
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
      redirect(controller:'shipper', action:'profile')
      return
    }

    return hsRes
  }

  def settllist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    hsRes.searchresult = new PayorderSearchShipper().findOrdersForShipperSettlements(hsRes.client.id?:0,20,requestService.getOffset())

    return hsRes
  }

  def printorder = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.payorder = Payorder.get(requestService.getIntDef('id',0))
    if (!hsRes.client||!hsRes.payorder) {
      response.sendError(404)
      return
    }
    hsRes.syscompany = Syscompany.get(hsRes.payorder.syscompany_id)
    hsRes.clientrequisites = Clientrequisites.get(hsRes.payorder.clientcompany_id)
    hsRes.priceASstring = Tools.num2str(hsRes.payorder.fullcost+hsRes.payorder.idlesum+hsRes.payorder.forwardsum,false)
    hsRes.chiefsign = Signature.findByName(hsRes.syscompany?.chief?:'')?.filename
    hsRes.accountantsign = Signature.findByName(hsRes.syscompany?.accountant?:'')?.filename

    renderPdf(template: 'payorderprint', model: hsRes, filename: "orderprint.pdf")
    return
  }

  def orderxls = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      redirect(controller:'shipper', action:'profile')
      return
    }

    def oObject = new ShOrderReport()
    hsRes.report = oObject.csiGetReport(hsRes.client.id)
    hsRes.syscompanies = Syscompany.list().inject([:]){map, company -> map[company.id]=company.name;map}

    if (hsRes.report.records.size()==0) {
      new WebXlsxExporter().with {
        setResponseHeaders(response)
        putCellValue(0, 4, "Нет данных")
        save(response.outputStream)
      }
    } else {
      def reportsize = hsRes.report.records.size()
      def rowCounter = 4
      new WebXlsxExporter().with {
        setResponseHeaders(response)
        fillRow(['Заказ','№счета','Дата счета','От кого','Кому','№контейнера','Ставка'],3,false)
        (0..<reportsize).eachWithIndex{ rowNumber, idx ->
          fillRow([hsRes.report.records[idx].zakaz_id,hsRes.report.records[idx].norder,
            String.format('%td.%<tm.%<tY',hsRes.report.records[idx].orderdate),
            hsRes.syscompanies[hsRes.report.records[idx].syscompany_id],hsRes.report.records[idx].companyname,
            hsRes.report.records[idx].containernumber1,hsRes.report.records[idx].price_sh], rowCounter++, false)
          if (hsRes.report.records[idx].containernumber2) {
            fillRow([hsRes.report.records[idx].zakaz_id,hsRes.report.records[idx].norder,
              String.format('%td.%<tm.%<tY',hsRes.report.records[idx].orderdate),
              hsRes.syscompanies[hsRes.report.records[idx].syscompany_id],hsRes.report.records[idx].companyname,
              hsRes.report.records[idx].containernumber2,hsRes.report.records[idx].price_sh], rowCounter++, false)
          }
        }
        save(response.outputStream)
      }
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Financial <<<///////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////

}