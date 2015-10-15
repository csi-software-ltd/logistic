import org.codehaus.groovy.grails.commons.ConfigurationHolder

class MailerService {   
  static transactional = false
  def MAIL_SUPPORT='info@containerovoz.ru'

  def sendUserConfirmMail(hsRes){  
		//<<Email		
    def lsText=Email_template.findWhere(action:'#activation')
    def sText='[@EMAIL], for activation of your account use follow link [@URL]'
    def sHeader="Registration at StayToday" 
    if(lsText){
      sText=lsText.itext
      sHeader=lsText.title
    }
    sText=sText.replace(
    '[@NICKNAME]',hsRes.inrequest.name.split(' ')[0]).replace(
    '[@EMAIL]',hsRes.inrequest.email).replace(
    '[@URL]',(ConfigurationHolder.config.grails.mailServerURL+'/user/confirm/'+hsRes.code))
    sText=((sText?:'').size()>Tools.getIntVal(ConfigurationHolder.config.mail.textsize,500))?sText.substring(0,Tools.getIntVal(ConfigurationHolder.config.mail.textsize,500)):sText
    sHeader=sHeader.replace(
    '[@EMAIL]',hsRes.inrequest.email).replace(
    '[@URL]',(ConfigurationHolder.config.grails.mailServerURL+'/user/confirm/'+hsRes.code))
    
    def bReturn=1
    try{        
      sendMail{
        to hsRes.inrequest.email        
        subject sHeader
        html sText
      /*  body( view:"/_mail",
        model:[mail_body:sText])              
      */  
      }                
    }catch(Exception e) {
      log.debug("Cannot sent email in sendUserConfirmMail \n"+e.toString()) 
      bReturn=0      
    }
    //>>Email
    return bReturn
	}
  def sendZakazNewAsync(oAdmin){
    def th=new Thread()
    th.start{
      synchronized(this) {
        def lsText=Email_template.findWhere(action:'#zakaz_new')
        def sText='Новая заявка'
        def sHeader="Новая заявка"
        if(lsText){
          sText=lsText.itext
          sHeader=lsText.title
        }
        if(Tools.checkEmailString(oAdmin?.email)){                   
          try{
            sendMail{
              to oAdmin.email
              subject sHeader
              html sText
            /*  body( view:"/_mail",
                  model:[mail_body:sText])
            */
            }
          }catch(Exception e) {
            log.debug("Cannot sent email \n"+e.toString().replace("'","").replace('"','')+" in MailerService/sendZakazNewAsync")
          }
        } else { log.debug("Cannot sent email in sendZakazNewAsync\n\t incorrect User.email for User:") }
      }
    }
  }

  def sendUserConfirmMailAsync(oUser){
    def th=new Thread()
    th.start{
      synchronized(this) {
        def lsText=Email_template.findWhere(action:'#activation')
        def sText='[@EMAIL], for activation of your account use follow link [@URL]'
        def sHeader="Registration at Logistic"
        if(lsText){
          sText=lsText.itext
          sHeader=lsText.title
        }
        if(Tools.checkEmailString(oUser?.email)){
          sText=sText.replace(
          '[@NICKNAME]',oUser.nickname?:'').replace(
          '[@EMAIL]',oUser.email).replace(
          '[@URL]',(ConfigurationHolder.config.grails.mailServerURL+'/user/confirm/'+oUser.code))
          sHeader=sHeader.replace(
          '[@EMAIL]',oUser.email).replace(
          '[@URL]',(ConfigurationHolder.config.grails.mailServerURL+'/user/confirm/'+oUser.code))

          try{
            sendMail{
              to oUser.email
              subject sHeader
              html sText
            /*  body( view:"/_mail",
                  model:[mail_body:sText])
            */
            }
          }catch(Exception e) {
            log.debug("Cannot sent email \n"+e.toString().replace("'","").replace('"','')+" in MailerService/sendUserConfirmMailAsync")
          }
        } else { log.debug("Cannot sent email in sendUserConfirmMailAsync\n\t incorrect User.email for User:"+oUser?.id) }
      }
    }
  }

