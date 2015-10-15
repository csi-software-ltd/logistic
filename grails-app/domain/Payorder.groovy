import org.codehaus.groovy.grails.commons.ConfigurationHolder
class Payorder {
  def searchService
  static mapping = {
    version false
  }
  static constraints = {
    lastpayment(nullable:true)
    docdate(nullable:true)
    maxpaydate(nullable:true)
    maxbenefitdate(nullable:true)
  }

  Long id
  Long zakaz_id
  Long trip_id
  Long client_id
  Integer modstatus = 0
  Integer paystatus = 0
  String norder = ''
  Date orderdate = new Date()
  Date inputdate = new Date()
  Date lastpayment
  Date docdate
  Date maxpaydate
  Date maxbenefitdate
  String nagr = ''
  Integer syscompany_id
  Long clientcompany_id
  Integer fullcost = 0
  Integer benefit = 0
  Integer idlesum = 0
  Integer forwardsum = 0
  Integer paid = 0
  Integer nds = 0
  Integer is_longtrip = 0
  String contnumbers = ''
  String contcarnumbers = ''
  String contbenefit = ''
  String destination = ''
  String paycomment = ''
  String doccomment = ''
  Integer is_fix = 0
  Integer is_act = 0
  Integer is_delete = 0
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Payorder setMainData(Trip oTrip){
    if (!oTrip) throw new Exception('Trip is not specified')
    def oClCompany = Clientrequisites.findByModstatusAndClient_id(1,oTrip.shipper)
    zakaz_id = 0
    trip_id = oTrip.id
    client_id = oTrip.shipper
    syscompany_id = oClCompany?.syscompany_id?:0
    clientcompany_id = oClCompany?.id?:0
    nds = oClCompany?.nds?:0
    contnumbers = Zakaztodriver.get(oTrip.zakaztodriver_id).collect{((it.containernumber1?[it.containernumber1]:[])+(it.containernumber2?[it.containernumber2]:[]))}.flatten().join(',')
    contcarnumbers = Zakaztodriver.get(oTrip.zakaztodriver_id).collect{((it.containernumber1?[it.containernumber1+' а/м '+oTrip.cargosnomer]:[])+(it.containernumber2?[it.containernumber2+' а/м '+oTrip.cargosnomer]:[]))}.flatten().join(',')
    fullcost = oTrip.zakazcost
    benefit = oTrip.benefit
    idlesum = oTrip.idlesum
    forwardsum = oTrip.forwardsum
    destination = oTrip?.addressD?:oTrip?.addressC?:oTrip?.addressB?:oTrip?.addressA?:''
    paycomment = "Транспортно-экспедиционное обслуживание за доставку контейнеров [@CONTNUMBERS] по адресу [@ADDRESS]".replace('[@CONTNUMBERS]',contcarnumbers).replace('[@ADDRESS]',destination)
    this
  }

