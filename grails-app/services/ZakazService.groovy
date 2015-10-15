import org.codehaus.groovy.grails.commons.ConfigurationHolder

class ZakazService {   
  def mailerService
  def smsService  
  def gcmService

  def receiveWeightsAndTrailertypeFromRequest(requestService,iZcol){
    def hsResinrequest = [:]
    switch(iZcol?:1){
      case 1:
        hsResinrequest.weight1 = requestService.getFloatDef('weight1',-1)
      break;
      case 2:
        hsResinrequest.weight1 = requestService.getFloatDef('weight1',-1)
        hsResinrequest.weight2 = requestService.getFloatDef('weight2',-1)
      break;
      case 3:
        hsResinrequest.weight1 = requestService.getFloatDef('weight1',-1)
        hsResinrequest.weight2 = requestService.getFloatDef('weight2',-1)
        hsResinrequest.weight3 = requestService.getFloatDef('weight3',-1)
      break;
      case 4:
        hsResinrequest.weight1 = requestService.getFloatDef('weight1',-1)
        hsResinrequest.weight2 = requestService.getFloatDef('weight2',-1)
        hsResinrequest.weight3 = requestService.getFloatDef('weight3',-1)
        hsResinrequest.weight4 = requestService.getFloatDef('weight4',-1)
      break;
      case 5:
        hsResinrequest.weight1 = requestService.getFloatDef('weight1',-1)
        hsResinrequest.weight2 = requestService.getFloatDef('weight2',-1)
        hsResinrequest.weight3 = requestService.getFloatDef('weight3',-1)
        hsResinrequest.weight4 = requestService.getFloatDef('weight4',-1)
        hsResinrequest.weight5 = requestService.getFloatDef('weight5',-1)
      break;
    }
    hsResinrequest.trailertype_id = requestService.getIds('trailertype_id')
    return hsResinrequest
  }

  def receiveGeoDataFromRequest(requestService){
    def hsResinrequest = [:]
    hsResinrequest.xA = requestService.getIntDef('xA',0)
    hsResinrequest.yA = requestService.getIntDef('yA',0)
    hsResinrequest.xB = requestService.getIntDef('xB',0)
    hsResinrequest.yB = requestService.getIntDef('yB',0)
    hsResinrequest.xC = requestService.getIntDef('xC',0)
    hsResinrequest.yC = requestService.getIntDef('yC',0)
    hsResinrequest.xD = requestService.getIntDef('xD',0)
    hsResinrequest.yD = requestService.getIntDef('yD',0)
    return hsResinrequest
  }

  def checkCommonRequestData(_request){
    def hsResReturn = [:]
    hsResReturn.slot_error = []
    hsResReturn.date_error = []
    hsResReturn.price_error = []
    hsResReturn.weight_error = []
    hsResReturn.error = []
    hsResReturn.notice_error = []

    if(_request.weight1 && (_request.weight1<0 || _request.weight1>50))
      hsResReturn.weight_error << 1
    if(_request.weight2 && (_request.weight2<0 || _request.weight2>50))
      hsResReturn.weight_error << 2
    if(_request.weight3 && (_request.weight3<0 || _request.weight3>50))
      hsResReturn.weight_error << 3
    if(_request.weight4 && (_request.weight4<0 || _request.weight4>50))
      hsResReturn.weight_error << 4
    if(_request.weight5 && (_request.weight5<0 || _request.weight5>50))
      hsResReturn.weight_error << 5
    if(!_request.zcol&&!_request.addzcol)
      hsResReturn.weight_error << 6
    else if (!_request.zcol&&_request.addzcol<6)
      hsResReturn.weight_error << 6

    if((_request?.price?:-1)<0 || (_request?.price?:-1)>1000000)
      hsResReturn.price_error << 1
    if(_request?.idle&&(!_request.idle.isInteger()||_request.idle.toInteger()<0||_request.idle.toInteger()>1000000))
      hsResReturn.price_error << 2

    def iSlot_start=0
    def iSlot_end=0
    if((_request?.terminal?:0)>=0){
      if(_request.is_slotlist?:0){
        if(!_request.slotlist)
          hsResReturn.slot_error << 5
      }else{
        iSlot_start=_request.slot_start
        iSlot_end=_request.slot_end

        if(iSlot_start>=iSlot_end)
          hsResReturn.slot_error << 1

        if(iSlot_start>23 || iSlot_start<0)
          hsResReturn.slot_error << 2
        if(iSlot_end>23 || iSlot_end<0)
          hsResReturn.slot_error << 3
      }
    }else{
      hsResReturn.error<<1
    }

    if(_request.date_start<curDate())
      hsResReturn.date_error << 2
    if(_request.zdate&&_request.zdate<_request.date_start)
      hsResReturn.date_error << 3

    _request.iSlot_start = iSlot_start
    _request.iSlot_end = iSlot_end

    if (_request.noticetel&&!_request.noticetel.matches('\\+\\d{11}')) {
      hsResReturn.notice_error << 1
    }
    if(_request.noticetime&&(_request.noticetime<0||_request.noticetime>23)){
      hsResReturn.notice_error << 2
    }

    return [returnerrors:hsResReturn,inrequest:_request]
  }

