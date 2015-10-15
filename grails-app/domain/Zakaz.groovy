class Zakaz {
  def searchService
  def smsService
  def gcmService  
  
  static mapping = {
    version false
  }
  static constraints = {
    container(nullable:true)
    terminal(nullable:true)
    weight1(nullable:true)
    weight2(nullable:true)
    weight3(nullable:true)
    weight4(nullable:true)
    weight5(nullable:true)
    dangerclass(nullable:true)
    gabarit(nullable:true)
    timestart_end(nullable:true)
    timeend_end(nullable:true)
    terminal_end(nullable:true)
    date_zat(nullable:true)
    timestart_zat(nullable:true)
    timeend_zat(nullable:true)
    price_basic(nullable:true)
    offerdate(nullable:true) 
    zdate(nullable:true)    
    date_cust(nullable:true)
  }  
  Long id
  Long user_id = 0
  Integer ztype_id
  Integer zcol
  Long shipper = 0
  Long carrier = 0
  Integer admin_id = 0
  Integer manager_id = 0
  Integer container
  String trailertype_id = ''
  Date zdate
  Integer terminal
  Integer timestart
  Integer timeend
  String slotlist = ''
  Date date_start
  String region_start
  String city_start
  String address_start
  String prim_start
  String region_end
  String city_end
  String address_end
  String prim_end
  String region_dop = ''
  String city_dop = ''
  String address_dop = ''
  String prim_dop = ''
  String region_cust = ''
  String city_cust = ''
  String address_cust = ''
  String prim_cust = ''
  Integer price
  Integer zakazcost = 0
  Integer benefit = 0
  Integer price_basic = 0
  Integer is_debate = 0
  Integer is_mobile = 0
  Float weight1 = 0f
  Float weight2 = 0f
  Float weight3 = 0f
  Float weight4 = 0f
  Float weight5 = 0f
  Integer dangerclass = 0
  Integer gabarit = 0
  Integer modstatus = 0
  Date inputdate = new Date()
  Date moddate = new Date()
  Date offerdate
  Integer ztime_id = 1
  Integer is_roof = 0
  String doc
  String comment
  Integer timestart_end = 0
  Integer timeend_end = 0
  String slotlist_end = ''
  Integer terminal_end

  String region_zat = ''
  String city_zat = ''
  String address_zat = ''
  String prim_zat = ''
  Date date_zat
  Integer timestart_zat = 0
  Integer timeend_zat = 0

  Integer xA = 0
  Integer yA = 0
  Integer xB = 0
  Integer yB = 0
  Integer xC = 0
  Integer yC = 0
  Integer xD = 0
  Integer yD = 0
  Integer distance = 0
  String idle = ''
  Integer base_id = 0
  Date date_cust
  String noticetel = ''
  Integer noticetime = 8
  Long payorder_id = 0
  Integer route_id = 0
  String delayedclients = ''

  def beforeUpdate() {
    moddate = new Date()
  }

  def findZakaz(lUserId,iModstatus,iMax,iOffset,bMobile=false){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsInt=[:]

    def oUser = User.get(lUserId)

    hsSql.select="*"
    hsSql.from="zakaz"
    hsSql.where="shipper=:shipper"+
      ((iModstatus!=100)?" and modstatus=:modstatus":" and (modstatus=0 or  modstatus=1 or modstatus=2 or modstatus=3)")+
      ((!oUser?.client_id)?" and user_id=:user_id":"")
    hsSql.order=(bMobile)?"inputdate DESC, id DESC":"id DESC"

    hsLong['shipper'] = oUser?.client_id?:0
    if (!oUser?.client_id?:0)
      hsLong['user_id'] = oUser?.id?:0

    if(iModstatus<100){
      hsInt['modstatus']=iModstatus
    }

    return searchService.fetchDataByPages(hsSql,null,hsLong,hsInt,null,null,null,iMax,iOffset,'id',true,Zakaz.class,null)
  }

  Zakaz setGeneralData(_request,lUserId){
    user_id = lUserId?:user_id?:0
    ztype_id = _request.ztype_id?:0
    shipper = shipper?:Client.findByFullname(_request.shipper?:'')?.id?:0
    container = _request.container
    zcol = modstatus<2?(_request.zcol?:_request.addzcol?:0):zcol?:0
    price = _request.price
    idle = _request.idle?:''
    ztime_id = _request.ztime_id?:0
    dangerclass = _request.dangerclass?:0
    is_roof = _request.is_roof?:0
    weight1 = _request.weight1
    weight2 = _request.weight2
    weight3 = _request.weight3
    weight4 = _request.weight4
    weight5 = _request.weight5

    trailertype_id = Container.get(_request.container?:0)?.is_vartrailer?(_request.trailertype_id?.join(',')?:''):''

    doc = _request.doc?:''
    comment = _request.comment?:''
    date_start = _request.date_start
    region_start = _request.region_start?:''
    city_start = _request.city_start?:''
    address_start = _request.address_start?:''
    prim_start = _request.prim_start?:''
    terminal = _request.terminal?:0

    timestart = _request.iSlot_start
    timeend = _request.iSlot_end
    slotlist = _request.slotlist

    region_end = _request.region_end?:''
    city_end = _request.city_end?:''
    address_end = _request.address_end?:''
    prim_end = _request.prim_end?:''

    this
  }

  Zakaz setImportData(_request){
    zdate = _request.zdate
    region_dop = _request.region_dop?:''
    city_dop = _request.city_dop?:''
    address_dop = _request.address_dop?:''
    prim_dop = _request.prim_dop?:''
    noticetel = _request.noticetel?:''
    noticetime = _request.noticetime>=0?_request.noticetime:8
    this
  }

  Zakaz setTransitData(_request){
    region_dop = _request.region_dop?:''
    city_dop = _request.city_dop?:''
    address_dop = _request.address_dop?:''
    prim_dop = _request.prim_dop?:''

    region_cust = _request.region_cust?:''
    city_cust = _request.city_cust?:''
    address_cust = _request.address_cust?:''
    prim_cust = _request.prim_cust?:''
    date_cust = _request.date_cust
    this
  }

  Zakaz setAdminData(_request,iAdmId){
    admin_id = iAdmId?:admin_id?:0
    price_basic = _request.price_basic?:0
    is_debate = _request.is_debate?:0
    manager_id = _request.manager_id?:manager_id
    benefit = _request.benefit==-1?(Clientrequisites.findByModstatusAndClient_id(1,shipper?:0)?.getBenefit(price)?:0):_request.benefit?:0
    this
  }

  Zakaz setExportData(_request){
    terminal_end = _request.terminal_end?:0
    region_zat = _request.region_zat?:''
    city_zat = _request.city_zat?:''
    address_zat = _request.address_zat?:''
    prim_zat = _request.prim_zat?:''
    date_zat = _request.date_zat
    timestart_zat = _request.timestart_zat?:0

    region_cust = _request.region_cust?:''
    city_cust = _request.city_cust?:''
    address_cust = _request.address_cust?:''
    prim_cust = _request.prim_cust?:''

    this
  }

  Zakaz geocode(_request){
    def oTerminal, oTerminal_end, lsStart, lsEnd, lsDop, lsCust, lsZat
    if (terminal) oTerminal = Terminal.get(terminal)
    if (terminal_end) oTerminal_end = Terminal.get(terminal_end)
    if (region_start) lsStart = smsService.geocodeYandex(region_start+' '+city_start+' '+address_start)
    if (region_end) lsEnd = smsService.geocodeYandex(region_end+' '+city_end+' '+address_end)
    if (region_dop) lsDop = smsService.geocodeYandex(region_dop+' '+city_dop+' '+address_dop)
    if (region_cust) lsCust = smsService.geocodeYandex(region_cust+' '+city_cust+' '+address_cust)
    if (region_zat) lsZat = smsService.geocodeYandex(region_zat+' '+city_zat+' '+address_zat)

    xA = oTerminal?oTerminal.x:_request.xA?:lsStart?.first()?:0
    yA = oTerminal?oTerminal.y:_request.yA?:lsStart?.last()?:0

    Double tempdistance = 0
    switch(ztype_id) {
      case 1:
        xB = _request.xB?:lsEnd?.first()?:0
        yB = _request.yB?:lsEnd?.last()?:0
        xC = _request.xC?:lsDop?.first()?:0
        yC = _request.yC?:lsDop?.last()?:0
        if (xA && xB) {
          tempdistance = searchService.getDistance(xA,yA,xB,yB)
          if (xC) tempdistance += searchService.getDistance(xB,yB,xC,yC)
        }
      break
      case 2:
        xB = _request.xB?:lsZat?.first()?:0
        yB = _request.yB?:lsZat?.last()?:0
        xC = _request.xC?:lsCust?.first()?:0
        yC = _request.yC?:lsCust?.last()?:0
        xD = oTerminal_end?oTerminal_end.x:_request.xD?:lsEnd?.first()?:0
        yD = oTerminal_end?oTerminal_end.y:_request.yD?:lsEnd?.last()?:0
        if (xA && xB && xC && xD) {
          tempdistance = searchService.getDistance(xA,yA,xB,yB)
          tempdistance += searchService.getDistance(xB,yB,xC,yC)
          tempdistance += searchService.getDistance(xC,yC,xD,yD)
        }
      break
      case 3:
        xB = _request.xB?:lsCust?.first()?:0
        yB = _request.yB?:lsCust?.last()?:0
        xC = _request.xC?:lsEnd?.first()?:0
        yC = _request.yC?:lsEnd?.last()?:0
        xD = _request.xD?:lsDop?.first()?:0
        yD = _request.yD?:lsDop?.last()?:0
        if (xA && xB && xC) {
          tempdistance = searchService.getDistance(xA,yA,xB,yB)
          tempdistance += searchService.getDistance(xB,yB,xC,yC)
          if (xD) tempdistance += searchService.getDistance(xC,yC,xD,yD)
        }
      break
    }
    distance = Math.round(tempdistance/1000)

    this
  }

  Zakaz detectroute(iRoute){
    route_id = iRoute?:Standartroute.checkforstandartroute(this)
    this
  }

  Zakaz csiSetModstatus(iStatus){
    modstatus = iStatus==-2?(modstatus in 0..1?iStatus:modstatus):iStatus?:0
    this
  }

  Zakaz assign(){
    csiSetModstatus(2)
    offerdate = new Date()
    gcmService.sendMessage('notice_unread_count_shipper',Zakaz.countByShipperAndModstatus(shipper,2)+1,shipper)
    this
  }

  Zakaz partition(iCol){
    def oZakaz = new Zakaz()
    oZakaz.properties = this.properties
    oZakaz.inputdate = new Date()
    oZakaz.moddate = new Date()
    oZakaz.ztime_id = Ztime.list(sort:'qtime',max:1)[0]?.id?:1
    oZakaz.zcol = zcol-iCol>0?zcol-iCol:1
    oZakaz.base_id = this.id
    oZakaz.csiSetModstatus(1)
  }

  Zakaz afterpartition(iCol){
    zcol = iCol?:zcol
    assign()
  }

  Zakaz updatePayorderId(lOrderId){
    payorder_id = lOrderId?:0
    this
  }

  Zakaz updatetotalcost(){
    zakazcost = price*zcol
    this
  }

  Zakaz updatetotalcost(Integer iContcount){
    zakazcost = price*iContcount
    this
  }

  Zakaz updatedelayedclients(lsClientIds){
    if (lsClientIds) delayedclients = delayedclients?(delayedclients.split(',').collect{it as Long}+lsClientIds).unique().join(','):lsClientIds.unique().join(',')
    this
  }

  Zakaz cleardelayedclients(){
    delayedclients = ''
    this
  }

  Integer csigetTimestart(){
    return timestart?:slotlist.split(',').collect{Slot.get(it.toInteger()).getTimeStart()}.min()
  }

  Integer csigetTimeend(){
    return timeend?:slotlist.split(',').collect{Slot.get(it.toInteger()).getTimeEnd()?:24}.max()
  }

}