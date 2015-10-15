class Triproute {
  def sessionFactory
  def searchService
  static mapping = {
    version false
  }
  static constraints = {
  }

  Long id
  Long trip_id
  Long trackingdata_id
	Long x
	Long y
	Date tracktime
	Date inputdate
	Integer kurs
	Integer speed
	Integer is_processed = 0

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	def updateFromTrackingdata(oTrip){
		if (!oTrip?.imei) return false
		def sSql="insert into triproute (`trip_id`, `trackingdata_id`, `x`,  `y`, `inputdate`, `tracktime`, `kurs`, `speed`)"+
					" SELECT $oTrip.id, `id`, `x`,  `y`, `inputdate`, `tracktime`, `kurs`, `speed`"+
					" FROM trackingdata"+
					" where inputdate > (IFNULL((select inputdate from triproute where trip_id=$oTrip.id order by inputdate desc limit 1),(select date_add(dateA, INTERVAL timestartA-1 hour) from trip where id=$oTrip.id)))"+
					" AND imei=$oTrip.imei"

		def session = sessionFactory.getCurrentSession()
		def qSql = session.createSQLQuery(sSql)

		try{
			qSql.executeUpdate()
    }catch(Exception e){
      log.debug('Error on copying trackingdata to triproute')
      log.debug(sSql)
      log.debug(e.toString())
    }
    session.clear()
    true
  }

  Triproute processed(){
  	is_processed = 1
  	this
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def csiSelectRoute(lTripId,dMaxDateTime=null){
    def hsSql=[select:'',from:'',where:'',order:''] 
    def hsLong=[:]
    def hsString=[:]

    hsSql.select = "*"
    hsSql.from = "(select * from triproute where trip_id=:trip_id order by tracktime desc) as tmp"
    hsSql.where = "1=1"+
      (dMaxDateTime?' AND tracktime <=:maxtracktime':'')
    hsSql.group = "(x+y)"
    hsSql.order = "tracktime desc"

    hsLong['trip_id']=lTripId
    if(dMaxDateTime)
      hsString['maxtracktime']=String.format('%tF %<tT', dMaxDateTime)

    def hsRes=searchService.fetchData(hsSql,hsLong,null,hsString,null,Triproute.class)
  }

}