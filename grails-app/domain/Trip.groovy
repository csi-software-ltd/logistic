import org.codehaus.groovy.grails.commons.ConfigurationHolder
class Trip {
  def monitoringService
  def searchService
  def gcmService
  def smsService
  def mailerService
  
  static mapping = {
    version false
    taxmoney formula: "price - paid - trackertax"
  }
  static constraints = {
    dateB(nullable:true)
    dateC(nullable:true)
    dateD(nullable:true)
    taskdate(nullable:true)
    docdate(nullable:true)
    maxpaydate(nullable:true)
    lastpayment(nullable:true)
    extmonitoringdate(nullable:true)
  }

  Long id
  Long zakaz_id
  Integer ztype_id
  Integer zcol
  Long shipper
  Long carrier
  Integer container
  Long zakaztodriver_id
  Integer terminal
  Integer terminal_end
  Long driver_id
  String driver_fullname
  Integer car_id
  String cargosnomer
  String imei = ''
  Integer trailer_id
  String trailnumber
  Integer price
  Integer idlesum = 0
  Integer forwardsum = 0
  Integer paid = 0
  Integer trackertax = 0
  Integer price_sh
  Integer modstatus = 1
  Integer trackstatus = 1
  Integer taskstatus = 0
  Integer routestatus = 0
//>>task
  Date taskdate
  String taskslot = ''
  Integer taskterminal = 0
  Integer taskstart = 0
  Integer taskend = 0
  Integer is_mark = 0
  String taskaddress = ''
  String stockbooking = ''
  String taskprim = ''
  Long returndriver_id
  String returndriver_fullname
  Integer returncar_id
  String returncargosnomer
  Integer xT = 0
  Integer yT = 0
//<<task
  String description = ''
  Date inputdate = new Date()
  Date moddate = new Date()
  String comment = ''

  Integer xA = 0
  Integer yA = 0
  Date dateA
  Integer timestartA
  Integer timeendA
  String addressA
  String primA

  Integer xB = 0
  Integer yB = 0
  Date dateB
  Integer timestartB
  Integer timeendB
  String addressB
  String primB

  Integer xC = 0
  Integer yC = 0
  Date dateC
  Integer timestartC
  Integer timeendC
  String addressC
  String primC

  Integer xD = 0
  Integer yD = 0
  Date dateD
  Integer timestartD
  Integer timeendD
  String addressD
  String primD

  Integer distance = 0
  Integer deliverydistance = 0
  String realdistance = ''
  Integer is_readcurrier = 1
  Integer is_readeventcurrier = 1
  Integer is_readeventshipper = 1
  Integer is_readeventadmin = 1
  Date docdate
  Date maxpaydate
  Date lastpayment
  Date extmonitoringdate
  Date zakazdate
  String doc = ''
  String noticetel = ''
  Integer noticetime = 0
  Integer manager_id
  Long payorder_id = 0
  Integer is_longtrip = 0
  Integer zakazcost = 0
  Integer benefit = 0

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def beforeUpdate() {
    moddate = new Date()
  }
  
  def afterInsert() {
		Trip.withNewSession { monitoringService.generateTripEvent(23,id) }
  }

