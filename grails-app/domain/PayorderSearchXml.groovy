class PayorderSearchXml {
  def searchService
  static mapping = {
    table 'adm_NAME'
    version false
    cache false
  }
  static constraints = {
  }

  Long id
  Long zakaz_id
  Long trip_id
  Integer modstatus
  Integer paystatus
  String norder
  Date orderdate
  Date inputdate
  String nagr
  Integer syscompany_id
  Long clientcompany_id
  Integer fullcost
  Integer idlesum
  Integer forwardsum
  Integer nds
  String contnumbers
  String destination
  String paycomment
  Integer is_delete

  String mastername

  String payee
  String inn
  String kpp
  String address
  Integer ctype_id
  String masterinn

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def findOrdersForXML(){
    def hsSql=[select:'',from:'',where:'',order:'']

    hsSql.select="*, syscompany.name as mastername, syscompany.inn as masterinn"
    hsSql.from="payorder join clientrequisites on (payorder.clientcompany_id=clientrequisites.id) join syscompany on (payorder.syscompany_id=syscompany.id)"
    hsSql.where="payorder.modstatus in (0,1) and payorder.trip_id>0"
    hsSql.order="payorder.id ASC"

    return searchService.fetchData(hsSql,null,null,null,null,PayorderSearchXml.class)
  }

}