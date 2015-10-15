class ZakazSearchAdmin {
  def searchService

  static mapping = {
    table 'adm_NAME'
    version false
    cache false
  }

  Long id
  Long user_id
  Integer ztype_id  
  Integer zcol
  Long shipper
  Long carrier
  Integer container
  String trailertype_id
  Date zdate
  Integer terminal
  Integer timestart
  Integer timeend
  String slotlist
  Date date_start
  String region_start
  String city_start
  String address_start
  String prim_start
  String region_end
  String city_end
  String address_end
  String prim_end
  String region_dop
  String city_dop
  String address_dop
  String prim_dop
  String region_cust
  String city_cust
  String address_cust
  String prim_cust
  Integer price
  Float weight1
  Float weight2
  Float weight3
  Float weight4
  Float weight5
  Integer dangerclass
  Integer gabarit
  Integer modstatus
  Date inputdate
  Date moddate
  Integer ztime_id
  Integer is_roof
  String doc
  String comment
  Integer timestart_end
  Integer timeend_end
  String slotlist_end
  Integer terminal_end
  
  String region_zat
  String city_zat
  String address_zat
  String prim_zat
  Date date_zat
  Integer timestart_zat
  Integer timeend_zat
  Integer route_id

  String shippername
  Integer carriercount

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def csiSelectZakaz(lId,sShipper,iModstatus,sUnloading,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:''] 
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*, sh.fullname as shippername, SUM(if(zakaztocarrier.modstatus>0, 1, 0)) as carriercount"
    hsSql.from='zakaz left join client sh on zakaz.shipper = sh.id left join zakaztocarrier on zakaztocarrier.zakaz_id=zakaz.id'
    hsSql.where="1=1"+
                ((lId>0)?' AND zakaz.id =:id':'')+
                ((sShipper!='')?' AND sh.fullname like CONCAT("%",:sh_name,"%")':'')+
                ((sUnloading!='')?' AND (city_end like CONCAT("%",:unload,"%") OR address_end like CONCAT("%",:unload,"%") OR region_end like CONCAT("%",:unload,"%"))':'')+
                ((iModstatus>-100)?' AND zakaz.modstatus =:modstatus':'')
    hsSql.order="zakaz.id desc"
    hsSql.group="zakaz.id"

    if(iModstatus>-100)
      hsLong['modstatus']=iModstatus
    if(lId>0)
      hsLong['id']=lId
    if(sShipper!='')
      hsString['sh_name']=sShipper
    if(sUnloading!='')
      hsString['unload']=sUnloading

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,
      null,null,iMax,iOffset,'*',true,ZakazSearchAdmin.class)
  }

}