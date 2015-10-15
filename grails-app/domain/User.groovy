import org.codehaus.groovy.grails.commons.ConfigurationHolder

class User {
  def searchService
  def sessionFactory
  static constraints = {
    name(nullable:true)
    nickname(nullable:true)
    company(nullable:true)
    description(nullable:true)    
    client_id(nullable:true)
    type_id(nullable:true)
    is_am(nullable:true)
    tel(nullable:true)
    tel1(nullable:true)
    is_telcheck(nullable:true)
    skype(nullable:true)
    password(nullable:true)
    inputdate(nullable:true)
    lastdate(nullable:true)
    is_news(nullable:true)
    is_subscribe(nullable:true)
    is_zayavka(nullable:true)
    is_noticeemail(nullable:true)
    is_ratingnote(nullable:true)
    is_noticeSMS(nullable:true)
    code(nullable:true)
    confirmtermdate(nullable:true)
  }
  static mapping = {
    cache false
    version false
  }
  Long id
  String name
  String nickname
  String company
  String description  
  Long client_id = 0
  Integer type_id
  Integer is_am
  String tel
  String tel1
  Integer is_telcheck
  String skype
  String password
  Date inputdate
  Date lastdate
  String smscode = ''
  Integer modstatus
  Integer is_news
  Integer is_subscribe
  Integer is_zayavka
  Integer is_noticeemail = 1
  Integer is_ratingnote
  Integer is_noticeSMS
  Integer is_needtochangepassword = 0
  String email
  String code
  Integer is_emailcheck = 0
  Integer is_termconfirm = 0
  Date confirmtermdate

  String toString() {"${this.name}" }
  ////////////////////////////////////////////////////////////////////////////////
  def restorySession(sGuid){  
    def hsSql=[
      select:"*, user.id as id",
      from:"user,usession",
      where:"(user.id=usession.users_id) AND (usession.guid=:guid)"]
    
    return searchService.fetchData(hsSql,null,null,[guid:sGuid],null,User.class)
  }

  def csiInsertInternal(hsUser){
    def session = sessionFactory.getCurrentSession()
    def iId=0
    hsUser.email=hsUser.email.toLowerCase()
    def sSql="""
          INSERT INTO user(name,email,password,nickname,modstatus,is_needtochangepassword)
          VALUES (:name,:email,:password,:nickname,:modstatus,1)
          ON DUPLICATE KEY  UPDATE name=:name,password=:password,modstatus=:modstatus
          """
    def qSql=session.createSQLQuery(sSql)
    qSql.setString("name",hsUser.name);
    qSql.setString("email",hsUser.email);
    qSql.setString("password",hsUser.password?:'');
    qSql.setString("nickname",hsUser.nickname);
    qSql.setLong("modstatus",0);

    try{
      qSql.executeUpdate();
      return searchService.getLastInsert();
    }catch(Exception e){
      log.debug("User:csiInsert Cannot add new user. \n"+e.toString())
    }
    session.clear()
    return iId
  }

  def csiSelectUsers(sUserName,sNickname,sCompany,sEmail,iModstatus,lUserId,lClientId,iTypeId,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*"
    hsSql.from='user'
    hsSql.where="1=1"+
                ((sUserName!='')?' AND name like CONCAT("%",:name,"%")':'')+
                ((sNickname!='')?' AND nickname like CONCAT("%",:nickname,"%")':'')+
                ((sCompany!='')?' AND company like CONCAT("%",:company,"%")':'')+
                ((sEmail!='')?' AND email like CONCAT("%",:email,"%")':'')+
                ((iModstatus>-2)?' AND modstatus =:modstatus':'')+
                ((lUserId>0)?' AND id =:id':'')+
                ((lClientId>0)?' AND client_id =:client_id':'')+
                ((iTypeId>0)?' AND type_id =:type_id':'')
    hsSql.order="id desc"

    if(sUserName!='')
      hsString['name']=sUserName
    if(sNickname!='')
      hsString['nickname']=sNickname
    if(sCompany!='')
      hsString['company']=sCompany
    if(sEmail!='')
      hsString['email']=sEmail
    if(iModstatus>-2)
      hsLong['modstatus']=iModstatus
    if(lUserId>0)
      hsLong['id']=lUserId
    if(lClientId>0)
      hsLong['client_id']=lClientId
    if(iTypeId>0)
      hsLong['type_id']=iTypeId

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,
      null,null,iMax,iOffset,'id',true,User.class)
  }

  User confirmUser(){
    modstatus = 1
    this
  }

  User confirmterm(){
    if(type_id==2&&!is_termconfirm){
      is_termconfirm = 1
      confirmtermdate = new Date()
    }
    this
  }

  User confirmTel(){
    if (tel) {
      is_telcheck = 1
    } else {
      throw new Exception('Phone number is not specified')
    }
    this
  }

  User setModerateData(lsRequest,oClient){
    name = lsRequest.name?:name
    nickname = lsRequest.nickname?:nickname
    company = lsRequest.company?:''
    description = lsRequest.description?:''
    if (tel!=(lsRequest.tel?:tel)) {
      is_telcheck = 0
    }
    tel = lsRequest.tel?:''
    tel1 = lsRequest.tel1?:''
    client_id = oClient?.id?:0
    type_id = oClient?.type_id?:lsRequest.type_id?:type_id
    is_am = lsRequest.is_am?:0
    if (lsRequest.is_changepass) {
      password = Tools.hidePsw(lsRequest.password2)
    }
    email?:(email=id.toString())
    (code||is_emailcheck)?:(code=java.util.UUID.randomUUID().toString())
    this
  }
  
  /////////////////////////////////////////////////////////////////////////////
  Boolean validateTelNumber(){
    this.smscode = Tools.generateSMScode()
    if(!this.save(flush:true)||!tel)
      return false
    return true
  }

  User setProfileData(lsRequest){
    name = lsRequest.name?:name
    nickname = lsRequest.nickname?:nickname
    if (tel!=(lsRequest.tel?:'')) {
      is_telcheck = 0
    }
    tel = lsRequest.tel?:''
    tel1 = lsRequest.tel1?:''
    is_news = lsRequest.is_news?:0
    is_zayavka = lsRequest.is_zayavka?:0
    is_noticeemail = lsRequest.is_noticeemail&&Tools.checkEmailString(email)?lsRequest.is_noticeemail:0
    is_noticeSMS = lsRequest.is_noticeSMS&&tel?lsRequest.is_noticeSMS:0
    if (lsRequest.is_changepass||is_needtochangepassword) {
      password = Tools.hidePsw(lsRequest.password2)
      is_needtochangepassword = 0
    }
    this
  }

  static void changeTypeByClient_id(iType_id,lClientId){
    User.findAllByClient_id(lClientId)?.each{
      it.type_id = iType_id
      it.save()
    }
  }
}