class PayorderSearchShipper {
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
  Integer benefit
  Integer paid
  Integer nds
  Integer is_longtrip
  String contnumbers
  String contbenefit
  String destination
  String paycomment

  Integer debt
  String payee
  Date zakazdate
  Integer sh_price
  String clientname
  Long client_id
  Integer admin_id
  String manager
  Integer is_paidbenefit


  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def findOrdersForShipperSettlements(lZakazId,lClientId,iSyscompany,sNorder,iBenefit,iAdminId,iDebt,lClCompany,iOverpayment,iSort,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*"
    hsSql.from="v_payorder"
    hsSql.where="is_delete=0"+
      ((lZakazId>0)?" and zakaz_id=:zakaz_id":"")+
      ((lClientId>0)?" and client_id=:client_id":"")+
      ((iSyscompany>0)?" and syscompany_id=:syscompany":"")+
      ((lClCompany>0)?" and clientcompany_id=:clcompany":"")+
      ((iAdminId>0)?" and admin_id=:admin_id":"")+
      ((iDebt>0)?" and debt>0 and IFNULL(maxpaydate,curdate())<curdate()":"")+
      ((sNorder!='')?' and norder like CONCAT("%",:norder,"%")':'')+
      ((iBenefit)?' and is_paidbenefit=0':'')+
      ((iOverpayment)?' and paid>(fullcost+idlesum+forwardsum)':'')
    hsSql.order=(iSort==1?"norder DESC":iSort==2?"case when (debt>0 and IFNULL(maxpaydate,curdate())<curdate()) then 0 else IFNULL(maxpaydate,1) end asc, maxpaydate asc":"id DESC")

    if(lZakazId>0)
      hsLong['zakaz_id']=lZakazId
    if(lClientId>0)
      hsLong['client_id']=lClientId
    if(iSyscompany>0)
      hsLong['syscompany']=iSyscompany
    if(lClCompany>0)
      hsLong['clcompany']=lClCompany
    if(iAdminId>0)
      hsLong['admin_id']=iAdminId
    if(sNorder!='')
      hsString['norder']=sNorder

    return searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,null,null,iMax,iOffset,'id',true,PayorderSearchShipper.class)
  }

  def findOrdersForShipperSettlements(lClientId,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select="*"
    hsSql.from="v_payorder"
    hsSql.where="norder!='' and is_delete=0"+
      ((lClientId>0)?" and client_id=:client_id":"")
    hsSql.order="orderdate desc"
    //hsSql.order="case when (debt>0 and IFNULL(maxpaydate,curdate())<curdate()) then 0 else 1 end asc, debt desc, orderdate desc"

    if(lClientId>0)
      hsLong['client_id']=lClientId

    return searchService.fetchDataByPages(hsSql,null,hsLong,null,null,null,null,iMax,iOffset,'id',true,PayorderSearchShipper.class)
  }

  def findOrdersForProfitSettlements(lZakazId,lClientId,iAdminId,iShipperDebt,iCarrierDebt,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select="*"
    hsSql.from="v_payorder"
    hsSql.where="is_delete=0"+
      ((lZakazId>0)?" and zakaz_id=:zakaz_id":"")+
      ((lClientId>0)?" and client_id=:client_id":"")+
      ((iAdminId>0)?" and admin_id=:admin_id":"")+
      ((iShipperDebt>0)?" and debt>0 and IFNULL(maxpaydate,curdate())<curdate()":"")+
      ((iCarrierDebt>0)?" and (select sum(price)-sum(paid)+sum(idlesum)+sum(forwardsum)-sum(trackertax)+IF((select containernumber2 from zakaztodriver where zakaztodriver.id=trip.zakaztodriver_id)!='',trip.price,0) from trip where trip.payorder_id=v_payorder.id and trip.modstatus>=-1)>0":"")
    hsSql.order="zakazdate DESC"

    if(lZakazId>0)
      hsLong['zakaz_id']=lZakazId
    if(lClientId>0)
      hsLong['client_id']=lClientId
    if(iAdminId>0)
      hsLong['admin_id']=iAdminId

    return searchService.fetchDataByPages(hsSql,null,hsLong,null,null,null,null,iMax,iOffset,'id',true,PayorderSearchShipper.class)
  }

  def findOrdersForShSettlementsReport(lClientId,iYear,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select="*"
    hsSql.from="v_payorder"
    hsSql.where="is_delete=0"+
      ((lClientId>0)?" and client_id=:client_id":"")+
      ((iYear>0)?" and (year(IFNULL(zakazdate,curdate()))=:year or (debt>0 and year(IFNULL(zakazdate,curdate()))<:year))":"")
    hsSql.order="zakaz_id DESC"

    if(lClientId>0)
      hsLong['client_id']=lClientId
    if(iYear>0)
      hsLong['year']=iYear

    return searchService.fetchDataByPages(hsSql,null,hsLong,null,null,null,null,iMax,iOffset,'id',true,PayorderSearchShipper.class)
  }

  def findNonbenefitcontainers(lShipper,sContainer){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*"
    hsSql.from="v_payorder"
    hsSql.where="is_paidbenefit=0 and is_delete=0"+
      ((lShipper>0)?" and client_id=:shipper":"")+
      ((sContainer!='')?' and contnumbers like CONCAT("%",:contnumbers,"%")':'')
    hsSql.order="zakaz_id DESC"

    if(lShipper>0)
      hsLong['shipper']=lShipper
    if(sContainer!='')
      hsString['contnumbers']=sContainer

    searchService.fetchData(hsSql,hsLong,null,hsString,null,PayorderSearchShipper.class)
  }

  def findNonPaidOrders(lClientId,lClCompany,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select="*"
    hsSql.from="v_payorder"
    hsSql.where="is_delete=0 and debt>0"+
      ((lClientId>0)?" and client_id=:client_id":"")+
      ((lClCompany>0)?" and clientcompany_id=:clcompany":"")
    hsSql.order="case when (debt>0 and IFNULL(maxpaydate,curdate())<curdate()) then 0 else IFNULL(maxpaydate,1) end asc, maxpaydate asc"

    if(lClientId>0)
      hsLong['client_id']=lClientId
    if(lClCompany>0)
      hsLong['clcompany']=lClCompany

    searchService.fetchDataByPages(hsSql,null,hsLong,null,null,null,null,20,iOffset,'id',true,PayorderSearchShipper.class)
  }

  def getclientnames(){
    def hsSql=[select:'distinct(clientname), client_id',from:'v_payorder', order:'clientname asc']
    return searchService.fetchData(hsSql,null,null,null,null)
  }

  def getclientcompanies(){
    def hsSql=[select:'distinct(payee), clientcompany_id, client_id',from:'v_payorder', order:'payee asc']
    return searchService.fetchData(hsSql,null,null,null,null)
  }

}