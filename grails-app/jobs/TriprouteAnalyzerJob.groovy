import org.codehaus.groovy.grails.commons.ConfigurationHolder
class TriprouteAnalyzerJob {
	def monitoringService
	def smsService
	static triggers = {
		//simple repeatInterval: 60000 // execute job once in 60 seconds
		cron cronExpression: ((ConfigurationHolder.config.triprouteAnalyzer.cron!=[:])?ConfigurationHolder.config.triprouteAnalyzer.cron:"0 5/30 * * * ?")
	}

	def execute() {
		monitoringService.processAnalyze()
		smsService.resendNoticeSms()
	}

}