  def curDate(){
    def dateStart = new Date()
    def date1 = new GregorianCalendar()
    date1.setTime(dateStart)
    date1.set(Calendar.HOUR_OF_DAY ,0)
    date1.set(Calendar.MINUTE ,0)
    date1.set(Calendar.SECOND,0)
    date1.set(Calendar.MILLISECOND,0)

    return date1.getTime()
  }

  def checkTransitRequestData(_request){
    def transiterrors = []

    if(_request.date_cust<_request.date_start)
        transiterrors << 1

    return transiterrors
  }

  def checkExportRequestData(_request,_returnerrors){
    def iSlot_start_end = 0
    def iSlot_end_end = 0
    def slotlist_end = ''
    if((_request.terminal_end?:0)<0){
      _returnerrors.error<<2
    }

    _returnerrors.timezat_error = []

    if(_request.timestart_zat){
      if(_request.timestart_zat>23 || _request.timestart_zat<0)
        _returnerrors.timezat_error << 1
    }

    if(_request.date_zat<_request.date_start)
      _returnerrors.date_error << 4

    return [returnerrors:_returnerrors,inrequest:_request]
  }

  def checkAdminRequestData(_request){
    def admin_error = []

    if(!Client.findByFullname(_request.shipper?:''))
      admin_error << 1
    if(!_request.price_basic)
      admin_error << 2
    else if(_request.price_basic>_request?.price)
      admin_error << 3
    else if(_request.price_basic<0)
      admin_error << 4
    if(!_request.manager_id)
      admin_error << 5

    return admin_error
  }

  void sendZakazOfferForCarriers(_sendingIds){
    def emailUsers = []
    def smsUsers = []
    def _zakaz = _sendingIds?.size()?Zakaz.get(Zakaztocarrier.get(_sendingIds.first())?.zakaz_id?:0):null
    _sendingIds.each{
      def clId = Zakaztocarrier.get(it)?.client_id?:0
      User.findAllByClient_idAndIs_noticeemail(clId,1).each{ user -> emailUsers << user }
      User.findAllByClient_idAndIs_noticeSMS(clId,1).each{ user -> smsUsers << user }
    }
    mailerService.sendZakazOfferForCarriersAsync(emailUsers)
    smsService.sendZakazOfferForCarriersAsync(smsUsers,_zakaz)
  }

  void sendZakazOfferForShipper(_zakaz){
    def oUser = User.get(_zakaz.user_id)?:User.findByClient_idAndIs_am(_zakaz.shipper,1)
    if (oUser?.is_noticeemail)
      mailerService.sendZakazOfferForShipperAsync(oUser)
    if (oUser?.is_noticeSMS)
      smsService.sendZakazOfferForShipperAsync(oUser)
  }

  void sendOrderRemindForCarrier(_clientId){
    mailerService.sendOrderRemindForCarrierAsync(User.findAllByClient_idAndIs_noticeemail(_clientId,1))
    smsService.sendOrderRemindForCarrierAsync(User.findAllByClient_idAndIs_noticeSMS(_clientId,1))
  }

