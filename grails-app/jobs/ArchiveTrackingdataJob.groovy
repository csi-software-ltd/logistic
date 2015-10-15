import org.codehaus.groovy.grails.commons.ConfigurationHolder
class ArchiveTrackingdataJob {
	static triggers = {
		//simple repeatInterval: 150000 // execute job once in 150 seconds
		cron cronExpression: ((ConfigurationHolder.config.archiveTrackingdata.cron!=[:])?ConfigurationHolder.config.archiveTrackingdata.cron:"0 0 0 1 * ?")
	}

	def execute() {
		new Trackingdata().archiveTrackingdata()
	}

}