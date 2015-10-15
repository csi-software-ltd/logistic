import org.codehaus.groovy.grails.commons.ConfigurationHolder
class JetPilotJob {
	def zakazService
	static triggers = {
		//simple repeatInterval: 150000 // execute job once in 150 seconds
		cron cronExpression: ((ConfigurationHolder.config.autopilot.cron!=[:])?ConfigurationHolder.config.autopilot.cron:"0 0/5 * * * ?")
	}

	def execute() {
		if (Adminmenu.get(15)?.is_on)
			zakazService.administrate()
	}

}