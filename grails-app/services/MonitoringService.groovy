import org.codehaus.groovy.grails.commons.ConfigurationHolder

class MonitoringService {
  def searchService
  static final Integer CONNECTIONTIMEOUT = Tools.getIntVal(ConfigurationHolder.config.monitoring.connectiontimeout.hours,6)
  static final Integer ZONERADIUS = Tools.getIntVal(ConfigurationHolder.config.monitoring.zoneradius.kms,5)
  static final Integer MERGERADIUS = Tools.getIntVal(ConfigurationHolder.config.monitoring.mergeradius.kms,1)
  static final Integer TRIPENDTIMEOUT = Tools.getIntVal(ConfigurationHolder.config.monitoring.tripend.timeout.slot.hours,3)
  static final Integer TRIPENDNOSLOTTIMEOUT = Tools.getIntVal(ConfigurationHolder.config.monitoring.tripend.timeout.noslot.hours,15)

  void processAnalyze(){
    def oTriproute = new Triproute()
    Trip.findAllByModstatusInListAndImeiNotEqual([0,1],'').each{
      oTriproute.updateFromTrackingdata(it)
    }
    Trip.findAll {
      modstatus in [0,1] &&
      imei != '' &&
      distance > 0
    }.each{
      def lsNewRoute = Triproute.findAllByTrip_idAndIs_processed(it.id,0)
      analyzeCommonEvent(lsNewRoute,it)
      Boolean isneedanalyzeroute = true
      while(isneedanalyzeroute) {
        isneedanalyzeroute = analyzeRouteEvent(getNextRouteEventForAnalyze(it),lsNewRoute,it)
      }
      lsNewRoute.each{route ->
        route.processed().save(flush:true)
      }
      it.routestatus = it.routestatus - 1
      try {
        it.merge(flush:true,failOnError:true)
      } catch(Exception e) {
        log.debug("Error save trip in MonitoringService/processAnalyze\n"+e.toString())
        log.debug("Trip data:\n"+it.properties.toString())
      }
    }
  }

  Integer getNextRouteEventForAnalyze(oTrip){
    switch(oTrip.routestatus) {
      case 0:
      case 1:
      case 3:
      case 5:
      case 7:
      case 9:
        return oTrip.routestatus+1
        break
      case 2:
        if (!oTrip.xB&&!oTrip.xC&&!oTrip.xD) return 10
        else if (Math.round(searchService.getDistance(oTrip.xA,oTrip.yA,oTrip.xB,oTrip.yB)/1000)<MERGERADIUS){
          generateTripEvent(3,oTrip.id)
          //add exit zone B event here if need
          return 5
        } else return oTrip.routestatus+1
        break
      case 4:
        if (!oTrip.xC&&!oTrip.xD) return 10
        else if (Math.round(searchService.getDistance(oTrip.xB,oTrip.yB,oTrip.xC,oTrip.yC)/1000)<MERGERADIUS){
          generateTripEvent(5,oTrip.id)
          //add exit zone C event here if need
          return 7
        } else return oTrip.routestatus+1
        break
      case 6:
        if (!oTrip.xD) return 10
        else if (Math.round(searchService.getDistance(oTrip.xC,oTrip.yC,oTrip.xD,oTrip.yD)/1000)<MERGERADIUS){
          generateTripEvent(7,oTrip.id)
          //add exit zone D event here if need
          return 10
        } else return oTrip.routestatus+1
        break
      case 8:
        return 10
        break
      default:
        return 0
    }
  }

  Boolean analyzeRouteEvent(iEventToAnalyze,lsRoute,oTrip){
    if (!iEventToAnalyze) return false
    oTrip.routestatus = iEventToAnalyze
    return this.('analyzeRouteEventType'+iEventToAnalyze)(lsRoute,oTrip)
  }