  def getContainersAndSlotsFromRequest(requestService,_request,lId){
    _request.('cont1_'+lId) = requestService.getStr('cont1_'+lId)
    if(_request.('cont1_'+lId)) _request.contcount++
    _request.('cont2_'+lId) = requestService.getStr('cont2_'+lId)
    if(_request.('cont2_'+lId)) _request.contcount++
    _request.('timestart_'+lId) = requestService.getStr('timestart_'+lId)
    _request.('timeend_'+lId) = requestService.getStr('timeend_'+lId)
    return _request
  }

  def checkContainerDataForZakazdrivers(_request,lId){
    def resultlist = []
    if(_request.('cont1_'+lId)&&!_request.('cont1_'+lId).matches("[A-z]{4}\\d{7}")) resultlist << ('cont1_'+lId)
    if(_request.('cont2_'+lId)&&!_request.('cont2_'+lId).matches("[A-z]{4}\\d{7}")) resultlist << ('cont2_'+lId)
    return resultlist
  }
  def checkDataForZakazdrivers(_request,lId,isSlot){
    if(isSlot) {
      def slotstart = Slot.get(_request.('timestart_'+lId).isInteger()?_request.('timestart_'+lId).toInteger():0)
      if (!slotstart) return [lId]
    } else {
      if (!_request.('timestart_'+lId).isInteger()||
          !_request.('timeend_'+lId).isInteger()||
          _request.('timestart_'+lId).toInteger()<0||
          _request.('timestart_'+lId).toInteger()>=24||
          _request.('timeend_'+lId).toInteger()<=0||
          _request.('timeend_'+lId).toInteger()>24||
          _request.('timestart_'+lId).toInteger()>=_request.('timeend_'+lId).toInteger()
          )
        return [lId]
    }
    return []
  }

  void sendOfferConfirmForCarrier(_lsZakazToDriver){
    _lsZakazToDriver.each{ _zakaztodriver ->
      smsService.sendOfferConfirmForCarrierAsync(_zakaztodriver)
    }
  }

  void sendOfferDeclineForCarrier(_clientIds,lZakazId=0){
    _clientIds.each{ _clientId ->
      mailerService.sendOfferDeclineForCarrier(User.findAllByClient_idAndIs_noticeemail(_clientId,1))
      smsService.sendOfferDeclineForCarrier(User.findAllByClient_idAndIs_noticeSMS(_clientId,1),lZakazId)
      gcmService.sendMessage('zakaz_refuse',lZakazId,_clientId)
    }
  }

  void sendContDeliveryForCarrier(_trip){
    def oUser = User.findByClient_idAndIs_amAndIs_noticeSMS(_trip.carrier,1,1)
    if (oUser){
      smsService.sendContDeliveryForCarrierAsync(oUser,_trip)
    }
  }

  void sendDeliveryRequestForShipper(_trip){
    def oZakaz = Zakaz.get(_trip.zakaz_id)
    def oUser = User.get(oZakaz?.user_id)?:User.findByClient_idAndIs_am(_trip.shipper,1)
    if (oUser?.is_noticeemail)
      mailerService.sendDeliveryRequestForShipperAsync(oUser)
    if (oUser?.is_noticeSMS)
      smsService.sendDeliveryRequestForShipperAsync(oUser)
  }

