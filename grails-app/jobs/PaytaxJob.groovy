import org.codehaus.groovy.grails.commons.ConfigurationHolder
class PaytaxJob {
	static triggers = {
		//simple repeatInterval: 60000 // execute job once in 60 seconds
		cron cronExpression: ((ConfigurationHolder.config.paytax.cron!=[:])?ConfigurationHolder.config.paytax.cron:"0 0 5 1 * ?")
	}

	def execute() {
		log.debug("LOG>> PaytaxJob -> start")
		def basesumma = Tools.getIntVal(Dynconfig.findByName('paytax.default.summa')?.value,1000)
		Paytax.findAllByTrip_id(0).each{
			it.setMainData([paydate:it.paydate,summa:it.summa,trip_id:Trip.findTripForPaytax(it.client_id,it.summa)?.updatetrackertax(it.summa)?.save(flush:true)?.id?:0l]).save(failOnError:true)
		}
		Car.findAllByImeiNotEqual('').groupBy([{it.client_id}]).each{
			new Paytax([client_id:it.key]).setMainData([paydate:new Date()-1,summa:it.value.size()*basesumma,trip_id:Trip.findTripForPaytax(it.key,it.value.size()*basesumma)?.updatetrackertax(it.value.size()*basesumma)?.save(flush:true)?.id?:0l]).save(failOnError:true)
		}
		log.debug("LOG>> PaytaxJob -> finish")
	}

}