  void sendNewUserMailAsync(oUser,sPass){
    def th=new Thread()
    th.start{
      synchronized(this) {
        def lsText=Email_template.findWhere(action:'#admin_newUser')
        def sText='[@NICKNAME], for activation of your account use follow link [@URL]'
        def sHeader="Greetings at Logistic"
        if(lsText){
          sText=lsText.itext
          sHeader=lsText.title
        }
        if(Tools.checkEmailString(oUser?.email)){
          sText=sText.replace(
          '[@NICKNAME]',oUser.nickname?:'').replace(
          '[@EMAIL]',oUser.email).replace(
          '[@ID]',oUser.id.toString()).replace(
          '[@PASSWORD]',sPass).replace(
          '[@URL]',(ConfigurationHolder.config.grails.mailServerURL+'/user/passwconfirm/'+oUser.code))
          sHeader=sHeader.replace(
          '[@NICKNAME]',oUser.nickname?:'').replace(
          '[@EMAIL]',oUser.email).replace(
          '[@URL]',(ConfigurationHolder.config.grails.mailServerURL+'/user/passwconfirm/'+oUser.code))

          try{
            sendMail{
              to oUser.email
              subject sHeader
              html sText
            /*  body( view:"/_mail",
                  model:[mail_body:sText])
            */
            }
          }catch(Exception e) {
            log.debug("Cannot sent email \n"+e.toString().replace("'","").replace('"','')+" in MailerService/sendNewUserMailAsync")
          }
        } else { log.debug("Cannot sent email in sendNewUserMailAsync\n\t incorrect User.email for User:"+oUser?.id) }
      }
    }
  }

  void sendZakazOfferForCarriersAsync(lsUsers){
    def th=new Thread()
    th.start{
      synchronized(this) {
        def lsText=Email_template.findWhere(action:'#zakaz_offer_for_carrier')
        def sText='[@NICKNAME], you receive new zakaz at Logistic. Check your account.'
        def sHeader="New zakaz at Logistic"
        if(lsText){
          sText=lsText.itext
          sHeader=lsText.title
        }
        lsUsers.each{ oUser ->
          if(Tools.checkEmailString(oUser?.email)){
            def sResultText=sText.replace(
            '[@NICKNAME]',oUser.nickname?:'')
            def sResultHeader=sHeader.replace(
            '[@NICKNAME]',oUser.nickname?:'')
            try{
              sendMail{
                to oUser.email
                subject sResultHeader
                html sResultText
              /*  body( view:"/_mail",
                    model:[mail_body:sText])
              */
              }
            }catch(Exception e) {
              log.debug("Cannot sent email \n"+e.toString().replace("'","").replace('"','')+" in MailerService/sendZakazOfferForCarriersAsync")
            }
            th.sleep(Tools.getIntVal(ConfigurationHolder.config.notemail.delay,10) *1000)
          } else { log.debug("Cannot sent email in sendZakazOfferForCarriersAsync\n\t incorrect User.email for User:"+oUser?.id) }
        }
      }
    }
  }

  void sendZakazOfferForShipperAsync(oUser){
    def th=new Thread()
    th.start{
      synchronized(this) {
        def lsText=Email_template.findWhere(action:'#zakaz_offer_for_shipper')
        def sText='[@NICKNAME], you receive new offer at Logistic. Check your account.'
        def sHeader="New offer at Logistic"
        if(lsText){
          sText=lsText.itext
          sHeader=lsText.title
        }
        if(Tools.checkEmailString(oUser?.email)){
          sText=sText.replace(
          '[@NICKNAME]',oUser.nickname?:'')
          sHeader=sHeader.replace(
          '[@NICKNAME]',oUser.nickname?:'')
          try{
            sendMail{
              to oUser.email
              subject sHeader
              html sText
            /*  body( view:"/_mail",
                  model:[mail_body:sText])
            */
            }
          }catch(Exception e) {
            log.debug("Cannot sent email \n"+e.toString().replace("'","").replace('"','')+" in MailerService/sendZakazOfferForShipperAsync")
          }
        } else { log.debug("Cannot sent email in sendZakazOfferForShipperAsync\n\t incorrect User.email for User:"+oUser?.id) }
      }
    }
  }

