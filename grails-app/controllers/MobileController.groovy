import org.codehaus.groovy.grails.commons.ConfigurationHolder
import grails.converters.JSON
class MobileController {
  def requestService
  def usersService
  def mailerService
  def searchService
  def zakazService    
  
  def static final DATE_FORMAT_MOBILE='yyyy-MM-dd'
  def static final DATE_FORMAT_TIME_MOBILE='yyyy-MM-dd HH:mm'

  def checkUser(hsRes) {
    if (hsRes?.user?.type_id==2&&!hsRes?.user?.is_termconfirm) hsRes.user = null
    if(!hsRes?.user)
      return false    
    return true
  }
  
  def checkZakazIdShipper(hsRes){
    if(hsRes.order_id)  
      if(!Zakaz.findWhere(id:hsRes.order_id,shipper:hsRes.user.client_id))    
        return false  
    
    return true    
  }

  def index = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()//for wallet icon 
    if (hsRes.user?.type_id==2&&!hsRes.user?.is_termconfirm) hsRes.user = null
    //log.debug(hsRes)
    //hsRes.near_page=Tools.getIntVal(ConfigurationHolder.config.mobile.near.paging,5)
    /*if(!hsRes.user)	
      hsRes.user='[]'
    if(!hsRes.wallet)
      hsRes.wallet=[]*/
      //log.debug(hsRes)
//    requestService.setStatistic('index',0,0,0,'','',[],true)                               
    render "${params.jsoncallback}(${hsRes as JSON})"
    return 
  } 
 
  ///////////////////////////////////////////////////////////////////////////////////////
  def login = {  
    requestService.init(this)
    requestService.setCookie('user_LG','parararam',10000)    
    def sUser=requestService.getStr('user')        
    def sPassword=requestService.getStr('password')
    flash.error = 0                  
    if((sUser=='')||(!sPassword)){	  
      flash.error = 1 // set user and provider          
    }      
    
    def oUserlog = new Userlog()
    def blocktime = Tools.getIntVal(ConfigurationHolder.config.login.blocktime,1800)
    def unsuccess_log_limit = Tools.getIntVal(ConfigurationHolder.config.login.unsuccess_log_limit,5)
    
    def oUser=[:]
    if(!flash.error){
      oUser=User.findWhere(email:sUser)
      if(!oUser){
        try{
          sUser=sUser.toLong()
          oUser=User.findWhere(id:sUser)
        }catch(Exception e){
        }                 
      }    
    }
    if (oUser?.type_id==2&&!oUser?.is_termconfirm) flash.error = 2
    if(!flash.error){  
      if(!oUser){
        flash.error=1 // Wrong password or user does not exists
        //redirect(action:'login',params:hsInrequest)
        //return
      }else if (oUserlog.csiCountUnsuccessLogs(oUser.id, new Date(System.currentTimeMillis()-blocktime*1000))[0]>=unsuccess_log_limit){
        flash.error=2 // user blocked
        oUserlog = new Userlog(user_id:oUser.id,logtime:new Date(),ip:request.remoteAddr,success:2)
        if (!oUserlog.save(flush:true)){
          log.debug('error on save Userlog in User:login_user')
          oUserlog.errors.each{log.debug(it)}
        } 
         render "${params.jsoncallback}(${flash as JSON})"          	        
         return        
      }else if (oUser.password != Tools.hidePsw(sPassword)) {
        flash.error=1 // Wrong password or user does not exists
        oUserlog = new Userlog(user_id:oUser.id,logtime:new Date(),ip:request.remoteAddr,success:0)
        if (!oUserlog.save(flush:true)){
          log.debug('error on save Userlog in User:login_user')
          oUserlog.errors.each{log.debug(it)}
        }       
        //redirect(action:'login',params:hsInrequest)
        //return
      }                  
    }                            
    
    if(!flash.error){
      if(!usersService.loginInternalUser(sUser,sPassword,requestService,1,0)){        
        flash.error=1 // Wrong password or user does not exists        		
      }else {	        
        if(oUser!=null){
          oUser.lastdate=new Date()		
          if(!oUser.save(flush:true)) {
            log.debug(" Error on save User:")
            oUser.errors.each{log.debug(it)}	 
          }
        }
        if(requestService.getStr('deviceToken')){        
          def lsDevice=Device.findAllWhere(device:requestService.getStr('deviceToken'))
          for(dev in lsDevice)    
            dev.delete(flush:true)       
        
          def oDevice=new Device()
          oDevice.user_id=oUser?.id
          oDevice.device=requestService.getStr('deviceToken')
          oDevice.inputdate=new Date()
        
          if(!oDevice.save(flush:true)) {
            log.debug(" Error on save Device:")
            oDevice.errors.each{log.debug(it)}	 
          }    
        }
        redirect (action:'index',params:[jsoncallback:params.jsoncallback])
        return
      }
    } 
    if(flash.error){
      render "${params.jsoncallback}(${flash as JSON})"          	        
      return
    }    
  }
  ///////////////////////////////////////////////////////////////////////////////////////
  def logout = {
    requestService.init(this)        
    if(requestService.getStr('deviceToken')){
      def lsDevice=Device.findAllWhere(device:requestService.getStr('deviceToken'))
      for(dev in lsDevice)    
        dev.delete(flush:true)   
    }    
    
    usersService.logoutUser(requestService)      
    def hsRes=[logout:true]  
    render "${params.jsoncallback}(${hsRes as JSON})"   
    return
  }   
  //////////////////////////////////////////////////////////////////////////////////////////////////  
  def rest={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    hsRes.inrequest=[:]
    if(hsRes.user!=null){ 
      redirect (action:'index',params:[jsoncallback:params.jsoncallback])
      return
    }
    
    hsRes.inrequest.name=requestService.getStr('name')
    hsRes.inrequest.error=0    
    
    def oUser=User.findWhere(email:hsRes.inrequest.name)      
    
    if(!oUser){               
      try{
        hsRes.inrequest.name=hsRes.inrequest.name.toLong()
        hsRes.inrequest.error=6
      }catch(Exception e){
        hsRes.inrequest.error=1 //USER NOT EXISTS
      }
      
      render "${params.jsoncallback}(${hsRes.inrequest as JSON})"
      return
    }
    if(!Tools.checkEmailString(hsRes.inrequest.name)){
      hsRes.inrequest.error=2 //ERROR IN EMAIL
      render "${params.jsoncallback}(${hsRes.inrequest as JSON})"
      return
    }               
    if (!oUser.code) {
      oUser.code=java.util.UUID.randomUUID().toString()
      if(!oUser.save(flush:true)) {
        log.debug(" Error on save User:")
        oUser.errors.each{log.debug(it)}
      }
    }
    def sCode=oUser.code     
    if((hsRes.inrequest.name?:'').size()>0){
      //<<Email
      def lsText=Email_template.findAllWhere(action:'#restore')
      def sText='[@EMAIL], for restore of your password use follow link [@URL]'
      def sHeader="Restore password" 
      if((lsText?:[]).size()>0){
        sText=lsText[0].itext
        sHeader=lsText[0].title
      }
      sText=sText.replace(
      '[@NICKNAME]',oUser.nickname).replace(
      '[@EMAIL]',hsRes.inrequest.name).replace(
      '[@URL]',(ConfigurationHolder.config.grails.mailServerURL+'/user/passwconfirm/'+sCode))
      sText=((sText?:'').size()>Tools.getIntVal(ConfigurationHolder.config.mail.textsize,500))?sText.substring(0,Tools.getIntVal(ConfigurationHolder.config.mail.textsize,500)):sText
      sHeader=sHeader.replace(
      '[@EMAIL]',hsRes.inrequest.name).replace(
      '[@URL]',(ConfigurationHolder.config.grails.mailServerURL+'/user/passwconfirm/'+sCode))
      try{        
        sendMail{
          to hsRes.inrequest.name        
          subject sHeader
          html sText
        } 
          /*body( view:"/_mail",
          model:[mail_body:sText])*/          
      }catch(Exception e) {
        log.debug("Cannot sent email \n"+e.toString())          
        hsRes.inrequest.error=-100
        redirect(action:"restore",params:hsRes.inrequest)
        return		  
      }
		//>>Email	                       
    }
    render "${params.jsoncallback}(${hsRes.inrequest as JSON})"  
    return
  }
