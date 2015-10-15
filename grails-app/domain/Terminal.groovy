class Terminal {
  def searchService
  static mapping = {
    version false
  }

  static constraints = {
  }

  Integer id
  String name
  String address = ''
  String infourl = ''
  Integer x = 0
  Integer y = 0
  Integer modstatus = 0
  Integer is_slot = 0
  Integer is_main = 0

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def csiSelectTerminal(sName,iId,iMain,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*"
    hsSql.from='terminal'
    hsSql.where="1=1"+
                ((sName!='')?' AND name like CONCAT("%",:name,"%")':'')+
                ((iId>0)?' AND id =:terminal_id':'')+
                ((iMain>-1)?' AND is_main =:is_main':'')
    hsSql.order="id"

    if(sName!='')
      hsString['name']=sName
    if(iId>0)
      hsLong['terminal_id']=iId
    if(iMain>-1)
      hsLong['is_main']=iMain

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,
      null,null,iMax,iOffset,'id',true,Terminal.class)
  }

  Terminal setData(lsRequest){
    name = lsRequest.name?:name
    address = lsRequest.address?:''
    infourl = lsRequest.infourl?:''
    x = lsRequest.x?:0
    y = lsRequest.y?:0
    modstatus = lsRequest.modstatus?:0
    is_main = lsRequest.is_main?:0
    this
  }

  Terminal csiSetIsSlot(iStatus){
    is_slot = iStatus
    this
  }

}