  def csiSelectTrip(bType,lClId,lZakazId,lTripId,iModstatus,iTaskstatus,iMax,iOffset,bMobile=0){
    def hsSql=[select:'',from:'',where:'',order:''] 
    def hsLong=[:]

    hsSql.select="*"
    hsSql.from='trip'
    hsSql.where=(bType?"trip.carrier =:client":"trip.shipper =:client")+
                ((lZakazId>0)?' AND trip.zakaz_id =:zakaz_id':'')+
                ((lTripId>0)?' AND trip.id =:id':'')+
                ((iModstatus>-100)?' AND trip.modstatus =:modstatus':'')+
                ((iTaskstatus>-100)?' AND trip.taskstatus =:taskstatus':'')+
                ((bMobile)?' AND (trip.modstatus =0 OR trip.modstatus =1)':'')
    hsSql.order=(bMobile==1)?"dateA desc, trip.id desc":"trip.id desc"

    if(iModstatus>-100)
      hsLong['modstatus']=iModstatus
    if(iTaskstatus>-100)
      hsLong['taskstatus']=iTaskstatus
    if(lZakazId>0)
      hsLong['zakaz_id']=lZakazId
    if(lTripId>0)
      hsLong['id']=lTripId
		hsLong['client']=lClId

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,null,
      null,null,iMax,iOffset,'trip.id',true,Trip.class)
  }

	Trip createFromZakaz(_zakaz,_zakaztodriver,_price){
		zakaz_id = _zakaz.id
		ztype_id = _zakaz.ztype_id
		zcol = _zakaztodriver.zcol
		shipper = _zakaz.shipper
		carrier = _zakaztodriver.client_id
		container = _zakaz.container
		zakaztodriver_id = _zakaztodriver.id
		terminal = _zakaz.terminal
		terminal_end = _zakaz.terminal_end?:0
		driver_id = _zakaztodriver.driver_id
		driver_fullname = Driver.get(_zakaztodriver.driver_id)?.fullname?:''
		car_id = _zakaztodriver.car_id
		def oCar = Car.get(_zakaztodriver.car_id)
		cargosnomer = oCar?.gosnomer?:''
		returndriver_id = driver_id?:0
		returndriver_fullname = driver_fullname?:''
		returncar_id = car_id?:0
		returncargosnomer = cargosnomer?:''
		imei = oCar?.imei?:''
		trailer_id = _zakaztodriver.trailer_id
		trailnumber = Trailer.get(_zakaztodriver.trailer_id)?.trailnumber?:''
		price = _price?:0
		price_sh = _zakaz.price?:0
		comment = _zakaz.comment?:''
		doc = _zakaz.doc?:''
		noticetel = _zakaz.noticetel?:''
		noticetime = _zakaz.noticetime?:0
		zakazdate = _zakaz.inputdate
		manager_id = _zakaz.manager_id?:0
    is_longtrip = (_zakaz.price<Tools.getIntVal(ConfigurationHolder.config.longtrip.default.price,32000))?0:1
    zakazcost = zcol*price_sh
    benefit = zcol*_zakaz.benefit>0?zcol*_zakaz.benefit:0

		xA = _zakaz.xA
		yA = _zakaz.yA
		dateA = _zakaz.date_start
		timestartA = _zakaztodriver.timestart
		timeendA = _zakaztodriver.timeend
		addressA = _zakaz.terminal?(Terminal.get(_zakaz.terminal)?.address?:''):(_zakaz.region_start+' '+_zakaz.city_start+' '+_zakaz.address_start)
		primA = _zakaz.prim_start

		xB = _zakaz.xB
		yB = _zakaz.yB
		xC = _zakaz.xC
		yC = _zakaz.yC
		xD = _zakaz.xD
		yD = _zakaz.yD
		distance = _zakaz.distance

		if (!imei||distance==0)
			extmonitoringdate = new Date()

		switch(_zakaz.ztype_id) {
			case 1:
				setImportData(_zakaz)
			break
			case 2:
				setExportData(_zakaz)
			break
			case 3:
				setTransitData(_zakaz)
			break
		}

		this
	}

	void setImportData(_zakaz){
		dateB = _zakaz.zdate
		timestartB = _zakaz.timestart_end
		timeendB = _zakaz.timeend_end
		addressB = _zakaz.terminal_end?(Terminal.get(_zakaz.terminal_end)?.address?:''):(_zakaz.region_end+' '+_zakaz.city_end+' '+_zakaz.address_end)
		primB = _zakaz.prim_end
		timestartC = 0
		timeendC = 0
		addressC = _zakaz.region_dop?(_zakaz.region_dop+' '+_zakaz.city_dop+' '+_zakaz.address_dop):''
		primC = _zakaz.prim_dop
		timestartD = 0
		timeendD = 0
		addressD = ''
		primD = ''
	}
	void setExportData(_zakaz){
		dateB = _zakaz.date_zat
		timestartB = _zakaz.timestart_zat
		timeendB = _zakaz.timeend_zat
		addressB = _zakaz.region_zat?(_zakaz.region_zat+' '+_zakaz.city_zat+' '+_zakaz.address_zat):''
		primB = _zakaz.prim_zat
		timestartC = 0
		timeendC = 0
		addressC = _zakaz.region_cust?(_zakaz.region_cust+' '+_zakaz.city_cust+' '+_zakaz.address_cust):''
		primC = _zakaz.prim_cust
		timestartD = 0
		timeendD = 0
		addressD = ''
		primD = ''
		taskdate = _zakaz.zdate
		taskstart = _zakaz.timestart_end
		taskend = _zakaz.timeend_end
		taskaddress = (!_zakaz.terminal_end)?(_zakaz.region_end+' '+_zakaz.city_end+' '+_zakaz.address_end):''
		taskterminal = _zakaz.terminal_end?:0
		taskprim = _zakaz.prim_end
	}
	void setTransitData(_zakaz){
		dateB = _zakaz.date_cust
		timestartB = 0
		timeendB = 0
		addressB = _zakaz.region_cust?(_zakaz.region_cust+' '+_zakaz.city_cust+' '+_zakaz.address_cust):''
		primB = _zakaz.prim_cust
		dateC = _zakaz.zdate
		timestartC = _zakaz.timestart_end
		timeendC = _zakaz.timeend_end
		addressC = _zakaz.terminal_end?(Terminal.get(_zakaz.terminal_end)?.address?:''):(_zakaz.region_end+' '+_zakaz.city_end+' '+_zakaz.address_end)
		primC = _zakaz.prim_end
		timestartD = 0
		timeendD = 0
		addressD = _zakaz.region_dop?(_zakaz.region_dop+' '+_zakaz.city_dop+' '+_zakaz.address_dop):''
		primD = _zakaz.prim_dop
	}

	Trip setAdminData(_request){
		comment = _request.comment?:''
		price = _request.price?:price
		updateIdlesum(_request.idlesum)
		updateForwardsum(_request.forwardsum)
		updateBenefit(_request.benefit)
		def oDriver = Driver.get(_request.driver_id)
		driver_id = oDriver.id
		driver_fullname = oDriver.fullname
		def oCar = Car.get(_request.car_id)
		car_id = oCar.id
		cargosnomer = oCar.gosnomer
		updatepayorderdata(_request.containernumber1,_request.containernumber2)
		this
	}

	void updatepayorderdata(_cont1,_cont2){
		if (payorder_id>0) {
			Payorder.get(payorder_id)?.updatepaycomment(this,_cont1,_cont2)?.save(flush:true,failOnError:true)
			def oldOrder = Payorder.findByTrip_id(id)
			if (oldOrder&&payorder_id!=oldOrder?.id) oldOrder.updatepaycomment(this,_cont1,_cont2).save(flush:true,failOnError:true)
		}
	}

	void updateForwardsum(_sum){
		forwardsum = _sum?:0
		if (payorder_id>0) {
			Payorder.get(payorder_id)?.updateForwardsum(id,_sum?:0)?.save(flush:true,failOnError:true)
			def oldOrder = Payorder.findByTrip_id(id)
			if (oldOrder&&payorder_id!=oldOrder?.id) oldOrder.updateForwardsum(id,_sum?:0)?.save(flush:true,failOnError:true)
		}
	}

	void updateIdlesum(_sum){
		idlesum = _sum?:0
		if (payorder_id>0) {
			Payorder.get(payorder_id)?.updateIdlesum(id,_sum?:0)?.save(flush:true,failOnError:true)
			def oldOrder = Payorder.findByTrip_id(id)
			if (oldOrder&&payorder_id!=oldOrder?.id) oldOrder.updateIdlesum(id,_sum?:0)?.save(flush:true,failOnError:true)
		}
	}

	void updateBenefit(_sum){
		benefit = _sum?:0
		if (payorder_id>0) {
			Payorder.get(payorder_id)?.updateBenefit(id,_sum?:0)?.save(flush:true,failOnError:true)
			def oldOrder = Payorder.findByTrip_id(id)
			if (oldOrder&&payorder_id!=oldOrder?.id) oldOrder.updateBenefit(id,_sum?:0)?.save(flush:true,failOnError:true)
		}
	}

	Trip csiSetModstatus(iStatus){
		switch(iStatus) {
			case 1:		monitoringService.generateTripEvent(18,id); break;
			case 2:		monitoringService.generateTripEvent(16,id); break;
			case -1:	monitoringService.generateTripEvent(17,id); csiSetTaskstatus(0); break;
			case -2:	monitoringService.generateTripEvent(26,id); csiSetTaskstatus(0); checkLastTrip(); break;
			case -3:	monitoringService.generateTripEvent(27,id); csiSetTaskstatus(0); checkLastTrip(); break;
			case -4:	monitoringService.generateTripEvent(17,id); csiSetTaskstatus(0); checkLastTrip(); break;
		}
		modstatus = iStatus?:modstatus
		this
	}

	void checkLastTrip(){
		def oZakaz = Zakaz.get(zakaz_id)
		if(Trip.countByZakaz_idAndModstatusGreaterThanEquals(zakaz_id,-1)==1)
			oZakaz?.csiSetModstatus(-4)
		oZakaz?.updatetotalcost(Trip.findAllByModstatusGreaterThanEqualsAndZakaz_idAndIdNotEqual(-1,oZakaz.id,id).collect{ trip -> Zakaztodriver.get(trip.zakaztodriver_id).collect{((it.containernumber1?[it.containernumber1]:[])+(it.containernumber2?[it.containernumber2]:[]))}}.flatten().size())?.save()
	}

	Trip setShipperData(_request){
		if (_request.timeeditA) {
			dateA = _request.dateA?:dateA
			if (_request.timeslotA) {
				timestartA = Slot.get(_request.timeslotA)?.getTimeStart()?:0
				timeendA = Slot.get(_request.timeslotA)?.getTimeEnd()?:0
			} else {
				timestartA = _request.timestartA?:0
				timeendA = _request.timeendA?:0
			}
		}
		if (_request.timeeditB) {
			dateB = _request.dateB?:dateB
			timestartB = _request.timestartB?:0
			timeendB = _request.timeendB?:0
		}
		if (_request.timeeditC) {
			dateC = _request.dateC?:dateC
			timestartC = _request.timestartC?:0
			timeendC = _request.timeendC?:0
		}
		if (_request.timeeditD) {
			dateD = _request.dateD?:dateD
			if (_request.timeslotD) {
				timestartD = Slot.get(_request.timeslotD)?.getTimeStart()?:0
				timeendD = Slot.get(_request.timeslotD)?.getTimeEnd()?:0
			} else {
				timestartD = _request.timestartD?:0
				timeendD = _request.timeendD?:0
			}
		}
		this
	}

	Trip setDeliveryRequestData(_request){
		if (_request.timeeditE) {
			if (taskdate!=_request.dateE||taskstart!=(_request.timestartE?:0)){
				csiSetTaskstatus(1)
				mailerService.sendAdminNotice('#admin_delivery_request',id)
				mailerService.sendManagerNotice(Zakaz.get(zakaz_id)?.manager_id,'#admin_delivery_request',id)
			}
			taskdate = _request.dateE?:taskdate
			taskstart = _request.timestartE?:0
			taskend = _request.timeendE?:0
			taskslot = ''
			taskterminal = 0
			is_mark = 0
			taskaddress = ''
			stockbooking = ''
			taskprim = ''
			xT = 0
			yT = 0
			deliverydistance = 0
		}
		if (_request.driveredit) {
			if (taskdate&&(_request.driver_id!=returndriver_id||(_request.leftcargosnomer?0:_request.car_id)!=returncar_id))
				csiSetTaskstatus(1)
			returndriver_id = _request.driver_id?:returndriver_id
			returndriver_fullname = Driver.get(_request.driver_id)?.fullname?:returndriver_fullname
			returncar_id = _request.leftcargosnomer?0:_request.car_id?:returncar_id
			returncargosnomer = _request.leftcargosnomer?:Car.get(_request.car_id)?.gosnomer?:returncargosnomer
		}
		this
	}

	Trip csiSetTaskstatus(iStatus){
		if(taskstatus==0&&iStatus==1){ monitoringService.generateTripEvent(9,id); gcmService.sendMessage('message_unread_count',Trip.countByShipperAndTaskstatusInList(shipper,[1,3,4])+1,shipper); }
		else if(taskstatus==2&&iStatus==1){ monitoringService.generateTripEvent(19,id); gcmService.sendMessage('message_unread_count',Trip.countByShipperAndTaskstatusInList(shipper,[1,3,4])+1,shipper); }
		else if(taskstatus==2&&iStatus==4){ monitoringService.generateTripEvent(20,id); gcmService.sendMessage('message_unread_count',Trip.countByShipperAndTaskstatusInList(shipper,[1,3,4])+1,shipper); }
		else if((taskstatus in [0,1,3,4])&&iStatus==2){ monitoringService.generateTripEvent(22,id); csiSetUnreadDelivery(); }
		else if(taskstatus==2&&iStatus==5){ monitoringService.generateTripEvent(24,id); csiSetModstatus(2); }
		else if(taskstatus==5&&iStatus==6){ monitoringService.generateTripEvent(25,id); csiSetDocdate(new Date()); }
		else if(taskstatus==6&&iStatus==5){ monitoringService.generateTripEvent(28,id); csiSetDocdate(null); }
		else if(iStatus==0) readDelivery()
		taskstatus = taskstatus in [2,3]&&iStatus==1?3:iStatus
		this
	}

	void csiSetUnreadDelivery(){
		is_readcurrier = 0
    Trip.withNewSession{ gcmService.sendMessage('message_unread_count',Trip.countByCarrierAndIs_readcurrier(carrier,0)+1,carrier) }
	}

	Trip readDelivery(){
		is_readcurrier = 1
		this
	}

	Trip csiSetDocdate(){
		csiSetDocdate(docdate)
		this
	}

	void csiSetDocdate(_date){
		docdate = _date
		maxpaydate = docdate?docdate+(Clientrequisites.findByModstatusAndClient_id(1,carrier)?.payterm?:Tools.getIntVal(ConfigurationHolder.config.payterm.default.days,7)):null
	}

	Trip csiSetUnreadEvent(iType){
		if (iType==1){ 
			is_readeventcurrier = 0
			Trip.withNewSession{ gcmService.sendMessage('events_unread_count',Trip.countByCarrierAndIs_readeventcurrier(carrier,0)+1,carrier) }
		} else if (iType==2){ 
			is_readeventshipper = 0
			Trip.withNewSession{ gcmService.sendMessage('events_unread_count',Trip.countByShipperAndIs_readeventshipper(shipper,0)+1,shipper) }
		} else if (iType==3) is_readeventadmin = 0
		this
	}

	Trip csiSetReadEvent(iType){
		if (iType==1) is_readeventcurrier = 1
		else if (iType==2) is_readeventshipper = 1
		else if (iType==3) is_readeventadmin = 1
		this
	}

	Trip setDeliveryData(_request){
		def oTerminal = Terminal.get(_request.terminalh?:0)
  	taskdate = _request.dateE?:taskdate
		taskslot = _request.taskslot?:''
		taskterminal = _request.terminalh?:0
		taskstart = oTerminal?.is_slot?Slot.get(_request.taskslot)?.getTimeStart():_request.taskstart?:0
		taskend = oTerminal?.is_slot?Slot.get(_request.taskslot)?.getTimeEnd():_request.taskend?:0
		is_mark = _request.is_mark?:0
		taskaddress = _request.taskaddress?:''
		stockbooking = _request.stockbooking?:''
		taskprim = _request.taskprim?:''
		geocode()
		this
	}

	private void geocode(){
    def oTerminal, lsTask
    if (taskterminal) oTerminal = Terminal.get(taskterminal)
    else lsTask = smsService.geocodeYandex(taskaddress)

    xT = oTerminal?oTerminal.x:lsTask?.first()?:0
    yT = oTerminal?oTerminal.y:lsTask?.last()?:0

    Double tempdistance = 0
    if (xT && distance) {
      tempdistance = searchService.getDistance(xT,yT,xD?:xC?:xB?:xA,yD?:yC?:yB?:yA)
    }
    deliverydistance = Math.round(tempdistance/1000)
	}

	Trip updatePaymentData(){
		updatePaymentData(0l,null)
	}

	Trip updatePaymentData(Long _id){
		updatePaymentData(_id,null)
	}

	Trip updatePaymentData(Long _id, Payment _payment){
		def payments = Payment.findAllByTrip_idAndIdNotEqual(id,_id)+(_payment?:[])
		paid = payments?.sum{it.summa}?:0
		lastpayment = payments?.max{it.paydate}?.paydate?:null
		this
	}

	Trip updatetrackertax(Integer _summa){
		trackertax += _summa
		this
	}

	Integer computeContPaidSumma(bHaveSecond, bIsSecond){
		if (bIsSecond) return (price+paid<=(price+(bHaveSecond?price:0)+idlesum+forwardsum-trackertax)?price:(price+(bHaveSecond?price:0)+idlesum+forwardsum-trackertax-paid))
		else return (price+idlesum+forwardsum-trackertax+paid<=(price+(bHaveSecond?price:0)+idlesum+forwardsum-trackertax)?price+idlesum+forwardsum-trackertax:(price+(bHaveSecond?price:0)+idlesum+forwardsum-trackertax-paid))
	}

	static Trip findTripForPaytax(_client_id,_taxsum){
		Trip.get(Trip.executeQuery('select id from Trip where modstatus = 2 and paid = 0 and price > paid + trackertax + :taxsum and carrier=:carrier order by id desc',[taxsum:_taxsum,carrier:_client_id])[0])
	}

  Trip updatePayorderId(lOrderId){
    payorder_id = lOrderId?:0
    this
  }

}