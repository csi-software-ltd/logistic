class Zakaztocarrier {
  def searchService
  def gcmService
  
  static mapping = {
    version false
  }
  static constraints = {
  }

  Long id
  Long zakaz_id
  Long client_id
  Date inputdate = new Date()
  Date moddate = new Date()
  Integer modstatus = 0
  Integer cprice
  Integer zcol
  Integer is_read = 0
  Date deadline = new Date()
  Integer is_debate
  Integer is_carinfo = 0
  Integer ncar = 0

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def afterInsert() {
    //log.debug('zakaztocarrier: client_id: '+client_id)
    Zakaztocarrier.withNewSession { gcmService.sendMessage('notice_unread_count',Zakaztocarrier.countByClient_idAndIs_read(client_id,0),client_id)}
  }
  
  Zakaztocarrier setMainData(_zakaz){
    cprice = _zakaz.price_basic?:_zakaz.price
    zcol = _zakaz.zcol?:0
    is_debate = _zakaz.is_debate?:0
    deadline = new Date(_zakaz.inputdate.getTime()+(Ztime.get(_zakaz.ztime_id).qtime*1000*60))
    if(_zakaz.route_id){
      def curcol = 0
      def stepcol = Container.get(_zakaz.container)?.ctype_id?:1
      def zakazstarttime = _zakaz.csigetTimestart()
      def zakazendtime = _zakaz.csigetTimeend()
      Freecars.findAllByClient_idAndModstatusAndRoutesLike(client_id,1,'%;'+_zakaz.route_id+';%').each{
        if(curcol<_zakaz.zcol&&it.timestart<zakazendtime&&(it.timeend<0||it.timeend>zakazstarttime)){
          new Zakaztodriver(zakaz_id:_zakaz.id,client_id:client_id).setMainData([driver_id:it.driver_id,car_id:it.car_id,trailer_id:it.trailer_id,zcol:curcol+stepcol>_zakaz.zcol?1:stepcol]).save(failOnError:true)
          curcol+=stepcol
        }
      }
      if (curcol){
        csiSetModstatus(1).csiSetNcar(curcol/stepcol as Integer).csiSetCarInfo(1)
        zcol = curcol>=zcol?zcol:curcol
      }
    }
    this
  }

  def findOffers(iZakazId){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select="*"
    hsSql.from='zakaztocarrier'
    hsSql.where="zakaz_id =:id"
    hsSql.order="modstatus desc, cprice asc, moddate asc"

    hsLong['id'] = iZakazId

    def hsRes=searchService.fetchData(hsSql,hsLong,null,null,null,Zakaztocarrier.class)
  }

  Zakaztocarrier csiSetModstatus(iStatus){
    modstatus = iStatus?:modstatus
    if (iStatus==-2) carrierread()
    else if(iStatus==2) Zakaztodriver.findAllByZakaz_idAndClient_id(zakaz_id,client_id).each { it.assign().save() }
    this
  }

  Zakaztocarrier setCarrierOffer(_request){
    cprice = _request.cprice?:cprice
    zcol = _request.zcol?:zcol
    moddate = new Date()
    this
  }

  Zakaztocarrier carrierread(){
    is_read = 1
    this
  }

  Zakaztocarrier csiSetCarInfo(iStatus){
    is_carinfo = iStatus?:0
    this
  }

  Zakaztocarrier csiSetNcar(iStatus){
    ncar = iStatus?:0
    this
  }

  Zakaztocarrier updateDebate(iDebate){
    is_debate = iDebate?:0
    this
  }

}