class ReportSearchMain {
  def searchService
  static mapping = {
    table 'adm_NAME'
    version false
    cache false
  }
  static constraints = {
  }

  String clientname
  Long client_id
  Integer totalcost
  Integer arrears
  Integer totaldebt
  Double totalponi

  def getReportShipper(){
    def hsSql=[select:'',from:'',where:'',group:'',order:'']

    hsSql.select="*, sum(if(datediff(curdate(),IFNULL(maxpaydate,curdate()))>0,datediff(curdate(),IFNULL(maxpaydate,curdate()))*0.1*if(debt>0,debt,0)/100,0)) as totalponi, sum(fullcost+idlesum+forwardsum) as totalcost, sum(IF(debt>0,debt,0)) as arrears, sum(IF(maxpaydate<=curdate(),debt,0)) as totaldebt"
    hsSql.from="v_payorder"
    hsSql.where='is_delete=0'
    hsSql.group="client_id having sum(IF(debt>0,debt,0))>0"
    hsSql.order="sum(IF(maxpaydate<=curdate(),IF(debt>0,debt,0),0)) desc"

    return searchService.fetchData(hsSql,null,null,null,null,ReportSearchMain.class)
  }

  def getReportCarrier(iDaydiff=0){
    def hsSql=[select:'',from:'',where:'',group:'',order:'']

    hsSql.select="*, 0 as totalponi, sum(IF(debt>0,debt,0)) as arrears, sum(IF(ca_maxpaydate<=(curdate() + interval-(:daydiff) day),IF(debt>0,debt,0),0)) as totaldebt, 0 as totalcost, carrier as client_id, carrier_name as clientname"
    hsSql.from="v_payordercarrier"
    hsSql.where='is_delete=0'
    hsSql.group=(iDaydiff?"carrier having sum(IF(ca_maxpaydate<=(curdate() + interval-(:daydiff) day),IF(debt>0,debt,0),0))>0":"carrier having sum(IF(debt>0,debt,0))>0")
    hsSql.order="sum(IF(debt>0,debt,0)) desc"

    def hsLong=[daydiff:iDaydiff]

    return searchService.fetchData(hsSql,hsLong,null,null,null,ReportSearchMain.class)
  }

}