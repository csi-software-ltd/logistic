import org.codehaus.groovy.grails.commons.ConfigurationHolder
import grails.converters.JSON
import groovyx.net.http.*
import static groovyx.net.http.ContentType.*
import static groovyx.net.http.Method.*
import groovy.json.JsonSlurper

class SmsService {

  static transactional = false  

  def sendVerifySms(oUser) {
    def jSonBody = [:]
    //jSonBody.apikey = "59S9QNLO7I8521U9QZYG1P7C4A4OSO383378IL6O941B74D018Y7F3TY4045UGI4"
    jSonBody.apikey = (ConfigurationHolder.config.SMSgate.apikey)?ConfigurationHolder.config.SMSgate.apikey.trim():"XXXXXXXXXXXXYYYYYYYYYYYYZZZZZZZZXXXXXXXXXXXXYYYYYYYYYYYYZZZZZZZZ"
    jSonBody.send = []
    def sendBody = [:]
    sendBody.id = getNewSMSid(oUser)
    sendBody.from = ((ConfigurationHolder.config.SMSgate.from)?ConfigurationHolder.config.SMSgate.from:'logistic')
    if(sendBody.from.size()>11)
      sendBody.from = sendBody.from[0..10]
    sendBody.to = oUser.tel.replace('+','').replace('(','').replace(')','').replace(' ','').replace('-','')
    sendBody.text = oUser.smscode
    jSonBody.send << sendBody

    def error = 0
    def servId = ''
    def http = new HTTPBuilder('http://smspilot.ru')
    http.request(POST, JSON) {
      uri.path = '/api2.php'
      uri.query = [json:(jSonBody as JSON)]
      headers.Accept = 'application/json'
      response.success = { resp, json ->
        def tempResponse = json.text
        def parsedJSON = JSON.parse(tempResponse)
        if (parsedJSON){
          try{
            if (parsedJSON.send[0].error!='0'){
              error = (parsedJSON.send[0].error as int)
            }
            servId = parsedJSON.send[0]?.server_id?:''
          } catch (Exception e){
            try{
              if (parsedJSON.error.code!='0'){
                error = (parsedJSON.error.code as int)
              }
            } catch (Exception er){
              log.debug ('\nError parsing json sms gate response: '+er)
              error = 500
            }
          }
        } else {
          try {
            def parsedXML = new XmlSlurper().parseText(tempResponse)
            error = ((parsedXML.code[0]?:404).toString() as int)
          } catch (Exception e){
            log.debug ('\nError parsing xml sms gate response: '+e)
            error = 500
          }
        }
      }
      response.failure = { resp ->
        error = 404
      }
    }
    updateSmsStatus(sendBody.id,error,servId)
    return error
  }

  def sendOffer(oUser,sHeader) {
    def jSonBody = [:]
    //jSonBody.apikey = "59S9QNLO7I8521U9QZYG1P7C4A4OSO383378IL6O941B74D018Y7F3TY4045UGI4"
    jSonBody.apikey = (ConfigurationHolder.config.SMSgate.apikey)?ConfigurationHolder.config.SMSgate.apikey.trim():"XXXXXXXXXXXXYYYYYYYYYYYYZZZZZZZZXXXXXXXXXXXXYYYYYYYYYYYYZZZZZZZZ"
    jSonBody.send = []
    def sendBody = [:]
    sendBody.id = getNewSMSid(oUser.id,oUser.tel,sHeader)
    sendBody.from = ((ConfigurationHolder.config.SMSgate.from)?ConfigurationHolder.config.SMSgate.from:'staytoday.ru')
    if(sendBody.from.size()>11)
      sendBody.from = sendBody.from[0..10]
    sendBody.to = oUser.tel.replace('+','').replace('(','').replace(')','').replace(' ','').replace('-','')
    sendBody.text = sHeader
    jSonBody.send << sendBody

    def error = 0
    def servId = ''
    def http = new HTTPBuilder('http://smspilot.ru')
    http.request(POST, JSON) {
      uri.path = '/api2.php'
      uri.query = [json:(jSonBody as JSON)]
      headers.Accept = 'application/json'
      response.success = { resp, json ->
        def tempResponse = json.text
        def parsedJSON = JSON.parse(tempResponse)
        if (parsedJSON){
          try{
            if (parsedJSON.send[0].error!='0'){
              error = (parsedJSON.send[0].error as int)
            }
            servId = parsedJSON.send[0]?.server_id?:''
          } catch (Exception e){
            try{
              if (parsedJSON.error.code!='0'){
                error = (parsedJSON.error.code as int)
              }
            } catch (Exception er){
              log.debug ('\nError parsing json sms gate response: '+er)
              error = 500
            }
          }
        } else {
          try {
            def parsedXML = new XmlSlurper().parseText(tempResponse)
            error = ((parsedXML.code[0]?:404).toString() as int)
          } catch (Exception e){
            log.debug ('\nError parsing xml sms gate response: '+e)
            error = 500
          }
        }
      }
      response.failure = { resp ->
        error = 404
      }
    }
    updateSmsStatus(sendBody.id,error,servId)
    return error
  }

