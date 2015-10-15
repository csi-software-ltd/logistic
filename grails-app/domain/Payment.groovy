class Payment {
  def searchService
  static mapping = {
    version false
  }
  static constraints = {
    paydate(nullable:true)
  }

  Long id
  Long payorder_id
  Long zakaz_id
  Long client_id
  Date paydate
  Integer summa = 0
  Float summands
  String norder
  String platnumber
  String platcomment = ''
  String platname = ''
  Integer modstatus = 0
  Long trip_id = 0
  Integer pclass = 0
  Integer is_fix = 0
  Integer is_active = 1
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def afterDelete(){
    if (trip_id>0)
      Trip.withNewSession{
        def oTrip = Trip.get(trip_id)
        oTrip.updatePaymentData(id).save(flush:true)
        Zakaztodriver.get(oTrip.zakaztodriver_id).csiRemoveContpaid(platcomment).save(flush:true)
      }
  }
  def afterInsert(){
    if (trip_id>0)
      Trip.withNewSession{
        Trip.get(trip_id).updatePaymentData().save(flush:true)
      }
  }
  def afterUpdate(){
    if (trip_id>0)
      Trip.withNewSession{
        Trip.get(trip_id).updatePaymentData(id,this).save(flush:true)
      }
  }

  def findPayment(lZakazId,lPayorderId,iModstatus,sNorder,sPlatnumber,lClId,iFix,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*"
    hsSql.from="payment"
    hsSql.where="trip_id=0 and is_active=1"+
      ((lZakazId>0)?" and zakaz_id=:zakaz_id":"")+
      ((lClId>0)?" and client_id=:client_id":"")+
      ((iModstatus>-100)?" and modstatus=:status":"")+
      ((lPayorderId>0)?" and payorder_id=:payorder_id":"")+
      ((sPlatnumber!='')?" and platnumber like CONCAT('%',:platnumber,'%')":"")+
      ((iFix>0)?" and is_fix>0":"")+
      ((sNorder!='')?' and norder like CONCAT("%",:norder,"%")':'')
    hsSql.order="id DESC"

    if(lZakazId>0)
      hsLong['zakaz_id']=lZakazId
    if(lClId>0)
      hsLong['client_id']=lClId
    if(iModstatus>-100)
      hsLong['status']=iModstatus
    if(lPayorderId>0)
      hsLong['payorder_id']=lPayorderId
    if(sPlatnumber!='')
      hsString['platnumber']=sPlatnumber
    if(sNorder!='')
      hsString['norder']=sNorder

    return searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,null,null,iMax,iOffset,'id',true,Payment.class)
  }

  static Payment getInstance(_xmlNode){
    if(!_xmlNode.@Заказ?.text()||!_xmlNode.children().find{it.name()=='Дата'}||!_xmlNode.children().find{it.name()=='НомерПлатежа'})
      throw new Exception ('Not all data set')
    Payment.findOrCreateWhere(zakaz_id:_xmlNode.@Заказ.text().toLong(),platnumber:_xmlNode.НомерПлатежа.text(),paydate:Date.parse('dd.MM.yyyy',_xmlNode.Дата.text()))
  }

  Payment linkOrders(_xmlNode){
    if(!_xmlNode.children().find{it.name()=='Сумма'})
      throw new Exception ('Summa not set')
    summands = (_xmlNode.СуммаНДС.text().replace(',','.')?:0).toFloat()
    modstatus = (_xmlNode.Статус.text()?:0).toInteger()?:modstatus
    if (modstatus==0||_xmlNode.Корректировка.text()=='1'||(_xmlNode.Активность.text()=='0'&&is_active==1)) {
      platname = _xmlNode.Плательщик.text()?:''
      platcomment = _xmlNode.Комментарий.text()?_xmlNode.Комментарий.text().replace(',',', '):''
      def oPayorder = Payorder.findByZakaz_id(zakaz_id)?:Payorder.findByTrip_id(zakaz_id)
      payorder_id = oPayorder?.id?:0
      norder = oPayorder?.norder?:''
      client_id = oPayorder?.client_id?:0
      modstatus = payorder_id?1:0
      is_active = (_xmlNode.Активность.text()?:1).toInteger()
      oPayorder?.updatePaymentData((is_active?(_xmlNode.Сумма.text()?:0).toInteger():0)-summa,(Payment.findAllByPayorder_idAndTrip_idAndIs_activeAndIdNotEqual(payorder_id,0,1,id)+this)?.max{it?.paydate}?.paydate)?.save()
      summa = is_active?(_xmlNode.Сумма.text()?:0).toInteger():0
      is_fix = (_xmlNode.Корректировка.text()?:0).toInteger()
    }
    this
  }

  Payment setCarrierPayment(_request){
    payorder_id = _request.payorder_id
    zakaz_id = Payorder.get(payorder_id)?.trip_id?:Payorder.get(payorder_id)?.zakaz_id
    client_id = 0
    summa = _request.summa
    norder = _request.norder?:''
    platnumber = _request.trip_id?.toString()
    modstatus = 2
    trip_id = _request.trip_id
    pclass = _request.pclass?:0
    paydate = _request.paydate?:new Date()
    summands = pclass?summa*Tools.getFloatVal(Dynconfig.findByName('payment.cash.deduction')?.value,6.5f)/100:0f
    platcomment = _request.platcomment?:platcomment
    this
  }

  Payment setShipperPayment(_payorder,_request){
    payorder_id = _payorder.id
    zakaz_id = _payorder.trip_id?:_payorder.zakaz_id
    client_id = _payorder.client_id
    paydate = new Date()
    summa = _request.summa
    summands = 0f
    norder = _payorder.norder
    platnumber = _request.platnumber
    modstatus = 2
    _payorder.updatePaymentData(summa,(Payment.findAllByPayorder_idAndTrip_idAndIs_activeAndIdNotEqual(payorder_id,0,1,id)+this)?.max{it?.paydate}?.paydate)?.save()
    this
  }

}