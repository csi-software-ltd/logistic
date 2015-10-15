class TripSearchAdmin {
  def searchService

  static mapping = {
    table 'adm_NAME'
    version false
    cache false
  }

  Long id
  Long zakaz_id
  Integer ztype_id
  Integer zcol
  Long shipper
  Long carrier
  Integer container
  String imei
  Long zakaztodriver_id
  Integer terminal
  Integer terminal_end
  Long driver_id
  String driver_fullname
  Integer car_id
  String cargosnomer
  Integer trailer_id
  String trailnumber
  Integer price
  Integer price_sh
  Integer modstatus
  Integer trackstatus
  Integer taskstatus
  String description
  Date inputdate
  Date moddate
  String comment
  Integer payorder_id

//>>task
  Date taskdate
  String taskslot
  Integer taskterminal
  Integer taskstart
  Integer taskend
  String taskaddress
  String stockbooking
  String taskprim
//<<task

  Integer xA
  Integer yA
  Date dateA
  Integer timestartA
  Integer timeendA
  String addressA
  String primA

  Integer xB
  Integer yB
  Date dateB
  Integer timestartB
  Integer timeendB
  String addressB
  String primB

  Integer xC
  Integer yC
  Date dateC
  Integer timestartC
  Integer timeendC
  String addressC
  String primC

  Integer xD
  Integer yD
  Date dateD
  Integer timestartD
  Integer timeendD
  String addressD
  String primD

  Integer distance
  String realdistance
  Date docdate

  String shippername
  String carriername
  String containernumber1
  String containernumber2
  String docseria
  String docnumber

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def csiSelectTrip(lId,lShipperId,lCarrierId,lDriverId,sCarNomer,sContainer,lZakazId,iModstatus,iTaskstatus,iMax,iOffset,isMap=false,dDate=null,sShipperName=''){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*, sh.fullname as shippername, ca.fullname as carriername"
    hsSql.from='trip left join client sh on trip.shipper = sh.id left join client ca on trip.carrier = ca.id join zakaztodriver on trip.zakaztodriver_id=zakaztodriver.id,driver'
    hsSql.where="trip.driver_id=driver.id"+
                ((lId>0)?' AND trip.id =:id':'')+
                ((lZakazId>0)?' AND trip.zakaz_id =:zakaz_id':'')+
                ((lShipperId>0)?' AND trip.shipper =:shipper':'')+
                ((lCarrierId>0)?' AND trip.carrier =:carrier':'')+
                ((lDriverId>0)?' AND trip.driver_id =:driver_id':'')+
                ((sCarNomer!='')?' AND cargosnomer like CONCAT("%",:cargosnomer,"%")':'')+
                ((sContainer!='')?' AND (zakaztodriver.containernumber1 like CONCAT("%",:container,"%") OR zakaztodriver.containernumber2 like CONCAT("%",:container,"%"))':'')+
                ((iModstatus>-100)?' AND trip.modstatus =:modstatus':iModstatus==-101?' AND trip.modstatus in (0,1)':'')+
                ((iTaskstatus>-100)?' AND trip.taskstatus =:taskstatus':(iTaskstatus==-101)?' AND trip.taskstatus < 6':'')+
                (isMap?' AND trip.imei !=""':'')+
                (dDate&&!lShipperId?' AND trip.dateA >=:startdate AND trip.dateA <=:enddate and trip.modstatus>-2':'')+
                (dDate&&(lShipperId||lCarrierId)?' AND trip.taskstatus>4 AND trip.taskdate >=:startdate AND trip.taskdate <=:enddate':'')+
                ((sShipperName!='')?' AND sh.fullname like CONCAT("%",:shippername,"%")':'')
    hsSql.order="trip.id desc"

    if(lId>0)
      hsLong['id']=lId
    if(lZakazId>0)
      hsLong['zakaz_id']=lZakazId
    if(lShipperId>0)
      hsLong['shipper']=lShipperId
    if(lCarrierId>0)
      hsLong['carrier']=lCarrierId
    if(lDriverId>0)
      hsLong['driver_id']=lDriverId
    if(iModstatus>-100)
      hsLong['modstatus']=iModstatus
    if(iTaskstatus>-100)
      hsLong['taskstatus']=iTaskstatus
    if(sCarNomer!='')
      hsString['cargosnomer']=sCarNomer
    if(sContainer!='')
      hsString['container']=sContainer
    if(sShipperName!='')
      hsString['shippername']=sShipperName
    if(dDate){
      hsString['startdate']=String.format('%tF',dDate)
      def dateEnd = new GregorianCalendar()
      dateEnd.setTime(dDate)
      dateEnd.add(Calendar.MONTH,1)
      dateEnd.add(Calendar.DATE,-1)
      hsString['enddate']=String.format('%tF',dateEnd.getTime())
    }

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,
      null,null,iMax,iOffset,'trip.id',true,TripSearchAdmin.class)
  }

  def csiSelectTripForContreport(lShipperId,lCarrierId,dDate=null){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*, sh.fullname as shippername, ca.fullname as carriername"
    hsSql.from='trip left join client sh on trip.shipper = sh.id left join client ca on trip.carrier = ca.id join zakaztodriver on trip.zakaztodriver_id=zakaztodriver.id,driver'
    hsSql.where="trip.driver_id=driver.id"+
                ((lShipperId>0)?' AND trip.shipper =:shipper':'')+
                ((lCarrierId>0)?' AND trip.carrier =:carrier':'')+
                (dDate&&!lShipperId?' AND trip.dateA >=:startdate AND trip.dateA <=:enddate and trip.modstatus>-2':'')+
                (dDate&&(lShipperId||lCarrierId)?' AND trip.taskstatus>4 AND trip.taskdate >=:startdate AND trip.taskdate <=:enddate':'')
    hsSql.order="trip.dateA desc"

    if(lShipperId>0)
      hsLong['shipper']=lShipperId
    if(lCarrierId>0)
      hsLong['carrier']=lCarrierId
    if(dDate){
      hsString['startdate']=String.format('%tF',dDate)
      def dateEnd = new GregorianCalendar()
      dateEnd.setTime(dDate)
      dateEnd.add(Calendar.MONTH,1)
      dateEnd.add(Calendar.DATE,-1)
      hsString['enddate']=String.format('%tF',dateEnd.getTime())
    }

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,
      null,null,-1,0,'trip.id',true,TripSearchAdmin.class)
  }

}