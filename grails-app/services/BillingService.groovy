import groovy.xml.MarkupBuilder
class BillingService {

  /*void generateNewOrders(){
    //do some action
    Zakaz.findAllByPayorder_idAndModstatusAndIdNotInList(0,3,Trip.findAllByModstatusGreaterThanEqualsAndTaskstatusLessThan(-1,5).collect{it.zakaz_id}?:[0l]).each{
      try { it.updatePayorderId(new Payorder().setMainData(it).save(flush:true)?.id?:0).save(flush:true) } catch(Exception e) { log.debug('error on generate Payorder in BillingService:generateNewOrders '+e.toString()) }
    }
  }*/

  void generateNewOrders(){
    Trip.findAllByPayorder_idAndModstatusGreaterThanAndTaskstatusGreaterThan(0,-1,4).each{
      try { it.updatePayorderId(new Payorder().setMainData(it).save(flush:true)?.id?:0).save(flush:true) } catch(Exception e) { log.debug('error on generate Payorder in BillingService:generateNewOrders '+e.toString()) }
    }
  }

  void generateNewOrder(lTripId){
    Trip.findAllByPayorder_idAndModstatusGreaterThanAndId(0,-1,lTripId).each{
      try { it.updatePayorderId(new Payorder().setMainData(it).save(flush:true)?.id?:0).save(flush:true) } catch(Exception e) { log.debug('error on generate Payorder in BillingService:generateNewOrder '+e.toString()) }
    }
  }

  String prepareXmlDataFor1SUnloading(){
  	def orders = new PayorderSearchXml().findOrdersForXML()
    def writer = new StringWriter()
    def xml = new MarkupBuilder(writer)
    xml.mkp.xmlDeclaration(version: "1.0", encoding: "windows-1251")
    xml.Данные(Источник:"LG",ДатаВремя:String.format('%td.%<tm.%<ty %<tT',new Date()),Назначение:"1C"){
    	Счета(){
    		orders.each{ order ->
    			Счет(Заказ:order.trip_id?:order.zakaz_id){
            Дата(String.format('%td.%<tm.%<tY',order.inputdate))
            ИНН(order.inn?:'')
            КПП(order.kpp?:'')
            ПолнНаименование(order.payee?.replace('\"','')?:'')
            ЮрАдрес(order.address?:'')
            Тип(order.ctype_id==1?'ООО':order.ctype_id==2?'ИП':order.ctype_id==3?'ЗАО':'')
            СтавкаНДС(order.nds?:'')
            Сумма(order.fullcost+order.idlesum+order.forwardsum)
            Простой(order.idlesum)
            Переадресация(order.forwardsum)
            МастерКомпания(order.masterinn?:'')
            Назначение(order.paycomment?:'')
            Номер1С(order.norder?:'')
            Дата1С(order.orderdate&&order.modstatus==1?String.format('%td.%<tm.%<tY',order.orderdate):'')
            Статус(order.modstatus)
            Удален(order.is_delete)
            Поездки(){
              Trip.findAllByPayorder_idAndModstatusGreaterThan(order.id,-1).each { trip ->
                Поездка(trip.id)
              }
            }
          }
    		}
    	}
    }
    writer.toString()
  }

  String prepareXmlPaymentDataFor1SUnloading(){
    def payments = Payment.findAllByModstatus(1)
    def writer = new StringWriter()
    def xml = new MarkupBuilder(writer)
    xml.mkp.xmlDeclaration(version: "1.0", encoding: "windows-1251")
    xml.Данные(Источник:"LG",ДатаВремя:String.format('%td.%<tm.%<ty %<tT',new Date()),Назначение:"1C"){
      Платежи(){
        payments.each{ payment ->
          Платеж(Заказ:payment.zakaz_id){
            МастерКомпания(Syscompany.get(Payorder.get(payment.payorder_id)?.syscompany_id)?.inn?:'')
            Дата(String.format('%td.%<tm.%<tY',payment.paydate))
            Сумма(payment.summa)
            СуммаНДС(payment.summands)
            НомерПлатежа(payment.platnumber)
            Статус(payment.modstatus)
          }
        }
      }
    }
    writer.toString()
  }

