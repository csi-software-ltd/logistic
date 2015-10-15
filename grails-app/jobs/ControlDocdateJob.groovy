import org.codehaus.groovy.grails.commons.ConfigurationHolder
class ControlDocdateJob {
	static triggers = {
		//simple repeatInterval: 60000 // execute job once in 60 seconds
		cron cronExpression: ((ConfigurationHolder.config.controldocdate.cron!=[:])?ConfigurationHolder.config.controldocdate.cron:"0 0 1 * * ?")
	}

	def execute() {
		log.debug("LOG>> ControlDocdateJob Start")
		Trip.findAllByTaskstatusAndTaskdateLessThanAndInputdateGreaterThan(5,new Date()-Tools.getIntVal(Dynconfig.findByName('docdate.nonblock.days')?.value,6),new Date()-30).collect{it.carrier}.unique().each{
			log.debug("LOG>> ControlDocdateJob -> banned client id:"+it)
			Client.get(it).csiSetIsBlocked(1).save(flush:true)
		}
		log.debug("LOG>> ControlDocdateJob Finish")
	}

}