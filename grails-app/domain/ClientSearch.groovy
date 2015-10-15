import org.codehaus.groovy.grails.commons.ConfigurationHolder
class ClientSearch {
  def searchService

  static mapping = {
    table 'adm_NAME'
    version false
    cache false
  }

  Long id
  String name
  String fullname
  String phone
  Date inputdate
  Integer modstatus
  Integer type_id
  String comment
  Integer shipstatus
  Integer carcount
  Integer shipweight
  Integer shipprice
  Integer shipdistance
  Date lastorder
  Integer ordercount
  String tels
  Integer isblocked

  String toString() {"${this.fullname}" }
  ////////////////////////////////////////////////////////////////////////////////
  def csiSelectClient(sName,sFullname,sTel,lId,iType,iModstatus,iIsblocked,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*, group_concat(tel separator ', ') as tels"
    hsSql.from='client as cl left join user on user.client_id = cl.id and user.is_am = 1'
    hsSql.where="1 = 1"+
                ((sName!='')?' AND cl.name like CONCAT("%",:name,"%")':'')+
                ((sFullname!='')?' AND cl.fullname like CONCAT("%",:fullname,"%")':'')+
                ((lId>0)?' AND cl.id =:client_id':'')+
                ((iType>0)?' AND cl.type_id =:type_id':'')+
                ((iIsblocked>0)?' AND cl.isblocked =:isblocked':'')+
                ((iModstatus>-2)?' AND cl.modstatus =:modstatus':'')+
                ((sTel!='')?' AND (select group_concat(tel separator ", ") from client join user on user.client_id=client.id where is_am=1 and client.id=cl.id group by client.id) like CONCAT("%",:tel,"%")':'')
    hsSql.order="cl.id desc"
    hsSql.group="cl.id"

    if(sName!='')
      hsString['name']=sName
    if(sFullname!='')
      hsString['fullname']=sFullname
    if(sTel!='')
      hsString['tel']=sTel
    if(lId>0)
      hsLong['client_id']=lId
    if(iType>0)
      hsLong['type_id']=iType
    if(iIsblocked>0)
      hsLong['isblocked']=iIsblocked
    if(iModstatus>-2)
      hsLong['modstatus']=iModstatus

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,
      null,null,iMax,iOffset,'*',true,ClientSearch.class)
  }

}