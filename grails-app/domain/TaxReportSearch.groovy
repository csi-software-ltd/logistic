class TaxReportSearch {
  def searchService

  static mapping = {
    table 'adm_NAME'
    version false
    cache false
  }

  Integer id
  Long client_id
  Long trip_id = 0
  Date paydate
  Integer summa

  String client_name
  Integer tax

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def csiSearchTax(iYear,iMonth){
    def hsSql=[select:'',from:'',where:'',order:''] 
    def hsLong=[:]

    hsSql.select="*, sum(summa) as tax, client.fullname as client_name"
    hsSql.from='paytax join client on client.id=paytax.client_id'
    hsSql.where="year(paydate)=:year"+
                (iMonth>0?" and month(paydate)=:month":"")
    hsSql.order="client.id desc"
    hsSql.group="paytax.client_id"

    hsLong['year']=iYear?:2014
    if(iMonth>0)
      hsLong['month']=iMonth

    def hsRes=searchService.fetchData(hsSql,hsLong,null,null,null,TaxReportSearch.class)
  }

}