/////////////////////////////////////////////////////////////////////////    
  def orderlist={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id) 
    
    hsRes.container=Container.list()        
    hsRes.terminal=Terminal.list()       
    hsRes.region = Region.findAll('from Region where modstatus = 1 order by regorder desc, name asc')
    hsRes.modstatus=Zakazstatus.list()

    hsRes.max=Tools.getIntVal(ConfigurationHolder.config.mobile.search.listing.max,5)    	  
    hsRes.paging_set=Tools.getIntVal(ConfigurationHolder.config.mobile.paging_set,5)

    def oZakaz=new Zakaz()    
    hsRes+=oZakaz.findZakaz(hsRes.user.id,100,hsRes.max,requestService.getOffset()-1,true)        
    
    hsRes.paging=Paging.computeNavigation(requestService.getOffset(),hsRes.count,hsRes.max,hsRes.paging_set)
    
    render "${params.jsoncallback}(${hsRes as JSON})"
    return
  }   
/////////////////////////////////////////////////////////////////////////  
  def order={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)
    hsRes.ztype=Ztype.list()     
    hsRes.zcol=[[id:'1'],[id:'2'],[id:'3'],[id:'4'],[id:'5']]
    hsRes.dangerclass=Dangerclass.list()
    hsRes.container=Container.list()
    hsRes.ztime=Ztime.list()
    hsRes.trailertype=Trailertype.list()
    
    hsRes.terminal=Terminal.list()       
    hsRes.region = Region.findAll('from Region where modstatus = 1 order by regorder desc, name asc')
    
    hsRes.order_id=requestService.getLongDef('id',0)
    hsRes.copy=requestService.getIntDef('copy',0)        
    hsRes.modstatus=Zakazstatus.list()
    
    if(checkZakazIdShipper(hsRes)){          
      hsRes.zakaz=Zakaz.get(hsRes.order_id) 
      if(hsRes.zakaz){
        hsRes.trailertype_id=(hsRes.zakaz.trailertype_id?:'').split(',')
        //for mobile only>> 
        hsRes.terminal_is_slot=Terminal.get(hsRes.zakaz?.terminal?:0)?.is_slot       
        //<<
        hsRes.slot=Slot.findAllByTerminal_idAndModstatus(hsRes.zakaz.terminal,1)        
        hsRes.slotlist=hsRes.zakaz?.slotlist.split(',')                     
      }
    }
    
    render "${params.jsoncallback}(${hsRes as JSON})"
    return
  }
/////////////////////////////////////////////////////////////////////////    
  def getslot={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    def iId=requestService.getIntDef('id',0)
    
    if(iId>=0){
      hsRes.slot=Slot.findAllByTerminal_idAndModstatus(iId,1)      
      hsRes.terminal=Terminal.get(iId)            
    }
    render "${params.jsoncallback}(${hsRes as JSON})"
    return 
  } 
///////////////////////////////save zakaz>>>  
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
      render "${params.jsoncallback}(${hsOut as JSON})"
      return       
    }  
    return
  }    
///////////////////////////////////////////////////////////////////////////////////  
  def saveZakazImport={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.order_id=requestService.getLongDef('order_id',0)
    if(!checkZakazIdShipper(hsRes)) return
    hsRes.inrequest = requestService.getParams(['ztype_id','container','zcol','price','ztime_id','dangerclass','is_roof','terminal'],[],['doc','comment','region_start','city_start','address_start','prim_start','region_end','city_end','address_end','prim_end','region_dop','city_dop','address_dop','prim_dop','idle'],['zdate','date_start']).inrequest                
    hsRes.inrequest=findCommon(hsRes.inrequest)     
    def hsResReturn=commonError(hsRes)

//zdate>>    
    try {      
      if (hsRes.inrequest.zdate)
        hsRes.inrequest.zdate=Date.parse(DATE_FORMAT_MOBILE, hsRes.inrequest?.zdate)
    } catch(Exception e) {
      hsResReturn.date_error<<1
    }    
    if(!hsResReturn.date_error.contains(1) && hsRes.inrequest.zdate<curDate())
      hsResReturn.date_error<<3
    if(!hsResReturn.date_error.contains(1) && hsRes.inrequest.zdate<hsRes.inrequest.date_start)
      hsResReturn.date_error<<6  
//zdate<<    
      
    if(!hsResReturn.error && !hsResReturn.slot_error && !hsResReturn.date_error && !hsResReturn.price_error && !hsResReturn.weight_error && !hsResReturn.time_error){        
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

        if(!oZakaz.detectroute(null).save(flush:true)) {
          log.debug(" Error on save Zakaz:")
          oZakaz.errors.each{log.debug(it)}	
          hsResReturn.error<<100        
        }
      }
    }

    hsResReturn.ztype_id=1
    render "${params.jsoncallback}(${hsResReturn as JSON})"
    return
  }
