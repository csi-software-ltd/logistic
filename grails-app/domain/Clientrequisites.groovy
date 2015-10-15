import org.codehaus.groovy.grails.commons.ConfigurationHolder
class Clientrequisites {
  static constraints = {
    agrdate(nullable:true)
  }
  static mapping = {
    version false
  }

  Long id
  Long client_id
  Integer modstatus = 0
  Integer ctype_id = 0

  Integer nds = 0
  String payee = ''
  String inn = ''
  String kpp = ''
  String bankname = ''
  String bik = ''
  String settlaccount = ''
  String corraccount = ''
  String ogrn = ''
  String license = ''
  String address = ''
  
  String nagr = ''
  Date agrdate
  Integer syscompany_id = 0
  Integer shortbenefit = 0
  Integer longbenefit = 0
  Integer payterm = 0

  Date inputdate = new Date()
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  Clientrequisites setClientRequisites(lsRequest){
    payee = lsRequest.payee?:''
    inn = lsRequest.inn?:''
    kpp = lsRequest.kpp?:''
    bankname = lsRequest.bankname?:''
    bik = lsRequest.bik?:''
    corraccount = lsRequest.corraccount?:''
    settlaccount = lsRequest.settlaccount?:''
    ogrn = lsRequest.ogrn?:''
    license = lsRequest.license?:''
    address = lsRequest.address?:''
    nds = lsRequest.nds?:0
    ctype_id = lsRequest.ctype_id?:0
    if (!Clientrequisites.findAllByClient_idAndModstatus(lsRequest.client_id,1)) {
      modstatus = 1
    }

    nagr = lsRequest.nagr?:''
    agrdate = lsRequest.agrdate
    syscompany_id = lsRequest.syscompany_id?:0
    shortbenefit = lsRequest.shortbenefit?:0
    longbenefit = lsRequest.longbenefit?:0
    payterm = lsRequest.payterm

    this
  }

  private Clientrequisites rawSetModstatus(iStatus){
    modstatus = iStatus
    this
  }

  Clientrequisites csiSetModstatus(iStatus){
    if(modstatus==1&&iStatus!=1) {
      Clientrequisites.findByClient_idAndModstatus(client_id,0)?.rawSetModstatus(1)?.save()
    } else if (modstatus!=1&&iStatus==1) {
      Clientrequisites.findByClient_idAndModstatus(client_id,1)?.rawSetModstatus(0)?.save()
    }
    if (iStatus==0&&!Clientrequisites.findAllByClient_idAndModstatus(client_id,1))
      modstatus = 1
    else 
      modstatus = iStatus
    this
  }

  Integer getBenefit(_price){
    (_price<Tools.getIntVal(ConfigurationHolder.config.longtrip.default.price,32000))?shortbenefit:longbenefit
  }

}