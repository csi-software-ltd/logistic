class DeliverySearch {
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
  Long returndriver_id
  String returndriver_fullname
  Integer returncar_id
  String returncargosnomer
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
  Integer is_readcurrier
  Integer is_readeventcurrier
  Integer is_readeventshipper
  Integer is_readeventadmin
  Date docdate

  String containernumber1
  String containernumber2
  String docseria
  String docnumber

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def csiSelectTrip(bType,lClId,lZakazId,lTripId,iModstatus,iTaskstatus,iMax,iOffset,bMobile=0){
    def hsSql=[select:'',from:'',where:'',order:''] 
    def hsLong=[:]

    hsSql.select="*"
    hsSql.from='trip join zakaztodriver on trip.zakaztodriver_id=zakaztodriver.id,driver'
    hsSql.where="trip.returndriver_id = driver.id"+
                (bType?" AND trip.carrier =:client":" AND trip.shipper =:client")+
                ((lZakazId>0)?' AND trip.zakaz_id =:zakaz_id':'')+
                ((lTripId>0)?' AND trip.id =:id':'')+
                ((iModstatus>-100)?' AND trip.modstatus =:modstatus':'')+
                ((iTaskstatus>-100)?' AND trip.taskstatus =:taskstatus':'')+
                ((bMobile)?' AND (trip.modstatus =0 OR trip.modstatus =1)':'')
    hsSql.order=(bMobile==1)?"dateA desc, trip.id desc":"trip.id desc"

    if(iModstatus>-100)
      hsLong['modstatus']=iModstatus
    if(iTaskstatus>-100)
      hsLong['taskstatus']=iTaskstatus
    if(lZakazId>0)
      hsLong['zakaz_id']=lZakazId
    if(lTripId>0)
      hsLong['id']=lTripId
    hsLong['client']=lClId

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,null,
      null,null,iMax,iOffset,'trip.id',true,DeliverySearch.class)
  }

}