  void sendZakazOfferForCarriersAsync(lsUsers,_zakaz) {
    def th=new Thread()
    th.start{
      synchronized(this) {
        Sms.withNewSession{
          def sHeader
          if (_zakaz) sHeader = "${_zakaz.zcol}x${Container.get(_zakaz.container).shortname} ${_zakaz.collect{[it.weight1,it.weight2,it.weight3,it.weight4,it.weight5]}?.max()?.max()?.toInteger()?:0}т ${_zakaz.price_basic} ${String.format('%td.%<tm',_zakaz.date_start)}${_zakaz.zdate?"-"+String.format('%td.%<tm',_zakaz.zdate):''} ${_zakaz.terminal?Terminal.get(_zakaz.terminal)?.name:_zakaz.region_start=='Санкт-Петербург'?'СПБ':_zakaz.region_start} ${_zakaz.slotlist?(Slot.get(_zakaz.slotlist.split(',').last().toInteger())?.start):_zakaz.timeend} ${_zakaz.terminal_end?Terminal.get(_zakaz.terminal_end)?.name:_zakaz.region_end=='Санкт-Петербург'?'СПБ '+_zakaz.address_end:_zakaz.region_end+' '+_zakaz.address_end}"
          else {
            def lsText = Email_template.findWhere(action:'#zakaz_offer_for_carrier_sms')
            sHeader = lsText?.title?:"New zakaz at Logistic"
          }
          lsUsers.each{ user ->
            if (user.tel) {
              sendOffer(user,sHeader)
            }
          }
        }
      }
    }
  }

  void sendOrderRemindForCarrierAsync(lsUsers) {
    def th=new Thread()
    th.start{
      synchronized(this) {
        Sms.withNewSession{
          def lsText=Email_template.findWhere(action:'#zakaz_remind_for_carrier_sms')
          def sHeader=lsText?.title?:"You must add driver info"
          lsUsers.each{ user ->
            if (user.tel) {
              sendOffer(user,sHeader)
            }
          }
        }
      }
    }
  }

  void sendZakazOfferForShipperAsync(oUser) {
    def th=new Thread()
    th.start{
      synchronized(this) {
        Sms.withNewSession{
          def lsText=Email_template.findWhere(action:'#zakaz_offer_for_shipper_sms')
          def sHeader=lsText?.title?:"New offer at Logistic"
          if (oUser.tel) {
            sendOffer(oUser,sHeader)
          }
        }
      }
    }
  }

  void sendOfferConfirmForCarrierAsync(oZakaztodriver) {
    def th=new Thread()
    th.start{
      synchronized(this) {
        Sms.withNewSession{
          def oTrip = Trip.findByZakaztodriver_id(oZakaztodriver?.id)
          def oDriver = Driver.get(oTrip?.driver_id)
          def oTerminal = Terminal.get(oTrip?.terminal)
          def sHeader = "${oTrip?.cargosnomer} - ${oDriver?.name}\n${oTerminal?.name} - ${String.format('%tF',oTrip?.dateA)} с ${oTrip?.timestartA} по ${oTrip?.timeendA}\n${oZakaztodriver?.containernumber1} ${oZakaztodriver?.containernumber2}\n${oTrip?.doc}"
          User.findAllByClient_idAndIs_noticeSMS(oTrip?.carrier,1).each{ user ->
            if (user.tel) {
              sendOffer(user,sHeader)
            }
          }
        }
      }
    }
  }

  void sendContDeliveryForCarrierAsync(oUser,oTrip) {
    def th=new Thread()
    th.start{
      synchronized(this) {
        Sms.withNewSession{
          def oDriver = Driver.get(oTrip?.driver_id)
          def oTerminal = Terminal.get(oTrip?.taskterminal)
          def oZakaztodriver = Zakaztodriver.get(oTrip.zakaztodriver_id)
          def sHeader = "${oTrip?.returncargosnomer}\nСдача: ${oTerminal?.name?:oTrip?.taskaddress} - ${String.format('%tF',oTrip?.taskdate)} с ${oTrip?.taskstart} по ${oTrip?.taskend}\n${oZakaztodriver?.containernumber1} ${oZakaztodriver?.containernumber2}\n${oTrip?.stockbooking}"
          if (oUser.tel) {
            sendOffer(oUser,sHeader)
          }
        }
      }
    }
  }