  Boolean analyzeRouteEventType1(lsRoute,oTrip){
    if (!oTrip.xA) return true
    for(it in lsRoute) {
      if (Math.round(searchService.getDistance(oTrip.xA,oTrip.yA,Math.round(it.x/100),Math.round(it.y/100))/1000)<ZONERADIUS){
        generateTripEvent(1,oTrip.id)
        if (oTrip.dateA) {
          def trackdate = new Date(it.tracktime.getYear(),it.tracktime.getMonth(),it.tracktime.getDate())
          if(oTrip.dateA<trackdate||(oTrip.dateA==trackdate&&(oTrip.timeendA?:24)<it.tracktime.getHours())){
            generateTripEvent(11,oTrip.id)
            oTrip.modstatus = 0
          }
        }
        return true
      }
    }
    return false
  }
  Boolean analyzeRouteEventType3(lsRoute,oTrip){
    if (!oTrip.xB) return true
    for(it in lsRoute) {
      if (Math.round(searchService.getDistance(oTrip.xB,oTrip.yB,Math.round(it.x/100),Math.round(it.y/100))/1000)<ZONERADIUS){
        generateTripEvent(3,oTrip.id)
        if(oTrip.noticetel) generateNoticeSms(oTrip)
        if (oTrip.dateB) {
          def trackdate = new Date(it.tracktime.getYear(),it.tracktime.getMonth(),it.tracktime.getDate())
          if(oTrip.dateB<trackdate||(oTrip.dateB==trackdate&&(oTrip.timeendB?:24)<it.tracktime.getHours())){
            generateTripEvent(12,oTrip.id)
            oTrip.modstatus = 0
          }
        }
        return true
      }
    }
    return false
  }
  Boolean analyzeRouteEventType5(lsRoute,oTrip){
    if (!oTrip.xC) return true
    for(it in lsRoute) {
      if (Math.round(searchService.getDistance(oTrip.xC,oTrip.yC,Math.round(it.x/100),Math.round(it.y/100))/1000)<ZONERADIUS){
        generateTripEvent(5,oTrip.id)
        if (oTrip.dateC) {
          def trackdate = new Date(it.tracktime.getYear(),it.tracktime.getMonth(),it.tracktime.getDate())
          if(oTrip.dateC<trackdate||(oTrip.dateC==trackdate&&(oTrip.timeendC?:24)<it.tracktime.getHours())){
            generateTripEvent(13,oTrip.id)
            oTrip.modstatus = 0
          }
        }
        return true
      }
    }
    return false
  }
  Boolean analyzeRouteEventType7(lsRoute,oTrip){
    if (!oTrip.xD) return true
    for(it in lsRoute) {
      if (Math.round(searchService.getDistance(oTrip.xD,oTrip.yD,Math.round(it.x/100),Math.round(it.y/100))/1000)<ZONERADIUS){
        generateTripEvent(7,oTrip.id)
        if (oTrip.dateD) {
          def trackdate = new Date(it.tracktime.getYear(),it.tracktime.getMonth(),it.tracktime.getDate())
          if(oTrip.dateD<trackdate||(oTrip.dateD==trackdate&&(oTrip.timeendD?:24)<it.tracktime.getHours())){
            generateTripEvent(14,oTrip.id)
            oTrip.modstatus = 0
          }
        }
        return true
      }
    }
    return false
  }
  Boolean analyzeRouteEventType2(lsRoute,oTrip){
    if (!oTrip.xA) return true
    for(it in lsRoute) {
      if (Math.round(searchService.getDistance(oTrip.xA,oTrip.yA,Math.round(it.x/100),Math.round(it.y/100))/1000)>ZONERADIUS){
        //add exit zone A event here if need
        return true
      }
    }
    return false
  }
  Boolean analyzeRouteEventType4(lsRoute,oTrip){
    if (!oTrip.xB) return true
    for(it in lsRoute) {
      if (Math.round(searchService.getDistance(oTrip.xB,oTrip.yB,Math.round(it.x/100),Math.round(it.y/100))/1000)>ZONERADIUS){
        //add exit zone B event here if need
        oTrip.extmonitoringdate = it.tracktime
        println 111
        return true
      }
    }
    return false
  }
  Boolean analyzeRouteEventType6(lsRoute,oTrip){
    if (!oTrip.xC) return true
    for(it in lsRoute) {
      if (Math.round(searchService.getDistance(oTrip.xC,oTrip.yC,Math.round(it.x/100),Math.round(it.y/100))/1000)>ZONERADIUS){
        //add exit zone C event here if need
        return true
      }
    }
    return false
  }
  Boolean analyzeRouteEventType8(lsRoute,oTrip){
    if (!oTrip.xD) return true
    for(it in lsRoute) {
      if (Math.round(searchService.getDistance(oTrip.xD,oTrip.yD,Math.round(it.x/100),Math.round(it.y/100))/1000)>ZONERADIUS){
        //add exit zone D event here if need
        return true
      }
    }
    return false
  }
  Boolean analyzeRouteEventType10(lsRoute,oTrip){
    return false
  }

  void generateTripEvent(iType,lTripId){
    try {
      new Tripevent(type_id:iType,trip_id:lTripId).save(failOnError:true)
    }catch(Exception e) {
      log.debug("Error save event type:"+iType+" for trip:"+lTripId+"\n"+e.toString())
    }
  }

  void generateNoticeSms(oTrip){
    try {
      new Noticesms(trip_id:oTrip.id,tel:oTrip.noticetel,time:oTrip.noticetime).save(failOnError:true)
    }catch(Exception e) {
      log.debug("Error save notice Sms for trip:"+oTrip.id+"\n"+e.toString())
    }
  }

  void analyzeCommonEvent(lsRoute,oTrip){
    if(oTrip.taskstatus in [2,5,6] && (oTrip.taskdate?.getTime()?:new Date().getTime())+(oTrip.taskend?:24)*60*60*1000+(oTrip.taskslot?TRIPENDTIMEOUT:TRIPENDNOSLOTTIMEOUT)*60*60*1000 < new Date().getTime()){
      if(oTrip.taskstatus==2) generateTripEvent(24,oTrip.id)
      generateTripEvent(16,oTrip.id)
      oTrip.taskstatus = 5
      oTrip.modstatus = 2
    }
    if(oTrip.trackstatus&&lsRoute.size()==0&&((Triproute.findByTrip_id(oTrip.id,[sort:'tracktime',order:'desc'])?.tracktime?.getTime()?:(oTrip.dateA.getTime()+oTrip.timestartA*60*60*1000))+CONNECTIONTIMEOUT*60*60*1000 < new Date().getTime())){
      oTrip.trackstatus = 0
      generateTripEvent(10,oTrip.id)
    } else if(!oTrip.trackstatus&&lsRoute.size()>0){
      oTrip.trackstatus = lsRoute.last().speed>0?1:2
      generateTripEvent(15,oTrip.id)
    }
  }

}