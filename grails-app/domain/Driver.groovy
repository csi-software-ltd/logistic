class Driver {
  static mapping = {
    version false
  }
  static constraints = {
    docdata(nullable:true)
  }

  Long id
  String name
  Long client_id
  String tel = ''
  String fullname = ''
  Integer document_id = 1
  String docseria = ''
  String docnumber = ''
  Date docdata = new Date()
  String docuch = ''
  Date inputdate = new Date()
  Date moddate = new Date()
  Integer modstatus = 1
  Integer is_passport1 = 0
  Integer is_passport2 = 0
  Integer is_prava = 0

  def beforeUpdate() {
    moddate = new Date()
  }

  Driver setData(lsRequest){
    name = lsRequest.name?:name
    tel = lsRequest.tel?:''
    fullname = lsRequest.fullname?:''
    document_id = lsRequest.document_id?:1
    docseria = lsRequest.docseria?:''
    docnumber = lsRequest.docnumber?:''
    docuch = lsRequest.docuch?:''
    docdata = lsRequest.docdata
    this
  }

  Driver csiSetModstatus(iStatus){
    modstatus = iStatus?:0
    this
  }

  Driver updatescanstatus(sName,iStatus){
    this."$sName" = iStatus?:0
    this
  }

}