  void sendOrderRemindForCarrierAsync(lsUsers){
    def th=new Thread()
    th.start{
      synchronized(this) {
        def lsText=Email_template.findWhere(action:'#zakaz_remind_for_carrier')
        def sText='[@NICKNAME], you must add driver info for order.'
        def sHeader="Add driver info for order"
        if(lsText){
          sText=lsText.itext
          sHeader=lsText.title
        }
        lsUsers.each{ oUser ->
          if(Tools.checkEmailString(oUser?.email)){
            def sResultText=sText.replace(
            '[@NICKNAME]',oUser.nickname?:'')
            def sResultHeader=sHeader.replace(
            '[@NICKNAME]',oUser.nickname?:'')
            try{
              sendMail{
                to oUser.email
                subject sResultHeader
                html sResultText
              /*  body( view:"/_mail",
                    model:[mail_body:sText])
              */
              }
            }catch(Exception e) {
              log.debug("Cannot sent email \n"+e.toString().replace("'","").replace('"','')+" in MailerService/sendOrderRemindForCarrierAsync")
            }
            th.sleep(Tools.getIntVal(ConfigurationHolder.config.notemail.delay,10) *1000)
          } else { log.debug("Cannot sent email in sendOrderRemindForCarrierAsync\n\t incorrect User.email for User:"+oUser?.id) }
        }
      }
    }
  }

  def sendAdminZakazRemMailAsync(lOrderId){
    def th=new Thread()
    th.start{
      synchronized(this) {
        def lsText=Email_template.findWhere(action:'#zakaz_rem_admin_notice')
        def sText='Заказ № [@OrderId] снят грузоотправителем.'
        def sHeader="Заказ № [@OrderId] снят грузоотправителем."
        if(lsText){
          sText=lsText.itext
          sHeader=lsText.title
        }

        sText=sText.replace('[@OrderId]',lOrderId.toString()?:'')
        sHeader=sHeader.replace('[@OrderId]',lOrderId.toString()?:'')

        def oAdmin=Admin.get(Tools.getIntVal(ConfigurationHolder.config.zakaz.admin.id?:1).toLong())
        def oManager=Admin.get(Zakaz.get(lOrderId)?.manager_id?:0)
        try{
          sendMail{
            to oAdmin.email
            subject sHeader
            html sText
          /*  body( view:"/_mail",
                model:[mail_body:sText])
          */
          }
        }catch(Exception e) {
          log.debug("Cannot sent email \n"+e.toString().replace("'","").replace('"','')+" in MailerService/sendAdminZakazRemMailAsync")
        }
        th.sleep(Tools.getIntVal(ConfigurationHolder.config.notemail.delay,10) *1000)
        if (oManager?.email&&oManager?.email!=oAdmin.email) {
          try{
            sendMail{
              to oManager.email
              subject sHeader
              html sText
            /*  body( view:"/_mail",
                  model:[mail_body:sText])
            */
            }
          }catch(Exception e) {
            log.debug("Cannot sent manager email \n"+e.toString().replace("'","").replace('"','')+" in MailerService/sendAdminZakazRemMailAsync")
          }
        }
      }
    }
  }

  void sendOfferConfirmForCarrierAsync(lsUsers){
    def th=new Thread()
    th.start{
      synchronized(this) {
        def lsText=Email_template.findWhere(action:'#zakaz_confirm_for_carrier')
        def sText='[@NICKNAME], your offer was confirmed by shipper.'
        def sHeader="Your offer was confirmed"
        if(lsText){
          sText=lsText.itext
          sHeader=lsText.title
        }
        lsUsers.each{ oUser ->
          if(Tools.checkEmailString(oUser?.email)){
            def sResultText=sText.replace(
            '[@NICKNAME]',oUser.nickname?:'')
            def sResultHeader=sHeader.replace(
            '[@NICKNAME]',oUser.nickname?:'')
            try{
              sendMail{
                to oUser.email
                subject sResultHeader
                html sResultText
              /*  body( view:"/_mail",
                    model:[mail_body:sText])
              */
              }
            }catch(Exception e) {
              log.debug("Cannot sent email \n"+e.toString().replace("'","").replace('"','')+" in MailerService/sendOfferConfirmForCarrierAsync")
            }
            th.sleep(Tools.getIntVal(ConfigurationHolder.config.notemail.delay,10) *1000)
          } else { log.debug("Cannot sent email in sendOfferConfirmForCarrierAsync\n\t incorrect User.email for User:"+oUser?.id) }
        }
      }
    }
  }

