class ZakaztoshipperSearch {
  def searchService

  static mapping = {
    table 'fake'
    version false
    cache false
  }
  static constraints = {
  }

  Long id
  Long zakaz_id
  String gosnomer
  String fullname
  String docseria
  String docnumber
  String trailnumber
  Integer driverpassport1
  Integer driverpassport2
  Integer driverprava
  Integer carpassport1
  Integer carpassport2
  Integer trailerpassport1
  Integer trailerpassport2
  Long driver_id
  Integer car_id
  Integer trailer_id
  Integer zcol
  Long carrier

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def getDrivers(lZakazId){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select = "*"
    hsSql.from = "zakaztoshipper"
    hsSql.where = "zakaz_id=:zakazId"
    hsSql.order = "zakaz_id DESC"

    hsLong['zakazId'] = lZakazId

    return searchService.fetchData(hsSql,hsLong,null,null,null,ZakaztoshipperSearch.class)
  }

}