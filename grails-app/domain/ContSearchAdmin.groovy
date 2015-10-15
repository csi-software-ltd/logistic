class ContSearchAdmin {
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
  Long driver_id
  String driver_fullname
  Integer car_id
  String cargosnomer
  Integer trailer_id
  String trailnumber
  Integer modstatus
  Integer trackstatus
  Integer taskstatus
  String description
  Date inputdate
  Date moddate
  String comment

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

  String containernumber1 = ''
  String containernumber2 = ''
  Integer zakazstatus
  String docseria = ''
  String docnumber = ''
  String tel = ''

  Long payorder_id
  String norder
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def csiSelectTrip(lId,sContainer,lZakazId,iMax,iOffset,lClId=0){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*, zakaz.modstatus as zakazstatus, payorder.id as payorder_id"
    hsSql.from='trip join zakaz on trip.zakaz_id=zakaz.id join zakaztodriver on trip.zakaztodriver_id=zakaztodriver.id left join payorder on (payorder.id=trip.payorder_id),driver'
    hsSql.where="trip.returndriver_id=driver.id"+
                ((lId>0)?' AND trip.id =:id':'')+
                ((lZakazId>0)?' AND trip.zakaz_id =:zakaz_id':'')+
                ((lClId>0)?' AND trip.shipper =:shipper':'')+
                ((sContainer!='')?' AND (zakaztodriver.containernumber1 like CONCAT("%",:container,"%") OR zakaztodriver.containernumber2 like CONCAT("%",:container,"%"))':'')
    hsSql.order="trip.id desc"

    if(lId>0)
      hsLong['id'] = lId
    if(lZakazId>0)
      hsLong['zakaz_id'] = lZakazId
    if(lClId>0)
      hsLong['shipper'] = lClId
    if(sContainer!='')
      hsString['container'] = sContainer

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,
      null,null,iMax,iOffset,'trip.id',true,ContSearchAdmin.class)
  }

}