/////////////////////////////////////////////////////////////////////////////////////
  def saveZakazExport={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.order_id=requestService.getLongDef('order_id',0)
    if(!checkZakazIdShipper(hsRes)) return
    hsRes.inrequest = requestService.getParams(['ztype_id','container','zcol','price','ztime_id','dangerclass','is_roof','terminal','terminal_end','timestart_zat'],[],['doc','comment','region_start','city_start','address_start','prim_start','region_end','city_end','address_end','prim_end','region_zat','city_zat','address_zat','prim_zat','region_cust','city_cust','address_cust','prim_cust','idle'],['date_start','date_zat']).inrequest            
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
        hsRes.inrequest.date_zat=Date.parse(DATE_FORMAT_MOBILE, hsRes.inrequest?.date_zat)           
    } catch(Exception e) {
      hsResReturn.date_error<<1
    }
    if(!hsResReturn.date_error.contains(1) && hsRes.inrequest.date_zat<curDate())
      hsResReturn.date_error<<4
    if(!hsResReturn.date_error.contains(1) && hsRes.inrequest.date_zat<hsRes.inrequest.date_start)
      hsResReturn.date_error<<6  
//date<<        
      
    if(!hsResReturn.error && !hsResReturn.slot_error && !hsResReturn.date_error && !hsResReturn.price_error && !hsResReturn.weight_error && !hsResReturn.time_error){        
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
    render "${params.jsoncallback}(${hsResReturn as JSON})"
    return
  }
////////////////////////////////////////////////////////////////////////////////////////  
  def saveZakazTransit={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.order_id=requestService.getLongDef('order_id',0)
    if(!checkZakazIdShipper(hsRes)) return
    hsRes.inrequest = requestService.getParams(['ztype_id','container','zcol','price','ztime_id','dangerclass','is_roof','terminal','timestart_end','timeend_end'],[],['doc','comment','region_start','city_start','address_start','prim_start','region_end','city_end','address_end','prim_end','region_dop','city_dop','address_dop','prim_dop','region_cust','city_cust','address_cust','prim_cust','idle'],['date_cust','date_start']).inrequest                
    hsRes.inrequest=findCommon(hsRes.inrequest)

    def hsResReturn=commonError(hsRes) 

 //date>>    
    try {
      if (hsRes.inrequest.date_cust)
        hsRes.inrequest.date_cust=Date.parse(DATE_FORMAT_MOBILE, hsRes.inrequest?.date_cust)           
    } catch(Exception e) {
      hsResReturn.date_error<<1
    }
    if(!hsResReturn.date_error.contains(1) && hsRes.inrequest.date_cust<curDate())
      hsResReturn.date_error<<5
    if(!hsResReturn.date_error.contains(1) && hsRes.inrequest.date_cust<hsRes.inrequest.date_start)
      hsResReturn.date_error<<6   
//date<<    
    if(!hsResReturn.error && !hsResReturn.slot_error && !hsResReturn.date_error && !hsResReturn.price_error && !hsResReturn.weight_error && !hsResReturn.time_error){        
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
    render "${params.jsoncallback}(${hsResReturn as JSON})"
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
        hsRes.inrequest.date_start=Date.parse(DATE_FORMAT_MOBILE, hsRes.inrequest?.date_start)      
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
              def dateTMP=Date.parse(DATE_FORMAT_TIME_MOBILE, date_start +' '+ end) 
              if(dateTMP<new Date()){
                if(!hsResReturn.time_error.contains(1))
                   hsResReturn.time_error<<1   
                hsResReturn.time_error_slot_ids<<slot
              }  
            }
          }
        }else if(iSlot_start>0){        
          def dateTMP=Date.parse(DATE_FORMAT_TIME_MOBILE, date_start +' '+ ((iSlot_start<10)?'0'+iSlot_start:iSlot_start)+':00')
          if(dateTMP<new Date())
            hsResReturn.time_error<<2  
        }        
      }
    }          
//date<<

    hsResReturn.iSlot_start=iSlot_start
    hsResReturn.iSlot_end=iSlot_end
    hsResReturn.slotlist=slotlist
    return hsResReturn     
  }
///////////////////////////////////////////////////////////////////////////////////////  
  def commonZakaz(hsRes){
    def oZakaz=[:]
    def bNew=0
    if(!(hsRes?.order_id?:0)){
      oZakaz=new Zakaz()
      bNew=1      
    }else if(requestService.getIntDef('copy',0)){    
      oZakaz=new Zakaz()
      bNew=1
    }else{  
      oZakaz=Zakaz.get(hsRes.order_id?:0)
    }      
    if(bNew){
      def oAdmin=Admin.get(Tools.getIntVal(ConfigurationHolder.config.zakaz.admin.id?:1).toLong())
      mailerService.sendZakazNewAsync(oAdmin)
      
      oZakaz.inputdate=new Date()
    }
      
    oZakaz.user_id=hsRes.user.id
    oZakaz.ztype_id=hsRes.inrequest.ztype_id?:0
    oZakaz.container=hsRes.inrequest.container
    oZakaz.zcol=hsRes.inrequest.zcol?:0
    oZakaz.price=hsRes.inrequest.price
    oZakaz.idle=hsRes.inrequest.idle?:''
    oZakaz.ztime_id=hsRes.inrequest.ztime_id?:0
    oZakaz.dangerclass=hsRes.inrequest.dangerclass
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
    oZakaz.zdate=hsRes.inrequest.zdate
    
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
//only mobile!!!>>>    
    oZakaz.is_mobile=1
    
    return oZakaz
  }