  def checkDateForTripEdit(_request,isNeedCheckcontainers=true){
    def returnerrors = []
    if (isNeedCheckcontainers&&!_request.containernumber1&&!_request.containernumber2)
      returnerrors << 1
    if (_request.timeeditA) {
      if (_request.dateA<curDate())
        returnerrors << 2
      if (_request.timeslotA) {
        if(!Slot.get(_request.timeslotA))
          returnerrors << 3
      } else {
        if(_request.timestartA>=_request.timeendA)
          returnerrors << 4
        else if(_request.timestartA>23 || _request.timestartA<0)
          returnerrors << 5
        else if(_request.timeendA>24 || _request.timeendA<=0)
          returnerrors << 6
      }
    }
    if (_request.timeeditB) {
      if (_request.dateB<(_request.dateA?:curDate()))
        returnerrors << 7
      else if (_request.dateB<curDate())
        returnerrors << 7
      if(_request.timestartB>=(_request.timeendB?:24))
        returnerrors << 8
      else if((_request.timestartB?:0)>23 || (_request.timestartB?:0)<0)
        returnerrors << 9
      else if((_request.timeendB?:0)>24 || (_request.timeendB?:0)<0)
        returnerrors << 10
    }
    if (_request.timeeditC) {
      if (_request.dateC<(_request.dateB?:curDate()))
        returnerrors << 11
      else if (_request.dateC<curDate())
        returnerrors << 11
      if(_request.timestartC>=(_request.timeendC?:24))
        returnerrors << 12
      else if((_request.timestartC?:0)>23 || (_request.timestartC?:0)<0)
        returnerrors << 13
      else if((_request.timeendC?:0)>24 || (_request.timeendC?:0)<0)
        returnerrors << 14
    }
    if (_request.timeeditD) {
      if (_request.dateD<(_request.dateC?:curDate()))
        returnerrors << 15
      else if (_request.dateD<curDate())
        returnerrors << 15
      if (_request.timeslotD) {
        if(!Slot.get(_request.timeslotD))
          returnerrors << 16
      } else {
        if(_request.timestartD>=(_request.timeendD?:24))
          returnerrors << 17
        else if((_request.timestartD?:0)>23 || (_request.timestartD?:0)<0)
          returnerrors << 18
        else if((_request.timeendD?:0)>24 || (_request.timeendD?:0)<0)
          returnerrors << 19
      }
    }
    if(isNeedCheckcontainers&&_request.containernumber1&&!_request.containernumber1.matches("[A-z]{4}\\d{7}")) returnerrors << 20
    if(isNeedCheckcontainers&&_request.containernumber2&&!_request.containernumber2.matches("[A-z]{4}\\d{7}")) returnerrors << 21
    if (_request.timeeditE) {
      if (_request.dateE<(_request.dateD?:curDate()))
        returnerrors << 22
      else if (_request.dateE<curDate())
        returnerrors << 22
      if(_request.timestartE>=(_request.timeendE?:24))
        returnerrors << 23
      else if((_request.timestartE?:0)>23 || (_request.timestartE?:0)<0)
        returnerrors << 24
      else if((_request.timeendE?:0)>24 || (_request.timeendE?:0)<0)
        returnerrors << 25
      if(_request.timestartE==null&&(_request.timestartEstr?:'0')!='0')
        returnerrors << 28
      if(_request.timeendE==null&&(_request.timeendEstr?:'0')!='0')
        returnerrors << 29
    }
    if (_request.driveredit) {
      if (!_request.driver_id)
        returnerrors << 26
      if (!_request.car_id&&!_request.leftcargosnomer)
        returnerrors << 27
    }
    returnerrors
  }

  def checkDataForTripDelivery(_request,isNeedCheckPrim=true){
    def returnerrors = []
    if ((_request.terminalh?:0)<0) returnerrors << 1
    if (!_request.terminalh&&!_request.taskaddress) returnerrors << 2
    if (_request.dateE<curDate())
      returnerrors << 3
    if (Terminal.get(_request.terminalh)?.is_slot&&!_request.taskslot)
      returnerrors << 4
    else if((_request.terminalh?:0)>=0&&!Terminal.get(_request.terminalh)?.is_slot){
      if (!_request.taskstart)
        returnerrors << 5
      else if(_request.taskstart>=(_request.taskend?:24))
        returnerrors << 6
      else if((_request.taskstart?:0)>23 || (_request.taskstart?:0)<0)
        returnerrors << 7
      else if((_request.taskend?:0)>24 || (_request.taskend?:0)<0)
        returnerrors << 8
    }
    if(isNeedCheckPrim&&!_request.taskprim) returnerrors << 9
    returnerrors
  }

