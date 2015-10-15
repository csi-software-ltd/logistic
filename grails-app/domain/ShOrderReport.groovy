class ShOrderReport {
  def searchService

  static mapping = {
    table 'adm_NAME'
    version false
    cache false
  }

  Long id
  Long zakaz_id
  String norder
  Date orderdate
  String containernumber1
  String containernumber2
  Integer price_sh
  String companyname
  Integer syscompany_id

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def csiGetReport(lId){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select="*, zakaz.id as zakaz_id, clientrequisites.payee as companyname"
    hsSql.from='trip join zakaztodriver on trip.zakaztodriver_id=zakaztodriver.id join zakaz on trip.zakaz_id=zakaz.id join payorder on zakaz.id=payorder.zakaz_id left join clientrequisites on payorder.clientcompany_id=clientrequisites.id'
    hsSql.where="payorder.client_id=:shipper"
    hsSql.order="zakaz.id desc"

    if(lId>0)
      hsLong['shipper']=lId

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,null,null,null,-1,0,'trip.id',true,ShOrderReport.class)
  }

}