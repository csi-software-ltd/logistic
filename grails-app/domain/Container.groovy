class Container {
  def searchService
  static mapping = {
    version false
  }

  static constraints = {
  }

  Integer id
  String name
  String name2
  String shortname
  String picture = ''
  Integer ctype_id = 1
  Float length = 0f
  Float width = 0f
  Float hight = 0f
  Float volume = 0f
  Integer capacity = 0
  Integer is_vartrailer = 0
  Integer is_main = 0

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def csiSelectContainer(sName,iType,iMain,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*"
    hsSql.from='container'
    hsSql.where="1=1"+
                ((sName!='')?' AND name like CONCAT("%",:name,"%")':'')+
                ((iType>0)?' AND ctype_id =:ctype_id':'')+
                ((iMain>-1)?' AND is_main =:is_main':'')
    hsSql.order="id"

    if(sName!='')
      hsString['name']=sName
    if(iType>0)
      hsLong['ctype_id']=iType
    if(iMain>-1)
      hsLong['is_main']=iMain

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,
      null,null,iMax,iOffset,'id',true,Container.class)
  }

  Container setData(lsRequest){
    name = lsRequest.name?:name
    name2 = lsRequest.name2?:''
    shortname = lsRequest.shortname?:shortname
    picture = lsRequest.picture?:''
    ctype_id = lsRequest.ctype_id?:1
    length = lsRequest.length?.replace(',','.')?.isFloat()?lsRequest.length.replace(',','.').toFloat():0f
    width = lsRequest.width?.replace(',','.')?.isFloat()?lsRequest.width.replace(',','.').toFloat():0f
    hight = lsRequest.hight?.replace(',','.')?.isFloat()?lsRequest.hight.replace(',','.').toFloat():0f
    volume = lsRequest.volume?.replace(',','.')?.isFloat()?lsRequest.volume.replace(',','.').toFloat():0f
    capacity = lsRequest.capacity?:0
    is_main = lsRequest.is_main?:0
    this
  }

}
