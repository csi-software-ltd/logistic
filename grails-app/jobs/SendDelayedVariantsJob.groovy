import org.codehaus.groovy.grails.commons.ConfigurationHolder
class SendDelayedVariantsJob {
	def zakazService
	static triggers = {
		//simple repeatInterval: 150000 // execute job once in 150 seconds
		cron cronExpression: ((ConfigurationHolder.config.delayedvarints.cron!=[:])?ConfigurationHolder.config.delayedvarints.cron:"0 2/10 * * * ?")
	}

	def execute() {
		zakazService.sendDelayedVariants()
	}

}