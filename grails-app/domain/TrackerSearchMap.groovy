class TrackerSearchMap {
  def searchService

  static mapping = {
    table 'adm_NAME'
    version false
    cache false
  }

  Long id
  String imei
  String trackaccount
  String sim
  String tel
  Date inputdate
  Date moddate
  Integer modstatus

  String gosnomer
  Long client_id   
  Long trackingdata_id

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def csiSelectTrack(sImei,sTrackaccount,sGosnomer,lClId,iModstatus,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',group:'',order:''] 
    def hsLong=[:]
    def hsInt=[:]
    def hsString=[:]

    hsSql.select="*, MAX(trackingdata.id) AS trackingdata_id"
    hsSql.from='tracker left join car on tracker.imei = car.imei left join trackingdata on tracker.imei = trackingdata.imei'
    hsSql.where="1=1"+
                ((sImei!='')?' AND tracker.imei like CONCAT("%",:imei,"%")':'')+
                ((sTrackaccount!='')?' AND trackaccount like CONCAT("%",:trackaccount,"%")':'')+
                ((sGosnomer!='')?' AND gosnomer like CONCAT("%",:gosnomer,"%")':'')+
				        ((lClId>0)?' AND client_id =:client_id':'')+
                ((iModstatus>-2)?' AND tracker.modstatus =:modstatus':'')
                //((xr>0 && yu>0)?' AND x>=:xl AND x<=:xr AND y>=:yd AND y<=:yu':'')                
    hsSql.group="tracker.id"            
    hsSql.order="tracker.id desc"
/*
    if(xr>0 && yu>0){
      hsLong['xr']=xr
      hsLong['xl']=xl
      hsLong['yd']=yd
      hsLong['yu']=yu
    }    
*/    
    if(sImei!='')
      hsString['imei']=sImei
    if(sTrackaccount!='')
      hsString['trackaccount']=sTrackaccount
    if(sGosnomer!='')
      hsString['gosnomer']=sGosnomer
    if(lClId>0)
      hsLong['client_id']=lClId
    if(iModstatus>-2)
      hsLong['modstatus']=iModstatus

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,
      null,null,iMax,iOffset,'*',true,TrackerSearchMap.class)
  }

}