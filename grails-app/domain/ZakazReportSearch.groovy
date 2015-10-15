class ZakazReportSearch {
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
  Integer modstatus
  Date inputdate
  Date moddate
  Integer ztime_id

  String shippername
  Integer tripcount
  Integer trippricesum
  Integer carriercount
  String addressA
  String addressB
  String addressC
  String addressD

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def csiSelectZakaz(dreportDate){
    def hsSql=[select:'',from:'',where:'',order:''] 
    def hsString=[:]

    hsSql.select="*, client.fullname as shippername, count(trip.id) as tripcount, sum(trip.price*trip.zcol) as trippricesum, count(distinct trip.carrier) as carriercount"
    hsSql.from='zakaz join trip on trip.zakaz_id=zakaz.id join client on zakaz.shipper = client.id'
    hsSql.where="zakaz.modstatus > 2 and trip.modstatus > -2"+
                (dreportDate?' AND zakaz.date_start >=:startdate AND zakaz.date_start <=:enddate':'')
    hsSql.order="zakaz.id desc"
    hsSql.group="zakaz.id"

    if(dreportDate){
      hsString['startdate']=String.format('%tF',dreportDate)
      def dateEnd = new GregorianCalendar()
      dateEnd.setTime(dreportDate)
      dateEnd.add(Calendar.MONTH,1)
      dateEnd.add(Calendar.DATE,-1)
      hsString['enddate']=String.format('%tF',dateEnd.getTime())
    }

    def hsRes=searchService.fetchData(hsSql,null,null,hsString,null,ZakazReportSearch.class)
  }

}