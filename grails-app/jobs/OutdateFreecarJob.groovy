import org.codehaus.groovy.grails.commons.ConfigurationHolder
class OutdateFreecarJob {
	static triggers = {
		//simple repeatInterval: 60000 // execute job once in 60 seconds
		cron cronExpression: ((ConfigurationHolder.config.outdatefreecar.cron!=[:])?ConfigurationHolder.config.outdatefreecar.cron:"0 0/5 0 * * ?")
	}

	def execute() {
		Freecars.findAllByModstatusAndInputdateLessThan(1,new Date(System.currentTimeMillis()-Tools.getIntVal(Dynconfig.findByName('freecar.default.timelimit')?.value,4)*60*60*1000)).each{
			log.debug("LOG>> OutdateFreecarJob -> timelimit car id:"+it.id)
			it.csiSetModstatus(0).save(flush:true)
		}
	}

}