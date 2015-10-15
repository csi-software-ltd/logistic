class PayorderSearchCarrier {
  def searchService
  static mapping = {
    table 'adm_NAME'
    version false
    cache false
  }
  static constraints = {
  }

  Long order_id
  Long zakaz_id
  Integer modstatus
  Integer paystatus
  String norder
  Date orderdate
  Date inputdate
  Date lastpayment
  Date maxpaydate
  String nagr
  Integer syscompany_id
  Long clientcompany_id
  Integer fullcost
  Integer idlesum
  Integer forwardsum
  Integer paid
  Integer nds
  Integer is_longtrip
  String contnumbers
  String destination
  String paycomment

  Long id
  String drivername
  String cargosnomer
  Long shipper
  Long carrier
  String carrier_name
  Date zakazdate
  String shipper_name
  Integer terminal_start
  String address_start
  Integer sh_price
  Integer ca_price
  String cont1
  String cont2
  Integer contpaid1
  Integer contpaid2
  Integer debt
  Integer admin_id
  String manager
  Date ca_maxpaydate
  Integer ca_idlesum
  Integer ca_forwardsum
  Integer ca_paid
  Integer ca_trackertax
  Date ca_lastpaydate
  Date docdate

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def findOrdersForCarrierSettlements(lZakazId,lTripId,sCarrier,sContainer,iAdminId,iDebt,iSort,iMax,iOffset,iDaydiff=0,iTracker=0){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*"
    hsSql.from="v_payordercarrier"
    hsSql.where="is_delete=0"+
      ((lZakazId>0)?" and zakaz_id=:zakaz_id":"")+
      ((lTripId>0)?" and id=:trip_id":"")+
      ((iAdminId>0)?" and admin_id=:admin_id":"")+
      ((iDebt>0)?" and debt>0 and IFNULL(ca_maxpaydate,curdate())<curdate()":"")+
      ((sCarrier!='')?' and carrier_name like CONCAT("%",:carrier,"%")':'')+
      ((sContainer!='')?' and contnumbers like CONCAT("%",:contnumbers,"%")':'')+
      ((iDaydiff)?" and IFNULL(ca_maxpaydate,curdate())<=(curdate() + interval-(:daydiff) day) and debt>0":"")+
      ((iTracker>0)?" and imei!=''":"")
    hsSql.order=(iSort==1?"case when (debt>0 and 0<>IFNULL(ca_maxpaydate,0)) then 0 else IFNULL(ca_maxpaydate,1) end asc, ca_maxpaydate asc":iSort==2?"lastpayment DESC":"id DESC")

    if(lZakazId>0)
      hsLong['zakaz_id']=lZakazId
    if(lTripId>0)
      hsLong['trip_id']=lTripId
    if(iAdminId>0)
      hsLong['admin_id']=iAdminId
    if(sCarrier!='')
      hsString['carrier']=sCarrier
    if(sContainer!='')
      hsString['contnumbers']=sContainer
    if(iDaydiff)
      hsLong['daydiff']=iDaydiff

    return searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,null,null,iMax,iOffset,'id',true,PayorderSearchCarrier.class)
  }

  def findOrdersForCarrierSettlements(lOrderId,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select="*"
    hsSql.from="v_payordercarrier"
    hsSql.where="is_delete=0"+
      ((lOrderId>0)?" and order_id=:order_id":"")
    hsSql.order="id DESC"

    if(lOrderId>0)
      hsLong['order_id']=lOrderId

    return searchService.fetchDataByPages(hsSql,null,hsLong,null,null,null,null,iMax,iOffset,'id',true,PayorderSearchCarrier.class)
  }

  def findOrdersForCarrierSettlements(lTripId,lCarrier,iYear,sContainer,iDriverId,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*"
    hsSql.from="v_payordercarrier"
    hsSql.where="is_delete=0"+
      ((lTripId>0)?" and id=:trip_id":"")+
      ((lCarrier>0)?" and carrier=:carrier":"")+
      ((iDriverId>0)?" and driver_id=:driver_id":"")+
      ((iYear>0)?" and (year(IFNULL(docdate,curdate()))=:year or (debt>0 and year(IFNULL(docdate,curdate()))<:year))":"")+
      ((sContainer!='')?' and contnumbers like CONCAT("%",:contnumbers,"%")':'')
    hsSql.order="IFNULL(docdate,0) desc, zakazdate desc"
    //hsSql.order="case when (debt>0 and 0<>IFNULL(ca_maxpaydate,0)) then 0 else IFNULL(ca_maxpaydate,1) end asc, ca_maxpaydate asc"

    if(lTripId>0)
      hsLong['trip_id']=lTripId
    if(lCarrier>0)
      hsLong['carrier']=lCarrier
    if(iDriverId>0)
      hsLong['driver_id']=iDriverId
    if(iYear>0)
      hsLong['year']=iYear
    if(sContainer!='')
      hsString['contnumbers']=sContainer

    return searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,null,null,iMax,iOffset,'id',true,PayorderSearchCarrier.class)
  }

  def findOrdersForEditingMaxpaydate(lCarrier,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select="*"
    hsSql.from="v_payordercarrier"
    hsSql.where="debt>0"+
      ((lCarrier>0)?" and carrier=:carrier":"")
    hsSql.order="id DESC"

    if(lCarrier>0)
      hsLong['carrier']=lCarrier

    return searchService.fetchDataByPages(hsSql,null,hsLong,null,null,null,null,iMax,iOffset,'id',true,PayorderSearchCarrier.class)
  }

  def findNonpaidcontainers(lCarrier,sContainer){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*"
    hsSql.from="v_payordercarrier"
    hsSql.where="debt>0 and is_delete=0"+
      ((lCarrier>0)?" and carrier=:carrier":"")+
      ((sContainer!='')?' and contnumbers like CONCAT("%",:contnumbers,"%")':'')
    hsSql.order="IFNULL(docdate,0) desc, zakazdate desc"

    if(lCarrier>0)
      hsLong['carrier']=lCarrier
    if(sContainer!='')
      hsString['contnumbers']=sContainer

    searchService.fetchData(hsSql,hsLong,null,hsString,null,PayorderSearchCarrier.class)
  }

  def getclientnames(){
    def hsSql=[select:'distinct(carrier_name), carrier',from:'v_payordercarrier', order:'carrier_name asc']
    return searchService.fetchData(hsSql,null,null,null,null)
  }

}