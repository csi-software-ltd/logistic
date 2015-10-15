import org.codehaus.groovy.grails.commons.ConfigurationHolder
import grails.converters.JSON

class UserController {
  def usersService
  def requestService  
  def jcaptchaService
  def mailerService
  
  def registration={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true) 
    if(hsRes.user){    
      redirect(controller:'index',action:'index')
      return
    }  
    hsRes.inrequest = requestService.getParams(['type_id','registration'],[],['name','email','company','password1','password2','user','password']).inrequest
    hsRes.user_max_enter_fail=Tools.getIntVal(ConfigurationHolder.config.user_max_enter_fail,3)
    hsRes.passwordlength=Tools.getIntVal(ConfigurationHolder.config.user.passwordlength?:6)
    return hsRes
  }  
  def saveuser={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    hsRes.inrequest = requestService.getParams(['type_id'],[],['name','email','company','password1','password2']).inrequest 
    hsRes.hinrequest = requestService.getParams(['type_id'],[],['name','email','company']).inrequest    
    
    flash.error=[]    
    if(!(hsRes.inrequest?.name?:''))
      flash.error<<1 
    if(!(hsRes.inrequest?.company?:''))
      flash.error<<2      
    if(!(hsRes.inrequest?.email?:''))
      flash.error<<4
    else if (!Tools.checkEmailString(hsRes.inrequest.email))
      flash.error<<5
    if(!(hsRes.inrequest?.type_id?:0))
      flash.error<<6
    if((hsRes.inrequest?.password1?:'')!=(hsRes.inrequest?.password2?:''))
      flash.error<<7
    if((hsRes.inrequest?.password2?:'').size()<Tools.getIntVal(ConfigurationHolder.config.user.passwordlength?:6))
      flash.error<<8     
    if(!(hsRes.inrequest?.password1==~/^.*(?=.*[0-9])(?=.*[A-Za-z]).*$/))
      flash.error<<10
    if(hsRes.inrequest?.password1==~/^.*(?=.*[А-Яа-я]).*$/)
      flash.error<<10  
    if(hsRes.inrequest?.password1==~/^.*(?=.*\W).*$/)
      flash.error<<10
    if(hsRes.inrequest?.password1==~/^.*(?=.*_).*$/)
      flash.error<<10       
      
    if(!flash.error){
      if(User.findWhere(email:hsRes.inrequest.email?:'bad_email')){      
        flash.error<<9
      }else{           
        def oUser=new User()
        oUser.name=hsRes.inrequest.name   
        oUser.nickname=hsRes.inrequest.name.split(' ')[0]
        oUser.email=hsRes.inrequest.email
        oUser.type_id=hsRes.inrequest.type_id
        oUser.company=hsRes.inrequest.company
        oUser.password=Tools.hidePsw(hsRes.inrequest?.password1?:'')
        oUser.modstatus=0
        oUser.inputdate=new Date()
        def sCode=java.util.UUID.randomUUID().toString()
        oUser.code=sCode
      
        if(!oUser.save(flush:true)) {
          log.debug(" Error on save User:")
          oUser.errors.each{log.debug(it)}	 
        }        
        hsRes.code=sCode
        
        mailerService.sendUserConfirmMail(hsRes) //old variant: if success flash.error<<50
        
        if(!usersService.loginInternalUser(oUser.email,hsRes.inrequest?.password1,requestService,1,0)){      
          flash.error<<51 // Wrong password or user does not exists		
        }else if(oUser!=null){
          oUser.lastdate=new Date()		
          if(!oUser.save(flush:true)) {
            log.debug(" Error on save User:")
            oUser.errors.each{log.debug(it)}	 
          }
          
          def oUserlog = new Userlog(user_id:oUser.id,logtime:new Date(),ip:request.remoteAddr,success:1)
          if (!oUserlog.save(flush:true)){
            log.debug('error on save Userlog in User:saveuser')
            oUserlog.errors.each{log.debug(it)}
          }
          
          if((oUser.type_id?:0)==1){
            redirect(controller:'shipper', action:'profile',params:[from_reg:1])
            return
          }else if((oUser.type_id?:0)==2){
            redirect(controller:'carrier', action:'profile',params:[from_reg:1])
            return
          }                   
        }
                  
      }                 
    }  
    redirect(action:'registration',params:hsRes.hinrequest)
    return
  }
  ///////////////////////////////////////////////////////////////////////////////////////
  def sendUserConfirmMail = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary() 
    def lId=requestService.getLongDef('id',0)
    def bReturn=1    
    def oUser=User.get(hsRes?.user?.id?:0)
    
    if(oUser){
      hsRes.inrequest=[:]
      hsRes.inrequest.nickname=oUser.nickname
      hsRes.inrequest.email=oUser.email
      hsRes.code=oUser.code
      if(!mailerService.sendUserConfirmMail(hsRes))      
        bReturn=0       
    }else{
      bReturn=0
    }
    render(contentType:"application/json"){[flag:bReturn]}
    return
  }
  ///////////////////////////////////////////////////////////////////////////////////////
  def logout = {
    requestService.init(this)
    usersService.logoutUser(requestService)
    
    redirect(controller:'index',action: 'index')
    return
  } 
  ///////////////////////////////////////////////////////////////////////////////////////
  def login_user = {  
    requestService.init(this)
    requestService.setCookie('user_LG','parararam',10000)
    def hsInrequest=requestService.getParams(['remember'],[],['user']).inrequest       //'password'
    
    def sUser=requestService.getStr('user')    
    def sPassword=requestService.getStr('password')   
    def iRemember=requestService.getIntDef('remember',0)
    
    def oUserlog = new Userlog()
    def blocktime = Tools.getIntVal(ConfigurationHolder.config.login.blocktime,1800)
    def unsuccess_log_limit = Tools.getIntVal(ConfigurationHolder.config.login.unsuccess_log_limit,5)        
    
    flash.error=[]
    
    if(!flash?.user_id){        
      if(session.user_enter_fail>Tools.getIntVal(ConfigurationHolder.config.user_max_enter_fail,3)){
        try{
          if (! jcaptchaService.validateResponse("image", session.id, params.captcha)){
            flash.error<<99 //error in captha
            redirect(action:'login',params:hsInrequest)
            return
          } else {
            session.user_enter_fail=null
          }
        }catch(Exception e){
          flash.error<<99 //error in captha
          redirect(action:'login',params:hsInrequest)
          return
        }
      }
      if((sUser=='')||(sUser=='логин')){
        flash.error << 100 // set user
      }else if (!sPassword){      
        flash.error << 200 // empty password is not allowed        
      }else if(!Tools.checkEmailString(sUser) && !(sUser ==~ /^[0-9]+$/)){
        flash.error << 400 // set user
      }
    }  
    
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
    
    if(!flash.error && !flash?.user_id){  
      if(!oUser){
        flash.error<<51 // Wrong password or user does not exists
        //redirect(action:'login',params:hsInrequest)
        //return
      }else if (oUserlog.csiCountUnsuccessLogs(oUser.id, new Date(System.currentTimeMillis()-blocktime*1000))[0]>=unsuccess_log_limit){
        flash.error<<52 // user blocked
        oUserlog = new Userlog(user_id:oUser.id,logtime:new Date(),ip:request.remoteAddr,success:2)
        if (!oUserlog.save(flush:true)){
          log.debug('error on save Userlog in User:login_user')
          oUserlog.errors.each{log.debug(it)}
        }        
        redirect(action:'login',params:hsInrequest)
        return	
      }else if (oUser.password != Tools.hidePsw(sPassword)) {
        flash.error<<51 // Wrong password or user does not exists
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
      if(!usersService.loginInternalUser(sUser,sPassword,requestService,iRemember,flash?.user_id?:0)){      
        flash.error<<51 // Wrong password or user does not exists		
      }else if(oUser!=null){
        oUser.lastdate=new Date()		
        if(!oUser.save(flush:true)) {
          log.debug(" Error on save User:")
          oUser.errors.each{log.debug(it)}	 
        }
        
        oUserlog = new Userlog(user_id:oUser.id,logtime:new Date(),ip:request.remoteAddr,success:1)
        if (!oUserlog.save(flush:true)){
          log.debug('error on save Userlog in User:login')
          oUserlog.errors.each{log.debug(it)}
        }
        
        if((oUser.type_id?:0)==1){
          redirect(controller:'shipper', action:'orders')
          return
        }else if((oUser.type_id?:0)==2){
          redirect(controller:'carrier', action:'orders')
          return
        }      
      }      
    }
    if((flash.error?:[]).contains(51))
      if(session.user_enter_fail)
        session.user_enter_fail++
      else
        session.user_enter_fail=1                
    
    if(!flash.error){
      redirect(controller:'index',action:'index')	
      return
    }else{
      redirect(action:'login',params:hsInrequest)	      
      return
    }
  }        
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////   
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////           
  def passwconfirm={
    requestService.init(this)
	  def hsResult=[inrequest:[:]]
    def sCode=requestService.getStr('id')
    if(sCode=='')
      hsResult.inrequest.error=2
    else{
      def oUser=User.findWhere(code:sCode)
      if(!oUser)
        hsResult.inrequest.error=2
      else{
        session.regusercode=sCode
        session.startchange=true    
        redirect(action:'passwsetup')
        return
      }
    }    
    render(view:'confirm',model:hsResult)
  }  
  ////////////////////////////////////////////////////////////////////////////////////////////////// 
   def passwsetup={ 
    requestService.init(this)
    def hsResult=requestService.getContextAndDictionary(false,true)
/*   
   if(hsResult.spy_protection){	  
      redirect(controller:'index',action:'captcha')
      return
    }
*/    
    hsResult.inrequest=[error:0]
/*    
    if(hsResult.user!=null){
      redirect(action:'index')
      return
    }
*/    
    def sCode=session.regusercode?:''
    if(sCode==''){
      redirect(action:'restore')
      return
    } else {
      def oUser = User.findWhere(code:sCode)
      hsResult.inrequest.email = oUser.email
    }
    
    if(session.startchange?:false){
      session.startchange=false
      hsResult.inrequest.error=0      
    }else{
      def sPassword1=requestService.getStr('password1')
      def sPassword2=requestService.getStr('password2')
      
      if(sPassword2!=sPassword1)
        hsResult.inrequest.error=1
      else if(sPassword2.size()<Tools.getIntVal(ConfigurationHolder.config.user.passwordlength,6))
        hsResult.inrequest.error=2   
      else if(!(sPassword1==~/^.*(?=.*[0-9])(?=.*[A-Za-z]).*$/))
        hsResult.inrequest.error=3
      else if(sPassword1==~/^.*(?=.*[А-Яа-я]).*$/)
        hsResult.inrequest.error=3  
      else if(sPassword1==~/^.*(?=.*\W).*$/)
        hsResult.inrequest.error=3
      else if(sPassword1==~/^.*(?=.*_).*$/)
        hsResult.inrequest.error=3       
      else{
        def oNewUser
        def lsUsers=User.findAll('FROM User WHERE email=:email',[email:hsResult.inrequest.email])
        if((lsUsers?:[]).size()!=0){
          oNewUser=User.get(lsUsers[0].id)
          oNewUser.password=Tools.hidePsw(sPassword2)
          oNewUser.modstatus = oNewUser.modstatus?:1
          try{
            if( !oNewUser.save(flush:true)) {
              log.debug(" Error on save user")    
              oNewUser.errors.each { log.debug(it) }
            }else
              hsResult.inrequest.error=-1 //пароль изменен
            
          }catch(Exception e) {
            log.debug("Cannot save user \n"+e.toString())
            hsResult.inrequest.error=4 // general error
          }        
        }
        session.regusercode=null       
      }
    }
    
    if(hsResult.inrequest.error==-1){
      redirect(action:'login_user', params:[user:hsResult.inrequest.email,password:requestService.getStr('password1')])
    }

    return hsResult     
  }    
  //////////////////////////////////////////////////////////////////////////////////////////////////  
  def restore={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    /*
    if(hsRes.spy_protection){	  
      redirect(controller:'index',action:'captcha')
      return
    }
    */
    hsRes.inrequest=[error:requestService.getIntDef('error',0)]   
    if(hsRes.user!=null){
      redirect(controller:'index',action:'index')
      return
    }    
    return hsRes 
  }
//////////////////////////////////////////////////////////////////////////////////////////////////  
  def rest={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    hsRes.inrequest=[:]   
    if(hsRes.user!=null){
      redirect(controller:'index',action:'index')
      return
    }    
    hsRes.inrequest.name=requestService.getStr('name')
    hsRes.inrequest.error=0    
    withForm{
      def oUser=User.findWhere(email:hsRes.inrequest.name)
      if(!oUser){
        try{
          hsRes.inrequest.name=hsRes.inrequest.name.toLong()
          hsRes.inrequest.error=6
        }catch(Exception e){
          hsRes.inrequest.error=1 //USER NOT EXISTS
        }                
        redirect(action:"restore",params:hsRes.inrequest)
        return
      }                    
      if(!Tools.checkEmailString(hsRes.inrequest.name)){
        hsRes.inrequest.error=2 //ERROR IN EMAIL
        redirect(action:"restore",params:hsRes.inrequest)
        return
      }        
      try{
        if (! jcaptchaService.validateResponse("image", session.id, params.captcha)){
          hsRes.inrequest.error=3 //error in captha
          redirect(action:"restore",params:hsRes.inrequest)
          return
        }
      }catch(Exception e){
        hsRes.inrequest.error=3 //error in captha
        redirect(action:"restore",params:hsRes.inrequest)
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
    }.invalidToken {
      hsRes.inrequest.error=5
      redirect(action:"restore",params:hsRes.inrequest)
      return
    }
    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def confirm={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    /*
    if(hsRes.spy_protection){	  
      redirect(controller:'index',action:'captcha')
      return
    }*/
    def sCode=requestService.getStr('id')
    def iConf=requestService.getIntDef('confirm',0)
    if(sCode==''){
      if (!iConf)
        flash.error=1
    }else{
      def oUser=User.findWhere(code:sCode)   
      
      if(oUser){
        def lsText=''
        oUser.is_emailcheck=1
        oUser.code=''

        if(!oUser.save(flush:true)) {
          log.debug(" Error on save User")
          oUser.errors.each { log.debug(it)}
        }else{
          lsText=Email_template.findWhere(action:'#greeting_user')
        }
        //<<Email
        if(lsText){
          def sText='[@EMAIL] Registration at StayToday'
          def sHeader="Registration at StayToday"
          if(lsText){
            sText=lsText.itext
            sHeader=lsText.title
          }
          sText=sText.replace('[@NICKNAME]',oUser.nickname).replace('[@EMAIL]',oUser.email)
          sText=((sText?:'').size()>Tools.getIntVal(ConfigurationHolder.config.mail.textsize,500))?sText.substring(0,Tools.getIntVal(ConfigurationHolder.config.mail.textsize,500)):sText
          sHeader=sHeader.replace('[@EMAIL]',oUser.email)
          try{
          /*
            if(Tools.getIntVal(ConfigurationHolder.config.mail_gae,0))
              mailerService.sendMailGAE(sText,ConfigurationHolder.config.grails.mail.from1,ConfigurationHolder.config.grails.mail.username,oUser.email,sHeader,1)
            else{
          */  
              sendMail{
                to oUser.email
                subject sHeader
                html sText
                /*
                body( view:"/_mail",
                model:[mail_body:sText])
                */
              }
            //}
          }catch(Exception e) {
            log.debug("Cannot sent email \n"+e.toString())
            hsRes.hinrequest.error=-100
          }
        //>>Email
        }
        if(!hsRes?.user){          
          flash.user_id=oUser.id
          redirect(action:'login_user',params:[act:'confirm',control:'user'])
          return          
        }
      }else{
        flash.error=1
      }
    }
    return hsRes
  }
}
