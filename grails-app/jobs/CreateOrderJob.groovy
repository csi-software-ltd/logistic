import org.codehaus.groovy.grails.commons.ConfigurationHolder
class CreateOrderJob {
	def billingService
	static triggers = {
		//simple repeatInterval: 150000 // execute job once in 150 seconds
		cron cronExpression: ((ConfigurationHolder.config.createOrder.cron!=[:])?ConfigurationHolder.config.createOrder.cron:"0 0 6 * * ?")
	}

	def execute() {
		log.debug("LOG>> CreateOrderJob Start")
		billingService.generateNewOrders()
		log.debug("LOG>> CreateOrderJob Finish")
	}

}