/////////////////////////////////  
  def findCommon(hsResinrequest){
    switch(hsResinrequest?.zcol?:0){
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
    return hsResinrequest
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
    render "${params.jsoncallback}(${hsOut as JSON})"
    return
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Carrier >>>///////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Zakaz >>>///////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def orderlist_carrier = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes))
      return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      return
    }
    
    hsRes.container=Container.list()        
    hsRes.terminal=Terminal.list()   
/*    
    hsRes.terminal = Terminal.list().inject([:]){map, terminal -> map[terminal.id]=terminal.name;map}
    hsRes.container = Container.list().inject([:]){map, container -> map[container.id]=container.shortname;map}
*/    
    hsRes.region = Region.findAll('from Region where modstatus = 1 order by regorder desc, name asc')
    hsRes.modstatus=Zakazstatus.list()

    hsRes.max=Tools.getIntVal(ConfigurationHolder.config.mobile.search.listing.max,5)    	  
    hsRes.paging_set=Tools.getIntVal(ConfigurationHolder.config.mobile.paging_set,5)
    
    def oSearchObj = new ZakaztocarrierSearch()
    hsRes+= oSearchObj.csiSelectZakaz(hsRes.client.id,0,-100,hsRes.max,requestService.getOffset()-1,requestService.getIntDef('type',0))  
    
    hsRes.remindtime=[]
    for(def i=0; i<hsRes.records.size();i++){      
      if(hsRes.records[i].remindtime)    
        hsRes.remindtime[i]=String.format('%tT',new Date((hsRes.records[i].remindtime-60*180)*1000))
      else  
        hsRes.remindtime[i]=''
    }  
    
    hsRes.paging=Paging.computeNavigation(requestService.getOffset(),hsRes.count,hsRes.max,hsRes.paging_set)
    
    render "${params.jsoncallback}(${hsRes as JSON})"
    return
  }
  def ordercarrier = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {      
      return
    }

    def lId = requestService.getIntDef('id',0)

    hsRes.zakaztocarrier = Zakaztocarrier.findByClient_idAndId(hsRes.client.id,lId)
    hsRes.zakaz = Zakaz.get(hsRes.zakaztocarrier?.zakaz_id?:0)
    if (!hsRes.zakaztocarrier||!hsRes.zakaz) {      
      return
    }

    hsRes.ztype = Ztype.list()
    hsRes.container = Container.list()
    hsRes.terminal=Terminal.list()
    hsRes.zcol=[[id:'1'],[id:'2'],[id:'3'],[id:'4'],[id:'5']]
    hsRes.maxweight = hsRes.zakaz.collect{[it.weight1,it.weight2,it.weight3,it.weight4,it.weight5]}?.max()?.max()?.toInteger()?:0
    
    def terminalstart = Terminal.get(hsRes.zakaz.terminal?:0)
    hsRes.timestart = terminalstart?.is_slot?(hsRes.zakaz.slotlist.split(',').collect{Slot.get(it.isInteger()?it.toInteger():0)?.name}-null).join(', '):hsRes.zakaz.timestart.toString()
    hsRes.timeend = terminalstart?.is_slot?-1:hsRes.zakaz.timeend
    hsRes.confirmedTrailertypes = hsRes.zakaz.trailertype_id?hsRes.zakaz.trailertype_id.split(',').collect{Trailertype.get(it)}:null
    hsRes.manager = Admin.get(hsRes.zakaz.admin_id?:0)
    
    try {
      hsRes.zakaztocarrier.carrierread().save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in mobile/ordercarrier\n"+e.toString());
    }
    hsRes.deadline=hsRes.zakaztocarrier.deadline.getTime()-new Date().getTime()>0?String.format('%tT',new Date(hsRes.zakaztocarrier.deadline.getTime()-new Date().getTime()-60*180*1000)):''
    
    render "${params.jsoncallback}(${hsRes as JSON})"
    return
  }
  def saveoffer = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return 
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      return
    }

    def lId = requestService.getIntDef('id',0)

    hsRes.zakaztocarrier = Zakaztocarrier.findByClient_idAndId(hsRes.client.id,lId)
    hsRes.zakaz = Zakaz.get(hsRes.zakaztocarrier?.zakaz_id?:0)
    if (!hsRes.zakaztocarrier||!hsRes.zakaz) {
      return
    }

    hsRes+=requestService.getParams(['zcol','cprice','is_confirm'])

    def result = [:]
    result.errorcode = []
    if(hsRes.inrequest.is_confirm!=-1){
      if (hsRes.inrequest.zcol>hsRes.zakaztocarrier.zcol)
        result.errorcode << 1
      if (hsRes.zakaztocarrier.is_debate&&hsRes.inrequest.cprice<=0)
        result.errorcode << 2
      if (hsRes.inrequest.is_confirm==1&&(!(hsRes.zakaztocarrier.modstatus==0&&hsRes.zakaz.modstatus==1)||(hsRes.zakaztocarrier.deadline.getTime()-new Date().getTime()<=0)||(hsRes.client.isblocked)))
        result.errorcode << 3             
   
      if (!Zakaztodriver.findAllByClient_idAndZakaz_id(hsRes.client.id,hsRes.zakaz.id))
        result.errorcode << 5
      else if ((Zakaztodriver.findAllByClient_idAndZakaz_id(hsRes.client.id,hsRes.zakaz.id)?.sum{it.zcol}?:0)<hsRes.inrequest.zcol)
        result.errorcode << 6
      else if ((Zakaztodriver.findAllByClient_idAndZakaz_id(hsRes.client.id,hsRes.zakaz.id)?.sum{it.zcol}?:0)>hsRes.inrequest.zcol)
        result.errorcode << 7
    }else if (hsRes.zakaztocarrier.modstatus==2||hsRes.zakaztocarrier.modstatus==-1)
      result.errorcode << 4      

    if (result.errorcode.size()>0) {
      result.error = true      
      render "${params.jsoncallback}(${result as JSON})"
      return
    }

    try {
      if(hsRes.inrequest.is_confirm==-1)
        hsRes.zakaztocarrier.csiSetModstatus(-1).save(failOnError:true)
      else
        hsRes.zakaztocarrier.setCarrierOffer(hsRes.inrequest).csiSetModstatus(hsRes.inrequest.is_confirm?:0).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Mobile/saveoffer\n"+e.toString());
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true      
      render "${params.jsoncallback}(${result as JSON})"
      return
    } else{          
      render "${params.jsoncallback}(${hsRes as JSON})"
      return
    }  
  }
  
  def driversforzakazlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)
    def lZtoCId = requestService.getIntDef('zakaztocarrier_id',0)
    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.zakaz = Zakaz.get(lId)
    hsRes.zakaztocarrier = Zakaztocarrier.findByClient_idAndId(hsRes.client?.id,lZtoCId)
    if (!hsRes.client||!hsRes.zakaz||!hsRes.zakaztocarrier) {
      //render(contentType:"application/json"){[error:true]}
      return
    }

    hsRes.zakaztodriver = Zakaztodriver.findAllByClient_idAndZakaz_id(hsRes.client.id,hsRes.zakaz.id)

    hsRes.drivers = Driver.findAllByClient_id(hsRes.client.id).inject([:]){map, driver -> map[driver.id]=driver.name;map}
    hsRes.cars = Car.findAllByClient_id(hsRes.client.id).inject([:]){map, car -> map[car.id]=car.gosnomer;map}
    hsRes.trailers = Trailer.findAllByClient_id(hsRes.client.id).inject([:]){map, trailer -> map[trailer.id]=trailer.trailnumber;map}

    hsRes.drivercol = hsRes.zakaztodriver?.sum{it.zcol}?:0
    
    render "${params.jsoncallback}(${hsRes as JSON})"
    return
  }
  
  def zakaztodriver = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('zakaz_id',0)
    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.zakaz = Zakaz.get(lId)
    if (!hsRes.client||!hsRes.zakaz) {      
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
       
    render "${params.jsoncallback}(${hsRes as JSON})"
    return    
  }
  def addDriverToZakaz={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('zakaz_id',0)
    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.zakaz = Zakaz.get(lId)
    if (!hsRes.client||!hsRes.zakaz||(Zakaztodriver.findAllByClient_idAndZakaz_id(hsRes.client?.id,hsRes.zakaz?.id)?.sum{it.zcol}?:0)>=(hsRes.zakaz?.zcol?:1)) {      
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
      render "${params.jsoncallback}(${result as JSON})"
      return
    }
    try {
      new Zakaztodriver(zakaz_id:hsRes.zakaz.id,client_id:hsRes.client.id).setMainData(hsRes.inrequest).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Mobile/addDriverToZakaz\n"+e.toString());
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true      
      render "${params.jsoncallback}(${result as JSON})"
      return
    } else{
      render "${params.jsoncallback}({error:false})"
      return
    }  
  }

  def removedriverfromzakaz={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      return
    }

    def lId = requestService.getLongDef('id',0)
    def ztocId = requestService.getLongDef('zakaztocarrier_id',0)

    if(lId>0&&Zakaztocarrier.get(ztocId)?.modstatus==0){
      Zakaztodriver.findByClient_idAndId(hsRes.client.id,lId)?.delete(flush:true)
    }

    render "${params.jsoncallback}({error:false})"
    return
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Offer >>>///////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////
  def offerlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      return
    }
    
    hsRes.max=Tools.getIntVal(ConfigurationHolder.config.mobile.search.listing.max,5)    	  
    hsRes.paging_set=Tools.getIntVal(ConfigurationHolder.config.mobile.paging_set,5)
    
    def oSearchObj = new Zakaz()
    hsRes.searchresult = oSearchObj.findZakaz(hsRes.user.id,2,hsRes.max,requestService.getOffset()-1)
    hsRes.zakazDrivers = [:]
    def oZakazDrivers = new ZakaztoshipperSearch()
    
    hsRes.driver=[:]
    def idCount=0;
    hsRes.searchresult.records.each {      
      hsRes.zakazDrivers[it.id] = oZakazDrivers.getDrivers(it.id)
      
      idCount=it.id;
      hsRes.driver[idCount]=[]
      for(zDrivers in hsRes.zakazDrivers[idCount])    
        hsRes.driver[idCount]<<Driver.get(zDrivers.driver_id?:0)
    }
