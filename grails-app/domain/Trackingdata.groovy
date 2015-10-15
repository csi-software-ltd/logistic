class Trackingdata {
  def searchService
  def sessionFactory
  static constraints = {
  	tracktime(nullable:true)
  }
  static mapping = {
    version false
  }

	Long id
	String imei
	Long x
	Long y
	Integer kurs
	Integer speed
	Integer status = 1
	Integer distance = 0
	Integer car_id = 0
	Date tracktime
	Date inputdate = new Date()

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def csiSelectTrack(lsIds,xl,yd,xr,yu,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsList=[:]

    hsSql.select="*"
    hsSql.from='trackingdata'
    hsSql.where="id in (:ids)"+
                ((xr>0 && yu>0)?' AND x>=:xl AND x<=:xr AND y>=:yd AND y<=:yu':'')
    hsSql.order="id desc"

    hsList['ids']=lsIds

    if(xr>0 && yu>0){
      hsLong['xr']=xr
      hsLong['xl']=xl
      hsLong['yd']=yd
      hsLong['yu']=yu
    }

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,null,
      hsList,null,iMax,iOffset,'id',true,Trackingdata.class)
  }

  void archiveTrackingdata(){
    def session = sessionFactory.getCurrentSession()
    def sSql="insert into trackingdata_archive (`imei`, `x`, `y`, `kurs`, `speed`, `status`, `distance`, `car_id`, `tracktime`, `inputdate`)"+
          " SELECT `imei`, `x`, `y`, `kurs`, `speed`, `status`, `distance`, `car_id`, `tracktime`, `inputdate`"+
          " FROM trackingdata"+
          " where tracktime < date_sub(now(), INTERVAL 30 day)"
    def qSql = session.createSQLQuery(sSql)

    try{
      qSql.executeUpdate()
    }catch(Exception e){
      log.debug('Error on copying trackingdata to trackingdata_archive')
      log.debug(sSql)
      log.debug(e.toString())
      return
    }

    sSql ="delete "+
          " FROM trackingdata"+
          " where tracktime <= (IFNULL((select tracktime from trackingdata_archive order by tracktime desc limit 1),date_sub(now(), INTERVAL 30 day)))"
    qSql = session.createSQLQuery(sSql)
    try{
      qSql.executeUpdate()
    }catch(Exception e){
      log.debug('Error on clean trackingdata')
      log.debug(sSql)
      log.debug(e.toString())
    }
    session.clear()
  }

}