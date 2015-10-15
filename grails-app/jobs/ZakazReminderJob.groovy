import org.codehaus.groovy.grails.commons.ConfigurationHolder
class ZakazReminderJob {
	def mailerService
	static triggers = {
		//simple repeatInterval: 60000 // execute job once in 60 seconds
		cron cronExpression: ((ConfigurationHolder.config.zakazreminder.cron!=[:])?ConfigurationHolder.config.zakazreminder.cron:"0 0/5 * * * ?")
	}

	def execute() {
		def now = new Date().getTime()
		def zakazlist = []
		Zakaz.findAllByModstatusInList([0,1,2]).each{
			if((it.inputdate.getTime()+(Ztime.get(it.ztime_id)?.qtime?:0)*60*1000)-now in 0..5*60*1000l) zakazlist << it
		}
		if (zakazlist){
			mailerService.sendAdminNotice('#zakazreminder')
			zakazlist.collect{it.manager_id}.unique().each{
				mailerService.sendManagerNotice(it,'#zakazreminder')
			}
		}
	}

}