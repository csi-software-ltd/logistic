class Syscompany {

  static mapping = {
    version false    
  }

  static constraints = {
  }

  Integer id
  String name
  String inn
  String kpp
  String fulladdress
  String bik
  String bank
  String corschet
  String account
  Integer nds
  Integer ctype_id
  Integer modstatus = 1
  String ogrn
  String chief
  String accountant
  String stampname = ''

  Syscompany csiSetData(lsRequest){
    name = lsRequest.name
    nds = lsRequest.nds?:0
    inn = lsRequest.inn
    ctype_id = lsRequest.ctype_id
    fulladdress = lsRequest.fulladdress
    bik = lsRequest.bik
    bank = lsRequest.bank
    corschet = lsRequest.corschet
    account = lsRequest.account
    chief = lsRequest.chief
    accountant = lsRequest.accountant

    kpp = lsRequest.kpp?:''
    ogrn = lsRequest.ogrn?:''

    this
  }
}