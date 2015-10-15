import org.codehaus.groovy.grails.commons.ConfigurationHolder
class Client {
  def searchService
  static constraints = {
    name(unique:true)
    fullname(unique:true)
    lastorder(nullable:true)    
  }
  static mapping = {
    version false
  }

  Long id
  String name
  String fullname
  String phone = ''
  Date inputdate = new Date()
  Integer modstatus = 0
  Integer type_id
  String comment = ''
  Integer shipstatus = 1
  Integer carcount = 0
  Integer shipweight = 0
  Integer shipprice = 0
  Integer shipdistance = 500
  Date lastorder
  Integer ordercount = 0
  Integer admin_id = 0
  Integer ishavetrackers = 0
  Integer isblocked = 0
  String docpages = ''

  String toString() {"${this.fullname}" }
  ////////////////////////////////////////////////////////////////////////////////

  static Client findOrCreate(lsRequest,oUser){
    def cl = Client.get(lsRequest.client_id)
    if (!cl)
      cl = new Client(name:lsRequest.email?:oUser.email?:oUser.id.toString(),fullname:lsRequest.fullname,type_id:lsRequest.type_id).save(failOnError:true)
    cl
  }

  def csiSelectClient(sName,sFullname,lId,iType,iModstatus,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*"
    hsSql.from='client'
    hsSql.where="1=1"+
                ((sName!='')?' AND name like CONCAT("%",:name,"%")':'')+
                ((sFullname!='')?' AND fullname like CONCAT("%",:fullname,"%")':'')+
                ((lId>0)?' AND id =:client_id':'')+
                ((iType>0)?' AND type_id =:type_id':'')+
                ((iModstatus>-2)?' AND modstatus =:modstatus':'')
    hsSql.order="id desc"

    if(sName!='')
      hsString['name']=sName
    if(sFullname!='')
      hsString['fullname']=sFullname
    if(lId>0)
      hsLong['client_id']=lId
    if(iType>0)
      hsLong['type_id']=iType
    if(iModstatus>-2)
      hsLong['modstatus']=iModstatus

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,
      null,null,iMax,iOffset,'id',true,Client.class)
  }

  Client csiSetModstatus(iStatus){
    modstatus = iStatus?:modstatus
    this
  }

  Client csiSetIsBlocked(iValue){
    isblocked = iValue?:0
    this
  }

  Client setMainData(lsRequest){
    fullname = lsRequest.fullname?:fullname
    comment = lsRequest.comment?:''
    if (type_id!=(lsRequest.type_id?:type_id)) {
      User.changeTypeByClient_id(lsRequest.type_id,id?:0)
    }
    admin_id = lsRequest.admin_id?:0
    type_id = lsRequest.type_id?:type_id
    this
  }
  
  Client csiSetContractData(lsRequest){
    nagr = lsRequest.nagr
    agrdate = lsRequest.agrdate
    syscompany_id = lsRequest.syscompany_id
    shortbenefit = lsRequest.shortbenefit?:0
    longbenefit = lsRequest.longbenefit?:0
    payterm = lsRequest.payterm
    this
  }

  Client updateLimitingParams(hsParams){
    shipdistance = hsParams.distance?Math.abs(hsParams.distance):0
    shipweight = hsParams.weight?Math.abs(hsParams.weight):0
    shipprice = hsParams.price?Math.abs(hsParams.price):0
    this
  }

  Client computeCarCount(){
    carcount = Car.countByClient_idAndModstatus(id,1)
    this
  }

  Client updatetrackerstatus(Boolean isHave){
    ishavetrackers = isHave?1:0
    this
  }

  Client updatedocpages(Long picId){
    docpages+=docpages?','+picId:picId
    this
  }

  def findzakazvariants(oZakaz,isSimplesearch=false){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    def regionlist = []
    if (oZakaz?.region_start) regionlist << (Region.findByName(oZakaz.region_start)?.id?:0)
    if (oZakaz?.region_end) regionlist << (Region.findByName(oZakaz.region_end)?.id?:0)
    if (oZakaz?.region_dop) regionlist << (Region.findByName(oZakaz.region_dop)?.id?:0)
    if (oZakaz?.region_cust) regionlist << (Region.findByName(oZakaz.region_cust)?.id?:0)
    if (oZakaz?.region_zat) regionlist << (Region.findByName(oZakaz.region_zat)?.id?:0)

    hsSql.select="*"
    hsSql.from='client join clienttocontainer on client.id = clienttocontainer.client_id'
    hsSql.where="client.modstatus = 1 and client.type_id = 2 and container_id =:container_id"
    if (!isSimplesearch) {
      hsSql.where += " and shipprice <=:shipprice and (shipweight = 0 or shipweight >=:shipweight) and ( shipdistance=0 or shipdistance >=:shipdistance )"
      regionlist.eachWithIndex { it, i ->
        hsSql.where += " and :reg"+i+" not in(select clienttoregion.region_id from clienttoregion where clienttoregion.client_id = client.id)"
        hsLong['reg'+i] = it
      }
    }
    hsSql.order="client.carcount desc"

    hsLong['container_id'] = oZakaz?.container?:0
    if (!isSimplesearch) {
      hsLong['shipprice'] = oZakaz.is_debate?Long.MAX_VALUE:oZakaz?.price_basic?:oZakaz?.price?:0l
      hsLong['shipweight'] = oZakaz?.collect{[it.weight1,it.weight2,it.weight3,it.weight4,it.weight5]}?.max()?.max()?.toInteger()?:0
      hsLong['shipdistance'] = oZakaz?.distance?:0
    }

    def hsRes=searchService.fetchData(hsSql,hsLong,null,null,null,Client.class,-1/*Tools.getIntVal(ConfigurationHolder.config.zakaz.variants.limit,10)*/)
  }

}