/*  hsRes.documentphotourl = ConfigurationHolder.config.documentphotourl
    hsRes.cardocumentphotourl = { clId, objId -> hsRes.documentphotourl+clId+'/cars/'+objId+'/' }
    hsRes.trailerdocumentphotourl = { clId, objId -> hsRes.documentphotourl+clId+'/trailers/'+objId+'/' }
    hsRes.driverdocumentphotourl = { clId, objId -> hsRes.documentphotourl+clId+'/drivers/'+objId+'/' }

    hsRes.teminals = Terminal.list().inject([:]){map, terminal -> map[terminal.id]=terminal.name;map}
    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=container.shortname;map}
    hsRes.zakazstatus = Zakazstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.modstatus,icon:status.icon];map}
*/  

    hsRes.terminals = Terminal.list()
    hsRes.containers = Container.list()
    hsRes.zakazstatus = Zakazstatus.list()       
    
    hsRes.paging=Paging.computeNavigation(requestService.getOffset(),hsRes.searchresult.count,hsRes.max,hsRes.paging_set)
    
    render "${params.jsoncallback}(${hsRes as JSON})"
    return
  }

  def offerdecline={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      return
    }

    def lId = requestService.getLongDef('id',0)

    if(lId>0){
      try {                      
        def lZakazId = Zakaz.findByShipperAndId(hsRes.client.id,lId)?.csiSetModstatus(-1)?.save(failOnError:true)?.id
        zakazService.sendOfferDeclineForCarrier(Zakaztocarrier.findAllByZakaz_idAndModstatus(lZakazId,2).collect{it.client_id},lZakazId)
        Zakaztocarrier.findAllByZakaz_idAndModstatusGreaterThan(lZakazId,-1).each{ ztocarr -> ztocarr.csiSetModstatus(-1).carrierread().save(flush:true) }
      } catch(Exception e) {
        log.debug("Error save data in Mobile/offerdecline\n"+e.toString());      
        render "${params.jsoncallback}({error:true})"
        return
      }
    }

    render "${params.jsoncallback}({error:false})"
    return
  }

  def offerdetails = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {      
      return
    }

    def lId = requestService.getIntDef('id',0)

    hsRes.zakaz = Zakaz.findByShipperAndId(hsRes.client.id,lId)
    if (!hsRes.zakaz) {
      //response.sendError(404)
      return
    }

    def oZakazDrivers = new ZakaztoshipperSearch()
    hsRes.zakazDrivers = oZakazDrivers.getDrivers(hsRes.zakaz.id)
    hsRes.driver=[]
    for(zDrivers in hsRes.zakazDrivers)    
      hsRes.driver<<Driver.get(zDrivers.driver_id?:0)
    
    if (hsRes.zakaz.slotlist) {
      hsRes.slot = hsRes.zakaz.slotlist.split(',').collect{Slot.get(it.isInteger()?it.toInteger():0)}-null
    }
    render "${params.jsoncallback}(${hsRes as JSON})"
    return    
  }

  def confirmoffer={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes+=requestService.getParams(null,['id'])

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.zakaz = Zakaz.findByShipperAndId(hsRes.client?.id,hsRes.inrequest.id)
    if (!hsRes.client||!hsRes.zakaz||hsRes.zakaz.modstatus==3) {
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
      render "${params.jsoncallback}(${result as JSON})"   
      return
    }

    try {
      zakazService.sendOfferConfirmForCarrier(hsRes.zakazDrivers.collect{Zakaztodriver.get(it.id)?.setShipperData(hsRes.inrequest).createTrip(hsRes.zakaz).save(failOnError:true)})
      Zakaz.withNewSession{
        hsRes.zakaz.csiSetModstatus(3).updatetotalcost().save(failOnError:true,flush:true)
      }
    } catch(Exception e) {
      log.debug("Error save data in Mobile/confirmoffer\n"+e.toString());
      result.bdError = true
    }

    if (result.bdError) {
      result.error = true      
      render "${params.jsoncallback}(${result as JSON})"   
      return
    } else      
      render "${params.jsoncallback}({error:false})"
      return
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Offer <<<///////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Monitoring shipper <<<//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////
  def triplist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      return
    }    
    
    hsRes.max=Tools.getIntVal(ConfigurationHolder.config.mobile.search.listing.max,5)    	  
    hsRes.paging_set=Tools.getIntVal(ConfigurationHolder.config.mobile.paging_set,5)        

    def oSearchObj = new TripSearch()
    hsRes.searchresult = oSearchObj.csiSelectTrip(false,hsRes.client.id,0l,0l,-100,'',hsRes.max,requestService.getOffset()-1,true)

    hsRes.terminals = Terminal.list().inject([:]){map, terminal -> map[terminal.id]=terminal.name;map}    
    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=[shortname:container.shortname,name:container.name];map}
    hsRes.tripstatus = Tripstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.taskstatus = Taskstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}

    hsRes.paging=Paging.computeNavigation(requestService.getOffset(),hsRes.searchresult.count,hsRes.max,hsRes.paging_set)
    
    render "${params.jsoncallback}(${hsRes as JSON})"
    return    
  }
  def eventlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {    
      return
    }

    hsRes.max=Tools.getIntVal(ConfigurationHolder.config.mobile.search.listing.max,5)    	  
    hsRes.paging_set=Tools.getIntVal(ConfigurationHolder.config.mobile.paging_set,5)
    
    def oSearchObj = new TripEventSearchAdmin()
    hsRes.searchresult = oSearchObj.csiSelectTripEvent(0l,hsRes.client.id,0l,0l,'',-101,-100,'','',hsRes.max,requestService.getOffset()-1,true)
    hsRes.tripeventtype = Tripeventtype.list().inject([:]){map, type -> map[type.id]=[descr:type.name,icon:type.icon];map}        
    Trip.findAllByShipperAndIs_readeventshipper(hsRes.user.client_id,0).each{it.csiSetReadEvent(2).save()}
    
    hsRes.paging=Paging.computeNavigation(requestService.getOffset(),hsRes.searchresult.count,hsRes.max,hsRes.paging_set)

    render "${params.jsoncallback}(${hsRes as JSON})"
    return
  }

  def tripdetails = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {      
      return
    }

    def lId = requestService.getIntDef('id',0)

    hsRes.trip = Trip.findByShipperAndId(hsRes.client.id,lId)
    if (!hsRes.trip) {     
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
    
    if(hsRes.route)
      hsRes.route_end=hsRes.route[0]
    hsRes.route=[]  
    
    hsRes.taskstatus = Taskstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
   
   /*hsRes.documentphotourl = ConfigurationHolder.config.documentphotourl
    hsRes.cardocumentphotourl = hsRes.documentphotourl+hsRes.trip.carrier+'/cars/'+hsRes.trip.car_id+'/'
    hsRes.trailerdocumentphotourl = hsRes.documentphotourl+hsRes.trip.carrier+'/trailers/'+hsRes.trip.trailer_id+'/'
    hsRes.driverdocumentphotourl = hsRes.documentphotourl+hsRes.trip.carrier+'/drivers/'+hsRes.trip.driver_id+'/'
*/
    render "${params.jsoncallback}(${hsRes as JSON})"
    return    
  }

  def tripeventlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.trip = Trip.findByShipperAndId(hsRes.client.id,lId)
    if (!hsRes.client||!hsRes.trip) {
      return
    }

    hsRes.events = Tripevent.findAllByTrip_id(hsRes.trip.id)
    hsRes.eventtypes = Tripeventtype.list().inject([:]){map, type -> map[type.id]=[descr:type.name,icon:type.icon];map}

    render "${params.jsoncallback}(${hsRes as JSON})"
    return
  }

  

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Monitoring shipper<<<//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Monitoring carrier<<<//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////  
  /////////////////////////////////////////////////////////////////////////////////////////////
  def triplist_carrier = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      return
    }
    
    hsRes.max=Tools.getIntVal(ConfigurationHolder.config.mobile.search.listing.max,5)    	  
    hsRes.paging_set=Tools.getIntVal(ConfigurationHolder.config.mobile.paging_set,5)
    
    def oSearchObj = new Trip()
    hsRes.searchresult = oSearchObj.csiSelectTrip(true,hsRes.client.id,0l,0l,-100,-100,hsRes.max,requestService.getOffset()-1,1)

    hsRes.teminals = Terminal.list().inject([:]){map, terminal -> map[terminal.id]=terminal.name;map}
    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=[shortname:container.shortname,name:container.name];map}
    hsRes.tripstatus = Tripstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.taskstatus = Taskstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}

    hsRes.paging=Paging.computeNavigation(requestService.getOffset(),hsRes.searchresult.count,hsRes.max,hsRes.paging_set)
    
    render "${params.jsoncallback}(${hsRes as JSON})"
    return
  }

  def eventlist_carrier = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)
    hsRes.client = Client.get(hsRes.user.client_id)
    
    if (!hsRes.client) {
      return    
    }
    
    hsRes.max=Tools.getIntVal(ConfigurationHolder.config.mobile.search.listing.max,5)    	  
    hsRes.paging_set=Tools.getIntVal(ConfigurationHolder.config.mobile.paging_set,5)

    def oSearchObj = new TripEventSearchAdmin()
    hsRes.searchresult = oSearchObj.csiSelectTripEvent(0l,0l,hsRes.client.id,
                                      0l,'',-101,-100,'','',hsRes.max,requestService.getOffset()-1,true)
    hsRes.tripeventtype = Tripeventtype.list().inject([:]){map, type -> map[type.id]=[descr:type.name,icon:type.icon];map}
    Trip.findAllByCarrierAndIs_readeventcurrier(hsRes.user.client_id,0).each{it.csiSetReadEvent(1).save()}

    hsRes.paging=Paging.computeNavigation(requestService.getOffset(),hsRes.searchresult.count,hsRes.max,hsRes.paging_set)
    
    render "${params.jsoncallback}(${hsRes as JSON})"
    return
  }

  def tripdetails_carrier = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      return     
    }

    def lId = requestService.getIntDef('id',0)

    hsRes.trip = Trip.findByCarrierAndId(hsRes.client.id,lId)
    if (!hsRes.trip) {      
      return
    }

    hsRes.ztype = Ztype.list()
    hsRes.container = Container.list()
    hsRes.zakaztodriver = Zakaztodriver.get(hsRes.trip.zakaztodriver_id)
    hsRes.tripstatus = Tripstatus.get(hsRes.trip.modstatus)
    def oTriproute = new Triproute()
    hsRes.route = oTriproute.csiSelectRoute(hsRes.trip.id)
    
    if(hsRes.route)
      hsRes.route_end=hsRes.route[hsRes.route.size()-1]
    hsRes.route=[] 
    
    hsRes.taskstatus = Taskstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}

    render "${params.jsoncallback}(${hsRes as JSON})"
    return
  }

  def tripeventlist_carrier = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.trip = Trip.findByCarrierAndId(hsRes.client.id,lId)
    if (!hsRes.client||!hsRes.trip) {
      return      
    }

    hsRes.events = Tripevent.findAllByTrip_id(hsRes.trip.id)
    hsRes.eventtypes = Tripeventtype.list().inject([:]){map, type -> map[type.id]=[descr:type.name,icon:type.icon];map}

    render "${params.jsoncallback}(${hsRes as JSON})"
    return   
  }
  def trackermap = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)

    hsRes.client = Client.get(hsRes.user.client_id)    
    hsRes.cars=Car.findAllWhere(client_id:hsRes.client.id?:0)
    hsRes.tracking=[]
    hsRes.trackingTime=[]   
   
    def i=0    
    def tmp=[:]
    for(oCar in hsRes.cars){    
      tmp=Trackingdata.findByImei(oCar?.imei?:'',[sort: "tracktime", order: "desc"])  
      hsRes.tracking<<tmp  
      
      if(tmp){  
        hsRes.trackingTime<<String.format('%tF %<tT', tmp?.tracktime)
        i++
      }else
        hsRes.trackingTime<<''      
    }
    hsRes.trackers_count=i

    render "${params.jsoncallback}(${hsRes as JSON})"
    return
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Monitoring carrier<<<//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Request shipper>>>//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def requestlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      return
    }   
    
    hsRes.max=Tools.getIntVal(ConfigurationHolder.config.mobile.search.listing.max,5)    	  
    hsRes.paging_set=Tools.getIntVal(ConfigurationHolder.config.mobile.paging_set,5)
    
    def oSearchObj = new DeliverySearch()
    hsRes.searchresult = oSearchObj.csiSelectTrip(false,hsRes.client.id,0l,0l,-100,-100,hsRes.max,requestService.getOffset()-1,2)

    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=[shortname:container.shortname,name:container.name];map}
    hsRes.tripstatus = Tripstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.taskstatus = Taskstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.terminals = Terminal.list().inject([:]){map, terminal -> map[terminal.id]=terminal.name;map}

    hsRes.paging=Paging.computeNavigation(requestService.getOffset(),hsRes.searchresult.count,hsRes.max,hsRes.paging_set)
    
    render "${params.jsoncallback}(${hsRes as JSON})"
    return 
  }
  def requestdetails = {//instructiondetails
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {      
      return
    }

    def lId = requestService.getIntDef('id',0)

    hsRes.trip = Trip.findByShipperAndId(hsRes.client.id,lId)
    hsRes.zakaztodriver = Zakaztodriver.get(hsRes.trip?.zakaztodriver_id)
    if (!hsRes.trip||!hsRes.zakaztodriver) {     
      return
    }    
    hsRes.terminal = Terminal.list()      
    hsRes.terminal_is_slot=Terminal.get(hsRes.trip.taskterminal?:0)?.is_slot    
    hsRes.slot = Slot.findAllByTerminal_idAndModstatus(hsRes.trip.taskterminal,1)
    hsRes.region = Region.findAll('from Region where modstatus = 1 order by regorder desc, name asc')
    hsRes.driver = Driver.get(hsRes.trip.returndriver_id)

    render "${params.jsoncallback}(${hsRes as JSON})"
    return
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Request shipper<<<//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Instruction carrier>>>/////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def instructionlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      return
    }   
    hsRes.max=Tools.getIntVal(ConfigurationHolder.config.mobile.search.listing.max,5)    	  
    hsRes.paging_set=Tools.getIntVal(ConfigurationHolder.config.mobile.paging_set,5)    

    def oSearchObj = new DeliverySearch()
    hsRes.searchresult = oSearchObj.csiSelectTrip(true,hsRes.client.id,0l,0l,-100,-100,hsRes.max,requestService.getOffset()-1,2)

    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=[shortname:container.shortname,name:container.name];map}
    hsRes.tripstatus = Tripstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.taskstatus = Taskstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.terminals = Terminal.list().inject([:]){map, terminal -> map[terminal.id]=terminal.name;map}

    hsRes.paging=Paging.computeNavigation(requestService.getOffset(),hsRes.searchresult.count,hsRes.max,hsRes.paging_set)
    
    render "${params.jsoncallback}(${hsRes as JSON})"
    return 
  }
  def saveTripInstructionDetail = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.trip = Trip.findByCarrierAndId(hsRes.client.id,lId)
    if (!hsRes.client||!hsRes.trip||hsRes.trip?.taskstatus>3||!(hsRes.trip.modstatus in 0..1)) {
      return
    }
    hsRes+=requestService.getParams(['timestartE','timeendE','driveredit','car_id'],['driver_id'],[],['dateE'])
    //hsRes.inrequest.dateE = requestService.getDate('dateE')
    hsRes.inrequest.timestartEstr = requestService.getStr('timestartE')
    hsRes.inrequest.timeendEstr = requestService.getStr('timeendE')
    
    try {      
      if (hsRes.inrequest.dateE)
        hsRes.inrequest.dateE=Date.parse(DATE_FORMAT_MOBILE, hsRes.inrequest?.dateE)
    } catch(Exception e) {
      // if here - no save but error on dateE field in client side
    }
    
    hsRes.inrequest.timeeditE=1

    def result = [:]
    result.errorcode = zakazService.checkDateForTripEdit(hsRes.inrequest,false)

    if (result.errorcode.size()>0) {
      result.error = true
      render "${params.jsoncallback}(${result as JSON})"
      return
    }
    try {
      hsRes.trip.setDeliveryRequestData(hsRes.inrequest).save(failOnError:true)
      if (hsRes.trip.isDirty('taskstatus'))
        zakazService.sendDeliveryRequestForShipper(hsRes.trip)
    } catch(Exception e) {
      log.debug("Error save data in Mobile/saveTripInstructionDetail\n"+e.toString());
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render "${params.jsoncallback}(${result as JSON})"
      return
    } else{
      render "${params.jsoncallback}({error:false})"
      return   
    }  
  }
  def instructiondetails = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {      
      return
    }

    def lId = requestService.getIntDef('id',0)
    hsRes.forward = requestService.getIntDef('forward',0)

    hsRes.trip = Trip.findByCarrierAndId(hsRes.client.id,lId)
    hsRes.zakaztodriver = Zakaztodriver.get(hsRes.trip?.zakaztodriver_id)        
    if (!hsRes.trip||!hsRes.zakaztodriver) {     
      return
    }    

    hsRes.terminal = Terminal.get(hsRes.trip.taskterminal)
    if (hsRes.forward) {
      hsRes.terminal = Terminal.list()    
      hsRes.terminal_is_slot=Terminal.get(hsRes.trip.taskterminal?:0)?.is_slot
      hsRes.slot = Slot.findAllByTerminal_idAndModstatus(hsRes.trip.taskterminal,1)
    }
    hsRes.region = Region.findAll('from Region where modstatus = 1 order by regorder desc, name asc')
    hsRes.driver = Driver.get(hsRes.trip.returndriver_id)
    
    hsRes.drivers = Driver.findAllByClient_idAndModstatus(hsRes.client.id,1)
    hsRes.cars = Cartodriver.findAllByDriver_id(hsRes.trip.returndriver_id).collect{
      Car.findByModstatusAndId(1,it.car_id)
    }-null
    try {
      hsRes.trip.readDelivery().save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Mobile/instructiondetails\n"+e.toString());
    }

    render "${params.jsoncallback}(${hsRes as JSON})"
    return
  }
  
  def saveTripForwardDetail = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes))return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.trip = Trip.findByCarrierAndId(hsRes.client.id,lId)
    if (!hsRes.client||!hsRes.trip||hsRes.trip?.taskstatus>4) {     
      return
    }
   
    hsRes+=requestService.getParams(['terminalh','taskstart','taskend','taskslot','is_mark'],null,['taskaddress','taskprim','stockbooking'],['dateE'])
    try {      
      if (hsRes.inrequest.dateE)
        hsRes.inrequest.dateE=Date.parse(DATE_FORMAT_MOBILE, hsRes.inrequest?.dateE)
    } catch(Exception e) {
      // if here - no save but error on dateE field in client side
    }       

    def result = [:]
    result.errorcode = zakazService.checkDataForTripDelivery(hsRes.inrequest)

    if (result.errorcode.size()>0) {
      result.error = true
      render "${params.jsoncallback}(${result as JSON})"
      return
    }
    try {
      hsRes.trip.setDeliveryData(hsRes.inrequest).csiSetTaskstatus(4).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Mobile/saveTripForwardDetail\n"+e.toString());
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true     
      render "${params.jsoncallback}(${result as JSON})"
      return
    } else{
      render "${params.jsoncallback}({error:false})"
      return
    }
  }
  def saveTripDeliveryDetail = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)){ return }
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.trip = Trip.findByShipperAndId(hsRes.client.id,lId)
    if (!hsRes.client||!hsRes.trip||!(hsRes.trip?.taskstatus in 0..4)||!(hsRes.trip?.modstatus in 0..1)) {    
      return
    }
    hsRes+=requestService.getParams(['terminalh','taskstart','taskend','taskslot','is_mark'],null,['taskaddress','taskprim','stockbooking'],['dateE'])
    //hsRes.inrequest.dateE = requestService.getDate('dateE')
    try {      
      if (hsRes.inrequest.dateE)
        hsRes.inrequest.dateE=Date.parse(DATE_FORMAT_MOBILE, hsRes.inrequest?.dateE)
    } catch(Exception e) {
      // if here - no save but error on dateE field in client side
    }

    def result = [:]
    result.errorcode = zakazService.checkDataForTripDelivery(hsRes.inrequest,false)

    if (result.errorcode.size()>0) {
      result.error = true
      render "${params.jsoncallback}(${result as JSON})"
      return
    }
    try {
      hsRes.trip.setDeliveryData(hsRes.inrequest).csiSetTaskstatus(2).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Mobile/saveTripForwardDetail\n"+e.toString());
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render "${params.jsoncallback}(${result as JSON})"
      return
    } else{
      render "${params.jsoncallback}({error:false})"
      return
    }
  }
  def deliveryconfirm = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUser(hsRes)){ 
      render "${params.jsoncallback}({error:true})" 
      return
    }
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.trip = Trip.findByCarrierAndId(hsRes.client.id,lId)
    if (!hsRes.client||!hsRes.trip||hsRes.trip?.taskstatus!=2) {      
      return
    }
    try {
      hsRes.trip.csiSetTaskstatus(5).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Mobile/deliveryconfirm\n"+e.toString());
    }
    render "${params.jsoncallback}({error:false})"
    return
  }
  def driversfordelivery={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)){ return; }
    hsRes.user = User.get(hsRes.user.id)
    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {      
      return
    }

    hsRes.driverId = requestService.getLongDef('id',0)

    if(hsRes.driverId>=0){
      hsRes.drivers = Driver.findAllByClient_idAndModstatus(hsRes.client.id,1)
      hsRes.cars = Cartodriver.findAllByDriver_id(hsRes.driverId).collect{
        Car.findByModstatusAndId(1,it.car_id)
      }-null
    }
    render "${params.jsoncallback}(${hsRes as JSON})"
    return
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Instruction carrier<<</////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////// Shipment carrier<<<///////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////
  def shipmentlist = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    hsRes.client = Client.get(hsRes.user.client_id)
    if (!hsRes.client) {
      return
    }
    hsRes.max=Tools.getIntVal(ConfigurationHolder.config.mobile.search.listing.max,5)    	  
    hsRes.paging_set=Tools.getIntVal(ConfigurationHolder.config.mobile.paging_set,5)   
    hsRes+=requestService.getParams(['type'])

    def oSearchObj = new TripSearch()
    hsRes.searchresult = oSearchObj.csiSelectTrip(true,hsRes.client.id,0l,0l,-100,'',hsRes.max,requestService.getOffset(),false,hsRes.inrequest.type?:0)        
    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=[shortname:container.shortname,name:container.name];map}
    hsRes.terminals = Terminal.list().inject([:]){map, terminal -> map[terminal.id]=terminal.name;map}
    
    hsRes.paging=Paging.computeNavigation(requestService.getOffset(),hsRes.searchresult.count,hsRes.max,hsRes.paging_set)
    
    render "${params.jsoncallback}(${hsRes as JSON})"
    return
  }
  def canceltrip = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,false)
    if (!checkUser(hsRes)) return
    hsRes.user = User.get(hsRes.user.id)

    def lId = requestService.getIntDef('id',0)

    hsRes.client = Client.get(hsRes.user.client_id)
    hsRes.trip = Trip.findByCarrierAndId(hsRes.client.id,lId)
    if (!hsRes.client||!hsRes.trip||!(hsRes.trip.modstatus in 0..1)) {      
      return
    }
    try {
      hsRes.trip.csiSetModstatus(-3).save(failOnError:true)
      mailerService.sendAdminNotice('#tripcancel_carrier')
      mailerService.sendManagerNotice(Zakaz.get(hsRes.trip.zakaz_id)?.manager_id?:0,'#tripcancel_carrier')
    } catch(Exception e) {
      log.debug("Error save data in Mobile/canceltrip\n"+e.toString());
    }

    render "${params.jsoncallback}({error:false})"
    return
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////  
  //////////////////////// Shipment carrier<<<///////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