  void sendDeliveryRequestForShipperAsync(oUser) {
    def th=new Thread()
    th.start{
      synchronized(this) {
        Sms.withNewSession{
          def lsText=Email_template.findWhere(action:'#trip_delivery_request_for_shipper_sms')
          def sHeader=lsText?.title?:"New delivery request at Logistic"
          if (oUser.tel) {
            sendOffer(oUser,sHeader)
          }
        }
      }
    }
  }

  void sendNewZakazAdminNoticeAsync(oAdmin) {
    def th=new Thread()
    th.start{
      synchronized(this) {
        Sms.withNewSession{
          def lsText=Email_template.findWhere(action:'#zakaz_new')
          def sHeader=lsText?.title?:"New zakaz"
          if (oAdmin.tel) {
            sendOffer(oAdmin,sHeader)
          }
        }
      }
    }
  }

  void sendOfferDeclineForCarrier(lsUsers,_zakazId=0) {
    def th=new Thread()
    th.start{
      synchronized(this) {
        Sms.withNewSession{
          def lsText = Email_template.findWhere(action:'#zakaz_decline_for_carrier_sms')
          def sHeader = (lsText?.title?:"Your offer was declined").replace('[@ORDERID]',_zakazId.toString())
          lsUsers.each{ user ->
            if (user.tel) {
              sendOffer(user,sHeader)
            }
          }
        }
      }
    }
  }

  void sendDeliveryRemindForcarrier(lsUsers,_tripId=0) {
    def th=new Thread()
    th.start{
      synchronized(this) {
        Sms.withNewSession{
          def lsText = Email_template.findWhere(action:'#delivery_remind_for_carrier_sms')
          def sHeader = (lsText?.title?:"Container was not deliver").replace('[@ID]',_tripId.toString())
          lsUsers.each{ user ->
            if (user.tel) {
              sendOffer(user,sHeader)
            }
          }
        }
      }
    }
  }

  def getNewSMSid(oUser) {
    def oSms = new Sms(oUser)
    if(!oSms.save(flush:true)) {
      log.debug(" Error on add Sms:")
      oSms.errors.each{log.debug(it)}
      return oUser.id
    }else{
      return oSms.id
    }
  }

  def getNewSMSid(lId, sTel, sSmscode) {
    def oSms = new Sms(lId, sTel, sSmscode)
    if(!oSms.save(flush:true)) {
      log.debug(" Error on add Sms:")
      oSms.errors.each{log.debug(it)}
      return lId
    }else{
      return oSms.id
    }
  }

  def updateSmsStatus(lId,iStatus,sServerId) {
    def oSms = Sms.get(lId)
    if(oSms)
      oSms.updateStatusAndServerId(iStatus,sServerId)
    else {
      log.debug ('\nError updating sms status')
    }
  }

  def geocodeYandex(String address) {
    def http = new HTTPBuilder('http://geocode-maps.yandex.ru/1.x/')
    def queryMap = [:]
    queryMap.geocode = address
    queryMap.format = 'json'
    queryMap.results = '1'
    queryMap.ll = '30.31427,59.93880'
    queryMap.spn = '0.552069,0.400552'
    def results
    http.request(GET, ContentType.JSON) {
      uri.query = queryMap
      response.success = { resp, json ->
        if (json.response.GeoObjectCollection.featureMember.size()) {
          results = json.response.GeoObjectCollection.featureMember.GeoObject.Point.pos[0].split(' ').collect{(it.toDouble()*100000).toInteger()}
        } else {
          results = [0,0]
        }
      }
      response.failure = { resp ->
        results = [0,0]
      }
    }
    return results
  }

  void resendNoticeSms(){
    def th=new Thread()
    th.start{
      synchronized(this) {
        Sms.withNewSession{
          Noticesms.findAllByModstatusAndTimeLessThanEquals(0,new Date().getHours()).each{
            def oTrip = Trip.read(it.trip_id)
            def oCar = Car.read(oTrip?.car_id?:0)
            def oCarmodel = Carmodel.read(oCar?.model_id?:0)
            def oDriver = Driver.read(oTrip?.driver_id?:0)
            def oZakaztodriver = Zakaztodriver.read(oTrip?.zakaztodriver_id?:0)
            def sHeader = "${oCar?.gosnomer} - ${oCarmodel?.name} - ${oDriver?.tel}\n${oZakaztodriver?.containernumber1} ${oZakaztodriver?.containernumber2}"
            if (it.tel) {
              it.modstatus = sendOffer([id:0l,tel:it.tel],sHeader)?:1
              it.save(flush:true,failOnError:true)
            }
            th.sleep(1000)
          }
        }
      }
    }
  }

}