class ZakaztocarrierSearch {
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
  Long client_id
  Date inputdate
  Date moddate
  Integer modstatus
  Integer cprice
  Integer zcol
  Integer is_read
  Date deadline
  Integer is_debate
  Integer is_carinfo
  Integer ncar

  Long remindtime

  Integer ztype_id
  Integer container
  Date zdate
  Date date_start
  Integer terminal
  Integer terminal_end
  String region_start
  String city_start
  String region_end
  String city_end
  Integer ztime_id

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def csiSelectZakaz(lClId,lZakazId,iModstatus,iMax,iOffset,iMobileType=-1){
    def hsSql=[select:'',from:'',where:'',order:''] 
    def hsLong=[:]

    hsSql.select="*, IF((UNIX_TIMESTAMP(zakaztocarrier.deadline)-UNIX_TIMESTAMP(now()))>0,UNIX_TIMESTAMP(zakaztocarrier.deadline)-UNIX_TIMESTAMP(now()),0) as remindtime"
    hsSql.from='zakaztocarrier join zakaz on zakaztocarrier.zakaz_id=zakaz.id'
    hsSql.where="1 = 1"+
                ((lClId>0)?' AND zakaztocarrier.client_id =:carrier':'')+
                ((lZakazId>0)?' AND zakaztocarrier.zakaz_id =:id':'')+
                ((iModstatus>-100)?' AND zakaztocarrier.modstatus =:modstatus':(iMobileType>-1)?' AND zakaztocarrier.modstatus > -100':' AND zakaztocarrier.modstatus > -2')+
                ((iMobileType>-1)?((iMobileType==0)?' AND zakaztocarrier.modstatus IN (0,1)':((iMobileType==1)?' AND zakaztocarrier.modstatus IN (2,-1,-2)':'')):'')
    hsSql.order="zakaztocarrier.id desc"

    if(iModstatus>-100)
      hsLong['modstatus']=iModstatus
    if(lZakazId>0)
      hsLong['id']=lZakazId
    if(lClId>0)
      hsLong['carrier']=lClId

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,null,
      null,null,iMax,iOffset,'zakaztocarrier.id',true,ZakaztocarrierSearch.class)
  }

}