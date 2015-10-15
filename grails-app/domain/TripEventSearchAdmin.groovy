class TripEventSearchAdmin {
  def searchService

  static mapping = {
    table 'adm_NAME'
    version false
    cache false
  }

  Long id
  Integer type_id
  Long trip_id
  Date eventdate

  Long zakaz_id
  Long shipper
  Long carrier
  Long driver_id
  String driver_fullname
  Integer car_id
  String cargosnomer
  Integer trailer_id
  String trailnumber
  Integer modstatus

  String shippername
  String carriername

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def csiSelectTripEvent(lTripId,lShipperId,lCarrierId,lDriverId,sCarNomer,iModstatus,iTypeId,dStart,dEnd,iMax,iOffset,bMobile=false){
    def hsSql=[select:'',from:'',where:'',order:''] 
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*, sh.fullname as shippername, ca.fullname as carriername"
    hsSql.from='tripevent left join trip on tripevent.trip_id = trip.id left join client sh on trip.shipper = sh.id left join client ca on trip.carrier = ca.id'
    hsSql.where="1=1"+
                ((lTripId>0)?' AND trip.id =:trip_id':'')+
                ((lShipperId>0)?' AND trip.shipper =:shipper':'')+
                ((lCarrierId>0)?' AND trip.carrier =:carrier':'')+
                ((lDriverId>0)?' AND trip.driver_id =:driver_id':'')+
                ((sCarNomer!='')?' AND cargosnomer like CONCAT("%",:cargosnomer,"%")':'')+
                ((iModstatus>-100)?' AND trip.modstatus =:modstatus':iModstatus==-101?' AND trip.modstatus in (0,1)':'')+
                ((iTypeId>-100)?' AND tripevent.type_id =:type_id':'')+
                ((dStart)?' AND tripevent.eventdate >=:date_start':'')+
                ((dEnd)?' AND tripevent.eventdate <=:date_end':'')
    hsSql.order=(bMobile)?"eventdate desc, tripevent.id desc":"tripevent.id desc"

    if(lTripId>0)
      hsLong['trip_id']=lTripId
    if(lShipperId>0)
      hsLong['shipper']=lShipperId
    if(lCarrierId>0)
      hsLong['carrier']=lCarrierId
    if(lDriverId>0)
      hsLong['driver_id']=lDriverId
    if(iModstatus>-100)
      hsLong['modstatus']=iModstatus
    if(iTypeId>-100)
      hsLong['type_id']=iTypeId
    if(sCarNomer!='')
      hsString['cargosnomer']=sCarNomer
    if(dStart!='')
      hsString['date_start']=String.format('%tF %<tT', dStart)
    if(dEnd!='')
      hsString['date_end']=String.format('%tF %<tT', dEnd+1)

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,
      null,null,iMax,iOffset,'tripevent.id',true,TripEventSearchAdmin.class)
  }

}