  def importXmlDataFrom1S(_xml){
    if (!_xml)
      throw new Exception ('No file')
    if (_xml.getContentType() != "plain/xml" && _xml.getContentType() != "application/xml" && _xml.getContentType() != "text/xml" )
      throw new Exception ('Not supported file type')
    InputStreamReader isr = new InputStreamReader(_xml.getInputStream(), "windows-1251")
    def records = new XmlSlurper().parse(isr)
    if (records.@Назначение.text()!='LG')
      throw new Exception ('Invalid destination')
    if(records.children().find{it.name()=='Счета'}?true:false) parseXmlOrdersData(records)
    else if(records.children().find{it.name()=='Платежи'}?true:false) parseXmlPaymentsData(records)
    else throw new Exception ('Invalid file structure')
  }

  private def parseXmlOrdersData(records){
    def result = [complete:0,total:records.Счета.Счет.size()?:0,notimport:[]]
    records.Счета.Счет.each{
      try {
        if (Payorder.findByTrip_id((it.@Заказ?.text()?:0).toLong())?.synchronization1S(it)?.save(failOnError:true,flush:true))
          result.complete++
        /*else if (Payorder.findByZakaz_id((it.@Заказ?.text()?:0).toLong())?.synchronization1S(it)?.save(failOnError:true,flush:true))
          result.complete++*/
        else result.notimport << (it.@Заказ?.text()?:0).toLong()
      } catch(Exception e) {
          log.debug('error on update Payorder in BillingService:parseXmlOrdersData '+(it.@Заказ?.text()?:0).toLong()+'\n'+e.toString())
          result.notimport << (it.@Заказ?.text()?:0).toLong()
      }
    }
    return result.complete.toString() + ' of ' + result.total + ' was imported. ' + (result.notimport?('Not imported zakaz: '+result.notimport.toString()):'')
  }

  private def parseXmlPaymentsData(records){
    def result = [complete:0,total:records.Платежи.Платеж.size()?:0,notimport:[]]
    records.Платежи.Платеж.each{
      try {
        if (Payment.getInstance(it)?.linkOrders(it)?.save(failOnError:true,flush:true))
          result.complete++
        else result.notimport << (it.@Заказ?.text()?:0).toLong()
      } catch(Exception e) {
          log.debug('error on update Payment in BillingService:parseXmlPaymentsData '+(it.@Заказ?.text()?:0).toLong()+'\n'+e.toString())
          result.notimport << (it.@Заказ?.text()?:0).toLong()
      }
    }
    return result.complete.toString() + ' of ' + result.total + ' was imported. ' + (result.notimport?('Not imported zakaz: '+result.notimport.toString()):'')
  }

  def importCSVCarrierPaymentsData(_file){
    def result = [complete:0,total:0,notimport:[]]
    if(!_file.originalFilename) {
      return ''
    }
    result.total = _file.getInputStream().readLines('windows-1251').tail().each{ line ->
      def data = line.split(';',-1)
      try {
        def oTrip = Trip.get(data[0].toInteger())
        if (oTrip&&data[1].toInteger()) {
          if(data[14]&&!Payment.findByPlatnumberAndPaydateAndZakaz_idAndPlatcomment(oTrip.id.toString(),data[13]?Date.parse('dd.MM.yyyy', data[13]):new Date().clearTime(),Payorder.get(data[1].toInteger())?.trip_id?:Payorder.get(data[1].toInteger())?.zakaz_id,data[7])){
            def zToDriver = Zakaztodriver.get(oTrip.zakaztodriver_id)
            new Payment().setCarrierPayment([payorder_id:data[1].toInteger(),summa:data[15]?data[15].toInteger():data[12].toInteger(),trip_id:oTrip.id,pclass:0,platcomment:data[7],norder:data[14],paydate:data[13]?Date.parse('dd.MM.yyyy', data[13]):new Date()]).save(failOnError:true)
            zToDriver.csiSetContpaid(false).csiSetContpaid(true).save(failOnError:true)
            result.complete++
          }
        } else result.notimport << data[0]
      } catch(Exception e) {
        log.debug('error on update Payment in BillingService:importCSVCarrierPaymentsData '+data[0]+'\n'+e.toString())
        result.notimport << data[0]
      }
    }.size()?:0
    return result.complete.toString() + ' of ' + result.total + ' was imported. ' + (result.notimport?('Failed import trip: '+result.notimport.toString()):'')
  }
}