  def findOrders(lZakazId,iModstatus,iSyscompany,sNorder,iClCompany,lClId,iIsAct,iIsdocdate,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*"
    hsSql.from="payorder"
    hsSql.where="is_delete=0"+
      ((lZakazId>0)?" and zakaz_id=:zakaz_id":"")+
      ((lClId>0)?" and client_id=:client_id":"")+
      ((iModstatus>-100)?" and modstatus=:status":"")+
      ((iSyscompany>0)?" and syscompany_id=:syscompany":"")+
      ((iClCompany>0)?" and clientcompany_id=:clcompany":"")+
      ((iIsAct>-100)?" and is_act=:is_act":"")+
      ((iIsdocdate==1)?" and docdate>0":(iIsdocdate==0)?" and IFNULL(docdate,0)=0":"")+
      ((sNorder!='')?' and norder like CONCAT("%",:norder,"%")':'')
    hsSql.order="id DESC"

    if(lZakazId>0)
      hsLong['zakaz_id']=lZakazId
    if(lClId>0)
      hsLong['client_id']=lClId
    if(iModstatus>-100)
      hsLong['status']=iModstatus
    if(iIsAct>-100)
      hsLong['is_act']=iIsAct
    if(iSyscompany>0)
      hsLong['syscompany']=iSyscompany
    if(iClCompany>0)
      hsLong['clcompany']=iClCompany
    if(sNorder!='')
      hsString['norder']=sNorder

    return searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,null,null,iMax,iOffset,'id',true,Payorder.class)
  }

  Integer countOrdersByDebt(lClId=-1){
    def hsSql=[select:'',from:'',where:'']
    def hsLong=[:]

    hsSql.select="*"
    hsSql.from="payorder"
    hsSql.where="(fullcost+idlesum+forwardsum-paid)>0 and maxpaydate<curdate() and client_id=:client_id and is_delete=0"

    hsLong['client_id']=lClId

    return searchService.fetchData(hsSql,hsLong,null,null,null,Payorder.class).size()
  }

  Payorder updateCompanies(_request){
    updateSysCompany(_request.syscompany_id)
    updateClCompany(_request.clientcompany_id)
    this
  }

  private Payorder updateSysCompany(iSysCompanyId){
    syscompany_id = iSysCompanyId?:0
    nds = Syscompany.get(syscompany_id)?.nds?:0
    if (isDirty('syscompany_id')) modstatus = 0
    this
  }

  private Payorder updateClCompany(lClCompanyId){
    clientcompany_id = lClCompanyId?:0
    maxpaydate = docdate?docdate+(Clientrequisites.get(lClCompanyId)?.payterm?:Tools.getIntVal(ConfigurationHolder.config.payterm.default.days,7)):null
    this
  }

  Payorder updateDocdate(Date _dDate){
    docdate = _dDate
    maxpaydate = docdate?docdate+(Clientrequisites.get(clientcompany_id)?.payterm?:Tools.getIntVal(ConfigurationHolder.config.payterm.default.days,7)):null
    this
  }

  Payorder csiSetAct(_iAct){
    is_act = _iAct?:0
    this
  }

  Payorder synchronization1S(_xmlNode){
    if (!_xmlNode.children().find{it.name()=='Статус'})
      throw new Exception ('Invalid file structure')
    if (_xmlNode.Статус?.text()=='1') {
      norder = _xmlNode.Номер1С?.text()?:''
      if(_xmlNode.Дата1С.text()) orderdate = Date.parse('dd.MM.yyyy',_xmlNode.Дата1С.text())
      if(_xmlNode.Удален?.text()=='1'){
        is_delete = 1
      } else {
        is_delete = 0
        def lsTrips = _xmlNode.Поездки.Поездка.collect{
          Trip.get( it.text().toLong() )
        }?:[]
        updatepaycomment(lsTrips)
        updateIdlesum(lsTrips)
        updateForwardsum(lsTrips)
        updateBenefit(lsTrips)
        def lsOldTrips = Trip.findAllByPayorder_id(id)
        lsTrips.each {
          it.updatePayorderId(id).save(failOnError:true)
        }
        (lsOldTrips-lsTrips).each{
          it.updatePayorderId(-1).save(failOnError:true)
        }
      }
      if (_xmlNode.Корректировка?.text()=='1') {
        is_fix = 1
        fullcost = _xmlNode.Сумма.text().toInteger()-idlesum-forwardsum
      }
    }
    modstatus = _xmlNode.Статус.text().toInteger()?:modstatus
    if (modstatus==2) is_fix = 0
    this
  }

  Payorder updatePaymentData(iSumma,dPayDate){
    lastpayment = dPayDate
    paid += iSumma
    paystatus = paid>=(fullcost+idlesum+forwardsum)?2:paid>0?1:0
    if(paystatus==2) maxbenefitdate = lastpayment+14//dirty hack!!! Use magical number for determining this date:D
    else maxbenefitdate = null
    this
  }

  Payorder updateIdlesum(_tripId,_sum){
    idlesum = (Trip.findAllByModstatusGreaterThanEqualsAndPayorder_idAndIdNotEqual(-1,id,_tripId)?.sum{it.idlesum}?:0)+_sum
    if (isDirty('idlesum')) modstatus = modstatus?1:0
    this
  }

  Payorder updateIdlesum(lsTrip){
    idlesum = (lsTrip?.sum{it.idlesum}?:0)
    this
  }

  Payorder updateForwardsum(_tripId,_sum){
    forwardsum = (Trip.findAllByModstatusGreaterThanEqualsAndPayorder_idAndIdNotEqual(-1,id,_tripId)?.sum{it.forwardsum}?:0)+_sum
    if (isDirty('forwardsum')) modstatus = modstatus?1:0
    this
  }

  Payorder updateForwardsum(lsTrip){
    forwardsum = (lsTrip?.sum{it.forwardsum}?:0)
    this
  }

  Payorder updateBenefit(lsTrip){
    benefit = (lsTrip?.sum{it.benefit}?:0)
    this
  }

  Payorder updateBenefit(_tripId,_sum){
    benefit = (Trip.findAllByModstatusGreaterThanEqualsAndPayorder_idAndIdNotEqual(-1,id,_tripId)?.sum{it.benefit}?:0)+_sum
    this
  }

  Payorder updateContbenefit(_sContnumber){
    contbenefit = (contbenefit.split(',')-['']+[_sContnumber]).join(',')
    this
  }

  Payorder updatepaycomment(Trip _trip, String _cont1, String _cont2){
    def lsTrip = Trip.findAllByModstatusGreaterThanEqualsAndPayorder_idAndIdNotEqual(-1,id,_trip.id)
    contnumbers = (lsTrip.collect{ trip -> Zakaztodriver.get(trip.zakaztodriver_id).collect{((it.containernumber1?[it.containernumber1]:[])+(it.containernumber2?[it.containernumber2]:[]))}}+(_cont2?[_cont1,_cont2]:[_cont1])).flatten().join(',')
    contcarnumbers = (lsTrip.collect{ trip -> Zakaztodriver.get(trip.zakaztodriver_id).collect{((it.containernumber1?[it.containernumber1+' а/м '+trip.cargosnomer]:[])+(it.containernumber2?[it.containernumber2+' а/м '+trip.cargosnomer]:[]))}}+(_cont2?[_cont1+' а/м '+_trip.cargosnomer,_cont2+' а/м '+_trip.cargosnomer]:[_cont1+' а/м '+_trip.cargosnomer])).flatten().join(',')
    paycomment = "Транспортно-экспедиционное обслуживание за доставку контейнеров [@CONTNUMBERS] по адресу [@ADDRESS]".replace('[@CONTNUMBERS]',contcarnumbers).replace('[@ADDRESS]',destination)
    this
  }

  Payorder updatepaycomment(lsTrip){
    contnumbers = (lsTrip.collect{ trip -> Zakaztodriver.get(trip.zakaztodriver_id).collect{((it.containernumber1?[it.containernumber1]:[])+(it.containernumber2?[it.containernumber2]:[]))}}).flatten().join(',')
    contcarnumbers = (lsTrip.collect{ trip -> Zakaztodriver.get(trip.zakaztodriver_id).collect{((it.containernumber1?[it.containernumber1+' а/м '+trip.cargosnomer]:[])+(it.containernumber2?[it.containernumber2+' а/м '+trip.cargosnomer]:[]))}}).flatten().join(',')
    paycomment = "Транспортно-экспедиционное обслуживание за доставку контейнеров [@CONTNUMBERS] по адресу [@ADDRESS]".replace('[@CONTNUMBERS]',contcarnumbers).replace('[@ADDRESS]',destination)
    this
  }

}