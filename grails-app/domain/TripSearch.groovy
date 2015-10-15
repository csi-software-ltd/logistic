class TripSearch {
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
  Long zakaztodriver_id
  Integer terminal
  Integer terminal_end
  Long driver_id
  String driver_fullname
  Integer car_id
  String cargosnomer
  String imei
  Integer trailer_id
  String trailnumber
  Integer modstatus
  Integer trackstatus
  Integer taskstatus
  Integer price
  Integer idlesum
  Integer forwardsum
  Integer paid
  Integer trackertax

  Date dateA
  Integer timestartA
  Integer timeendA
  String addressA
  Date dateB
  String addressB
  String doc
  Integer payorder_id

  String containernumber1 = ''
  String containernumber2 = ''

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def csiSelectTrip(bType,lClId,lZakazId,lTripId,iModstatus,sContainer,iMax,iOffset,bMobile=false,iType=-1){
    def hsSql=[select:'',from:'',where:'',order:''] 
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*"
    hsSql.from='trip join zakaztodriver on trip.zakaztodriver_id=zakaztodriver.id'
    hsSql.where=(bType?"trip.carrier =:client":"trip.shipper =:client")+
                ((lZakazId>0)?' AND trip.zakaz_id =:zakaz_id':'')+
                ((lTripId>0)?' AND trip.id =:id':'')+
                ((iModstatus>-100)?' AND trip.modstatus =:modstatus':'')+
                ((sContainer!='')?' AND (zakaztodriver.containernumber1 like CONCAT(:container,"%") OR zakaztodriver.containernumber2 like CONCAT(:container,"%"))':'')+
                ((bMobile)?' AND (trip.modstatus =0 OR trip.modstatus =1)':'')+
                (iType>-1?(iType==0?' AND dateA >=:today AND trip.modstatus in (0,1)':iType==1?' AND dateA <:today AND trip.modstatus in (0,1,2)':iType==2?' AND trip.modstatus<0':''):'')
    hsSql.order=(bMobile)?"trip.dateA desc, trip.id desc":"trip.id desc" 

    if(iModstatus>-100)
      hsLong['modstatus']=iModstatus
    if(lZakazId>0)
      hsLong['zakaz_id']=lZakazId
    if(lTripId>0)
      hsLong['id']=lTripId
    if(sContainer!='')
      hsString['container']=sContainer
    if(iType in 0..1){
      hsString['today'] = String.format('%tF',new Date())
    }
		hsLong['client']=lClId

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,
      null,null,iMax,iOffset,'trip.id',true,TripSearch.class)
  }

  def csiSelectTrip(lOrderId){
    def hsSql=[select:'',from:'',where:'']
    def hsLong=[:]

    hsSql.select="*"
    hsSql.from='trip join zakaztodriver on trip.zakaztodriver_id=zakaztodriver.id'
    hsSql.where="trip.payorder_id =:order and trip.modstatus>=-1"

    hsLong['order']=lOrderId

    searchService.fetchData(hsSql,hsLong,null,null,null,TripSearch.class)
  }

}