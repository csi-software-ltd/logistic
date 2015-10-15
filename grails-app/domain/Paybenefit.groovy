class Paybenefit {
  static mapping = {
    version false
  }
  static constraints = {
  }

  Long id
  Long payorder_id
  Date paydate
  Integer summa
  String platcomment = ''
  String beneficial = ''

///////////////////////////////////////////////////////////////////////////////////////////////////

  Paybenefit setMainData(_request){
    summa = _request.summa
    platcomment = _request.platcomment?:''
    beneficial = _request.beneficial?:''
    this
  }

  static Integer getbenefitSumma(_payorder){
    def paidsumma = Paybenefit.findAllByPayorder_id(_payorder.id).sum{it.summa}?:0
    def summa = Math.ceil(_payorder.benefit/_payorder.contnumbers.split(',').size()).toInteger()
    _payorder.benefit-paidsumma<summa?_payorder.benefit-paidsumma:summa
  }

}