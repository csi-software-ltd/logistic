class PaybenefitSearch {
  def searchService
//////////Paybenefit///////////////////////////
  Long id
  Long payorder_id
  Date paydate
  Integer summa
  String platcomment
  String beneficial
//////////Shipper//////////////////////////////
  String shipper_name

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def csiSelectPayments(lShipper,sPlatcomment,dDate){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*, client.fullname as shipper_name"
    hsSql.from="paybenefit, payorder, client"
    hsSql.where="paybenefit.payorder_id=payorder.id and payorder.client_id=client.id"+
      ((lShipper>0)?" and payorder.client_id=:shipper":"")+
      ((sPlatcomment!='')?" and paybenefit.platcomment like CONCAT('%',:platcomment,'%')":"")+
      ((dDate)?' and paybenefit.paydate=:paydate':'')
    hsSql.order="paybenefit.id DESC"

    if(lShipper>0)
      hsLong['shipper']=lShipper
    if(sPlatcomment!='')
      hsString['platcomment']=sPlatcomment
    if(dDate)
      hsString['paydate']=String.format('%tF',dDate)

    searchService.fetchData(hsSql,hsLong,null,hsString,null,PaybenefitSearch.class)
  }

}