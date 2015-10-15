class GcmService {
  def androidGcmService
  def grailsApplication

  void sendMessage(sType,iCount,lClientId){
    //log.debug('GcmService: client_id: '+lClientId)
    //GCM>>
    def sendGCM=[:]
    sendGCM.message=sType
    sendGCM.msgcnt=iCount.toString()

    def lsDevices=[]    

    def lsUsers=User.findAllWhere(client_id:lClientId)
    def user_ids=[]
    for(user in lsUsers)
      user_ids<<user.id

    if (user_ids) lsDevices=Device.findAll("FROM Device WHERE user_id IN (:user_ids)",[user_ids:user_ids])

    //log.debug('lsDevices='+lsDevices)
    if(lsDevices){
      def lsDevices_ids=[]

      for(device in lsDevices)
        lsDevices_ids<<device.device
      if(lsDevices_ids)
        androidGcmService.sendMessage(sendGCM,lsDevices_ids,'message', grailsApplication.config.android.gcm.api.key ?: '')  //ConfigurationHolder??? 
    }
    //GCM<<
  }
}