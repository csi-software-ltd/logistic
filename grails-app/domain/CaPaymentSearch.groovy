class CaPaymentSearch {
  def searchService
//////////Payment//////////////////////////////
  Long id
  Long payorder_id
  Long zakaz_id
  Long client_id
  Date paydate
  Integer summa
  Float summands
  String norder
  String platnumber
  String platcomment
  String platname
  Integer modstatus
  Long trip_id
  Integer pclass
  Integer is_fix
  Integer is_active
//////////Carrier//////////////////////////////
  String carrier_name

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def csiSelectPayments(lCarrier,sPlatcomment,dDate){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*, client.fullname as carrier_name"
    hsSql.from="payment, trip, client"
    hsSql.where="payment.trip_id!=0 and payment.trip_id=trip.id and trip.carrier=client.id"+
      ((lCarrier>0)?" and trip.carrier=:carrier":"")+
      ((sPlatcomment!='')?" and payment.platcomment like CONCAT('%',:platcomment,'%')":"")+
      ((dDate)?' and payment.paydate=:paydate':'')
    hsSql.order="payment.id DESC"

    if(lCarrier>0)
      hsLong['carrier']=lCarrier
    if(sPlatcomment!='')
      hsString['platcomment']=sPlatcomment
    if(dDate)
      hsString['paydate']=String.format('%tF',dDate)

    searchService.fetchData(hsSql,hsLong,null,hsString,null,CaPaymentSearch.class)
  }

}