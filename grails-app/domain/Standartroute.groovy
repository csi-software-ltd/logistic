class Standartroute {
  def searchService
  static mapping = {
    version false
  }
  static constraints = {
    terminal(nullable:true)
    terminal_end(nullable:true)
  }
  Integer id
  Integer ztype_id
  Integer container
  Integer terminal
  String region_start
  String city_start
  String address_start
  String region_zat = ''
  String city_zat = ''
  String address_zat = ''
  Integer terminal_end
  String region_end = ''
  String city_end = ''
  String address_end = ''
  String region_cust = ''
  String city_cust = ''
  String address_cust = ''
  Float weight1 = 0f
  Integer price_basic = 0
  Integer modstatus = 1
  String shortname = ''
  Date inputdate = new Date()
  Date moddate = new Date()

  String toString(){
    "$shortname/${Container.get(container)?.shortname}/$weight1 т./$price_basic"
  }

  def beforeUpdate() {
    moddate = new Date()
  }

  def csiSelectRoute(iModstatus,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select="*"
    hsSql.from="standartroute"
    hsSql.where="1=1"+
      ((iModstatus>-100)?" and modstatus=:modstatus":"")
    hsSql.order="id DESC"

    if(iModstatus>-100){
      hsLong['modstatus']=iModstatus
    }

    return searchService.fetchDataByPages(hsSql,null,hsLong,null,null,null,null,iMax,iOffset,'id',true,Standartroute.class)
  }

  Standartroute setGeneralData(_request){
    ztype_id = _request.ztype_id?:0
    shortname = _request.shortname?:shortname?:''
    container = _request.container
    price_basic = _request.price_basic?:0
    weight1 = _request.weight1?:0f

    region_start = _request.region_start?:''
    city_start = _request.city_start?:''
    address_start = _request.address_start?:''
    terminal = _request.terminal?:0

    region_end = _request.region_end?:''
    city_end = _request.city_end?:''
    address_end = _request.address_end?:''

    this
  }

  Standartroute setImportData(_request){
    //add some action here
    this
  }

  Standartroute setTransitData(_request){
    region_cust = _request.region_cust?:''
    city_cust = _request.city_cust?:''
    address_cust = _request.address_cust?:''
    this
  }

  Standartroute setExportData(_request){
    terminal_end = _request.terminal_end?:0
    region_zat = _request.region_zat?:''
    city_zat = _request.city_zat?:''
    address_zat = _request.address_zat?:''

    region_cust = _request.region_cust?:''
    city_cust = _request.city_cust?:''
    address_cust = _request.address_cust?:''

    this
  }

  static Integer checkforstandartroute(oZakaz){
    return Standartroute.findAllByModstatusAndZtype_idAndContainer(1,oZakaz?.ztype_id,oZakaz.container).find{
        it.terminal == oZakaz.terminal &&
        it.region_start == oZakaz.region_start &&
        it.city_start == oZakaz.city_start &&
        it.address_start == oZakaz.address_start &&
        it.region_zat == oZakaz.region_zat &&
        it.city_zat == oZakaz.city_zat &&
        it.address_zat == oZakaz.address_zat &&
        it.terminal_end == oZakaz.terminal_end &&
        it.region_end == oZakaz.region_end &&
        it.city_end == oZakaz.city_end &&
        it.address_end == oZakaz.address_end &&
        it.region_cust == oZakaz.region_cust &&
        it.city_cust == oZakaz.city_cust &&
        it.address_cust == oZakaz.address_cust &&
        it.price_basic == oZakaz.price_basic &&
        it.weight1 == oZakaz.collect{[it.weight1,it.weight2,it.weight3,it.weight4,it.weight5]}?.max()?.max()?.toInteger()
      }?.id?:0
  }

}