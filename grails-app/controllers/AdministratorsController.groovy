import grails.converters.*
import org.codehaus.groovy.grails.commons.ConfigurationHolder
import grails.gorm.*
import pl.touk.excel.export.WebXlsxExporter

class AdministratorsController {
  
  def requestService
  def usersService
  def mailerService
  def zakazService
  def imageService
  def searchService
  def billingService

  def static final COOKIENAME = 'admin'
  def beforeInterceptor = [action:this.&checkAdmin,except:['login','index']]
  def static final DATE_FORMAT='dd.MM.yyyy' 
  
  def checkAdmin() {
    if(session?.admin?.id!=null){
      session.admin.notice_count = Zakaz.countByModstatus(0)
      if (session.admin.notice_count==1) session.admin.notice_id = Zakaz.findByModstatus(0)?.id
      session.admin.events_count = Trip.countByIs_readeventadmin(0)
      
      def oTemp_notification=Temp_notification.findWhere(id:1,status:1)
      session.attention_message=oTemp_notification?oTemp_notification.text:null      
    }else{
      redirect(controller:'administrators', action:'index', params:[redir:1], base:(ConfigurationHolder.config.grails.secureServerURL?:ConfigurationHolder.config.grails.serverURL))
      return false;
    }
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def checkAccess(iActionId){
    def bDenied = true
    session.admin.menu.each{
	    if (iActionId==it.id) bDenied = false
	  }
    if (bDenied) {
	    redirect(action:'profile');
	    return
	  }
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def cont_autocomplete={
    requestService.init(this)

    def hsRes = [:]
    hsRes.query = requestService.getStr('query')
    if(hsRes.query?:''){
      hsRes.suggestions = (Zakaztodriver.findAllByContainernumber1Ilike('%'+hsRes.query+'%').collect{it.containernumber1}+Zakaztodriver.findAllByContainernumber2Ilike(hsRes.query+'%').collect{it.containernumber2}).unique().take(10)
    } else {
      hsRes.suggestions = []
    }

    render hsRes as JSON
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def index = {
    if (session?.admin?.id){
      redirect(action:Admingroup.get(session?.admin?.group)?.is_chief?'overview':'profile')
      return
    } else return params
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def login = {
    requestService.init(this)
    def sAdmin=requestService.getStr('login')
    def sPassword=requestService.getStr('password')	
    
    if (sAdmin==''){
      flash.error = 1 // set login
      redirect(controller:'administrators',action:'index')//TODO change action
      return
    }
    def oAdminlog = new Adminlog()
    def blocktime = Tools.getIntVal(ConfigurationHolder.config.admin.blocktime,1800)
    def unsuccess_log_limit = Tools.getIntVal(ConfigurationHolder.config.admin.unsuccess_log_limit,5)
    sPassword=Tools.hidePsw(sPassword)
    def oAdmin=Admin.find('from Admin where login=:login',
                             [login:sAdmin.toLowerCase()])
    if(!oAdmin){
      flash.error=2 // Wrong password or admin does not exists
      redirect(controller:'administrators',action:'index')
      return
    }else if (oAdminlog.csiCountUnsuccessLogs(oAdmin.id, new Date(System.currentTimeMillis()-blocktime*1000))[0]>=unsuccess_log_limit){
      flash.error=3 // Admin blocked
      oAdminlog = new Adminlog(admin_id:oAdmin.id,logtime:new Date(),ip:request.remoteAddr,success:2)
      if (!oAdminlog.save(flush:true)){
        log.debug('error on save Adminlog in Admin:login')
        oAdminlog.errors.each{log.debug(it)}
      }
      redirect(controller:'administrators',action:'index')
      return	
    }else if (oAdmin.password != sPassword) {
      flash.error=2 // Wrong password or admin does not exists
      oAdminlog = new Adminlog(admin_id:oAdmin.id,logtime:new Date(),ip:request.remoteAddr,success:0)
      if (!oAdminlog.save(flush:true)){
        log.debug('error on save Adminlog in Admin:login')
        oAdminlog.errors.each{log.debug(it)}
      }
      redirect(controller:'administrators',action:'index')
      return
    }	

    def oAdminmenu = new Adminmenu()
    session.admin = [id            : oAdmin.id,
                     login         : oAdmin.login,
                     group         : oAdmin.admingroup_id,
                     menu          : oAdminmenu.csiGetMenu(oAdmin.admingroup_id),
                     accesslevel   : oAdmin.accesslevel,
                     is_allvariants: Admingroup.get(oAdmin.admingroup_id)?.is_alwaysallvariants?:0,
                     notice_count  : 0,
                     notice_id     : 0,
                     events_count  : 0
                    ]

    //println(session.admin)
    oAdminlog = new Adminlog(admin_id:oAdmin.id,logtime:new Date(),ip:request.remoteAddr,success:1)
    if (!oAdminlog.save(flush:true)){
      log.debug('error on save Adminlog in Admin:login')
      oAdminlog.errors.each{log.debug(it)}
    }
    redirect(action:Admingroup.get(session.admin.group)?.is_chief?'overview':'profile',params:[ext:1])
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def logout = {
    requestService.init(this)
    session.admin = null

    redirect(controller:'administrators',action: 'index')
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def menu = {
    requestService.init(this)
    def iPage = requestService.getIntDef('menu',1)	
    switch (iPage){	
      case  1: redirect(action:'profile'); return
      case  2: redirect(action:'administration'); return
      case  3: redirect(action:'users'); return
      case  4: redirect(action:'infotext'); return
      case  5: redirect(action:'container'); return
      case  6: redirect(action:'terminal'); return
      case  7: redirect(action:'clients'); return
      case  8: redirect(action:'trackers'); return
      case  9: redirect(action:'zakaz'); return
      case  10: redirect(action:'monitoring'); return
      case  11: redirect(action:'requests'); return
      case  12: redirect(action:'contsearch'); return
      case  13: redirect(action:'reports'); return
      case  14: redirect(action:'guestbook'); return
      case  16: redirect(action:'syscompany'); return
      case  17: redirect(action:'payorders'); return
      case  18: redirect(action:'financial'); return
      case  19: redirect(action:'route'); return

      default: redirect(action:'profile'); return
    }
    return [admin:session.admin,action_id:iPage]
  }
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////Administrator`s profile >>>//////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def profile = {
    requestService.init(this)
    def hsRes = [administrator:Admin.get(session.admin.id),action_id:1]	
    hsRes.admin = session.admin
    def oAdminlog = new Adminlog()
    def lsLogs = oAdminlog.csiGetLogs(hsRes.admin.id)
    if (lsLogs.size()>1){
      hsRes.lastlog = lsLogs[1]
      hsRes.unsuccess_log_amount = oAdminlog.csiCountUnsuccessLogs(hsRes.admin.id, new Date()-7)[0]
      hsRes.unsuccess_limit = Tools.getIntVal(ConfigurationHolder.config.admin.unsuccess_log_showlimit,5)
    }
    hsRes.groupname = Admingroup.get(hsRes.administrator.admingroup_id).name
    //if(requestService.getLongDef('ext',0))
      //hsRes.temp_notification=Temp_notification.findWhere(id:2,status:1)
    return hsRes
  }
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def profilesave = {
    checkAccess(1)
    requestService.init(this)
    def hsRes = requestService.getParams([],[],['name','email','tel'])	
    hsRes.inrequest.id=session.admin.id

    def result=[errorcode:[]]    
    if (hsRes.inrequest.id){      
      if (hsRes.inrequest.tel && !hsRes.inrequest.tel.matches('\\+\\d{11}'))
        result.errorcode << 1
      if (hsRes.inrequest.email && !Tools.checkEmailString(hsRes.inrequest.email))
        result.errorcode << 2 
        
      if(!result.errorcode){
        def oAdmin = Admin.get(hsRes.inrequest.id)             
        oAdmin.name = hsRes.inrequest.name?:''
        oAdmin.email = hsRes.inrequest.email?:'' 
        oAdmin.tel = hsRes.inrequest.tel?:''         
        if (!oAdmin.save(flush:true)){
          log.debug('error on save Admin: Administrators.usersave')
          oAdmin.errors.each{log.debug(it)}
        } 
      }
    }
    if (result.errorcode.size()>0) {
        result.error = true
        render result as JSON
        return
    } else
      render(contentType:"application/json"){[error:false]}       
      return
  }  
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def changepass = {
    requestService.init(this)
    def hsRes = [done:true,message:'Ошибка']
    def sPass = requestService.getStr('pass')
    def lAjax = requestService.getLongDef('ajax',0)
    if (lAjax) checkAccess(2)
    def lId = lAjax?requestService.getLongDef('id',0):session.admin.id

    if(sPass.size()<Tools.getIntVal(ConfigurationHolder.config.user.passwordlength,5)){
      flash.error=3	
      hsRes = [done: false,message:message(code:'admin.passw.min.length.error', default:'')+' '+Tools.getIntVal(ConfigurationHolder.config.user.passwordlength,5)]	  
    }else if (lId>1){
      if (sPass==requestService.getStr('confirm_pass')){
        def oAdmin = new Admin()
        oAdmin.changePass(lId,Tools.hidePsw(sPass))
        hsRes.message = message(code:'passw.done', default:'')
        flash.error=0
      } else {
        hsRes = [done: false,message:message(code:'admin.passwordequal.error', default:'')]        
        flash.error=2
      }
    }
    if (lAjax){
      render hsRes as JSON
      return
    }
    redirect(action:'profile')
  }
 ///////////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////User administration >>>////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def administration = {
    checkAccess(2)
    requestService.init(this)
    def hsRes = [inrequest:[part:requestService.getLongDef('part',0)],action_id:2]
    if (hsRes.inrequest.part){
      hsRes += [groupusers:Admin.findAll('from Admin')]
    } else {
      hsRes += [groupusers:Admingroup.findAll('from Admingroup')]
    }
    hsRes.admin = session.admin
    return hsRes
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def groupuserlist = {
    checkAccess(2)
    requestService.init(this)
    def hsRes = [inrequest:[part:requestService.getLongDef('id',0)]]
    if (hsRes.inrequest.part){
      hsRes += [groupusers:Admin.findAll('from Admin where id<>1')]
    }else{
      hsRes += [groupusers:Admingroup.findAll('from Admingroup')]
    }
    return hsRes
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def groupuserdetails = {
    checkAccess(2)
    requestService.init(this)
    def hsRes = [inrequest:[id   :requestService.getLongDef('id',0),
                            part :requestService.getLongDef('part',0)]]

    if (hsRes.inrequest.part){
	  hsRes += [groups:Admingroup.findAll('from Admingroup')]
      if (hsRes.inrequest.id&&hsRes.inrequest.id != 1){        
        hsRes += [user:Admin.get(hsRes.inrequest.id)]        
      }
    }else{
      hsRes += [group:Admingroup.get(hsRes.inrequest.id)]
    }
    return hsRes
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def groupsave = {
    checkAccess(2)
    requestService.init(this)
    def hParams = requestService.getParams(['id','is_profile','is_users','is_infotext','is_container','is_terminal',
                                            'is_clients','is_tracker','is_zakaz','is_monitoring','is_requests',
                                            'is_contsearch','is_reports','is_guestbook','is_autopilot','is_syscompany',
                                            'is_payorders','is_financial','is_chief','is_route'])
    if (hParams.inrequest.id>0){
      def oAdmingroup = Admingroup.get(hParams.inrequest.id)
      try {
        def sMenu = '1,'
        oAdmingroup.is_profile = 1
        
        if (hParams.inrequest.is_users)      {oAdmingroup.is_users=1;    sMenu += '3,'}
        else oAdmingroup.is_users=0
        if (hParams.inrequest.is_infotext)   {oAdmingroup.is_infotext=1; sMenu += '4,'}
        else oAdmingroup.is_infotext=0
        if (hParams.inrequest.is_container)   {oAdmingroup.is_container=1; sMenu += '5,'}
        else oAdmingroup.is_container=0
        if (hParams.inrequest.is_terminal)   {oAdmingroup.is_terminal=1; sMenu += '6,'}
        else oAdmingroup.is_terminal=0
        if (hParams.inrequest.is_clients)   {oAdmingroup.is_clients=1; sMenu += '7,'}
        else oAdmingroup.is_clients=0
        if (hParams.inrequest.is_tracker)   {oAdmingroup.is_tracker=1; sMenu += '8,'}
        else oAdmingroup.is_tracker=0
        if (hParams.inrequest.is_zakaz)   {oAdmingroup.is_zakaz=1; sMenu += '9,'}
        else oAdmingroup.is_zakaz=0
        if (hParams.inrequest.is_monitoring)   {oAdmingroup.is_monitoring=1; sMenu += '10,'}
        else oAdmingroup.is_monitoring=0
        if (hParams.inrequest.is_requests)   {oAdmingroup.is_requests=1; sMenu += '11,'}
        else oAdmingroup.is_requests=0
        if (hParams.inrequest.is_contsearch)   {oAdmingroup.is_contsearch=1; sMenu += '12,'}
        else oAdmingroup.is_contsearch=0
        if (hParams.inrequest.is_reports)   {oAdmingroup.is_reports=1; sMenu += '13,'}
        else oAdmingroup.is_reports=0
        if (hParams.inrequest.is_guestbook)   {oAdmingroup.is_guestbook=1; sMenu += '14,'}
        else oAdmingroup.is_guestbook=0
        if (hParams.inrequest.is_autopilot)   {oAdmingroup.is_autopilot=1; sMenu += '15,'}
        else oAdmingroup.is_autopilot=0
        if (hParams.inrequest.is_syscompany)   {oAdmingroup.is_syscompany=1; sMenu += '16,'}
        else oAdmingroup.is_syscompany=0
        if (hParams.inrequest.is_payorders)   {oAdmingroup.is_payorders=1; sMenu += '17,'}
        else oAdmingroup.is_payorders=0
        if (hParams.inrequest.is_financial)   {oAdmingroup.is_financial=1; sMenu += '18,'}
        else oAdmingroup.is_financial=0
        if (hParams.inrequest.is_route)   {oAdmingroup.is_route=1; sMenu += '19,'}
        else oAdmingroup.is_route=0
        if (hParams.inrequest.is_chief)   {oAdmingroup.is_chief=1}
        else oAdmingroup.is_chief=0

        if (oAdmingroup.is_superuser)        sMenu+='2,'

        oAdmingroup.menu = sMenu

        if (!oAdmingroup.save(flush:true)){
          log.debug('error on save Admingroup: Administrators.groupsave')
          oAdmingroup.errors.each{log.debug(it)}
        }
      } catch(Exception e){
        log.debug('error in Administrators.groupsave')
        log.debug(e.toString())
      }
      def hsRes = [id:hParams.inrequest.id]
      hsRes['part'] = 0

      redirect(action:'groupuserdetails',params:hsRes)
      return
    }

    render(contentType:"application/json"){[error:true]}
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def usersave = {
    checkAccess(2)
    requestService.init(this)
    def hParams = requestService.getParams(['group','id','is_manager'],[],['login','name','email','tel'])    
    def result=[errorcode:[]] 
    if (hParams.inrequest.id>1){             
      if (hParams.inrequest.tel && !hParams.inrequest.tel.matches('\\+\\d{11}'))
        result.errorcode << 1
      if (hParams.inrequest.email && !Tools.checkEmailString(hParams.inrequest.email))
        result.errorcode << 2         
      if(!result.errorcode){   
        def oAdmin = Admin.get(hParams.inrequest.id)
        try{
          oAdmin.admingroup_id = hParams.inrequest.group?:0        
          oAdmin.login = hParams.inrequest.login?:''
          oAdmin.name = hParams.inrequest.name?:''
          oAdmin.email = hParams.inrequest.email?:''
          oAdmin.password = oAdmin.password?:''
          oAdmin.tel = hParams.inrequest.tel?:''
          oAdmin.is_manager = hParams.inrequest.is_manager?:0
          if (!oAdmin.save(flush:true)){
            log.debug('error on save Admin: Administrators.usersave')
            oAdmin.errors.each{log.debug(it)}
          }        
        }catch(Exception e){
          log.debug('error in Administrators.usersave')
          log.debug(e.toString())
        }      
      }  
    }
   
    render result as JSON
    return
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def creategroup = {
    checkAccess(2)
    requestService.init(this)
    def hsRes = [done:true, message:'Ошибка']
    def sName = requestService.getStr('name')
    if (sName) {
      def lsAdmingroups = Admingroup.findAllWhere(name:sName)
      if (!lsAdmingroups){
         def oAdmingroup = new Admingroup(name:sName,menu:'',is_profile:0,is_groupmanage:0,is_users:0,is_superuser:0,
                                          is_infotext:0,is_container:0,is_terminal:0,is_clients:0,is_tracker:0,is_zakaz:0,
                                          is_monitoring:0,is_requests:0,is_contsearch:0,is_reports:0,is_guestbook:0,
                                          is_autopilot:0,is_payorders:0,is_syscompany:0,is_financial:0,is_chief:0,is_route:0)
        if (!oAdmingroup.save(flush:true)){
          log.debug('Error on create Admingroup: Administrators.creategroup')
          oAdmingroup.errors.each{log.debug(it)}
          hsRes = [done:true,message:message(code:'admin.group.add.error', default:'')]
        }else{
          hsRes = [done:true]
		      hsRes.id=oAdmingroup.id
        }
      }else{
        hsRes = [done:false,message:message(code:'admin.group.add.alreadyexists.error', default:'')]
      }
    }else{
      hsRes = [done:false,message:message(code:'admin.group.add.entername.error', default:'')]
    }
    render hsRes as JSON
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def createuser = {
    checkAccess(2)
    requestService.init(this)
    def hsRes = [done:true, message:message(code:'error', default:'')]
    def sLogin = requestService.getStr('login')
    def sPass = requestService.getStr('pass')
    if (sLogin) {
      def lsAdmin = Admin.findAllWhere(login:sLogin)
      if (!lsAdmin){
        if(sPass.size()<Tools.getIntVal(ConfigurationHolder.config.user.passwordlength,5)){
         	
          hsRes = [done: false,message:message(code:'admin.passw.min.length.error', default:'')+' '+Tools.getIntVal(ConfigurationHolder.config.user.passwordlength,5)]	  
        }else if (sPass==requestService.getStr('confirm_pass')){
          def oAdmin = new Admin(login:sLogin,password:Tools.hidePsw(sPass),
                                 email:'',name:'',admingroup_id:0,accesslevel:0,tel:'',is_manager:0)
          if (!oAdmin.save(flush:true)){
            log.debug('Error on create Admin: Administrators.createuser')
            oAdmin.errors.each{log.debug(it)}
            hsRes = [done:true,message:message(code:'admin.adduser.error', default:'')]			
          }else{
            hsRes = [done:true]
			      hsRes.id=oAdmin.id
          }
        }else{
          hsRes = [done:false, message:message(code:'admin.passwordequal.error', default:'')]
        }
      }else{
        hsRes = [done:false,message:message(code:'admin.user.alreadyexists.error', default:'')]
      }
    }else{
      hsRes = [done:false, message:message(code:'admin.enter.user.login', default:'')]
    }
    render hsRes as JSON
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def deleteuser = {
    checkAccess(2)
    requestService.init(this)
    def hsRes = [done:false, message:'Ошибка']
    def lId = requestService.getLongDef('id',0)
    if (lId>1){
      if (lId == session.admin.id)
        hsRes.message = message(code:'admin.user.not.delete.error', default:'')
      else{
        def oAdmin = Admin.get(lId)
		    if(oAdmin){
          oAdmin.delete()
          hsRes.done = true
		    }
      }
    }
    render hsRes as JSON
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def deletegroup = {
    checkAccess(2)
    requestService.init(this)
    def lId = requestService.getLongDef('id',0)
    if (lId>0){
      def oAdmingroup = Admingroup.get(lId)
      oAdmingroup.delete()
    }

    render(contentType:"application/json"){[ok:true]}
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////User administration <<<////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////  
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Administrator`s profile <<<///////////////////////////////////////////////////////// 
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Users >>>///////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def users = {
    checkAccess(3)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=3
    hsRes.admin = session.admin

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def userlist = {    
    checkAccess(3)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)  	
    hsRes.action_id=3
    hsRes.admin = session.admin
    def oUser=new User()	
    hsRes+=requestService.getParams(['type_id'],['user_id','client_id'],['email','nickname','company','name'])
    hsRes.inrequest.modstatus = requestService.getIntDef('modstatus',0)

    hsRes.users = oUser.csiSelectUsers(hsRes.inrequest.name?:'',hsRes.inrequest.nickname?:'',hsRes.inrequest.company?:'',
                                hsRes.inrequest.email?:'',hsRes.inrequest.modstatus,hsRes.inrequest.user_id?:0l,
                                hsRes.inrequest.client_id?:0l,hsRes.inrequest.type_id?:0,20,requestService.getOffset())
    return hsRes
  }

  def loginAsUser={
    checkAccess(3)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)    
    hsRes.action_id=3
    hsRes.admin = session.admin
    
    def lId=requestService.getLongDef('id',0)
    def oUser = User.get(lId)
    if (oUser) {
      usersService.loginInternalUser(oUser.name, '', requestService, 0, oUser.id)
      render(contentType:"application/json"){[error:false]}
      return
    }
    render(contentType:"application/json"){[error:true]}
    return
  }

  def banned={
    requestService.init(this)
    def lId=requestService.getLongDef('id',0)
    def iBanned=requestService.getLongDef('banned',0)

    if(lId>0){
      def oUser=User.get(lId)
      oUser.modstatus=iBanned

      if(!oUser.save(flush:true)) {
        log.debug(" Error on save User:")
        oUser.errors.each{log.debug(it)}
      }
    }

    render(contentType:"application/json"){[error:false]}
  }

  def confirmTel={
    requestService.init(this)
    def lId=requestService.getLongDef('id',0)

    if(lId>0){
      try {
        User.get(lId)?.confirmTel()?.save(failOnError:true)
        render(contentType:"application/json"){[error:false]}
        return
      } catch(Exception e) {
        log.debug("Error save data in Admin/confirmTel \n"+e.toString());
      }
    }
    response.sendError(400)
    return
  }

  def userdetail={
    checkAccess(3)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=3
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('id',0)

    hsRes.user = User.get(lId)
    if (!hsRes.user&&lId) {
      response.sendError(404)
      return
    }

    return hsRes
  }

  def saveUserDetails={
    checkAccess(3)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=3
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('id',0)
    hsRes+=requestService.getParams(['type_id','is_am','is_confirm','is_changepass'],null,
                                    ['nickname','company','name','tel','tel1','description','fullname','email','password1','password2'])
    hsRes.inrequest.client_id = requestService.getLongDef('client_id',0)

    hsRes.user = User.get(lId)
    if (!hsRes.user&&lId) {
      response.sendError(404)
      return
    }

    def result = [:]
    result.errorcode = []
    if (!hsRes.inrequest.name)
      result.errorcode << 1
    if (!hsRes.inrequest.nickname)
      result.errorcode << 2
    if (!(hsRes.inrequest.client_id||hsRes.inrequest.fullname))
      result.errorcode << 3
    if(!lId||hsRes.inrequest.is_changepass){
      if((hsRes.inrequest?.password1?:'')!=(hsRes.inrequest?.password2?:''))
        result.errorcode << 4
      else if((hsRes.inrequest?.password2?:'').size()<Tools.getIntVal(ConfigurationHolder.config.user.passwordlength?:6))
        result.errorcode << 5
      else if(!(hsRes.inrequest?.password2?:'').matches('.*(?=.*[0-9])(?=.*[A-Za-z])(?!.*[\\W_А-я]).*'))
        result.errorcode << 6
    }
    if (hsRes.inrequest.tel&&!hsRes.inrequest.tel.matches('\\+\\d{11}'))
      result.errorcode << 9
    if(!lId){
      if (hsRes.inrequest.email) {
        if (!Tools.checkEmailString(hsRes.inrequest.email))
          result.errorcode << 7
        if (User.findByEmail(hsRes.inrequest.email))
          result.errorcode << 8
      }
      if(result.errorcode.size()==0){
        hsRes.user = User.get(new User().csiInsertInternal([name:hsRes.inrequest.name,email:hsRes.inrequest.email?:'',password:Tools.hidePsw(hsRes.inrequest.password2),nickname:hsRes.inrequest.nickname]))
        if (!hsRes.user) {
          result.errorcode << 100
        }
      }
    }
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      if (hsRes.inrequest.is_confirm) {
        hsRes.user.setModerateData(hsRes.inrequest,Client.findOrCreate(hsRes.inrequest,hsRes.user)).confirmUser().save(failOnError:true)
      } else {
        hsRes.user.setModerateData(hsRes.inrequest,Client.findOrCreate(hsRes.inrequest,hsRes.user)).save(failOnError:true)
      }
      if(!lId){
        //send mail after user create
        mailerService.sendNewUserMailAsync(hsRes.user,hsRes.inrequest.password2)
      }
    } catch(grails.validation.ValidationException e) {
      log.debug("Validation Error in Admin/saveUserDetails\n"+e.toString())
      if(!lId){
        User.withNewSession{
          hsRes.user.delete(flush:true)
        }
      }
      result.error = true
      result.errorcode << 101
    } catch(Exception e) {
      log.debug("Error save data in Admin/saveUserDetails\n"+e.toString())
      result.error = true
      result.errorcode << 100
    }
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false,uId:hsRes.user.id]}
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Users <<<///////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////////////////////// 
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Infotext >>>////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def infotext = {    
    checkAccess(4)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.itemplate=Itemplate.findAll('FROM Itemplate ORDER BY name')  	
    hsRes.action_id=4
    hsRes.admin = session.admin	

    def fromEdit = requestService.getIntDef('fromEdit',0)
    hsRes.type = requestService.getIntDef('type',0)
    if (fromEdit){
      session.lastRequest.fromEdit = fromEdit
      hsRes.inrequest = session.lastRequest
    }
    return hsRes
  }

  def infotextlist = {
    checkAccess(4)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)  	
    hsRes.action_id=4
    hsRes.admin = session.admin
    def oInfotext=new Infotext()

    if (session.lastRequest?.fromEdit?:0){
      hsRes.inrequest = session.lastRequest
      session.lastRequest.fromEdit = 0
    } else {
      hsRes+=requestService.getParams(['id'],[],['inf_action','inf_controller'])
      hsRes.inrequest.itemplate_id = requestService.getIntDef('itemplate_id',-1)
      session.lastRequest = [:]
      session.lastRequest = hsRes.inrequest
    }

    if (!hsRes.inrequest.id){
      hsRes+=oInfotext.csiSelectInfotext(hsRes.inrequest.inf_action?:'',hsRes.inrequest.inf_controller?:'',(hsRes.inrequest.itemplate_id!=null)?hsRes.inrequest.itemplate_id:-1,requestService.getLongDef('order',0),20,requestService.getOffset())
      hsRes.itemplate=Itemplate.findAll('FROM Itemplate ORDER BY name')
    } else {
      hsRes+=oInfotext.csiSelectMailtemplate(hsRes.inrequest.inf_action?:'',20,requestService.getOffset())
    }
    return hsRes
  }

  def infotextedit = {
    checkAccess(4)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)  	
    hsRes.action_id=4
    hsRes.admin = session.admin
    def lId=requestService.getLongDef('id',0)
    def lType=requestService.getLongDef('type',0)
    if (!lType)
      hsRes.infotext = Infotext.get(lId)
    else
      hsRes.emailTemplate = Email_template.get(lId)
    if(hsRes.infotext){
      def bSave=requestService.getLongDef('save',0)
      if(!bSave)
        hsRes.inrequest=hsRes.infotext
      else {
        flash.save_error=[]
        hsRes+=requestService.getParams([],[],['title','keywords','description','promotext1','promotext2','itext','itext2','itext3','header'])
        hsRes.infotext.title = hsRes.inrequest.title?:''
        hsRes.infotext.keywords = hsRes.inrequest.keywords?:''
        hsRes.infotext.description = hsRes.inrequest.description?:''
        hsRes.infotext.header = hsRes.inrequest.header?:''
        hsRes.infotext.promotext1 = hsRes.inrequest.promotext1?:''
        hsRes.infotext.promotext2 = hsRes.inrequest.promotext2?:''
        hsRes.infotext.itext = hsRes.inrequest.itext?:''
        hsRes.infotext.itext2 = hsRes.inrequest.itext2?:''
        hsRes.infotext.itext3 = hsRes.inrequest.itext3?:''
        hsRes.infotext.moddate = new Date()
        if(!hsRes.infotext.save(flush:true)) {
          log.debug(" Error on save infotext:")
          hsRes.infotext.errors.each{log.debug(it)}
          flash.save_error<<101
        }
        hsRes.inrequest=hsRes.infotext
      }
    } else if (hsRes.emailTemplate){
      def bSave=requestService.getLongDef('save',0)
      if(!bSave)
        hsRes.inrequest=hsRes.emailTemplate.properties
      else {
        flash.save_error=[]
        hsRes+=requestService.getParams([],[],['title','itext','name'])
        hsRes.emailTemplate.title = hsRes.inrequest.title?:''
        hsRes.emailTemplate.itext = hsRes.inrequest.itext?:''
        hsRes.emailTemplate.name = hsRes.inrequest.name?:''
        if(!hsRes.emailTemplate.save(flush:true)) {
          log.debug(" Error on save emailTemplate:")
          hsRes.emailTemplate.errors.each{log.debug(it)}
          flash.save_error<<101
        }
        hsRes.inrequest=hsRes.emailTemplate.properties
      }
    } else {
      redirect(action:'index')
      return
    }
    hsRes.type=lType
    return hsRes
  }
 
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////// Infotext Add //////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////  
  def infotextadd = {    
    checkAccess(4)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false) 
    hsRes.action_id=4
    hsRes.admin = session.admin  
    hsRes+=requestService.getParams(['itemplate_id','npage','type'],[],['tcontroller','taction','name'])
    hsRes.itemplate=Itemplate.findAll('FROM Itemplate ORDER BY name')   

    return hsRes
  }
  
  def saveinfotext={    
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    hsRes+=requestService.getParams(['itemplate_id','npage','type'],[],['tcontroller','taction','name'])
    
    flash.error=[]
    
    if((!hsRes.inrequest?.tcontroller && !hsRes.inrequest?.type)|| !hsRes.inrequest?.taction || !hsRes.inrequest?.name){ 
    
      if(!hsRes.inrequest?.tcontroller && !hsRes.inrequest?.type)
        flash.error<<1
      if(!hsRes.inrequest?.taction)
        flash.error<<2      
      if(!hsRes.inrequest?.name)  
        flash.error<<3
        
      redirect(action:'infotextadd',params:hsRes.inrequest)
      return
    }
    def iId
    if(!hsRes.inrequest?.type) {
      def oInfotext = new Infotext()
      oInfotext.itemplate_id = hsRes.inrequest?.itemplate_id?:0
      oInfotext.controller = hsRes.inrequest?.tcontroller
      oInfotext.action = hsRes.inrequest?.taction    
      oInfotext.npage = hsRes.inrequest?.npage?:0
      oInfotext.icon = ''
      oInfotext.shortname = ''
      oInfotext.name = hsRes.inrequest?.name
      oInfotext.header = ''
      oInfotext.title = hsRes.inrequest?.name
      oInfotext.keywords = ''
      oInfotext.description = ''
      oInfotext.itext = ''
      oInfotext.itext2 = ''
      oInfotext.itext3 = ''
      oInfotext.promotext1 = ''
      oInfotext.promotext2 = ''
      oInfotext.moddate = new Date()
    
      if(!oInfotext.save(flush:true)) {
        log.debug(" Error on save Infotext:")
        oInfotext.errors.each{log.debug(it)}
      }
      iId = oInfotext.id
    } else {
      def oEmailTemplate = new Email_template()
      oEmailTemplate.action = hsRes.inrequest?.taction
      oEmailTemplate.name = hsRes.inrequest?.name
      oEmailTemplate.title = hsRes.inrequest?.name
      oEmailTemplate.itext = ''
    
      if(!oEmailTemplate.save(flush:true)) {
        log.debug(" Error on save Email_template:")
        oEmailTemplate.errors.each{log.debug(it)}
      }
      iId = oEmailTemplate.id
    }
	
    redirect(action:'infotextedit',id:iId, params: [type:hsRes.inrequest?.type?:0])
    return
  }    
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Infotext <<<////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Containers >>>//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def container = {
    checkAccess(5)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=5
    hsRes.admin = session.admin

    hsRes.ctype = Ctype.list()
    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def containerlist = {    
    checkAccess(5)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)    
    hsRes.action_id=5
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(['ctype_id','is_main'],null,['name'])

    def oCont=new Container()
    hsRes.containers = oCont.csiSelectContainer(hsRes.inrequest.name?:'',hsRes.inrequest.ctype_id?:0,hsRes.inrequest.is_main?:0,20,requestService.getOffset())
    hsRes.ctype = Ctype.list()

    return hsRes
  }

  def containerdetail={
    checkAccess(5)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=5
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)

    hsRes.container = Container.get(lId)
    if (!hsRes.container&&lId) {
      response.sendError(404)
      return
    }
    hsRes.ctype = Ctype.list()

    return hsRes
  }

  def saveContainerDetail={
    checkAccess(5)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=5
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)
    hsRes+=requestService.getParams(['ctype_id','capacity','is_main'],null,['name','shortname','length','width','hight','volume','picture','name2'])

    hsRes.container = Container.get(lId)
    if (!hsRes.container&&lId) {
      response.sendError(404)
      return
    }

    def result = [:]
    result.errorcode = []
    if (!hsRes.inrequest.name)
      result.errorcode << 1
    if (!hsRes.inrequest.shortname)
      result.errorcode << 2
    if (!(hsRes.inrequest.length?:'0').replace(',','.').isFloat())
      result.errorcode << 3
    if (!(hsRes.inrequest.width?:'0').replace(',','.').isFloat())
      result.errorcode << 4
    if (!(hsRes.inrequest.hight?:'0').replace(',','.').isFloat())
      result.errorcode << 5
    if (!(hsRes.inrequest.volume?:'0').replace(',','.').isFloat())
      result.errorcode << 6

    if(!lId&&result.errorcode.size()==0){
      hsRes.container = new Container([name:hsRes.inrequest.name,shortname:hsRes.inrequest.shortname])
      if (!hsRes.container) {
        result.errorcode << 100
      }
    }
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      hsRes.container.setData(hsRes.inrequest).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/saveContainerDetail\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }
    
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false,uId:hsRes.container.id]}
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Containers <<<//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Terminals >>>///////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def terminal = {
    checkAccess(6)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 6
    hsRes.admin = session.admin

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def terminallist = {
    checkAccess(6)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 6
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(['terminal_id','is_main'],null,['name'])

    def oSearchObj = new Terminal()
    hsRes.searchresult = oSearchObj.csiSelectTerminal(hsRes.inrequest.name?:'',hsRes.inrequest.terminal_id?:0,hsRes.inrequest.is_main?:0,20,requestService.getOffset())

    return hsRes
  }

  def terminaldetail={
    checkAccess(6)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=6
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)

    hsRes.terminal = Terminal.get(lId)
    if (!hsRes.terminal&&lId) {
      response.sendError(404)
      return
    }

    return hsRes
  }

  def saveTerminalDetail={
    checkAccess(6)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 6
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)
    hsRes+=requestService.getParams(['modstatus','x','y','is_main'],null,['name','infourl','address'])

    hsRes.terminal = Terminal.get(lId)
    if (!hsRes.terminal&&lId) {
      response.sendError(404)
      return
    }

    def result = [:]
    result.errorcode = []
    if (!hsRes.inrequest.name)
      result.errorcode << 1

    if(!lId&&result.errorcode.size()==0){
      hsRes.terminal = new Terminal([name:hsRes.inrequest.name])
      if (!hsRes.terminal) {
        result.errorcode << 100
      }
    }
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      hsRes.terminal.setData(hsRes.inrequest).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/saveTerminalDetail\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }
    
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false,uId:hsRes.terminal.id]}
  }

  def slotlist = {
    checkAccess(6)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 6
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)

    hsRes.slots = Slot.findAllByTerminal_id(lId)

    return hsRes
  }

  def saveSlotDetail={
    checkAccess(6)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 6
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('slot_id',0)
    hsRes+=requestService.getParams(['terminal_id','slot_modstatus'],null,['slot_name','slot_start','slot_end'])

    hsRes.slot = Slot.get(lId)
    if (!hsRes.slot&&lId) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    def result = [:]
    result.errorcode = []
    if (!hsRes.inrequest.slot_name)
      result.errorcode << 1
    if (!hsRes.inrequest.terminal_id)
      result.errorcode << 2
    if(hsRes.inrequest.slot_start&&hsRes.inrequest.slot_end){
      hsRes.inrequest.slot_start = hsRes.inrequest.slot_start.replace('-',':').replace('.',':').replace(',',':').replace(' ',':')
      hsRes.inrequest.slot_end = hsRes.inrequest.slot_end.replace('-',':').replace('.',':').replace(',',':').replace(' ',':')
      if (!hsRes.inrequest.slot_start.matches('([01]?[0-9]|2[0-3]):[0-5][0-9]'))
        result.errorcode << 3
      if (!hsRes.inrequest.slot_end.matches('([01]?[0-9]|2[0-3]):[0-5][0-9]'))
        result.errorcode << 4
    }

    if(!lId&&result.errorcode.size()==0){
      hsRes.slot = new Slot([name:hsRes.inrequest.slot_name,terminal_id:hsRes.inrequest.terminal_id])
      if (!hsRes.slot) {
        result.errorcode << 100
      }
    }
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      hsRes.slot.setData(hsRes.inrequest).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/saveSlotDetail\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }
    
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false,uId:hsRes.slot.id]}
  }

  def deleteSlot={
    requestService.init(this)
    def lId=requestService.getIntDef('id',0)
    def iTerminal_id=requestService.getIntDef('terminal_id',0)

    if(lId>0){
      Slot.findByIdAndTerminal_id(lId,iTerminal_id)?.delete(flush:true)
    }

    render(contentType:"application/json"){[error:false]}
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Terminals <<<///////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////////////////////// 
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Clients >>>/////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def clients = {
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def clientlist = {
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(['type_id','modstatus','isblocked'],['client_id'],['name','fullname','tel'])

    hsRes.searchresult = new ClientSearch().csiSelectClient(hsRes.inrequest.name?:'',hsRes.inrequest.fullname?:'',hsRes.inrequest.tel?:'',
                                                    hsRes.inrequest.client_id?:0l,hsRes.inrequest.type_id?:0,
                                                    hsRes.inrequest.modstatus?:0,hsRes.inrequest.isblocked?:0,20,requestService.getOffset())

    return hsRes
  }

  def unblockclient={
    requestService.init(this)
    def lId=requestService.getLongDef('id',0)

    if(lId>0){
      Client.get(lId)?.csiSetIsBlocked(0)?.save(flush:true)
    }

    render(contentType:"application/json"){[error:false]}
  }

  def clientdetail={
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)

    hsRes.client = Client.get(lId)
    if (!hsRes.client&&lId) {
      response.sendError(404)
      return
    }  

    hsRes.managers=Admin.findAllByIs_manager(1)    

    return hsRes
  }

  def saveMainClientDetail={
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)
    hsRes+=requestService.getParams(['type_id','is_confirm'],['admin_id'],['name','fullname','comment'])

    hsRes.client = Client.get(lId)
    if (!hsRes.client&&lId) {
      response.sendError(404)
      return
    }

    def result = [:]
    result.errorcode = []
    if (!(hsRes.inrequest.name||lId))
      result.errorcode << 1
    if (!hsRes.inrequest.fullname)
      result.errorcode << 2

    if(!lId&&result.errorcode.size()==0){
      hsRes.client = new Client([name:hsRes.inrequest.name,fullname:hsRes.inrequest.fullname])
      if (!hsRes.client) {
        result.errorcode << 100
      }
    }
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }

    try {
      hsRes.client.setMainData(hsRes.inrequest).csiSetModstatus(hsRes.inrequest.is_confirm?:0).save(failOnError:true)
    } catch(grails.validation.ValidationException e) {
      log.debug("Validation Error in Admin/saveMainClientDetail\n"+e.toString())
      result.error = true
      result.errorcode << 101
    } catch(Exception e) {
      log.debug("Error save data in Admin/saveMainClientDetail\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }
    
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false,uId:hsRes.client.id]}
  }    

  def dogupload={
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId = requestService.getLongDef('id',0)
    hsRes.client = Client.get(lId)
    if (!hsRes.client) {
      response.sendError(404)
      render(contentType:"application/json"){[error:true]}
      return
    }
    imageService.init(this,'somepath')
    def hsData = imageService.rawUpload('file') // 3

    if (!hsData.error) {
      try {
        hsRes.client.updatedocpages(hsData.fileid).save(failOnError:true,flush:true)
      } catch(Exception e) {
        response.sendError(409)
        log.debug('Administrators:dogupload. Error on save client:'+hsRes.client.id+'\n'+e.toString())
      }
    } else
      response.sendError(409)

    render ''
    return
  }

  def displaydogovor={
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId = requestService.getLongDef('id',0)
    hsRes.client = Client.get(lId)
    if (!hsRes.client||!hsRes.client?.docpages) {
      response.sendError(404)
      return
    }

    def lsPictures = Picture.getAll(hsRes.client.docpages.split(',').collect{it as Long})
    if (lsPictures.find{it.mimetype == 'image/jpeg'}) {
      renderPdf(template: 'dogovorpdf', model: [pictures:lsPictures], filename: "dogovor.pdf")
    } else {
      response.contentType = 'application/pdf'
      response.outputStream << lsPictures.head().filedata
      response.flushBuffer()
    }
    return
  }

  def clientrequisites = {
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)

    hsRes.requisites = Clientrequisites.findAllByClient_id(lId)
    hsRes.client = Client.get(lId)

    return hsRes
  }

  def requisitesdetail = {
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('requisites_id',0)

    hsRes.requisites = Clientrequisites.get(lId)
    hsRes.syscompanies = Syscompany.findAllByModstatus(1)
    hsRes.syscompany = Syscompany.get(hsRes.requisites?.syscompany_id)
    hsRes.defaultpayterm = Tools.getIntVal(ConfigurationHolder.config.payterm.default.days,7)

    return hsRes
  }

  def saveClientRequisites={
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('requisites_id',0)
    hsRes+=requestService.getParams(['nds','ctype_id','syscompany_id','shortbenefit','longbenefit','payterm'],['client_id'],['payee','inn','kpp','bankname','bik','corraccount','settlaccount','ogrn','license','address','nagr'],['agrdate'])

    hsRes.requisites = Clientrequisites.get(lId)
    if (!hsRes.requisites&&lId) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    def result = [:]
    result.errorcode = []
    if (Client.get(hsRes.inrequest.client_id)?.type_id==1&&!hsRes.inrequest.payee)
      result.errorcode << 1
    if (!hsRes.inrequest.client_id)
      result.errorcode << 2
    if(hsRes.inrequest.inn&&!hsRes.inrequest.inn.matches('\\d{10}|\\d{12}'))
      result.errorcode << 3
    if(hsRes.inrequest.kpp&&!hsRes.inrequest.kpp.matches('\\d{9}'))
      result.errorcode << 4
    if(hsRes.inrequest.bik&&!hsRes.inrequest?.bik?.matches('04\\d{7}'))
      result.errorcode << 5
    if(hsRes.inrequest.corraccount&&!hsRes.inrequest.corraccount.matches('\\d{20,25}'))
      result.errorcode << 6
    if(hsRes.inrequest.settlaccount&&!hsRes.inrequest.settlaccount.matches('\\d{20,25}'))
      result.errorcode << 7
    if (Client.get(hsRes.inrequest.client_id)?.type_id==1&&!hsRes.inrequest.inn)
      result.errorcode << 8
//contract>>
    if (hsRes.inrequest.nagr&&!hsRes.inrequest.agrdate)
      result.errorcode << 12

    if (Client.get(hsRes.inrequest.client_id)?.type_id==1&&!hsRes.inrequest.syscompany_id)
      result.errorcode << 13

    if (!hsRes.inrequest.payterm)
      result.errorcode << 14
    else if(!hsRes.inrequest.payterm && requestService.getStr('payterm'))
      result.errorcode << 41

    if (!hsRes.inrequest.shortbenefit && requestService.getStr('shortbenefit'))
      result.errorcode << 51
    if (!hsRes.inrequest.longbenefit && requestService.getStr('longbenefit'))
      result.errorcode << 61

    try {
      if (hsRes.inrequest.agrdate)
        hsRes.inrequest.agrdate=Date.parse(DATE_FORMAT, hsRes.inrequest?.agrdate)
    } catch(Exception e) {
      result.errorcode << 21
    }
//contract<<

    if(!lId&&result.errorcode.size()==0){
      hsRes.requisites = new Clientrequisites([client_id:hsRes.inrequest.client_id])
      if (!hsRes.requisites) {
        result.errorcode << 100
      }
    }
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      hsRes.requisites.setClientRequisites(hsRes.inrequest).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/saveClientRequisites\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
  }

  def requisitesstatus={
    requestService.init(this)
    def lId = requestService.getLongDef('id',0)
    def iStatus = requestService.getIntDef('status',0)

    if(lId>0){
      Clientrequisites.get(lId)?.csiSetModstatus(iStatus)?.save(flush:true,failOnError:true)
    }

    render(contentType:"application/json"){[error:false]}
  }

  def driverlist = {
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('id',0)

    hsRes.drivers = Driver.findAllByClient_id(lId)
    hsRes.client = Client.get(lId)

    return hsRes
  }

  def driverdetail = {
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('driver_id',0)
    def lClId=requestService.getLongDef('client_id',0)

    hsRes.driver = Driver.get(lId)
    hsRes.client = Client.get(lClId)

    return hsRes
  }

  def saveDriverDetail={
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('driver_id',0)
    hsRes+=requestService.getParams(['document_id'],['client_id'],['name','fullname','tel','docseria','docnumber','docuch'])
    hsRes.inrequest.docdata = requestService.getDate('docdata')

    hsRes.driver = Driver.get(lId)
    if (!hsRes.driver&&lId) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    def result = [:]
    result.errorcode = []
    if (!hsRes.inrequest.name)
      result.errorcode << 1
    if (!hsRes.inrequest.client_id)
      result.errorcode << 2
    if (hsRes.inrequest.tel&&!hsRes.inrequest.tel.matches('\\+\\d{11}'))
      result.errorcode << 3
    if (!hsRes.inrequest.fullname)
      result.errorcode << 4
    if (hsRes.inrequest.docdata>new Date())
      result.errorcode << 5

    if(!lId&&result.errorcode.size()==0){
      hsRes.driver = new Driver([name:hsRes.inrequest.name,client_id:hsRes.inrequest.client_id])
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
      log.debug("Error save data in Admin/saveDriverDetail\n"+e.toString());
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
    def lId = requestService.getLongDef('id',0)
    def iStatus = requestService.getIntDef('status',0)

    if(lId>0){
      Driver.get(lId)?.csiSetModstatus(iStatus)?.save(flush:true)
    }

    render(contentType:"application/json"){[error:false]}
  }

  def savescandriver={
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId = requestService.getLongDef('id',0)
    hsRes.driver = Driver.get(lId)
    if (!hsRes.driver) {
      render(contentType:"application/json"){[error:true]}
    }
    def docname = params.passport1?'passport1':params.passport2?'passport2':params.prava?'prava':'none'

    imageService.init(this,ConfigurationHolder.config.pathtophoto+hsRes.driver.client_id+File.separatorChar+'drivers'+File.separatorChar+hsRes.driver.id+File.separatorChar)
    def hsData = imageService.rawUpload(docname) // 3
    hsData['num'] = docname

    if (!hsData.error) {
      try {
        hsRes.driver.updatescanstatus("is_$hsData.num",hsData.fileid).save(failOnError:true)
      } catch(Exception e) {
        hsData.error = 4
        log.debug('Administrators:savescandriver. Error on save driver:'+hsRes.driver.id+'\n'+e.toString())
      }
    }

    render(view:'savepictureresult',model:hsData)
    return
  }

  def deletedriverscan={
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId = requestService.getLongDef('id',0)
    hsRes.driver = Driver.get(lId)
    if (!hsRes.driver) {
      render(contentType:"application/json"){[error:true]}
    }
    def docname = requestService.getStr('file')
    try {
      Picture.get(hsRes.driver."is_$docname")?.delete(flush:true)
      hsRes.driver.updatescanstatus("is_$docname",0).save(failOnError:true)
    } catch(Exception e) {
      log.debug('Administrators:deletedriverscan. Error on save driver:'+hsRes.driver.id+'\n'+e.toString())
    }

    render(contentType:"application/json"){[error:false]}
  }

  def carlist = {
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('id',0)

    hsRes.cars = Car.findAllByClient_id(lId)
    hsRes.carDrivers_id = hsRes.cars.collect{it.id}.inject([:]){map,car_id -> map[car_id]=Cartodriver.findAllByCar_id(car_id).collect{it.driver_id};map}
    hsRes.drivers = Driver.findAllByClient_id(lId)
    hsRes.client = Client.get(lId)
    hsRes.carmodel = Carmodel.list()

    return hsRes
  }

  def cardetail = {
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lCar_id=requestService.getLongDef('car_id',0)
    def lClient_id=requestService.getLongDef('client_id',0)

    hsRes.car = Car.get(lCar_id)
    hsRes.carmodel = Carmodel.list([sort:'name'])
    hsRes.drivers = Driver.findAllByClient_id(lClient_id)
    hsRes.carDrivers_id = Cartodriver.findAllByCar_id(lCar_id).collect{it.driver_id}
    hsRes.client = Client.get(lClient_id)

    return hsRes
  }

  def saveCarDetail={
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('car_id',0)
    hsRes+=requestService.getParams(['car_trailer','car_model_id','car_is_platform'],['client_id'],['car_gosnomer'])
    def lsDrivers = requestService.getIds('drivers')

    hsRes.car = Car.get(lId)
    if (!hsRes.car&&lId) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    def result = [:]
    result.errorcode = []
    if (!hsRes.inrequest.car_gosnomer)
      result.errorcode << 1
    if (!hsRes.inrequest.client_id)
      result.errorcode << 2

    if(!lId&&result.errorcode.size()==0){
      hsRes.car = new Car([gosnomer:hsRes.inrequest.car_gosnomer,client_id:hsRes.inrequest.client_id])
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
    } catch(grails.validation.ValidationException e) {
      log.debug("Validation Error in Admin/saveCarDetail\n"+e.toString())
      result.errorcode << 3
    } catch(Exception e) {
      log.debug("Error save data in Admin/saveCarDetail\n"+e.toString());
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
    def lId = requestService.getIntDef('id',0)
    def iStatus = requestService.getIntDef('status',0)

    if(lId>0){
      Car.get(lId)?.csiSetModstatus(iStatus)?.save(flush:true)?.computeCarCount()
    }

    render(contentType:"application/json"){[error:false]}
  }

  def savescancar={
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId = requestService.getLongDef('id',0)
    hsRes.car = Car.get(lId)
    if (!hsRes.car) {
      render(contentType:"application/json"){[error:true]}
    }
    def docname = params.passport1?'passport1':params.passport2?'passport2':'none'

    imageService.init(this,ConfigurationHolder.config.pathtophoto+hsRes.car.client_id+File.separatorChar+'cars'+File.separatorChar+hsRes.car.id+File.separatorChar)
    def hsData = imageService.rawUpload(docname) // 3
    hsData['num'] = docname

    if (!hsData.error) {
      try {
        hsRes.car.updatescanstatus("is_$hsData.num",hsData.fileid).save(failOnError:true)
      } catch(Exception e) {
        hsData.error = 4
        log.debug('Administrators:savescancar. Error on save car:'+hsRes.car.id+'\n'+e.toString())
      }
    }

    render(view:'savepictureresult',model:hsData)
    return
  }

  def deletecarscan={
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId = requestService.getLongDef('id',0)
    hsRes.car = Car.get(lId)
    if (!hsRes.car) {
      render(contentType:"application/json"){[error:true]}
    }
    def docname = requestService.getStr('file')
    try {
      Picture.get(hsRes.car."is_$docname")?.delete(flush:true)
      hsRes.car.updatescanstatus("is_$docname",0).save(failOnError:true)
    } catch(Exception e) {
      log.debug('Administrators:deletecarscan. Error on save car:'+hsRes.car.id+'\n'+e.toString())
    }

    render(contentType:"application/json"){[error:false]}
  }

  def trailerlist = {
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('id',0)

    hsRes.trailers = Trailer.findAllByClient_id(lId)
    hsRes.cars = Car.findAllByClient_id(lId)
    hsRes.carTrailers_id = hsRes.trailers.collect{it.id}.inject([:]){map,trailer_id -> map[trailer_id]=Cartotrailer.findAllByTrailer_id(trailer_id).collect{it.car_id};map}
    hsRes.client = Client.get(lId)

    return hsRes
  }

  def trailerdetail = {
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lTrailer_id=requestService.getLongDef('trailer_id',0)
    def lClient_id=requestService.getLongDef('client_id',0)

    hsRes.trailer = Trailer.get(lTrailer_id)
    hsRes.cars = Car.findAllByClient_id(lClient_id)
    hsRes.carTrailers_id = Cartotrailer.findAllByTrailer_id(lTrailer_id).collect{it.car_id}
    hsRes.client = Client.get(lClient_id)

    return hsRes
  }

  def saveTrailerDetail={
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('trailer_id',0)
    hsRes+=requestService.getParams(['trailer_trailertype_id'],['client_id'],['trailnumber'])
    def lsCars = requestService.getIds('cars')

    hsRes.trailer = Trailer.get(lId)
    if (!hsRes.trailer&&lId) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    def result = [:]
    result.errorcode = []
    if (!hsRes.inrequest.trailnumber)
      result.errorcode << 1
    if (!hsRes.inrequest.client_id)
      result.errorcode << 2

    if(!lId&&result.errorcode.size()==0){
      hsRes.trailer = new Trailer([trailnumber:hsRes.inrequest.trailnumber,client_id:hsRes.inrequest.client_id])
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
      log.debug("Error save data in Admin/saveTrailerDetail\n"+e.toString());
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
    def lId = requestService.getIntDef('id',0)
    def iStatus = requestService.getIntDef('status',0)

    if(lId>0){
      Trailer.get(lId)?.csiSetModstatus(iStatus)?.save(flush:true)
    }

    render(contentType:"application/json"){[error:false]}
  }

  def savescantrailer={
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId = requestService.getLongDef('id',0)
    hsRes.trailer = Trailer.get(lId)
    if (!hsRes.trailer) {
      render(contentType:"application/json"){[error:true]}
    }
    def docname = params.passport1?'passport1':params.passport2?'passport2':'none'

    imageService.init(this,ConfigurationHolder.config.pathtophoto+hsRes.trailer.client_id+File.separatorChar+'trailers'+File.separatorChar+hsRes.trailer.id+File.separatorChar)
    def hsData = imageService.rawUpload(docname) // 3
    hsData['num'] = docname

    if (!hsData.error) {
      try {
        hsRes.trailer.updatescanstatus("is_$hsData.num",hsData.fileid).save(failOnError:true)
      } catch(Exception e) {
        hsData.error = 4
        log.debug('Administrators:savescantrailer. Error on save trailer:'+hsRes.trailer.id+'\n'+e.toString())
      }
    }

    render(view:'savepictureresult',model:hsData)
    return
  }

  def deletetrailerscan={
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId = requestService.getLongDef('id',0)
    hsRes.trailer = Trailer.get(lId)
    if (!hsRes.trailer) {
      render(contentType:"application/json"){[error:true]}
    }
    def docname = requestService.getStr('file')
    try {
      Picture.get(hsRes.trailer."is_$docname")?.delete(flush:true)
      hsRes.trailer.updatescanstatus("is_$docname",0).save(failOnError:true)
    } catch(Exception e) {
      log.debug('Administrators:deletetrailerscan. Error on save trailer:'+hsRes.trailer.id+'\n'+e.toString())
    }

    render(contentType:"application/json"){[error:false]}
  }

  def geoexceptionlist = {
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('id',0)

    hsRes.client = Client.get(lId)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    hsRes.regions = Clienttoregion.findAllByClient_id(hsRes.client.id).collect{Region.get(it.region_id)}?.sort { it.name }
    hsRes.fullexclude = (hsRes.regions.size()==Region.count())

    return hsRes
  }

  def regionsforexc = {
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('id',0)

    hsRes.client = Client.get(lId)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    hsRes.excludedregions = Clienttoregion.findAllByClient_id(hsRes.client.id).collect{it.region_id}
    hsRes.regions = []
    Region.list().each{ region -> if (!hsRes.excludedregions.contains(region.id)) hsRes.regions << region }

    return hsRes
  }

  def saveexcludedregion={
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('id',0)

    hsRes.client = Client.get(lId)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def lsRegions = requestService.getIds('regions')

    def result = [:]
    result.errorcode = []

    try {
      lsRegions.each{ new Clienttoregion([client_id:hsRes.client.id,region_id:it]).save(failOnError:true) }
    } catch(Exception e) {
      log.debug("Error save data in Admin/saveexcludedregion\n"+e.toString());
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
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lClId=requestService.getLongDef('client_id',0)

    hsRes.client = Client.get(lClId)
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
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('id',0)

    hsRes.client = Client.get(lId)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    Clienttoregion.findAllByClient_id(hsRes.client.id).each{ it.delete(flush:true) }

    render(contentType:"application/json"){[error:false]}
  }

  def savelimitingparams={
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('id',0)

    hsRes.client = Client.get(lId)
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
      log.debug("Error save data in Admin/savelimitingparams\n"+e.toString());
      render(contentType:"application/json"){[error:true]}
    }

    render(contentType:"application/json"){[error:false]}
  }

  def acceptablecontlist = {
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('id',0)

    hsRes.client = Client.get(lId)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    hsRes.containers = Clienttocontainer.findAllByClient_id(hsRes.client.id).collect{Container.get(it.container_id)}
    hsRes.fullaccept = (hsRes.containers.size()==Container.count())

    return hsRes
  }

  def contforaccept = {
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('id',0)

    hsRes.client = Client.get(lId)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    hsRes.acceptablecont = Clienttocontainer.findAllByClient_id(hsRes.client.id).collect{it.container_id}
    hsRes.containers = []
    Container.list().each{ container -> if (!hsRes.acceptablecont.contains(container.id)) hsRes.containers << container }

    return hsRes
  }

  def saveacceptedcont = {
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('id',0)

    hsRes.client = Client.get(lId)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    def lsCont = requestService.getIds('containers')

    def result = [:]
    result.errorcode = []

    try {
      lsCont.each{ new Clienttocontainer([client_id:hsRes.client.id,container_id:it]).save(failOnError:true) }
    } catch(Exception e) {
      log.debug("Error save data in Admin/saveacceptedcont\n"+e.toString());
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
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lClId=requestService.getLongDef('client_id',0)

    hsRes.client = Client.get(lClId)
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
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('id',0)

    hsRes.client = Client.get(lId)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    Clienttocontainer.findAllByClient_id(hsRes.client.id).each{ it.delete(flush:true) }

    render(contentType:"application/json"){[error:false]}
  }

  def bik_autocomplete={
    requestService.init(this)

    def hsRes = [:]
    hsRes.query = requestService.getStr('query')
    hsRes.suggestions = []
    hsRes.data = []
    if(hsRes.query?:''){
      Bik.findAllByBikIlike(hsRes.query+'%',[max:10]).each{ hsRes.suggestions << it.bik; hsRes.data << it.bankname+';'+it.corraccount }
    }

    render hsRes as JSON
  }

  def paytaxlist = {
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('id',0)

    hsRes.client = Client.get(lId)
    if (!hsRes.client) {
      render(contentType:"application/json"){[error:true]}
    }

    hsRes.paytaxlist = Paytax.findAllByClient_id(hsRes.client.id)

    return hsRes
  }

  def paytaxdetail = {
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('paytax_id',0)

    hsRes.paytax = Paytax.get(lId)
    hsRes.defaultsumma = Tools.getIntVal(Dynconfig.findByName('paytax.default.summa')?.value,1000)

    return hsRes
  }

  def savepaytax={
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('paytax_id',0)
    hsRes+=requestService.getParams(['summa'],['client_id'])
    hsRes.inrequest.paydate = requestService.getRaw('paydate')

    hsRes.paytax = Paytax.get(lId)
    if (!hsRes.paytax&&lId) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    def result = [:]
    result.errorcode = []
    if (!hsRes.inrequest.summa)
      result.errorcode << 1
    if (!hsRes.inrequest.client_id)
      result.errorcode << 2
    if (!hsRes.inrequest.paydate)
      result.errorcode << 3
    /*if (Paytax.findByClient_idAndPaydateAndIdNotEqual(hsRes.inrequest.client_id,hsRes.inrequest.paydate,lId))
      result.errorcode << 4*/

    if(!lId&&result.errorcode.size()==0){
      hsRes.paytax = new Paytax([client_id:hsRes.inrequest.client_id])
      if (!hsRes.paytax) {
        result.errorcode << 100
      }
    }
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      hsRes.paytax.setMainData(hsRes.inrequest).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/savepaytax\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
  }

  def paytaxdelete={
    checkAccess(7)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 7
    hsRes.admin = session.admin

    def lId = requestService.getIntDef('id',0)

    if(lId>0){
      Paytax.get(lId)?.delete(flush:true)
    }

    render(contentType:"application/json"){[error:false]}
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Clients <<</////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Trackers >>>////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def trackers = {
    checkAccess(8)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 8
    hsRes.admin = session.admin

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def trackerlist = {
    checkAccess(8)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 8
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(['modstatus'],['client_id'],['gosnomer','trackaccount','imei'])

    def oSearchObj = new TrackerSearchAdmin()
    hsRes.searchresult = oSearchObj.csiSelectTrack(hsRes.inrequest.imei?:'',hsRes.inrequest.trackaccount?:'',
                                                    hsRes.inrequest.gosnomer?:'',hsRes.inrequest.client_id?:0l,
                                                    hsRes.inrequest.modstatus?:0,20,requestService.getOffset())

    return hsRes
  }

  def trackermap = {
    checkAccess(8)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 8
    hsRes.admin = session.admin
   
    hsRes+=requestService.getParams(['modstatus'],['client_id'],['gosnomer','trackaccount','imei'])      
    hsRes.inrequest.offset = requestService.getOffset()          
    
    hsRes.inrequest.param=requestService.getStr('param')
    def hsFilter=[:]    
    
    if(hsRes.inrequest.param){                                                
      def coordinates=searchService.findViewPortTile(hsRes.inrequest.param) 
       
      hsFilter.xl=Math.round(coordinates[0]).toLong()
      hsFilter.yd=Math.round(coordinates[1]).toLong()
      hsFilter.xr=Math.round(coordinates[2]).toLong()
      hsFilter.yu=Math.round(coordinates[3]).toLong()
      
      if(hsFilter.xr>0 && hsFilter.yu>0)
        hsFilter.coordinates=1
    } 
//log.debug('hsFilter='+hsFilter)    
    def oSearchObj = new TrackerSearchMap()  
    hsRes.searchresult = oSearchObj.csiSelectTrack(hsRes.inrequest.imei?:'',hsRes.inrequest.trackaccount?:'',
                                                   hsRes.inrequest.gosnomer?:'',hsRes.inrequest.client_id?:0l,
                                                   hsRes.inrequest.modstatus?:0,-1,0)      
    hsRes.trackingdata = []
    hsRes.cars = []
    hsRes.count=0
    
    if(!hsFilter.coordinates)
      hsRes.count=hsRes.searchresult.count    
    
    def lsIds=[]
    for(sresult in hsRes.searchresult.records){
      if(sresult?.trackingdata_id?:0)
        lsIds << sresult?.trackingdata_id
    }      
log.debug('lsIds='+lsIds)    
    if(lsIds){
      oSearchObj = new Trackingdata()  
      hsRes.searchresult = oSearchObj.csiSelectTrack(lsIds,hsFilter.xl,hsFilter.yd,hsFilter.xr,hsFilter.yu,20,requestService.getOffset())
    
      if(hsFilter.coordinates)
        hsRes.count=hsRes.searchresult.count 
    
      for(sresult in hsRes.searchresult.records){
        hsRes.cars << Car.findWhere(imei:sresult?.imei?:'')
      }         
    }    
    return hsRes
  }

  def trackerdetail={
    checkAccess(8)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 8
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)

    hsRes.tracker = Tracker.get(lId)
    if (!hsRes.tracker&&lId) {
      response.sendError(404)
      return
    }

    hsRes.trackingdata = Trackingdata.findByImei(hsRes.tracker?.imei?:'',[sort: "tracktime", order: "desc"])
    hsRes.car = Car.findByImei(hsRes.tracker?.imei?:0)
    hsRes.client = Client.get(hsRes.car?.client_id?:0l)

    return hsRes
  }

  def saveTrackerDetail={
    checkAccess(8)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 8
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)
    hsRes+=requestService.getParams(['modstatus'],null,['imei','sim','tel','trackaccount','car_gosnomer'])

    hsRes.tracker = Tracker.get(lId)
    if (!hsRes.tracker&&lId) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    def result = [:]
    result.errorcode = []
    if (!hsRes.inrequest.imei)
      result.errorcode << 1
    if (!hsRes.inrequest.tel)
      result.errorcode << 2
    if (!hsRes.inrequest.trackaccount)
      result.errorcode << 3
    if (hsRes.inrequest.car_gosnomer&&!Car.findByGosnomer(hsRes.inrequest.car_gosnomer))
      result.errorcode << 4

    if(!lId&&result.errorcode.size()==0){
      hsRes.tracker = new Tracker([imei:hsRes.inrequest.imei])
      if (!hsRes.tracker) {
        result.errorcode << 100
      }
    }
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      hsRes.tracker.setData(hsRes.inrequest).associate(hsRes.inrequest.car_gosnomer?:'').save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/saveTrackerDetail\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false,uId:hsRes.tracker.id]}
  }

  def car_autocomplete={
    requestService.init(this)

    def hsRes = [:]
    hsRes.query = requestService.getStr('query')
    if(hsRes.query?:''){
      hsRes.suggestions = Car.findAllByModstatusAndGosnomerIlike(1,hsRes.query+'%').collect{it.gosnomer}
    } else {
      hsRes.suggestions = []
    }

    render hsRes as JSON
  }
  def tracker_route={
    requestService.init(this)
    def lId=requestService.getIntDef('id',0)  
    def DateStart=requestService.getDate('date')        
    def hsRes=[:]       
    hsRes.tracker_route=[]
    
    def oTracker=Tracker.get(lId)    
    if(oTracker){
      hsRes.tracker_route=Trackingdata.findAllByImeiAndTracktimeBetween(oTracker.imei,DateStart,DateStart+1)
      if (!hsRes.tracker_route)
        hsRes.tracker_route = Trackingdata_archive.findAllByImeiAndTracktimeBetween(oTracker.imei,DateStart,DateStart+1)
    }
    
    return hsRes
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Trackers <<<////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Zakaz >>>///////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def zakaz = {
    checkAccess(9)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 9
    hsRes.admin = session.admin

    def fromDetails = requestService.getIntDef('fromDetails',0)
    if (fromDetails&&session.lastRequest){
      session.lastRequest.fromDetails = fromDetails
      hsRes.inrequest = session.lastRequest
    }

    hsRes.zakazstatus = Zakazstatus.list()

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def zakazlist = {
    checkAccess(9)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 9
    hsRes.admin = session.admin

    if (session.lastRequest?.fromDetails?:0) {
      hsRes.inrequest = session.lastRequest
      session.lastRequest.fromDetails = 0
    } else {
      hsRes+=requestService.getParams(null,['zakaz_id'],['shipper','unloading'])
      hsRes.inrequest.modstatus = requestService.getIntDef('modstatus',0)
      hsRes.inrequest.offset = requestService.getOffset()
      session.lastRequest = [:]
      session.lastRequest = hsRes.inrequest
    }

    def oSearchObj = new ZakazSearchAdmin()
    hsRes.searchresult = oSearchObj.csiSelectZakaz(hsRes.inrequest.zakaz_id?:0l,hsRes.inrequest.shipper?:'',hsRes.inrequest.modstatus?:0,hsRes.inrequest.unloading?:'',20,hsRes.inrequest.offset)

    hsRes.terminals = Terminal.list().inject([:]){map, terminal -> map[terminal.id]=terminal.name;map}
    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=[shortname:container.shortname,name:container.name];map}
    hsRes.zakazstatus = Zakazstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.modstatus,icon:status.icon];map}
    hsRes.actualtimes = hsRes.searchresult.records.inject([:]){map, zakaz ->
      if (zakaz.modstatus<3)
        map[zakaz.id] = zakaz.inputdate.getTime()+(Ztime.get(zakaz.ztime_id)?.qtime?:0)*60*1000-new Date().getTime()
      else
        map[zakaz.id] = zakaz.zdate?(zakaz.zdate+1).getTime()-new Date().getTime():0
      map
    }

    return hsRes
  }

  def orderdetail={
    requestService.init(this)
    checkAccess(9)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 9
    hsRes.admin = session.admin

    def lId = requestService.getLongDef('id',0)
    hsRes.copiedId = requestService.getLongDef('copiedzakaz',0)

    hsRes.zakaz = Zakaz.get(lId)?:Zakaz.get(hsRes.copiedId)
    if (!hsRes.zakaz&&lId) {
      response.sendError(404)
      return
    }

    hsRes.ztype = Ztype.list()
    hsRes.dangerclass = Dangerclass.list()
    hsRes.container = Container.list()
    hsRes.ztime = Ztime.list()
    hsRes.trailertype = Trailertype.list()
    hsRes.terminal = Terminal.list()

    if(hsRes.zakaz){
      hsRes.trailertype_id = (hsRes.zakaz.trailertype_id?:'').split(',')
      if (hsRes.zakaz.modstatus<3)
        hsRes.actualTime = hsRes.zakaz.inputdate.getTime()+(Ztime.get(hsRes.zakaz.ztime_id)?.qtime?:0)*60*1000-new Date().getTime()
      else
        hsRes.actualTime = hsRes.zakaz.zdate?(hsRes.zakaz.zdate+1).getTime()-new Date().getTime():0
    }

    return hsRes
  }

  def ordertrackdetail={
    requestService.init(this)
    checkAccess(9)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 9
    hsRes.admin = session.admin

    hsRes.terminal=Terminal.list()
    hsRes.region = Region.findAll('from Region where modstatus = 1 order by regorder desc, name asc')

    def lId = requestService.getLongDef('id',0)
    def iZtype = requestService.getIntDef('ztype_id',0)
    hsRes.copied = requestService.getIntDef('copied',0)

    hsRes.zakaz = Zakaz.get(lId)
    if (!hsRes.zakaz&&lId) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    if(hsRes.zakaz){
      hsRes.slot=Slot.findAllByTerminal_idAndModstatus(hsRes.zakaz.terminal,1)
      hsRes.slot_end=Slot.findAllByTerminal_idAndModstatus(hsRes.zakaz.terminal_end,1)
      hsRes.slotlist=hsRes.zakaz?.slotlist.split(',')
      hsRes.slotlistend=hsRes.zakaz?.slotlist_end.split(',')
      if((hsRes.slotlistend?:[]).size()==2){
        hsRes.slotlist_end_start=hsRes.slotlistend[0]
        hsRes.slotlist_end_end=hsRes.slotlistend[1]
      }
    }

    switch(iZtype) {
      case 1:
        render(view: "order_import", model: hsRes); break;
      case 2:
        render(view: "order_export", model: hsRes); break;
      case 3:
        render(view: "order_transit", model: hsRes); break;
      default:
        render(contentType:"application/json"){[error:true]}
        break
    }
  }

  def getslot={
    requestService.init(this)
    checkAccess(9)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 9
    hsRes.admin = session.admin

    def iId=requestService.getIntDef('id',0)

    if(iId>=0){
      hsRes.slot=Slot.findAllByTerminal_idAndModstatus(iId,1)
      hsRes.terminal=Terminal.get(iId)
      hsRes.end=requestService.getIntDef('end',0)
    }
    return hsRes
  }

  def saveZakazDetail={
    requestService.init(this)
    checkAccess(9)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 9
    hsRes.admin = session.admin

    def lId = requestService.getLongDef('id',0)
    def iZtype = requestService.getIntDef('ztype_id',0)

    hsRes.zakaz = Zakaz.get(lId)
    if ((!hsRes.zakaz&&lId)||hsRes.zakaz?.modstatus>2) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    if (!(iZtype in 1..3)) {
      render(contentType:"application/json"){[error_ztype_id:1]}
      return
    }

    hsRes += requestService.getParams(['ztype_id','container','zcol','price','ztime_id','dangerclass','is_roof','terminal',
                                      'is_slotlist','slot_start','slot_end','timestart_end','timeend_end','terminal_end',
                                      'timestart_zat','timeend_zat','is_slotlist_end','slot_start_end','slot_end_end',
                                      'price_basic','is_debate','noticetime','manager_id','benefit','addzcol','route_id'],
                                      null,
                                      ['doc','comment','region_start','city_start','address_start','prim_start','region_end',
                                       'city_end','address_end','prim_end','region_dop','city_dop','address_dop','prim_dop',
                                       'region_cust','city_cust','address_cust','prim_cust','region_zat','city_zat',
                                       'address_zat','prim_zat','shipper','idle','noticetel'])

    hsRes.inrequest.zdate = requestService.getDate('zdate')
    hsRes.inrequest.date_start = requestService.getDate('date_start')
    hsRes.inrequest.date_zat = requestService.getDate('date_zat')
    hsRes.inrequest.date_cust = requestService.getDate('date_cust')
    hsRes.inrequest.slotlist = requestService.getStr('slotlist')
    hsRes.inrequest += zakazService.receiveWeightsAndTrailertypeFromRequest(requestService,hsRes.inrequest.zcol)
    hsRes.inrequest += zakazService.receiveGeoDataFromRequest(requestService)

    hsRes += zakazService.checkCommonRequestData(hsRes.inrequest)
    if(iZtype==2) {
      hsRes += zakazService.checkExportRequestData(hsRes.inrequest,hsRes.returnerrors)
    } else if(iZtype==3) {
      hsRes.returnerrors.transiterrors = zakazService.checkTransitRequestData(hsRes.inrequest)
    }
    hsRes.returnerrors.admin_error = zakazService.checkAdminRequestData(hsRes.inrequest)

    if(!hsRes.returnerrors.error && !hsRes.returnerrors.slot_error && !hsRes.returnerrors.date_error && !hsRes.returnerrors.price_error && !hsRes.returnerrors.transiterrors && !hsRes.returnerrors.timezat_error && !hsRes.returnerrors.admin_error && !hsRes.returnerrors.notice_error && !hsRes.returnerrors.weight_error){
      if(!lId){
        hsRes.zakaz = new Zakaz([ztype_id:hsRes.inrequest.ztype_id,shipper:Client.findByFullname(hsRes.inrequest.shipper)?.id?:0])
        if (!hsRes.zakaz) {
          hsRes.returnerrors.error << 100
        }
      }
      if(!hsRes.returnerrors.error){
        try {
          def ztypeHandler = 'set'+(iZtype==1?'Import':iZtype==2?'Export':'Transit')+'Data'
          hsRes.zakaz.setGeneralData(hsRes.inrequest,0)."$ztypeHandler"(hsRes.inrequest).setAdminData(hsRes.inrequest,session.admin.id?:0).geocode(hsRes.inrequest).detectroute(hsRes.inrequest.route_id).save(failOnError:true)
        } catch(Exception e) {
          log.debug("Error save data in Admin/saveZakazDetail\n"+e.toString());
          hsRes.returnerrors.error << 100
        }
      }
    } else {
      hsRes.returnerrors.ztype_id = iZtype
      render hsRes.returnerrors as JSON
      return
    }

    if (hsRes.returnerrors.error.size()>0) {
      hsRes.returnerrors.ztype_id = iZtype
      render hsRes.returnerrors as JSON
    } else
      render(contentType:"application/json"){[error:false,uId:hsRes.zakaz.id]}
  }

  def shipper_autocomplete = {
    requestService.init(this)

    def hsRes = [:]
    hsRes.query = requestService.getStr('query')
    if(hsRes.query?:''){
      hsRes.suggestions = Client.findAll {
        modstatus == 1 &&
        type_id == 1 &&
        fullname =~ ('%'+hsRes.query+'%')
      }.collect{it.fullname}
    } else {
      hsRes.suggestions = []
    }

    render hsRes as JSON
  }

  def zakazstatus={
    requestService.init(this)
    checkAccess(9)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 9
    hsRes.admin = session.admin

    def lId = requestService.getIntDef('id',0)
    def iStatus = requestService.getIntDef('status',0)

    if(lId>0){
      Zakaz.get(lId)?.csiSetModstatus(iStatus)?.save(flush:true)
      if(iStatus==-2) Zakaztocarrier.findAllByZakaz_idAndModstatusGreaterThan(lId,-1).each{it.csiSetModstatus(-2).save(failOnError:true)}
    }

    render(contentType:"application/json"){[error:false]}
  }

  def zakazvariants={
    requestService.init(this)
    checkAccess(9)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 9
    hsRes.admin = session.admin

    hsRes.zakazId = requestService.getIntDef('id',0)
    hsRes.iSsearch = requestService.getIntDef('is_simplesearch',0)
    hsRes.zakaz = Zakaz.get(hsRes.zakazId)

    hsRes.variants = new Client().findzakazvariants(hsRes.zakaz,hsRes.iSsearch?true:false)
    hsRes.offers = hsRes.variants.collect{it.id}.inject([:]){map, clientid -> map[clientid]=Zakaztocarrier.findByClient_idAndZakaz_id(clientid,hsRes.zakazId)?.inputdate?:null;map}

    return hsRes
  }

  def sendzakazoffer={
    requestService.init(this)
    checkAccess(9)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 9
    hsRes.admin = session.admin

    hsRes.zakaz = Zakaz.get(requestService.getIntDef('id',0))
    def clientIds = requestService.getIds('clientids')
    def delayedclientids = requestService.getIds('delayedclientids')
    if (session.admin.is_allvariants) {
      def variants = new Client().findzakazvariants(hsRes.zakaz,requestService.getIntDef('is_simplesearch',0)?true:false)
      clientIds = variants.collect{ it.ishavetrackers?it.id:null } - null
      delayedclientids = variants.collect{ !it.ishavetrackers?it.id:null } - null
    }

    if (!hsRes.zakaz||(!clientIds&&!delayedclientids)) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    try {
      def sendingIds = []
      clientIds?.each{
        if (!Zakaztocarrier.findByClient_idAndZakaz_id(it,hsRes.zakaz.id)) {
          sendingIds << new Zakaztocarrier(zakaz_id:hsRes.zakaz.id,client_id:it).setMainData(hsRes.zakaz).save(failOnError:true)?.id?:0
        }
      }
      hsRes.zakaz.csiSetModstatus(clientIds?1:hsRes.zakaz.modstatus).updatedelayedclients(delayedclientids).save(failOnError:true)
      zakazService.sendZakazOfferForCarriers(sendingIds)
    } catch(Exception e) {
      log.debug("Error save data in Admin/sendzakazoffer\n"+e.toString());
      render(contentType:"application/json"){[error:true]}
    }

    render(contentType:"application/json"){[error:false]}
  }

  def zakazoffers={
    requestService.init(this)
    checkAccess(9)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 9
    hsRes.admin = session.admin

    hsRes.zakazId = requestService.getIntDef('id',0)

    def oSearchObj = new Zakaztocarrier()
    hsRes.offers = oSearchObj.findOffers(hsRes.zakazId)
    hsRes.driverzcols = [:]
    hsRes.offers.each{ hsRes.driverzcols[it.id] = Zakaztodriver.findAllByClient_idAndZakaz_id(it.client_id,hsRes.zakazId)?.sum{it.zcol}?:0 }

    hsRes.zakaz = Zakaz.get(hsRes.zakazId)

    return hsRes
  }

  def orderassign = {
    requestService.init(this)
    checkAccess(9)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 9
    hsRes.admin = session.admin

    hsRes.ztocarId = requestService.getIntDef('id',0)

    def oZakaztocarrier = Zakaztocarrier.get(hsRes.ztocarId)
    hsRes.zakaz = Zakaz.get(oZakaztocarrier?.zakaz_id?:0)
    if (!oZakaztocarrier||!hsRes.zakaz) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    def assignedContainersCol = Zakaztocarrier.findAllByZakaz_idAndModstatus(hsRes.zakaz.id,2).sum{it.zcol}?:0
    if (assignedContainersCol+oZakaztocarrier.zcol>hsRes.zakaz.zcol) {
      render(contentType:"application/json"){[error:true,errorcode:1]}
      return
    }
    if ((Zakaztodriver.findAllByClient_idAndZakaz_id(oZakaztocarrier.client_id,hsRes.zakaz.id)?.sum{it.zcol}?:0)!=oZakaztocarrier.zcol) {
      render(contentType:"application/json"){[error:true,errorcode:2]}
      return
    }
    try {
      if (assignedContainersCol+oZakaztocarrier.zcol>=hsRes.zakaz.zcol) {
        hsRes.zakaz.assign().save(failOnError:true)
        zakazService.sendZakazOfferForShipper(hsRes.zakaz)
        Zakaztocarrier.findAllByZakaz_idAndModstatusNotEqual(hsRes.zakaz.id,2).each{it.csiSetModstatus(-2).save(failOnError:true)}
      }
      oZakaztocarrier.csiSetModstatus(2).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/orderassign\n"+e.toString());
      render(contentType:"application/json"){[error:true]}
    }

    render(contentType:"application/json"){[error:false]}
  }

  def orderremind={
    requestService.init(this)
    checkAccess(9)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 9
    hsRes.admin = session.admin

    def lId = requestService.getIntDef('id',0)

    hsRes.zakaztocarrier = Zakaztocarrier.get(lId)
    if (!hsRes.zakaztocarrier) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    try {
      zakazService.sendOrderRemindForCarrier(hsRes.zakaztocarrier.client_id)
    } catch(Exception e) {
      log.debug("Error save data in Admin/orderremind\n"+e.toString());
      render(contentType:"application/json"){[error:true]}
    }

    render(contentType:"application/json"){[error:false]}
  }

  def partition = {
    requestService.init(this)
    checkAccess(9)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 9
    hsRes.admin = session.admin

    hsRes.zakazId = requestService.getIntDef('id',0)

    hsRes.zakaz = Zakaz.get(hsRes.zakazId)
    if (!hsRes.zakaz) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    def assignedContainers = Zakaztocarrier.findAllByZakaz_idAndModstatus(hsRes.zakaz.id,2)
    def oClient = new Client()
    hsRes.variants = oClient.findzakazvariants(hsRes.zakaz,true)
    def newZakaz
    try {
      newZakaz = hsRes.zakaz.partition(assignedContainers.sum{it.zcol}?:0).save(failOnError:true)
      hsRes.zakaz.afterpartition(assignedContainers.sum{it.zcol}?:0).save(failOnError:true)
      zakazService.sendZakazOfferForShipper(hsRes.zakaz)
      Zakaztocarrier.findAllByZakaz_idAndModstatusNotEqual(hsRes.zakaz.id,2).each{it.csiSetModstatus(-2).save(failOnError:true)}
      zakazService.sendZakazOfferForCarriers(
        hsRes.variants.collect{ client ->
          if (!assignedContainers.find{it.client_id==client.id}) new Zakaztocarrier(zakaz_id:newZakaz.id,client_id:client.id).setMainData(newZakaz).save(failOnError:true)?.id?:0
        }-null
      )
    } catch(Exception e) {
      log.debug("Error save data in Admin/partition\n"+e.toString());
      render(contentType:"application/json"){[error:true]}
      return
    }

    render(contentType:"application/json"){[error:false,uId:newZakaz.id]}
  }

  def zakaztrips={
    requestService.init(this)
    checkAccess(9)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 9
    hsRes.admin = session.admin

    hsRes.zakazId = requestService.getIntDef('id',0)

    hsRes.trips = new TripSearchAdmin().csiSelectTrip(0,0,0,0,'','',hsRes.zakazId,-100,-100,0,0)
    hsRes.tripstatus = Tripstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}

    return hsRes
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Zakaz <<<///////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Monitoring >>>//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def monitoring = {
    checkAccess(10)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 10
    hsRes.admin = session.admin

    def fromEdit = requestService.getIntDef('fromEdit',0)
    hsRes.type = requestService.getIntDef('type',0)
    if (fromEdit){
      session.lastRequest.fromEdit = fromEdit
      hsRes.inrequest = session.lastRequest
    }
    hsRes.tripstatus = Tripstatus.list()
    hsRes.tripeventtype = Tripeventtype.list()
    hsRes.drivernames = Driver.list()
    hsRes.shippernames = Client.findAllByType_id(1)
    hsRes.carriernames = Client.findAllByType_id(2)
    return hsRes
  }

  def triplist = {
    checkAccess(10)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 10
    hsRes.admin = session.admin

    if (session.lastRequest?.fromDetails?:0) {
      hsRes.inrequest = session.lastRequest
      session.lastRequest.fromDetails = 0
    } else {
      hsRes+=requestService.getParams(null,['trip_id','shipper','carrier','driver_id','zakaz_id'],['cargosnomer','container'])
      hsRes.inrequest.modstatus = requestService.getIntDef('modstatus',0)
      hsRes.inrequest.offset = requestService.getOffset()
      session.lastRequest = [:]
      session.lastRequest = hsRes.inrequest
    }

    def oSearchObj = new TripSearchAdmin()
    hsRes.searchresult = oSearchObj.csiSelectTrip(hsRes.inrequest.trip_id?:0l,hsRes.inrequest.shipper?:0l,
                                      hsRes.inrequest.carrier?:0l,hsRes.inrequest.driver_id?:0l,
                                      hsRes.inrequest.cargosnomer?:'',hsRes.inrequest.container?:'',
                                      hsRes.inrequest.zakaz_id?:0l,hsRes.inrequest.modstatus?:0,-100,20,hsRes.inrequest.offset)

    hsRes.tripstatus = Tripstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.ztypes = Ztype.list().inject([:]){map, type -> map[type.id]=type.name;map}

    return hsRes
  }

  def tripmap = {
    checkAccess(10)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 10
    hsRes.admin = session.admin

    if (session.lastRequest?.fromDetails?:0) {
      hsRes.inrequest = session.lastRequest
      session.lastRequest.fromDetails = 0
    } else {
      hsRes+=requestService.getParams(null,['trip_id','shipper','carrier','driver_id','zakaz_id'],['cargosnomer','container'])
      hsRes.inrequest.modstatus = requestService.getIntDef('modstatus',0)
      hsRes.inrequest.offset = requestService.getOffset()
      session.lastRequest = [:]
      session.lastRequest = hsRes.inrequest
    }

    def oSearchObj = new TripSearchAdmin()
    hsRes.searchresult = oSearchObj.csiSelectTrip(hsRes.inrequest.trip_id?:0l,hsRes.inrequest.shipper?:0l,
                                      hsRes.inrequest.carrier?:0l,hsRes.inrequest.driver_id?:0l,
                                      hsRes.inrequest.cargosnomer?:'',hsRes.inrequest.container?:'',
                                      hsRes.inrequest.zakaz_id?:0l,hsRes.inrequest.modstatus?:0,-100,50,hsRes.inrequest.offset,true)

    hsRes.mapresult = hsRes.searchresult.records.collect{Triproute.findByTrip_id(it.id,[sort:'tracktime',order:'desc'])}-null

    return hsRes
  }

  def eventlist = {
    checkAccess(10)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 10
    hsRes.admin = session.admin

    if (session.lastRequest?.fromDetails?:0) {
      hsRes.inrequest = session.lastRequest
      session.lastRequest.fromDetails = 0
    } else {
      hsRes+=requestService.getParams(['type_id'],['trip_id','shipper','carrier','driver_id'],['cargosnomer'],['date_start','date_end'])
      hsRes.inrequest.modstatus = requestService.getIntDef('modstatus',0)
      hsRes.date_start = requestService.getDate('date_start')
      hsRes.date_end = requestService.getDate('date_end')
      hsRes.inrequest.offset = requestService.getOffset()
      session.lastRequest = [:]
      session.lastRequest = hsRes.inrequest
    }

    def oSearchObj = new TripEventSearchAdmin()
    hsRes.searchresult = oSearchObj.csiSelectTripEvent(hsRes.inrequest.trip_id?:0l,hsRes.inrequest.shipper?:0l,
                                      hsRes.inrequest.carrier?:0l,hsRes.inrequest.driver_id?:0l,
                                      hsRes.inrequest.cargosnomer?:'',hsRes.inrequest.modstatus?:0,
                                      hsRes.inrequest.type_id?:0,hsRes.date_start,hsRes.date_end,
                                      20,hsRes.inrequest.offset)
    hsRes.tripeventtype = Tripeventtype.list().inject([:]){map, type -> map[type.id]=[descr:type.name,icon:type.icon,significance:type.leveladm];map}
    Trip.findAllByIs_readeventadmin(0).each{it.csiSetReadEvent(3).save()}

    return hsRes
  }

  def generateorder={
    checkAccess(10)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 10
    hsRes.admin = session.admin

    billingService.generateNewOrder(requestService.getLongDef('id',0))

    render(contentType:"application/json"){[error:false]}
  }

  def tripdetail={
    checkAccess(10)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 10
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)

    hsRes.trip = Trip.get(lId)
    if (!hsRes.trip) {
      response.sendError(404)
      return
    }

    hsRes.shipper = Client.get(hsRes.trip.shipper)
    hsRes.carrier = Client.get(hsRes.trip.carrier)
    hsRes.driver = Driver.get(hsRes.trip.driver_id)
    hsRes.drivers = Driver.findAllByClient_idAndModstatus(hsRes.trip.carrier,1)
    hsRes.cars = Car.findAllByClient_idAndModstatus(hsRes.trip.carrier,1)
    hsRes.container = Container.get(hsRes.trip.container)
    hsRes.zakaztodriver = Zakaztodriver.get(hsRes.trip.zakaztodriver_id)
    def oTriproute = new Triproute()
    hsRes.route = oTriproute.csiSelectRoute(hsRes.trip.id)
    hsRes.tripstatus = Tripstatus.get(hsRes.trip.modstatus)

    return hsRes
  }

  def saveTripDetail={
    checkAccess(10)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 10
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)
    hsRes+=requestService.getParams(['status','idlesum','car_id','forwardsum','benefit'],['driver_id'],['comment','containernumber1','containernumber2'])
    if (hsRes.admin.menu?.find{it.id==18}) {
      hsRes.inrequest.price = requestService.getIntDef('price',0)
    }

    hsRes.trip = Trip.get(lId)
    if (!hsRes.trip) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    def result = [:]
    result.errorcode = []
    if (hsRes.inrequest.status==2&&hsRes.trip.taskstatus<5)
      result.errorcode << 1
    if (!hsRes.inrequest.car_id)
      result.errorcode << 2
    if (!hsRes.inrequest.driver_id)
      result.errorcode << 3
    if (!hsRes.inrequest.containernumber1)
      result.errorcode << 4
    if (Zakaztodriver.get(hsRes.trip.zakaztodriver_id)?.containernumber2&&!hsRes.inrequest.containernumber2)
      result.errorcode << 5

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      hsRes.trip.setAdminData(hsRes.inrequest).csiSetModstatus(hsRes.inrequest.status?:0).save(failOnError:true)
      Zakaztodriver.get(hsRes.trip.zakaztodriver_id)?.updatecontnumbers(hsRes.inrequest).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/saveTripDetail\n"+e.toString());
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
  }

  def tripeventlist = {
    checkAccess(10)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 10
    hsRes.admin = session.admin

    def lId = requestService.getIntDef('id',0)

    hsRes.trip = Trip.get(lId)
    if (!hsRes.trip) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    hsRes.events = Tripevent.findAllByTrip_id(hsRes.trip.id)
    hsRes.eventtypes = Tripeventtype.list().inject([:]){map, type -> map[type.id]=[descr:type.name,icon:type.icon];map}

    return hsRes
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Monitoring <<<//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Requests <<<//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def requests = {
    checkAccess(11)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 11
    hsRes.admin = session.admin

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
    checkAccess(11)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 11
    hsRes.admin = session.admin

    if (session.lastRequest?.fromDetails?:0) {
      hsRes.inrequest = session.lastRequest
      session.lastRequest.fromDetails = 0
    } else {
      hsRes+=requestService.getParams(null,['zakaz_id','trip_id'],['cargosnomer','container','shipper'])
      hsRes.inrequest.modstatus = requestService.getIntDef('modstatus',0)
      hsRes.inrequest.taskstatus = requestService.getIntDef('taskstatus',0)
      hsRes.inrequest.offset = requestService.getOffset()
      session.lastRequest = [:]
      session.lastRequest = hsRes.inrequest
    }

    def oSearchObj = new TripSearchAdmin()
    hsRes.searchresult = oSearchObj.csiSelectTrip(hsRes.inrequest.trip_id?:0l,0l,0l,0l,hsRes.inrequest.cargosnomer?:'',
                                                  hsRes.inrequest.container?:'',hsRes.inrequest.zakaz_id?:0l,
                                                  hsRes.inrequest.modstatus,hsRes.inrequest.taskstatus,20,hsRes.inrequest.offset,
                                                  false,null,hsRes.inrequest.shipper?:'')

    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=[shortname:container.shortname,name:container.name];map}
    hsRes.tripstatus = Tripstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.taskstatus = Taskstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.terminals = Terminal.list().inject([:]){map, terminal -> map[terminal.id]=terminal.name;map}
    hsRes.payorders = hsRes.searchresult.records.inject([:]){map, record -> map[record.id]=Payorder.get(record.payorder_id);map}

    return hsRes
  }

  def documentconfirm = {
    checkAccess(11)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 11
    hsRes.admin = session.admin

    def lId = requestService.getIntDef('id',0)

    hsRes.trip = Trip.get(lId)
    if (!hsRes.trip||hsRes.trip?.taskstatus!=5) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    try {
      hsRes.trip.csiSetTaskstatus(6).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/documentconfirm\n"+e.toString());
    }

    render(contentType:"application/json"){[error:false]}
  }

  def documentcancell = {
    checkAccess(11)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 11
    hsRes.admin = session.admin

    def lId = requestService.getIntDef('id',0)

    hsRes.trip = Trip.get(lId)
    if (!hsRes.trip||hsRes.trip?.taskstatus!=6) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    try {
      hsRes.trip.csiSetTaskstatus(5).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/documentconfirm\n"+e.toString());
    }

    render(contentType:"application/json"){[error:false]}
  }

  def instructiondetails = {
    checkAccess(11)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 11
    hsRes.admin = session.admin

    def lId = requestService.getIntDef('id',0)

    hsRes.trip = Trip.get(lId)
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
    hsRes.drivers = Driver.findAllByClient_idAndModstatus(hsRes.trip.carrier,1)
    hsRes.cars = Cartodriver.findAllByDriver_id(hsRes.trip.returndriver_id).collect{
      Car.findByModstatusAndId(1,it.car_id)
    }-null
    hsRes.driver = Driver.get(hsRes.trip.returndriver_id)
    hsRes.shipper = Client.get(hsRes.trip.shipper)

    return hsRes
  }

  def driversfordelivery={
    checkAccess(11)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 11
    hsRes.admin = session.admin

    hsRes.driverId = requestService.getLongDef('id',0)
    hsRes.clientId = requestService.getLongDef('client_id',0)

    if(hsRes.driverId>=0&&hsRes.clientId){
      hsRes.drivers = Driver.findAllByClient_idAndModstatus(hsRes.clientId,1)
      hsRes.cars = Cartodriver.findAllByDriver_id(hsRes.driverId).collect{
        Car.findByModstatusAndId(1,it.car_id)
      }-null
    }
    return hsRes
  }

  def getslottask = {
    checkAccess(11)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 11
    hsRes.admin = session.admin

    def iId=requestService.getIntDef('id',0)

    if(iId>=0){
      hsRes.slot = Slot.findAllByTerminal_idAndModstatus(iId,1)
      hsRes.terminal = Terminal.get(iId)
    }
    return hsRes
  }

  def saveTripDeliveryDetail = {
    checkAccess(11)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 11
    hsRes.admin = session.admin

    def lId = requestService.getIntDef('id',0)

    hsRes.trip = Trip.get(lId)
    if (!hsRes.trip||!(hsRes.trip?.taskstatus in 0..4)||!(hsRes.trip?.modstatus in 0..1)) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    hsRes+=requestService.getParams(['terminalh','taskstart','taskend','taskslot','is_mark','taskstatus'],null,['taskaddress','taskprim','stockbooking'])
    hsRes.inrequest.dateE = requestService.getDate('dateE_del')

    def result = [:]
    result.errorcode = zakazService.checkDataForTripDelivery(hsRes.inrequest,hsRes.inrequest.taskstatus==2?false:true)

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      hsRes.trip.setDeliveryData(hsRes.inrequest).csiSetTaskstatus(hsRes.inrequest.taskstatus?:2).save(failOnError:true)
      if (hsRes.inrequest.taskstatus==2)
        zakazService.sendContDeliveryForCarrier(hsRes.trip)
    } catch(Exception e) {
      log.debug("Error save data in Admin/saveTripDeliveryDetail\n"+e.toString());
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}

  }

  def saveDeliveryRequest = {
    checkAccess(11)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 11
    hsRes.admin = session.admin

    def lId = requestService.getIntDef('id',0)

    hsRes.trip = Trip.get(lId)
    if (!hsRes.trip||hsRes.trip?.taskstatus>3||!(hsRes.trip.modstatus in 0..1)) {
      render(contentType:"application/json"){[error:true]}
    }
    hsRes+=requestService.getParams(['timestartE','timeendE','timeeditE','driveredit','car_id'],['driver_id'],['leftcargosnomer'])
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
      log.debug("Error save data in Admin/saveDeliveryRequest\n"+e.toString());
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}

  }

  def deliveryconfirm = {
    checkAccess(11)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 11
    hsRes.admin = session.admin

    def lId = requestService.getIntDef('id',0)

    hsRes.trip = Trip.get(lId)
    if (!hsRes.trip||hsRes.trip?.taskstatus!=2) {
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

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Requests <<<//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Contsearch <<<////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def contsearch = {
    checkAccess(12)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 12
    hsRes.admin = session.admin

    hsRes.cont = requestService.getStr('cont')

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def contsearchlist = {
    checkAccess(12)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 12
    hsRes.admin = session.admin

    hsRes.cont = requestService.getStr('cont')

    hsRes.searchresult = new ContSearchAdmin().csiSelectTrip(0l,hsRes.cont?:'',0l,20,requestService.getOffset())

    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=[shortname:container.shortname,name:container.name];map}
    hsRes.tripstatus = Tripstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.taskstatus = Taskstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.status,icon:status.icon];map}
    hsRes.zakazstatus = Zakazstatus.list().inject([:]){map, status -> map[status.id]=[descr:status.modstatus,icon:status.icon];map}

    return hsRes
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Contsearch <<<////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Reports <<<///////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def reports = {
    checkAccess(13)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 13
    hsRes.admin = session.admin

    hsRes.clientnames = new PayorderSearchShipper().getclientnames()
    hsRes.carriernames = new PayorderSearchCarrier().getclientnames()

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def contreport = {
    checkAccess(13)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 13
    hsRes.admin = session.admin

    hsRes.contreport_date = requestService.getRaw('contreport_date')
    hsRes.manager_id = requestService.getIntDef('manager_id',0)

    hsRes.report = new TripSearchAdmin().csiSelectTripForContreport(0l,0l,hsRes.contreport_date)
    hsRes.orders = hsRes.report.records.inject([:]){map, trip -> map[trip.id]=Zakaz.get(trip.zakaz_id);map}
    hsRes.pricesum = hsRes.priceshsum = hsRes.contcol = hsRes.benefitsum = 0
    hsRes.contcolthispage = 8
    hsRes.pages = []
    hsRes.report.records.each{
      if(!hsRes.manager_id||hsRes.manager_id==hsRes.orders[it.id]?.manager_id?:0){
        if (hsRes.contcolthispage>=8){ hsRes.pages << it.id; hsRes.contcolthispage = 0 }
        hsRes.pricesum += it.price
        hsRes.priceshsum += it.price_sh
        hsRes.contcol++
        hsRes.contcolthispage++
        hsRes.benefitsum += hsRes.orders[it.id]?.benefit?:0
        if (it.containernumber2) {
          hsRes.pricesum += it.price
          hsRes.priceshsum += it.price_sh
          hsRes.contcol++
          hsRes.contcolthispage++
          hsRes.benefitsum += hsRes.orders[it.id]?.benefit?:0
        }
      }
    }
    hsRes.reportMonth = message(code:'calendar.monthName').split(',')[requestService.getIntDef('contreport_date_month',1)]
    hsRes.reportYear = requestService.getIntDef('contreport_date_year',2013)

    if (requestService.getStr('viewtype')!='table') {
      renderPdf(template: 'contreport', model: hsRes, filename: "contreport.pdf")
      return
    }
    return hsRes
  }

  def contreportXLS = {
    checkAccess(13)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 13
    hsRes.admin = session.admin

    hsRes.contreport_date = requestService.getRaw('contreport_date')
    hsRes.manager_id = requestService.getIntDef('manager_id',0)

    hsRes.report = new TripSearchAdmin().csiSelectTripForContreport(0l,0l,hsRes.contreport_date)
    hsRes.orders = hsRes.report.records.inject([:]){map, trip -> map[trip.id]=Zakaz.get(trip.zakaz_id);map}
    hsRes.pricesum = hsRes.priceshsum = hsRes.contcol = hsRes.benefitsum = 0
    hsRes.report.records.each{
      if(!hsRes.manager_id||hsRes.manager_id==hsRes.orders[it.id]?.manager_id?:0){
        hsRes.pricesum += it.price
        hsRes.priceshsum += it.price_sh
        hsRes.contcol++
        hsRes.benefitsum += hsRes.orders[it.id]?.benefit?:0
        if (it.containernumber2) {
          hsRes.pricesum += it.price
          hsRes.priceshsum += it.price_sh
          hsRes.contcol++
          hsRes.benefitsum += hsRes.orders[it.id]?.benefit?:0
        }
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
        fillRow(['Дата отправления','Отправитель','Маршрут','Ставка отправителя','Ставка перевозчика','Вознаграждение','Номер контейнера','Дата сдачи документов','ФИО водителя','Госномер автомобиля','Перевозчик'],3,false)
        (0..<reportsize).eachWithIndex{ rowNumber, idx ->
          if(!hsRes.manager_id||hsRes.manager_id==hsRes.orders[hsRes.report.records[idx].id]?.manager_id?:0){
            fillRow([String.format('%td/%<tm/%<tY',hsRes.report.records[idx].dateA),hsRes.report.records[idx].shippername,
              hsRes.report.records[idx].addressA+" "+(hsRes.report.records[idx].addressB?:"")+" "+(hsRes.report.records[idx].addressC?:"")+" "+(hsRes.report.records[idx].addressD?:""),
              hsRes.report.records[idx].price_sh, hsRes.report.records[idx].price, hsRes.orders[hsRes.report.records[idx].id]?.benefit,
              hsRes.report.records[idx].containernumber1,
              hsRes.report.records[idx].taskstatus>5?String.format('%td/%<tm/%<tY',hsRes.report.records[idx].docdate):'не сданы',
              hsRes.report.records[idx].driver_fullname, hsRes.report.records[idx].cargosnomer,hsRes.report.records[idx].carriername], rowCounter++, false)
            if (hsRes.report.records[idx].containernumber2) {
              fillRow([String.format('%td/%<tm/%<tY',hsRes.report.records[idx].dateA),hsRes.report.records[idx].shippername,
                hsRes.report.records[idx].addressA+" "+(hsRes.report.records[idx].addressB?:"")+" "+(hsRes.report.records[idx].addressC?:"")+" "+(hsRes.report.records[idx].addressD?:""),
                hsRes.report.records[idx].price_sh, hsRes.report.records[idx].price, hsRes.orders[hsRes.report.records[idx].id]?.benefit,
                hsRes.report.records[idx].containernumber2,
                hsRes.report.records[idx].taskstatus>5?String.format('%td/%<tm/%<tY',hsRes.report.records[idx].docdate):'не сданы',
                hsRes.report.records[idx].driver_fullname, hsRes.report.records[idx].cargosnomer,hsRes.report.records[idx].carriername], rowCounter++, false)
            }
          }
        }
        fillRow(["ИТОГО", "", "", hsRes.priceshsum, hsRes.pricesum, hsRes.priceshsum-hsRes.pricesum-hsRes.benefitsum, hsRes.contcol,
          "", "", "", ""], rowCounter++, false)
        save(response.outputStream)
      }
    }
  }

  def zakazreport = {
    checkAccess(13)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 13
    hsRes.admin = session.admin

    hsRes.zakazreport_date = requestService.getRaw('zakazreport_date')

    def oObject = new ZakazReportSearch()
    hsRes.report = oObject.csiSelectZakaz(hsRes.zakazreport_date)
    hsRes.pricesum = hsRes.priceshsum = hsRes.tripcount = hsRes.carriersum = 0
    hsRes.report.each{
      hsRes.pricesum += it.trippricesum
      hsRes.priceshsum += it.price*it.zcol
      hsRes.tripcount += it.tripcount
      hsRes.carriersum += it.carriercount
    }
    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=container.shortname;map}
    hsRes.reportMonth = message(code:'calendar.monthName').split(',')[requestService.getIntDef('zakazreport_date_month',1)]
    hsRes.reportYear = requestService.getIntDef('zakazreport_date_year',2013)

    renderPdf(template: 'zakazreport', model: hsRes, filename: "zakazreport.pdf")
    return
  }

  def zakazreportXLS = {
    checkAccess(13)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 13
    hsRes.admin = session.admin

    hsRes.zakazreport_date = requestService.getRaw('zakazreport_date')

    def oObject = new ZakazReportSearch()
    hsRes.report = oObject.csiSelectZakaz(hsRes.zakazreport_date)
    hsRes.pricesum = hsRes.priceshsum = hsRes.tripcount = hsRes.carriersum = 0
    hsRes.report.each{
      hsRes.pricesum += it.trippricesum
      hsRes.priceshsum += it.price*it.zcol
      hsRes.tripcount += it.tripcount
      hsRes.carriersum += it.carriercount
    }
    hsRes.containers = Container.list().inject([:]){map, container -> map[container.id]=container.shortname;map}
    hsRes.reportMonth = message(code:'calendar.monthName').split(',')[requestService.getIntDef('zakazreport_date_month',1)]
    hsRes.reportYear = requestService.getIntDef('zakazreport_date_year',2013)

    if (hsRes.report.size()==0) {
      new WebXlsxExporter().with {
        setResponseHeaders(response)
        putCellValue(0, 4, "Нет данных за указанный период")
        save(response.outputStream)
      }
    } else {
      def rowCounter = 4
      new WebXlsxExporter().with {
        setResponseHeaders(response)
        putCellValue(0, 5, "Отчет по заказам за ${hsRes.reportMonth} ${hsRes.reportYear}г.")
        fillRow(['Номер','Дата начала','Отправитель','Тип контейнера','Кол-во контейнеров','Маршрут','Кол-во поездок','Ставка отправителя','Сумма заказа','Сумма услуг по перевозке'],3,false)
        hsRes.report.each{ record ->
          fillRow([record.id, String.format('%td/%<tm/%<tY',record.date_start), record.shippername,
            hsRes.containers[record.container], record.zcol,
            record.addressA+" "+(record.addressB?:"")+" "+(record.addressC?:"")+" "+(record.addressD?:""),
            record.tripcount, record.price, record.price*record.zcol, record.trippricesum], rowCounter++, false)
        }
        fillRow(["ИТОГО", hsRes.report.size(), "", "", "", "", hsRes.tripcount+'/'+hsRes.carriersum, "",
          hsRes.priceshsum, hsRes.pricesum], rowCounter++, false)
        fillRow(["ИТОГО ДОХОД", "", hsRes.priceshsum-hsRes.pricesum], rowCounter++, false)
        save(response.outputStream)
      }
    }
    return
  }

  def shsettlmentreport = {
    checkAccess(13)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 13
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(['year'],['client_id'])

    hsRes.searchresult = new PayorderSearchShipper().findOrdersForShSettlementsReport(hsRes.inrequest.client_id?:0,hsRes.inrequest.year?:(new Date().getYear()+1900),0,0)
    hsRes.client = Client.get(hsRes.inrequest.client_id?:0)

    hsRes.pricesum = hsRes.debtsum = hsRes.arrearssum = 0
    hsRes.searchresult.records.each{
      hsRes.pricesum += it.fullcost+it.idlesum+it.forwardsum
      hsRes.arrearssum += it.debt
      if(it.debt>0&&it.maxpaydate?.before(new Date().clearTime()))
        hsRes.debtsum += it.debt
    }

    renderPdf(template: 'shsettlmentreport', model: hsRes, filename: "shsettlmentreport.pdf")
    return
  }

  def shsettlmentreportXLS = {
    checkAccess(13)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 13
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(['year'],['client_id'])

    hsRes.searchresult = new PayorderSearchShipper().findOrdersForShSettlementsReport(hsRes.inrequest.client_id?:0,hsRes.inrequest.year?:(new Date().getYear()+1900),0,0)
    hsRes.client = Client.get(hsRes.inrequest.client_id?:0)

    hsRes.pricesum = hsRes.debtsum = hsRes.arrearssum = 0
    hsRes.searchresult.records.each{
      hsRes.pricesum += it.fullcost+it.idlesum+it.forwardsum
      hsRes.arrearssum += it.debt
      if(it.debt>0&&it.maxpaydate?.before(new Date().clearTime()))
        hsRes.debtsum += it.debt
    }

    if (hsRes.searchresult.records.size()==0) {
      new WebXlsxExporter().with {
        setResponseHeaders(response)
        putCellValue(0, 4, "Нет данных за указанный период")
        save(response.outputStream)
      }
    } else {
      def rowCounter = 4
      new WebXlsxExporter().with {
        setResponseHeaders(response)
        putCellValue(0, 5, "Сверка ${hsRes.client?.fullname?'с '+hsRes.client.fullname:'сводная'} за ${hsRes.inrequest.year?:(new Date().getYear()+1900)}г.")
        fillRow(['Счет','Дата счета','Контейнеры','Срок оплаты','К оплате','в.т.ч. простой','в.т.ч. переадресация','Оплачено','Дата','Долг'],3,false)
        hsRes.searchresult.records.each{ record ->
          fillRow([record.norder, String.format('%td.%<tm.%<tY',record.orderdate),record.contnumbers.split(',').join('\n'),
            (!record.debt?'оплачено':record.maxpaydate?String.format('%td.%<tm.%<tY',record.maxpaydate):'документы не переданы'),
            record.fullcost+record.idlesum+record.forwardsum,record.idlesum,record.forwardsum,record.paid?:'',(record.lastpayment?String.format('%td.%<tm.%<tY',record.lastpayment):'нет'),
            (record.debt>0&&record.maxpaydate?.before(new Date().clearTime())?record.debt:'нет')], rowCounter++, false)
        }
        fillRow(["","","ИТОГО ЗАКАЗОВ", hsRes.searchresult.records.size()], rowCounter++, false)
        fillRow(["","","ИТОГО ОБОРОТ", hsRes.pricesum], rowCounter++, false)
        fillRow(["","","ИТОГО ЗАДОЛЖЕННОСТЬ С УЧЕТОМ ПЕРЕПЛАТ", hsRes.arrearssum], rowCounter++, false)
        fillRow(["","","ИТОГО ДОЛГ", hsRes.debtsum], rowCounter++, false)
        save(response.outputStream)
      }
    }
    return
  }

  def casettlmentreport = {
    checkAccess(13)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 13
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(['year'],['client_id'])

    hsRes.searchresult = new PayorderSearchCarrier().findOrdersForCarrierSettlements(0,hsRes.inrequest.client_id,hsRes.inrequest.year?:(new Date().getYear()+1900),'',0,0,0)
    hsRes.payments = hsRes.searchresult.records.inject([:]){map, trip -> map[trip.id]=Payment.findAllByTrip_id(trip.id);map}
    hsRes.client = Client.get(hsRes.inrequest.client_id?:0)

    hsRes.pricesum = hsRes.paidsum = hsRes.debtsum = 0
    hsRes.searchresult.records.each{
      hsRes.pricesum += it.ca_price+(it.cont2?it.ca_price:0)+it.ca_idlesum+it.ca_forwardsum
      hsRes.paidsum += it.ca_paid
      if(it.debt>0&&it.ca_maxpaydate?.before(new Date().clearTime()))
        hsRes.debtsum += it.debt
    }
    hsRes.taxsum = Paytax.findAll{client_id==(hsRes.inrequest.client_id?:0) && year(paydate)==(hsRes.inrequest.year?:(new Date().getYear()+1900))}.sum{it.summa}?:0

    renderPdf(template: 'casettlmentreport', model: hsRes, filename: "casettlmentreport.pdf")
    return
  }

  def casettlmentreportXLS = {
    checkAccess(13)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 13
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(['year'],['client_id'])

    hsRes.searchresult = new PayorderSearchCarrier().findOrdersForCarrierSettlements(0,hsRes.inrequest.client_id,hsRes.inrequest.year?:(new Date().getYear()+1900),'',0,0,0)
    hsRes.payments = hsRes.searchresult.records.inject([:]){map, trip -> map[trip.id]=Payment.findAllByTrip_id(trip.id);map}
    hsRes.client = Client.get(hsRes.inrequest.client_id?:0)

    hsRes.pricesum = hsRes.paidsum = hsRes.debtsum = 0
    hsRes.searchresult.records.each{
      hsRes.pricesum += it.ca_price+(it.cont2?it.ca_price:0)+it.ca_idlesum+it.ca_forwardsum
      hsRes.paidsum += it.ca_paid
      if(it.debt>0&&it.ca_maxpaydate?.before(new Date().clearTime()))
        hsRes.debtsum += it.debt
    }
    hsRes.taxsum = Paytax.findAll{client_id==(hsRes.inrequest.client_id?:0) && year(paydate)==(hsRes.inrequest.year?:(new Date().getYear()+1900))}.sum{it.summa}?:0

    if (hsRes.searchresult.records.size()==0) {
      new WebXlsxExporter().with {
        setResponseHeaders(response)
        putCellValue(0, 4, "Нет данных за указанный период")
        save(response.outputStream)
      }
    } else {
      def rowCounter = 4
      new WebXlsxExporter().with {
        setResponseHeaders(response)
        putCellValue(0, 5, "Сверка ${hsRes.client?.fullname?'с '+hsRes.client.fullname:'сводная'} за ${hsRes.inrequest.year?:(new Date().getYear()+1900)}г.")
        fillRow(['Заказ','Дата заказа','Поездка','Водитель','Тягач','Маршрут','Контейнеры','Дата сдачи\nдокументов','К оплате','ставка','простой','переадресация','абон. плата','Оплачено','Дата','Срок оплаты','Долг','Платежи'],3,false)
        hsRes.searchresult.records.each{ record ->
          fillRow([record.zakaz_id, String.format('%td.%<tm.%<tY',record.zakazdate), record.id,
            record.drivername,record.cargosnomer,(record.is_longtrip?'дальний':'ближний'),
            (record.cont1+(record.cont2?'\n'+record.cont2:'')), (record.docdate?String.format('%td.%<tm.%<tY',record.docdate):'документы не сданы'),
            (record.ca_price+(record.cont2?record.ca_price:0)+record.ca_idlesum+record.ca_forwardsum-record.ca_trackertax), record.ca_price, record.ca_idlesum, record.ca_forwardsum, record.ca_trackertax,
            record.ca_paid?:'', (record.ca_lastpaydate?String.format('%td.%<tm.%<tY',record.ca_lastpaydate):'нет'),
            (record.ca_maxpaydate?String.format('%td.%<tm.%<tY',record.ca_maxpaydate):'документы не сданы'),
            (record.debt>0&&record.ca_maxpaydate?.before(new Date().clearTime())?record.debt:'нет'),
            hsRes.payments[record.id].collect{ payment -> String.format('%td.%<tm.%<tY',payment.paydate)+' '+payment.summa+' '+payment.norder}.join('\n')], rowCounter++, false)
        }
        if (hsRes.inrequest.client_id) fillRow(["","","","СУММА НАЧИСЛЕННОЙ АБОНЕНТСКОЙ ПЛАТЫ", hsRes.taxsum,"","","","","","","","","","","",""], rowCounter++, false)
        fillRow(["","","","ИТОГО ПОЕЗДОК", hsRes.searchresult.records.size(),"","","","","","","","","","","",""], rowCounter++, false)
        fillRow(["","","","ИТОГО К ВЫПЛАТАМ", hsRes.pricesum,"","","","","","","","","","","",""], rowCounter++, false)
        fillRow(["","","","ИТОГО ВЫПЛАЧЕНО", hsRes.paidsum,"","","","","","","","","","","",""], rowCounter++, false)
        fillRow(["","","","ИТОГО ЗАДОЛЖЕННОСТЬ", hsRes.pricesum-hsRes.paidsum,"","","","","","","","","","","",""], rowCounter++, false)
        fillRow(["","","","ИТОГО ДОЛГ", hsRes.debtsum,"","","","","","","","","","","",""], rowCounter++, false)
        save(response.outputStream)
      }
    }
    return
  }

  def totalshreport = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 13
    hsRes.admin = session.admin

    hsRes.report = new ReportSearchMain().getReportShipper()

    hsRes.arrearssum = hsRes.debtsum = 0
    hsRes.detailed = [:]
    hsRes.virtualprofit = [:]
    hsRes.report.each{
      hsRes.arrearssum += it.arrears
      hsRes.debtsum += it.totaldebt
      hsRes.virtualprofit[it.client_id] = Trip.findAllByShipperAndPayorder_idAndModstatusGreaterThan(it.client_id,0,-1).sum{it.zakazcost}?:0
    }
    hsRes.detailed = new PayorderSearchShipper().findOrdersForShipperSettlements(0,0,0,'',0,0,1,0,0,0,0,0)

    renderPdf(template: 'totalshreport', model: hsRes, filename: "totalshreport.pdf")
    return
  }

  def totalcareport = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 13
    hsRes.admin = session.admin

    hsRes.report = new ReportSearchMain().getReportCarrier(requestService.getIntDef('daydiff',0))

    hsRes.arrearssum = hsRes.debtsum = 0
    hsRes.report.each{
      hsRes.arrearssum += it.arrears
      hsRes.debtsum += it.totaldebt
    }

    if (requestService.getStr('viewtype')!='table') {
      renderPdf(template: 'totalcareport', model: hsRes, filename: "totalcareport.pdf")
      return
    }

    return hsRes
  }

  def managerstat = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 13
    hsRes.admin = session.admin

    hsRes.managerstat_date = requestService.getRaw('managerstat_date')
    hsRes.kprofit = Tools.getFloatVal(Dynconfig.findByName('profit.effency.modifier')?.value,0.915f)

    hsRes.report = new ManagerStatCurr().getStatByMonth(hsRes.managerstat_date)
    hsRes.thismonth = hsRes.managerstat_date
    hsRes.thismonth.setDate(1)
    hsRes.thismonth.clearTime()
    hsRes.i = 0

    hsRes.dayprofit = []
    hsRes.dayincome = []
    hsRes.managerprofit = [:]
    (hsRes.thismonth..hsRes.thismonth+31).each{ date ->
      hsRes.dayincome << (hsRes.report.findAll{it.inputdate.clone().clearTime()==date}?.sum{it.totalzakazcost-it.totalbenefit}?:0)
      hsRes.dayprofit << Math.round((hsRes.report.findAll{it.inputdate.clone().clearTime()==date}?.sum{it.totalzakazcost-it.totalcarrcost}?:0)*hsRes.kprofit-(hsRes.report.findAll{it.inputdate.clone().clearTime()==date}?.sum{it.totalbenefit}?:0))
    }
    hsRes.report.collect{it.manager_id}.unique().each{ mng ->
      hsRes.managerprofit[mng] = Math.round((hsRes.report.findAll{it.manager_id==mng}?.sum{it.totalzakazcost-it.totalcarrcost}?:0)*hsRes.kprofit-(hsRes.report.findAll{it.manager_id==mng}?.sum{it.totalbenefit}?:0))
    }
    hsRes.reportMonth = message(code:'calendar.monthName').split(',')[requestService.getIntDef('managerstat_date_month',1)]
    hsRes.reportYear = requestService.getIntDef('managerstat_date_year',2013)

    renderPdf(template: 'managerstat', model: hsRes, filename: "managerstat.pdf")
    return
  }

  def taxreport = {
    checkAccess(13)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 13
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(['taxreport_date_year','taxreport_date_month'])

    hsRes.report = new TaxReportSearch().csiSearchTax(hsRes.inrequest.taxreport_date_year,hsRes.inrequest.taxreport_date_month)

    if (requestService.getStr('viewtype')!='table') {
      //nothing to do here now
    }
    return hsRes
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Reports <<<///////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Guestbook <<</////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def guestbook = {
    checkAccess(14)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 14
    hsRes.admin = session.admin

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def guestbooklist = {
    checkAccess(14)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 14
    hsRes.admin = session.admin

    def iStatus = requestService.getIntDef('status',0)

    hsRes.searchresult = Guestbook.findAllByModstatus(iStatus,[sort:'inputdate',order:'desc',max:20,offset:requestService.getOffset()])
    hsRes.searchcount = Guestbook.countByModstatus(iStatus)

    return hsRes
  }

  def deletemessage={
    checkAccess(14)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 14
    hsRes.admin = session.admin

    def lId = requestService.getIntDef('id',0)

    if(lId>0){
      Guestbook.get(lId)?.delete(flush:true)
    }

    render(contentType:"application/json"){[error:false]}
  }

  def readmessage={
    checkAccess(14)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 14
    hsRes.admin = session.admin

    def lId = requestService.getIntDef('id',0)

    if(lId>0){
      Guestbook.get(lId)?.readmessage().save(flush:true)
    }

    render(contentType:"application/json"){[error:false]}
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Guestbook <<</////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Autopilot <<</////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def autopilot={
    checkAccess(15)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 15
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(['is_on','margin'])

    def result = [:]
    result.errorcode = []

    if (hsRes.inrequest.margin<=0||hsRes.inrequest.margin>90) {
      result.errorcode << 1
    }
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      def oAdminmenu = Adminmenu.get(15).setAutopilotData(hsRes.inrequest).save(failOnError:true,flush:true)
      session.admin.menu = oAdminmenu.csiGetMenu(session.admin.group)
    } catch(Exception e) {
      log.debug("Error save data in Admin/autopilot\n"+e.toString());
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}

  }

  def getstat = {
    def hsRes = [
            curDayOrder: Zakaz.countByInputdateBetween(new Date().clearTime(),new Date().clearTime()+1),
            notEndedTrip: Trip.countByModstatusInList(0..1),
            notDeliveredCont: Trip.countByTaskstatusLessThanAndModstatusGreaterThan(5,-1),
            requestsCount: Trip.countByTaskstatusInListAndModstatusGreaterThan([1,3],-2),
            freecarCount: Freecars.countByModstatus(1)
        ]
    return hsRes
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// Autopilot <<</////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// syscompany >>>/////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def syscompany = {
    checkAccess(16)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 16
    hsRes.admin = session.admin

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def syscompanylist = {
    checkAccess(16)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 16
    hsRes.admin = session.admin    
    
    def iStatus = requestService.getIntDef('status',1)

    hsRes.searchresult = Syscompany.findAllByModstatus(iStatus)    
    
    return hsRes
  }
  def syscompanydetail={
    checkAccess(16)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=16
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)

    hsRes.syscompany = Syscompany.get(lId)
    if (!hsRes.syscompany&&lId) {
      response.sendError(404)
      return
    }   

    return hsRes
  }

  def saveSyscompanyDetail={
    checkAccess(16)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)

    def lId=requestService.getIntDef('id',0)
    hsRes+=requestService.getParams(['ctype_id','nds'],null,['name','inn','kpp','fulladdress','bik','corschet','account','ogrn','bank','chief','accountant'])

    def result = [:]
    result.errorcode = []
    if (!hsRes.inrequest.name)
      result.errorcode << 1
    if (!hsRes.inrequest.inn)
      result.errorcode << 2
    if (!hsRes.inrequest.fulladdress)
      result.errorcode << 3
    if (!hsRes.inrequest.bik)
      result.errorcode << 4
    if (!hsRes.inrequest.corschet)
      result.errorcode << 5
    if (!hsRes.inrequest.account)
      result.errorcode << 6
    if (!hsRes.inrequest.nds&&!requestService.getStr('nds').matches('0'))
      result.errorcode << 7
    if (!hsRes.inrequest.bank)
      result.errorcode << 8
    if (!hsRes.inrequest.chief)
      result.errorcode << 9
    if (!hsRes.inrequest.accountant)
      result.errorcode << 10

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }

    if(!lId)
      hsRes.syscompany = new Syscompany()
    else
      hsRes.syscompany = Syscompany.get(lId)

    if (!hsRes.syscompany&&lId) {
      response.sendError(404)
      return
    }

    try {
      hsRes.syscompany.csiSetData(hsRes.inrequest).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/saveSyscompanyDetail\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    } else
      render(contentType:"application/json"){[error:false,uId:hsRes.syscompany.id]}
      return
  }

  def activateSyscompany={
    checkAccess(16)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    def iId=requestService.getIntDef('id',0)
    def iStatus=requestService.getIntDef('status',0)
    
    def oSyscompany = Syscompany.get(iId)
      
    if (!oSyscompany&&iId) {
      response.sendError(404)
      return
    }
    
    oSyscompany.modstatus=iStatus
    
    if (!oSyscompany.save(flush:true)){
      log.debug('error on save oSyscompany in Admin:activateSyscompany')
      oSyscompany.errors.each{log.debug(it)}
    }      

    render(contentType:"application/json"){[error:false]}
    return        
  }  
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////// syscompany <<<////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Orders >>>//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def payorders = {
    checkAccess(17)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=17
    hsRes.admin = session.admin

    hsRes.type = requestService.getIntDef('type',0)
    hsRes.clientnames = new PayorderSearchShipper().getclientnames()
    hsRes.clientcompanies = new PayorderSearchShipper().getclientcompanies()

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def payorderlist = {
    checkAccess(17)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=17
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(['syscompany_id','modstatus','is_act','is_docdate'],['clientcompany_id','client_id'],['norder'])

    def oSearchObj = new Payorder()
    hsRes.searchresult = oSearchObj.findOrders(hsRes.inrequest.zakaz_id?:0,hsRes.inrequest.modstatus?:0,
                                               hsRes.inrequest.syscompany_id?:0,hsRes.inrequest.norder?:'',
                                               hsRes.inrequest.clientcompany_id?:0,hsRes.inrequest.client_id?:0,
                                               hsRes.inrequest.is_act?:0,hsRes.inrequest.is_docdate?:0,20,requestService.getOffset())
    hsRes.syscompanies = Syscompany.list().inject([:]){map, company -> map[company.id]=company.name;map}

    return hsRes
  }

  def paymentlist = {
    checkAccess(17)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=17
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(['modstatus','is_fix'],['payorder_id','clientpayment_id'],['platnumber','norder'])

    def oSearchObj = new Payment()
    hsRes.searchresult = oSearchObj.findPayment(hsRes.inrequest.zakaz_id?:0,hsRes.inrequest.payorder_id?:0,hsRes.inrequest.modstatus?:0,
                                                hsRes.inrequest.norder?:'',hsRes.inrequest.platnumber?:'',
                                                hsRes.inrequest.clientpayment_id?:0,hsRes.inrequest.is_fix?:0,20,requestService.getOffset())
    hsRes.clientnames = hsRes.searchresult.records.collect{it.client_id}.unique().collect{Client.get(it)}.inject([:]){map, client -> map[client?.id?:0]=client?.fullname?:'';map}

    return hsRes
  }

  def payorderdetail = {
    checkAccess(17)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=17
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)

    hsRes.payorder = Payorder.get(lId)
    if (!hsRes.payorder) {
      response.sendError(404)
      return
    }

    hsRes.clientcompanies = Clientrequisites.findAllByClient_idAndModstatusGreaterThanEquals(hsRes.payorder.client_id,0)
    hsRes.curclientcompany = Clientrequisites.get(hsRes.payorder.clientcompany_id)
    hsRes.cursyscompany = Syscompany.get(hsRes.payorder.syscompany_id)

    return hsRes
  }

  def savePayorderDetail={
    checkAccess(17)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 17
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)
    hsRes+=requestService.getParams(['syscompany_id'],['clientcompany_id'])
    hsRes.inrequest.docdate = requestService.getDate('docdate')

    hsRes.payorder = Payorder.get(lId)
    if (!hsRes.payorder) {
      response.sendError(404)
      return
    }

    def result = [errorcode:[]]

    try {
      hsRes.payorder.updateCompanies(hsRes.inrequest).updateDocdate(hsRes.inrequest.docdate).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/savePayorderDetail\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
  }

  def generateorders={
    checkAccess(17)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 17
    hsRes.admin = session.admin

    billingService.generateNewOrders()

    render(contentType:"application/json"){[error:false]}
  }

  def unloadingOrders={
    checkAccess(17)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 17
    hsRes.admin = session.admin

    response.setHeader("Content-disposition", "attachment; filename=scheta_to_1c.xml")
    render(contentType: "text/xml", encoding: "windows-1251", text:billingService.prepareXmlDataFor1SUnloading())
  }

  def uploadingOrders = {
    checkAccess(17)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 17
    hsRes.admin = session.admin

    try {
      hsRes.result = billingService.importXmlDataFrom1S(request.getFile('file'))
    } catch(Exception e) {
      log.debug('Error uploading XML from 1s: '+e.toString())
      hsRes.result = 'Неверный файл'
    }
    render(view:"uploading${requestService.getStr('type')}",model:hsRes)
  }

  def unloadingPayments={
    checkAccess(17)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 17
    hsRes.admin = session.admin

    response.setHeader("Content-disposition", "attachment; filename=oplata_to_1c.xml")
    render(contentType: "text/xml", encoding: "windows-1251", text:billingService.prepareXmlPaymentDataFor1SUnloading())
  }

  def documenttransfer = {
    checkAccess(17)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 17
    hsRes.admin = session.admin

    def lId = requestService.getIntDef('id',0)

    hsRes.payorder = Payorder.get(lId)
    if (!hsRes.payorder) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    try {
      hsRes.payorder.updateDocdate(new Date()).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/documenttransfer\n"+e.toString());
    }

    render(contentType:"application/json"){[error:false]}
  }

  def cancelltransfer = {
    checkAccess(17)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 17
    hsRes.admin = session.admin

    def lId = requestService.getIntDef('id',0)

    hsRes.payorder = Payorder.get(lId)
    if (!hsRes.payorder) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    try {
      hsRes.payorder.updateDocdate(null).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/cancelltransfer\n"+e.toString());
    }

    render(contentType:"application/json"){[error:false]}
  }

  def orderactconfirm = {
    checkAccess(17)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 17
    hsRes.admin = session.admin

    def lId = requestService.getIntDef('id',0)

    hsRes.payorder = Payorder.get(lId)
    if (!hsRes.payorder) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    try {
      hsRes.payorder.csiSetAct(1).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/orderactconfirm\n"+e.toString());
    }

    render(contentType:"application/json"){[error:false]}
  }

  def cancellorderract = {
    checkAccess(17)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 17
    hsRes.admin = session.admin

    def lId = requestService.getIntDef('id',0)

    hsRes.payorder = Payorder.get(lId)
    if (!hsRes.payorder) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    try {
      hsRes.payorder.csiSetAct(0).save(failOnError:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/cancellorderract\n"+e.toString());
    }

    render(contentType:"application/json"){[error:false]}
  }

  def newpayment = {
    checkAccess(17)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=17
    hsRes.admin = session.admin

    hsRes.clientnames = new PayorderSearchShipper().getclientnames()
    hsRes.clientcompanies = new PayorderSearchShipper().getclientcompanies()

    return hsRes
  }

  def nonpaidorders = {
    checkAccess(17)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=17
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(null,['client_id','clientcompany_id'])

    hsRes.searchresult = new PayorderSearchShipper().findNonPaidOrders(hsRes.inrequest.client_id?:0l,hsRes.inrequest.clientcompany_id?:0l,requestService.getOffset())

    return hsRes
  }

  def orderpay = {
    checkAccess(17)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=17
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(['summa'],['payorder_id'],['platnumber'])

    hsRes.payorder = Payorder.get(hsRes.inrequest.payorder_id)
    if (!hsRes.payorder) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    def result = [errorcode:[]]
    if (!hsRes.inrequest.platnumber)
      result.errorcode << 1
    else if (Payment.findAllByZakaz_idAndPaydateAndPlatnumber(hsRes.payorder.trip_id?:hsRes.payorder.zakaz_id,new Date().clearTime(),hsRes.inrequest.platnumber))
      result.errorcode << 4
    if (!hsRes.inrequest.summa)
      result.errorcode << 2
    else if (hsRes.inrequest.summa<0)
      result.errorcode << 3

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }

    try {
      new Payment().setShipperPayment(hsRes.payorder,hsRes.inrequest).save(failOnError:true,flush:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/orderpay\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
    return
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Orders <<<//////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Financial >>>///////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def financial = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=18
    hsRes.admin = session.admin

    hsRes.type = requestService.getIntDef('type',0)
    def fromDetails = requestService.getIntDef('fromDetails',0)
    if (fromDetails&&session.lastRequest){
      session.lastRequest.fromDetails = fromDetails
      hsRes.inrequest = session.lastRequest
      hsRes.type = session.lastRequest.shsettlparams?0:session.lastRequest.casettlparams?1:session.lastRequest.prsettlparams?2:hsRes.type
    }
    hsRes.clientnames = new PayorderSearchShipper().getclientnames()
    hsRes.clientcompanies = new PayorderSearchShipper().getclientcompanies()

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def shippersettlements = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=18
    hsRes.admin = session.admin

    if (session.lastRequest?.fromDetails?:0) {
      hsRes.inrequest = session.lastRequest.shsettlparams?:[:]
      session.lastRequest.fromDetails = 0
    } else {
      hsRes+=requestService.getParams(['syscompany_id','admin_id','sort','debt','benefit','overpayment'],['zakaz_id','client_id','clientcompany_id'],['norder'])
      session.lastRequest = [:]
      session.lastRequest.shsettlparams = hsRes.inrequest+[type:1]
    }

    hsRes.searchresult = new PayorderSearchShipper().findOrdersForShipperSettlements(hsRes.inrequest.zakaz_id?:0,hsRes.inrequest.client_id?:0,
                                                hsRes.inrequest.syscompany_id?:0,hsRes.inrequest.norder?:'',
                                                hsRes.inrequest.benefit?:0,hsRes.inrequest.admin_id?:0,hsRes.inrequest.debt?:0,
                                                hsRes.inrequest.clientcompany_id?:0,hsRes.inrequest.overpayment?:0,
                                                hsRes.inrequest.sort?:0,20,requestService.getOffset())
    hsRes.trips = hsRes.searchresult.records.inject([:]){map, order -> map[order.id]=new TripSearch().csiSelectTrip(order.id);map}

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def carriersettlements = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=18
    hsRes.admin = session.admin

    if (session.lastRequest?.fromDetails?:0) {
      hsRes.inrequest = session.lastRequest.casettlparams?:[:]
      session.lastRequest.fromDetails = 0
    } else {
      hsRes+=requestService.getParams(['admin_id_carrier','sort','debt','daydiff','is_tracker'],['zakaz_id','trip_id'],['contnumber','carrier'])
      session.lastRequest = [:]
      session.lastRequest.casettlparams = hsRes.inrequest+[type:2]
    }

    def oSearchObj = new PayorderSearchCarrier()
    hsRes.searchresult = oSearchObj.findOrdersForCarrierSettlements(hsRes.inrequest.zakaz_id?:0,hsRes.inrequest.trip_id?:0,
                                        hsRes.inrequest.carrier?:'',hsRes.inrequest.contnumber?:'',hsRes.inrequest.admin_id_carrier?:0,
                                        hsRes.inrequest.debt?:0,hsRes.inrequest.sort?:0,20,requestService.getOffset(),
                                        hsRes.inrequest.daydiff?:0,hsRes.inrequest.is_tracker?:0)

    return hsRes
  }

  def carriersettlementsXLS = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=18
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(['admin_id_carrier','sort','debt','daydiff','is_tracker'],['zakaz_id','trip_id'],['contnumber','carrier'])

    hsRes.searchresult = new PayorderSearchCarrier().findOrdersForCarrierSettlements(hsRes.inrequest.zakaz_id?:0,hsRes.inrequest.trip_id?:0,
                                        hsRes.inrequest.carrier?:'',hsRes.inrequest.contnumber?:'',hsRes.inrequest.admin_id_carrier?:0,
                                        hsRes.inrequest.debt?:0,hsRes.inrequest.sort?:0,0,requestService.getOffset(),
                                        hsRes.inrequest.daydiff?:0,hsRes.inrequest.is_tracker?:0)

    if (hsRes.searchresult.records.size()==0) {
      new WebXlsxExporter().with {
        setResponseHeaders(response)
        putCellValue(0, 4, "Нет данных за указанный период")
        save(response.outputStream)
      }
    } else {
      def rowCounter = 4
      new WebXlsxExporter().with {
        setResponseHeaders(response)
        fillRow(['Поездка','ID счета','Сис. компания','Перевозчик','Отправитель','Сумма отправителя','Статус оплаты','Контейнеры','Водитель','Тягач','К оплате','Оплачено','Долг','Дата оплаты','Номер платежки','Сумма оплаты'],3,false)
        hsRes.searchresult.records.each{ record ->
          fillRow([record.id, record.order_id, Syscompany.get(record.syscompany_id)?.name?:'', record.carrier_name, record.shipper_name, record.fullcost+record.idlesum+record.forwardsum,
                   !record.paystatus?'неоплачено':record.paystatus==1?'частично оплачено':'оплачено',
                   record.cont1+(record.cont2?', '+record.cont2:''),record.drivername,record.cargosnomer,
                   record.ca_price+(record.cont2?record.ca_price:0)+record.ca_idlesum+record.ca_forwardsum-record.ca_trackertax,
                   record.ca_paid?:'',record.debt>0&&record.ca_maxpaydate?.before(new Date().clearTime())?record.debt:'-','','',''], rowCounter++, false)
        }
        save(response.outputStream)
      }
    }
    return
  }

  def uploadingCarrierPayments = {
    checkAccess(18)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 18
    hsRes.admin = session.admin

    try {
      hsRes.result = billingService.importCSVCarrierPaymentsData(request.getFile('file'))
    } catch(Exception e) {
      log.debug('Error uploading CSV: '+e.toString())
      hsRes.result = 'Неверный файл'
    }
    render(view:"uploadingcarrierpayments",model:hsRes)
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def profitsettlements = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=18
    hsRes.admin = session.admin

    if (session.lastRequest?.fromDetails?:0) {
      hsRes.inrequest = session.lastRequest.prsettlparams?:[:]
      session.lastRequest.fromDetails = 0
    } else {
      hsRes+=requestService.getParams(['admin_id_profit','shipperdebt','carrierdebt'],['zakaz_id','client_id_profit'])
      session.lastRequest = [:]
      session.lastRequest.prsettlparams = hsRes.inrequest+[type:3]
    }

    hsRes.searchresult = new PayorderSearchShipper().findOrdersForProfitSettlements(hsRes.inrequest.zakaz_id?:0,hsRes.inrequest.client_id_profit?:0,
                                                hsRes.inrequest.admin_id_profit?:0,hsRes.inrequest.shipperdebt?:0,hsRes.inrequest.carrierdebt?:0,20,requestService.getOffset())
    hsRes.trips = hsRes.searchresult.records.inject([:]){map, order -> map[order.id]=new TripSearch().csiSelectTrip(order.id);map}
    hsRes.kprofit = Tools.getFloatVal(Dynconfig.findByName('profit.effency.modifier')?.value,0.915f)

    return hsRes
  }

  def findetail={
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 18
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)

    hsRes.payorder = Payorder.get(lId)
    if (!hsRes.payorder) {
      response.sendError(404)
      return
    }

    hsRes.clientcompany = Clientrequisites.get(hsRes.payorder.clientcompany_id)
    hsRes.debt = hsRes.payorder.fullcost+hsRes.payorder.idlesum+hsRes.payorder.forwardsum-hsRes.payorder.paid
    return hsRes
  }

  def shpayments = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 18
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)

    hsRes.payorder = Payorder.get(lId)
    hsRes.payments = Payment.findAllByPayorder_idAndTrip_idAndIs_active(lId,0,1)

    if (!hsRes.payorder) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    hsRes.debt = hsRes.payorder.fullcost+hsRes.payorder.idlesum+hsRes.payorder.forwardsum-hsRes.payorder.paid
    return hsRes
  }

  def casettlment = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 18
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)

    hsRes.payorder = Payorder.get(lId)
    if (!hsRes.payorder) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    hsRes.caSettlements = new PayorderSearchCarrier().findOrdersForCarrierSettlements(hsRes.payorder.id,0,0)

    return hsRes
  }

  def capayments = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 18
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)

    hsRes.payorder = Payorder.get(lId)
    hsRes.payments = Payment.findAllByPayorder_idAndTrip_idGreaterThanAndIs_active(lId,0,1)

    if (!hsRes.payorder) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    return hsRes
  }

  def capaymentdetail = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 18
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('payment_id',0)
    def lOrderId=requestService.getLongDef('order_id',0)

    hsRes.payment = Payment.get(lId)
    hsRes.trips = Trip.findAllByModstatusGreaterThanEqualsAndPayorder_id(-1,lOrderId)
    hsRes.cashdeduction = Tools.getFloatVal(Dynconfig.findByName('payment.cash.deduction')?.value,6.5f)

    return hsRes
  }

  def saveCarrierPayment={
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 18
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('payment_id',0)
    hsRes+=requestService.getParams(['summa','pclass'],['payorder_id','trip_id'],['norder'])
    hsRes.inrequest.paydate = requestService.getDate('paydate')

    hsRes.payment = Payment.get(lId)
    if (!hsRes.payment&&lId) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    def result = [errorcode:[]]
    if (!hsRes.inrequest.payorder_id)
      result.errorcode << 1
    if (!hsRes.inrequest.trip_id)
      result.errorcode << 2
    else if(!Trip.findByModstatusGreaterThanEqualsAndPayorder_idAndId(-1,hsRes.inrequest.payorder_id,hsRes.inrequest.trip_id))
      result.errorcode << 4
    if (hsRes.inrequest.summa<=0)
      result.errorcode << 3
    if (!hsRes.inrequest.pclass&&!hsRes.inrequest.norder)
      result.errorcode << 5

    if(!lId&&result.errorcode.size()==0){
      hsRes.payment = new Payment()
      if (!hsRes.payment) {
        result.errorcode << 100
      }
    }
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      hsRes.payment.setCarrierPayment(hsRes.inrequest).save(failOnError:true,flush:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/saveCarrierPayment\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
  }

  def deletecapayment={
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 18
    hsRes.admin = session.admin

    def lId = requestService.getLongDef('id',0)

    if(lId>0){
      Payment.get(lId)?.delete(flush:true)
    }

    render(contentType:"application/json"){[error:false]}
  }

  def benefitlist = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 18
    hsRes.admin = session.admin

    def lId=requestService.getIntDef('id',0)

    hsRes.payorder = Payorder.get(lId)
    hsRes.paybenefits = Paybenefit.findAllByPayorder_id(lId)

    if (!hsRes.payorder) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    hsRes.paidbenefit = hsRes.paybenefits?.sum{it.summa}?:0

    return hsRes
  }

  def editbenefitpayment = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 18
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('paybenefit_id',0)

    hsRes.paybenefit = Paybenefit.get(lId)

    return hsRes
  }

  def savebenefitpayment={
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 18
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('paybenefit_id',0)
    hsRes+=requestService.getParams(['summa'],['payorder_id'],['beneficial','platcomment'])

    hsRes.paybenefit = Paybenefit.get(lId)
    if (!hsRes.paybenefit&&lId) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    def result = [errorcode:[]]
    if (!hsRes.inrequest.payorder_id)
      result.errorcode << 1
    if (hsRes.inrequest.summa<=0)
      result.errorcode << 2

    if(!lId&&result.errorcode.size()==0){
      hsRes.paybenefit = new Paybenefit([paydate:new Date(),payorder_id:hsRes.inrequest.payorder_id])
      if (!hsRes.paybenefit) {
        result.errorcode << 100
      }
    }
    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      hsRes.paybenefit.setMainData(hsRes.inrequest).save(failOnError:true,flush:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/savebenefitpayment\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
  }

  def deletebenefitpayment={
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 18
    hsRes.admin = session.admin

    def lId = requestService.getLongDef('id',0)

    if(lId>0){
      Paybenefit.get(lId)?.delete(flush:true)
    }

    render(contentType:"application/json"){[error:false]}
  }

  def saveorderbenefit={
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 18
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('id',0)
    def iBenefit = requestService.getIntDef('benefit',0)

    hsRes.payorder = Payorder.get(lId)
    if (!hsRes.payorder&&lId) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    def result = [errorcode:[]]
    if (iBenefit<0)
      result.errorcode << 1

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      //hsRes.payorder.updateBenefit(iBenefit).save(failOnError:true,flush:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/saveorderbenefit\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
  }

  def updateMaxPaydate={
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 18
    hsRes.admin = session.admin

    def client = Client.get(requestService.getLongDef('id',0))

    if(client?.type_id==2){
      new PayorderSearchCarrier().findOrdersForEditingMaxpaydate(client.id,0,0).records.each{
        Trip.get(it.id).csiSetDocdate().save(flush:true,failOnError:true)
      }
    }

    render(contentType:"application/json"){[error:false]}
  }

  def capayment = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=18
    hsRes.admin = session.admin

    hsRes.clientnames = new PayorderSearchCarrier().getclientnames()

    return hsRes
  }

  def nonpaydcontainers = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=18
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(null,['client_id'],['contnumber'])

    hsRes.searchresult = new PayorderSearchCarrier().findNonpaidcontainers(hsRes.inrequest.client_id?:0l,hsRes.inrequest.contnumber?:'')

    return hsRes
  }

  def capay = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=18
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(['pclass','is_second'],['id','payorder_id'],['norder'])
    hsRes.paydate = requestService.getDate('paydate')

    hsRes.trip = Trip.get(hsRes.inrequest.id)
    if (!hsRes.trip||!hsRes.inrequest.payorder_id) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    hsRes.zToDriver = Zakaztodriver.get(hsRes.trip.zakaztodriver_id)

    try {
      new Payment().setCarrierPayment([payorder_id:hsRes.inrequest.payorder_id,summa:hsRes.trip.computeContPaidSumma(hsRes.zToDriver.containernumber2?true:false,hsRes.inrequest.is_second?true:false),trip_id:hsRes.trip.id,pclass:hsRes.inrequest.pclass,platcomment:hsRes.inrequest.is_second?hsRes.zToDriver.containernumber2:hsRes.zToDriver.containernumber1,norder:hsRes.inrequest.norder?:'',paydate:hsRes.paydate?:new Date()]).save(failOnError:true,flush:true)
      hsRes.zToDriver.csiSetContpaid(hsRes.inrequest.is_second?true:false).save(failOnError:true,flush:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/capay\n"+e.toString());
      render(contentType:"application/json"){[error:true]}
      return
    }

    render(contentType:"application/json"){[error:false]}
    return
  }

  def capaymentreport = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 18
    hsRes.admin = session.admin

    hsRes.capaymentreport_date = requestService.getDate('capaymentreport_date')
    hsRes.carrier = requestService.getLongDef('client_id',0)
    hsRes.contnumber = requestService.getStr('contnumber')

    hsRes.report = new CaPaymentSearch().csiSelectPayments(hsRes.carrier?:0l,hsRes.contnumber?:'',hsRes.capaymentreport_date?:new Date())

    renderPdf(template: 'capaymentreport', model: hsRes, filename: "capaymentreport.pdf")
    return
  }

  def capaymentreportXLS = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 18
    hsRes.admin = session.admin

    hsRes.capaymentreport_date = requestService.getDate('capaymentreport_date')
    hsRes.carrier = requestService.getLongDef('client_id',0)
    hsRes.contnumber = requestService.getStr('contnumber')

    hsRes.report = new CaPaymentSearch().csiSelectPayments(hsRes.carrier?:0l,hsRes.contnumber?:'',hsRes.capaymentreport_date?:new Date())

    if (hsRes.report.size()==0) {
      new WebXlsxExporter().with {
        setResponseHeaders(response)
        putCellValue(0, 4, "Нет данных за указанный период")
        save(response.outputStream)
      }
    } else {
      def rowCounter = 4
      new WebXlsxExporter().with {
        setResponseHeaders(response)
        fillRow(['Перевозчик','Контейнер','Сумма'],3,false)
        hsRes.report.each{ record ->
          fillRow([record.carrier_name, record.platcomment, record.summa], rowCounter++, false)
        }
        fillRow(["","ИТОГО", hsRes.report.sum{it.summa}], rowCounter++, false)
        save(response.outputStream)
      }
    }
    return
  }

  def shbenefit = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=18
    hsRes.admin = session.admin

    hsRes.clientnames = new PayorderSearchShipper().getclientnames()

    return hsRes
  }

  def nonbenefitcontainers = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=18
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(null,['client_id'],['contnumber'])

    hsRes.searchresult = new PayorderSearchShipper().findNonbenefitcontainers(hsRes.inrequest.client_id?:0l,hsRes.inrequest.contnumber?:'')

    return hsRes
  }

  def benefitpay = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=18
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(['summa'],['id'],['contnumber'])

    hsRes.payorder = Payorder.get(hsRes.inrequest.id)
    if (!hsRes.payorder||!hsRes.inrequest.contnumber) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    def result = [errorcode:[]]
    if (!hsRes.inrequest.summa)
      result.errorcode << 1
    else if (hsRes.inrequest.summa<0)
      result.errorcode << 2

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }

    try {
      new Paybenefit(payorder_id:hsRes.payorder.id,paydate:new Date()).setMainData([platcomment:hsRes.inrequest.contnumber,summa:hsRes.inrequest.summa]).save(failOnError:true,flush:true)
      hsRes.payorder.updateContbenefit(hsRes.inrequest.contnumber).save(failOnError:true,flush:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/benefitpay\n"+e.toString());
      render(contentType:"application/json"){[error:true]}
      return
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}
    return
  }

  def benefitreport = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 18
    hsRes.admin = session.admin

    hsRes.benefitreport_date = requestService.getDate('benefitreport_date')
    hsRes.shipper = requestService.getLongDef('client_id',0)
    hsRes.contnumber = requestService.getStr('contnumber')

    hsRes.report = new PaybenefitSearch().csiSelectPayments(hsRes.shipper?:0l,hsRes.contnumber?:'',hsRes.benefitreport_date?:new Date())

    renderPdf(template: 'benefitreport', model: hsRes, filename: "benefitreport.pdf")
    return
  }

  def benefitreportXLS = {
    checkAccess(18)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id = 18
    hsRes.admin = session.admin

    hsRes.benefitreport_date = requestService.getDate('benefitreport_date')
    hsRes.shipper = requestService.getLongDef('client_id',0)
    hsRes.contnumber = requestService.getStr('contnumber')

    hsRes.report = new PaybenefitSearch().csiSelectPayments(hsRes.shipper?:0l,hsRes.contnumber?:'',hsRes.benefitreport_date?:new Date())

    if (hsRes.report.size()==0) {
      new WebXlsxExporter().with {
        setResponseHeaders(response)
        putCellValue(0, 4, "Нет данных за указанный период")
        save(response.outputStream)
      }
    } else {
      def rowCounter = 4
      new WebXlsxExporter().with {
        setResponseHeaders(response)
        fillRow(['Клиент','Контейнер','Сумма'],3,false)
        hsRes.report.each{ record ->
          fillRow([record.shipper_name, record.platcomment, record.summa], rowCounter++, false)
        }
        fillRow(["","ИТОГО", hsRes.report.sum{it.summa}], rowCounter++, false)
        save(response.outputStream)
      }
    }
    return
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Financial <<<///////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Route >>>///////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def route = {
    checkAccess(19)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 19
    hsRes.admin = session.admin

    def fromDetails = requestService.getIntDef('fromDetails',0)
    if (fromDetails&&session.lastRequest){
      session.lastRequest.fromDetails = fromDetails
      hsRes.inrequest = session.lastRequest
    }

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def routelist = {
    checkAccess(19)
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 19
    hsRes.admin = session.admin

    if (session.lastRequest?.fromDetails?:0) {
      hsRes.inrequest = session.lastRequest
      session.lastRequest.fromDetails = 0
    } else {
      hsRes+=requestService.getParams(null)
      hsRes.inrequest.modstatus = requestService.getIntDef('modstatus',0)
      hsRes.inrequest.offset = requestService.getOffset()
      session.lastRequest = [:]
      session.lastRequest = hsRes.inrequest
    }

    hsRes.searchresult = new Standartroute().csiSelectRoute(hsRes.inrequest.modstatus?:0,20,hsRes.inrequest.offset)
    hsRes.terminals = Terminal.list().inject([:]){map, terminal -> map[terminal.id]=terminal.name;map}

    return hsRes
  }

  def routedetail={
    requestService.init(this)
    checkAccess(19)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 19
    hsRes.admin = session.admin

    def lId = requestService.getLongDef('id',0)
    hsRes.copiedId = requestService.getLongDef('copiedzakaz',0)

    hsRes.route = Standartroute.get(lId)?:Zakaz.get(hsRes.copiedId)
    if (!hsRes.route&&lId) {
      response.sendError(404)
      return
    }

    hsRes.ztype = Ztype.list()
    hsRes.terminal = Terminal.list()
    hsRes.container = Container.list()

    return hsRes
  }

  def routetrackdetail={
    requestService.init(this)
    checkAccess(19)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 19
    hsRes.admin = session.admin

    hsRes.terminal = Terminal.list()
    hsRes.region = Region.findAll('from Region where modstatus = 1 order by regorder desc, name asc')

    def lId = requestService.getLongDef('id',0)
    def iZtype = requestService.getIntDef('ztype_id',0)
    hsRes.copied = requestService.getIntDef('copied',0)

    hsRes.route = hsRes.copied?Zakaz.get(lId):Standartroute.get(lId)
    if (!hsRes.route&&lId) {
      render(contentType:"application/json"){[error:true]}
      return
    }

    switch(iZtype) {
      case 1:
        render(view: "route_import", model: hsRes); break;
      case 2:
        render(view: "route_export", model: hsRes); break;
      case 3:
        render(view: "route_transit", model: hsRes); break;
      default:
        render(contentType:"application/json"){[error:true]}
        break
    }
  }

  def saveRouteDetail={
    requestService.init(this)
    checkAccess(19)
    def hsRes = requestService.getContextAndDictionary(true)
    hsRes.action_id = 19
    hsRes.admin = session.admin

    def lId = requestService.getLongDef('id',0)
    def iZtype = requestService.getIntDef('ztype_id',0)

    hsRes.route = Standartroute.get(lId)
    if (!hsRes.route&&lId) {
      render(contentType:"application/json"){[error:true]}
      return
    }
    if (!(iZtype in 1..3)) {
      render(contentType:"application/json"){[error_ztype_id:1]}
      return
    }

    hsRes += requestService.getParams(['ztype_id','terminal','terminal_end','price_basic','container'],null,
                                      ['region_start','city_start','address_start','region_end','city_end','address_end',
                                       'region_cust','city_cust','address_cust','region_zat','city_zat','address_zat','shortname'])
    hsRes.inrequest.weight1 = requestService.getFloatDef('weight1',0f)

    hsRes.returnerrors = [error:[]]
    if(hsRes.inrequest.terminal<0) hsRes.returnerrors.error << 1
    if(!hsRes.inrequest.shortname) hsRes.returnerrors.error << 3
    if(!hsRes.inrequest.weight1||hsRes.inrequest.weight1<0||hsRes.inrequest.weight1>50) hsRes.returnerrors.error << 4
    if(!hsRes.inrequest.price_basic||hsRes.inrequest.price_basic<0) hsRes.returnerrors.error << 5
    if(iZtype==2) {
      hsRes += zakazService.checkExportRequestData(hsRes.inrequest,hsRes.returnerrors)
    }

    if(!hsRes.returnerrors.error){
      if(!lId){
        hsRes.route = new Standartroute([ztype_id:hsRes.inrequest.ztype_id])
        if (!hsRes.route) {
          hsRes.returnerrors.error << 100
        }
      }
      if(!hsRes.returnerrors.error){
        try {
          def ztypeHandler = 'set'+(iZtype==1?'Import':iZtype==2?'Export':'Transit')+'Data'
          hsRes.route.setGeneralData(hsRes.inrequest)."$ztypeHandler"(hsRes.inrequest).save(failOnError:true)
        } catch(Exception e) {
          log.debug("Error save data in Admin/saveRouteDetail\n"+e.toString());
          hsRes.returnerrors.error << 100
        }
      }
    } else {
      hsRes.returnerrors.ztype_id = iZtype
      render hsRes.returnerrors as JSON
      return
    }

    if (hsRes.returnerrors.error.size()>0) {
      hsRes.returnerrors.ztype_id = iZtype
      render hsRes.returnerrors as JSON
    } else
      render(contentType:"application/json"){[error:false,uId:hsRes.route.id]}
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Route <<<///////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Chief zone >>>//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def overview = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.admin = session.admin
    if(!Admingroup.get(session?.admin?.group)?.is_chief){
      response.sendError(404)
      return
    }
    hsRes.kprofit = Tools.getFloatVal(Dynconfig.findByName('profit.effency.modifier')?.value,0.915f)
    hsRes.ourarrearssum = new ReportSearchMain().getReportCarrier(0).sum{ it.arrears }
    hsRes.usarrearssum = new ReportSearchMain().getReportShipper().sum{ it.arrears }

    return hsRes
  }

  def editkprofit = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.admin = session.admin
    if(!Admingroup.get(session?.admin?.group)?.is_chief){
      render(contentType:"application/json"){[error:true]}
      return
    }

    def sKprofit = requestService.getStr('kprofit').replace(',','.')

    def result = [errorcode:[]]

    if (!sKprofit) result.errorcode << 1
    else if (!sKprofit?.isFloat()) result.errorcode << 2
    else if (sKprofit?.toFloat()>1) result.errorcode << 3

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
      return
    }
    try {
      Dynconfig.findByName('profit.effency.modifier').updateValue(sKprofit.toFloat().toString()).save(failOnError:true,flush:true)
    } catch(Exception e) {
      log.debug("Error save data in Admin/editkprofit\n"+e.toString());
      result.error = true
      result.errorcode << 100
    }

    if (result.errorcode.size()>0) {
      result.error = true
      render result as JSON
    } else
      render(contentType:"application/json"){[error:false]}

    return hsRes
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Chief zone <<<//////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
}