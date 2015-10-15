import org.codehaus.groovy.grails.commons.ConfigurationHolder
class ZakazGarbageCollectorJob {
		def zakazService
    
		static triggers = {
			//simple repeatInterval: 150000 // execute job once in 150 seconds
			cron cronExpression: ((ConfigurationHolder.config.garbagecollector.cron!=[:])?ConfigurationHolder.config.garbagecollector.cron:"0 0 1 * * ?")
		}

		def execute() {
			def now = new Date().getTime()
			Zakaz.findAllByModstatusInList([0,1,2]).each{
				if(it.inputdate.getTime()+(Ztime.get(it.ztime_id)?.qtime?:0)*60*1000+30*60*1000<now){
					if (it.modstatus==2)
						zakazService.sendOfferDeclineForCarrier(Zakaztocarrier.findAllByZakaz_idAndModstatus(it.id,2).collect{it.client_id},it.id)
					it.csiSetModstatus(-3).save(flush:true)
					Zakaztocarrier.findAllByZakaz_idAndModstatusGreaterThan(it.id,-1).each{ ztocarr ->
            ztocarr.csiSetModstatus(-1).carrierread().save(flush:true)                  
          }
				}
			}
		}
}