  void sendDeliveryRequestForShipperAsync(oUser){
    def th=new Thread()
    th.start{
      synchronized(this) {
        def lsText=Email_template.findWhere(action:'#trip_delivery_request_for_shipper')
        def sText='[@NICKNAME], you receive new delivery request at Logistic. Check your account.'
        def sHeader="New delivery request at Logistic"
        if(lsText){
          sText=lsText.itext
          sHeader=lsText.title
        }
        if(Tools.checkEmailString(oUser?.email)){
          sText=sText.replace(
          '[@NICKNAME]',oUser.nickname?:'')
          sHeader=sHeader.replace(
          '[@NICKNAME]',oUser.nickname?:'')
          try{
            sendMail{
              to oUser.email
              subject sHeader
              html sText
            /*  body( view:"/_mail",
                  model:[mail_body:sText])
            */
            }
          }catch(Exception e) {
            log.debug("Cannot sent email \n"+e.toString().replace("'","").replace('"','')+" in MailerService/sendDeliveryRequestForShipperAsync")
          }
        } else { log.debug("Cannot sent email in sendDeliveryRequestForShipperAsync\n\t incorrect User.email for User:"+oUser?.id) }
      }
    }
  }

  void sendAdminNotice(sAction,_Id=0){
    def th=new Thread()
    th.start{
      synchronized(this) {
        def oAdmin = Admin.get(Tools.getIntVal(ConfigurationHolder.config.zakaz.admin.id,1).toLong())
        def lsText = Email_template.findWhere(action:sAction)
        def sText = 'Новая заявка'
        def sHeader = "Новая заявка"
        if(lsText){
          sText = lsText.itext.replace('[@ID]',_Id.toString())
          sHeader = lsText.title
        }
        if(Tools.checkEmailString(oAdmin?.email)){
          try{
            sendMail{
              to oAdmin.email
              subject sHeader
              html sText
            /*  body( view:"/_mail",
                  model:[mail_body:sText])
            */
            }
          }catch(Exception e) {
            log.debug("Cannot sent email \n"+e.toString().replace("'","").replace('"','')+" in MailerService/sendAdminNotice/"+sAction)
          }
        } else { log.debug("Cannot sent email in sendAdminNotice\n\t incorrect Admin.email for Admin:"+oAdmin?.login) }
      }
    }
  }

  void sendManagerNotice(iManagerId,sAction,_Id=0){
    def th=new Thread()
    th.start{
      synchronized(this) {
        def oAdmin = Admin.get(iManagerId)
        def oMainAdmin = Admin.get(Tools.getIntVal(ConfigurationHolder.config.zakaz.admin.id,1).toLong())
        def lsText = Email_template.findWhere(action:sAction)
        def sText = 'Новая заявка'
        def sHeader = "Новая заявка"
        if(lsText){
          sText = lsText.itext.replace('[@ID]',_Id.toString())
          sHeader = lsText.title
        }
        if(Tools.checkEmailString(oAdmin?.email)&&oAdmin?.email!=oMainAdmin?.email){
          try{
            sendMail{
              to oAdmin.email
              subject sHeader
              html sText
            /*  body( view:"/_mail",
                  model:[mail_body:sText])
            */
            }
          }catch(Exception e) {
            log.debug("Cannot sent email \n"+e.toString().replace("'","").replace('"','')+" in MailerService/sendManagerNotice/"+sAction)
          }
        } else { log.debug("Cannot sent email in sendManagerNotice\n\t incorrect Admin.email for Admin:"+oAdmin?.login) }
      }
    }
  }