  void administrate(){
    def oClient = new Client()
    def iMargin = Adminmenu.get(15)?.margin?:10
    //part 1 - processing offers
    Zakaz.findAllByModstatus(1).each{ zakaz ->
      def assignedoffercount = Zakaztocarrier.findAllByZakaz_idAndModstatus(zakaz.id,2).sum{it.zcol}?:0
      def assignedContainers = []
      try {
        Zakaztocarrier.findAllByZakaz_idAndModstatus(zakaz.id,1,[sort:'cprice',order:'asc']).each { offer ->
          if (offer.cprice<=zakaz.price&&assignedoffercount+offer.zcol<=zakaz.zcol){
            assignedContainers << offer.csiSetModstatus(2).save(failOnError:true,flush:true).client_id
            assignedoffercount += offer.zcol
          }
        }
        if (assignedoffercount==zakaz.zcol) {
          zakaz.assign().save(failOnError:true,flush:true)
          sendZakazOfferForShipper(zakaz)
          Zakaztocarrier.findAllByZakaz_idAndModstatusNotEqual(zakaz.id,2).each{it.csiSetModstatus(-2).save(failOnError:true,flush:true)}
        } else if (assignedoffercount<zakaz.zcol&&assignedoffercount>0) {
          def newZakaz = zakaz.partition(assignedoffercount).save(failOnError:true,flush:true)
          zakaz.afterpartition(assignedoffercount).save(failOnError:true,flush:true)
          sendZakazOfferForShipper(zakaz)
          Zakaztocarrier.findAllByZakaz_idAndModstatusNotEqual(zakaz.id,2).each{it.csiSetModstatus(-2).save(failOnError:true,flush:true)}
          def variants = oClient.findzakazvariants(zakaz,true)
          sendZakazOfferForCarriers(
            variants.collect{ client ->
              if (!assignedContainers.find{it==client.id}) new Zakaztocarrier(zakaz_id:newZakaz.id,client_id:client.id).setMainData(newZakaz).save(failOnError:true)?.id?:0
            }-null
          )
        }
      } catch(Exception e) {
        log.debug("Error save data in Admin/administrate for zakaz: "+zakaz.id+"\n"+e.toString());
      }
    }
    //part 2 - processing new zakaz
    Zakaz.findAll{ modstatus==0 && shipper != 0 && price > 100 }.each{ zakaz ->
      try {
        zakaz.setAdminData([price_basic:getCarrierprice(zakaz.price,iMargin)],0).geocode([:]).csiSetModstatus(1).save(failOnError:true,flush:true)
        def variants = oClient.findzakazvariants(zakaz,true)
        def assignedContainers = Zakaztocarrier.findAllByZakaz_idAndModstatus(zakaz.base_id?:zakaz.id,2)
        sendZakazOfferForCarriers(
          variants.collect{ client ->
            if (!assignedContainers.find{it.client_id==client.id}) new Zakaztocarrier(zakaz_id:zakaz.id,client_id:client.id).setMainData(zakaz).save(failOnError:true)?.id?:0
          }-null
        )
      } catch(Exception e) {
        log.debug("Error save data in Admin/administrate for zakaz: "+zakaz.id+"\n"+e.toString());
      }
    }
  }

  Integer getCarrierprice(iPrice,iMargin){
    return Math.round((iPrice-iPrice*iMargin/100)/100)*100
  }

  void sendDelayedVariants(){
    Zakaz.findAllByDelayedclientsNotEqual('').each{ zakaz ->
      if (zakaz.modstatus in 0..1) {
        def sendingIds = []
        zakaz.delayedclients.split(',').collect{it as Long}.each{
          if (!Zakaztocarrier.findByClient_idAndZakaz_id(it,zakaz.id)) {
            sendingIds << new Zakaztocarrier(zakaz_id:zakaz.id,client_id:it).setMainData(zakaz).updateDebate(1).save(failOnError:true)?.id?:0
          }
        }
        zakaz.csiSetModstatus(1).cleardelayedclients().save(failOnError:true)
        sendZakazOfferForCarriers(sendingIds)
      } else
        zakaz.cleardelayedclients().save(failOnError:true)
    }
  }

}