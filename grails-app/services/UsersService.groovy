import org.codehaus.groovy.grails.commons.ConfigurationHolder

class UsersService implements Serializable{
  static boolean transactional = false
  static scope = "session"
  static proxy = true
  def transient m_hsUser=null
  //static final INTERNALPROVIDER='staytoday' //NOTE: lowercase
  static final COOKIENAME='user_LG'
  private static final long serialVersionUID = 1L;  

  ///////////////////////////////////////////////////////////////////
  def saveSession(requestService,iRemember=0){
    if((m_hsUser.id?:0)==0)
      return
    def oSession=new Usession()
    def sGuid=oSession.createSession(m_hsUser.id)	
    requestService.setCookie(COOKIENAME,sGuid,iRemember?Tools.getIntVal(ConfigurationHolder.config.user.remembertime,2592000):-1)
  }
  ///////////////////////////////////////////////////////////////////
  def deleteSession(requestService){ 
    def oSession=new Usession()
    def sGuid=requestService.getCookie(COOKIENAME)	
    oSession.deleteSession(sGuid)
    requestService.setCookie(COOKIENAME,'',Tools.getIntVal(ConfigurationHolder.config.user.timeout,259200))
    m_hsUser=null    
  }
 ///////////////////////////////////////////////////////////////////
  def restoreSession(requestService){
    def sGuid=requestService.getCookie(COOKIENAME)		
    if(sGuid=='')  return
	
    def oUser=new User()	
    def hsUser=oUser.restorySession(sGuid)
    if((hsUser!=null)&&(hsUser.size()>0))
      m_hsUser=[name:hsUser[0].name,id:hsUser[0].id,client_id:hsUser[0].client_id,is_am:hsUser[0].is_am,
        modstatus:hsUser[0].modstatus,nickname:hsUser[0].nickname,email:hsUser[0].email,type_id:hsUser[0].type_id,is_termconfirm:hsUser[0].is_termconfirm]
    else
      deleteSession(requestService)
	  
  }
  ///////////////////////////////////////////////////////////////////      
  def loginInternalUser(sUserName,sPassword,requestService,iRemember,lUserId=0){  
    m_hsUser=null    
    def hsDbUser=null
   
    if(lUserId){
      hsDbUser=User.get(lUserId)      
    }else{    
      sPassword=Tools.hidePsw(sPassword)
      try{
        sUserName=sUserName.toLong()
        hsDbUser=User.find('from User where id=:id and password=:password',
                        [id:sUserName,password:sPassword])  
      }catch(Exception e){
        hsDbUser=User.find('from User where email=:email and password=:password',
                        [email:sUserName.toLowerCase(),password:sPassword]) 
      }                         
    }
    if(hsDbUser==null)
      return false
      
    if(hsDbUser.modstatus!=-1){
      m_hsUser=[name:sUserName,id:hsDbUser.id,modstatus:hsDbUser.modstatus,nickname:hsDbUser.nickname,type_id:hsDbUser.type_id,is_termconfirm:hsDbUser.is_termconfirm]
      saveSession(requestService,iRemember)
      return true
    }
    
    return false
  }  
  ////////////////////////////////////////////////////////////////////
  def getCurrentUser(requestService){
    if (!checkSession(requestService)){ 
      m_hsUser = null
    }else{
      restoreSession(requestService)
    }
    return m_hsUser
  }
  ///////////////////////////////////////////////////////////////////
  def logoutUser(requestService){
    m_hsUser=null
    deleteSession(requestService)
    return true
  }
  ///////////////////////////////////////////////////////////////////
  def checkSession(requestService){
    if (!requestService) return
    def bGuid=requestService.getCookie(COOKIENAME)?true:false
    return bGuid
  }
  ///////////////////////////////////////////////////////////////////
  //def clearUserRegistraions(){ <---- moved into job since service has session scope
  //  def oTempusers=new Tempusers()
  //  oTempusers.clearOldRegistrations(Tools.getIntVal(ConfigurationHolder.config.user.registrationtimelive))
  // }
}