  def sendAdminGbNotice(oGuestbook){
    if (!oGuestbook) throw new Exception("Guestbook did not set")
    def th=new Thread()
    th.start{
      synchronized(this) {
        def mail_support = ConfigurationHolder.config.mail.support?:MAIL_SUPPORT
        if(Tools.checkEmailString(mail_support)){
          def sHtml= """
                  id                ${oGuestbook.id}
                  user_id           ${oGuestbook.user_id}
                  name              ${oGuestbook.name}
                  email             ${oGuestbook.email}
                  tel               ${oGuestbook.tel}
                  message           ${oGuestbook.message}
                  """
          def sSubject="Guestbook  ${oGuestbook.id}, ${oGuestbook.message}"
          try{
            sendMail{
              to mail_support
              subject sSubject
              html sHtml
            }
          }catch(Exception e) {
            log.debug("Cannot sent email \n"+e.toString().replace("'","").replace('"','')+" in MailerService/sendAdminGbNotice/"+sAction)
          }
        } else { log.debug("Cannot sent email in sendAdminGbNotice\n\t incorrect email: "+mail_support) }
      }
    }
  }

  void sendOfferDeclineForCarrier(lsUsers){
    def th=new Thread()
    th.start{
      synchronized(this) {
        def lsText=Email_template.findWhere(action:'#zakaz_decline_for_carrier')
        def sText='[@NICKNAME], your offer was declined by shipper.'
        def sHeader="Your offer was declined"
        if(lsText){
          sText=lsText.itext
          sHeader=lsText.title
        }
        lsUsers.each{ oUser ->
          if(Tools.checkEmailString(oUser?.email)){
            def sResultText=sText.replace(
            '[@NICKNAME]',oUser.nickname?:'')
            def sResultHeader=sHeader.replace(
            '[@NICKNAME]',oUser.nickname?:'')
            try{
              sendMail{
                to oUser.email
                subject sResultHeader
                html sResultText
              /*  body( view:"/_mail",
                    model:[mail_body:sText])
              */
              }
            }catch(Exception e) {
              log.debug("Cannot sent email \n"+e.toString().replace("'","").replace('"','')+" in MailerService/sendOfferDeclineForCarrier")
            }
            th.sleep(Tools.getIntVal(ConfigurationHolder.config.notemail.delay,10) *1000)
          } else { log.debug("Cannot sent email in sendOfferDeclineForCarrier\n\t incorrect User.email for User:"+oUser?.id) }
        }
      }
    }
  }

  void sendDeliveryRemindForCarrier(lsUsers,_tripId){
    def th=new Thread()
    th.start{
      synchronized(this) {
        def lsText=Email_template.findWhere(action:'#delivery_remind_for_carrier')
        def sText='[@NICKNAME], You must deliver container.'
        def sHeader="Container was not deliver"
        if(lsText){
          sText = lsText.itext.replace('[@ID]',_tripId.toString())
          sHeader = lsText.title
        }
        lsUsers.each{ oUser ->
          if(Tools.checkEmailString(oUser?.email)){
            def sResultText=sText.replace(
            '[@NICKNAME]',oUser.nickname?:'')
            def sResultHeader=sHeader.replace(
            '[@NICKNAME]',oUser.nickname?:'')
            try{
              sendMail{
                to oUser.email
                subject sResultHeader
                html sResultText
              /*  body( view:"/_mail",
                    model:[mail_body:sText])
              */
              }
            }catch(Exception e) {
              log.debug("Cannot sent email \n"+e.toString().replace("'","").replace('"','')+" in MailerService/sendDeliveryRemindForCarrier")
            }
            th.sleep(Tools.getIntVal(ConfigurationHolder.config.notemail.delay,10) *1000)
          } else { log.debug("Cannot sent email in sendDeliveryRemindForCarrier\n\t incorrect User.email for User:"+oUser?.id) }
        }
      }
    }
  }

}