import org.codehaus.groovy.grails.commons.ConfigurationHolder
class DeliveryReminderJob {
	def zakazService
	def monitoringService
	def mailerService
	static triggers = {
		//simple repeatInterval: 150000 // execute job once in 150 seconds
		cron cronExpression: ((ConfigurationHolder.config.deliveryreminder.cron!=[:])?ConfigurationHolder.config.deliveryreminder.cron:"0 0 8 * * ?")
	}

	def execute() {
		def today = zakazService.curDate()
		def tripsforremind = []
		Trip.findAllByTaskstatusAndModstatusGreaterThanEquals(0,0).each{
			if(it.addressD) {
				if((it.dateD?:today+1)<today){
					tripsforremind << it
					monitoringService.generateTripEvent(21,it.id)
				}
			} else if(it.addressC){
				if((it.dateC?:today+1)<today){
					tripsforremind << it
					monitoringService.generateTripEvent(21,it.id)
				}
			} else if(it.addressB){
				if((it.dateB?:today+1)<today){
					tripsforremind << it
					monitoringService.generateTripEvent(21,it.id)
				}
			}
		}
		if(tripsforremind){
			mailerService.sendAdminNotice('#admin_delivery_remind',tripsforremind.collect{it.id})
			tripsforremind.collect{Zakaz.get(it.zakaz_id)?.manager_id?:0}.unique().each{ manager ->
				mailerService.sendManagerNotice(manager,'#admin_delivery_remind',tripsforremind.findAll{Zakaz.get(it.zakaz_id)?.manager_id==manager}.collect{it.id})
			}
		}
	}

}