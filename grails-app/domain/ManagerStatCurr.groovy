class ManagerStatCurr {
  def searchService
  static mapping = {
    table 'adm_NAME'
    version false
    cache false
  }
  static constraints = {
  }

  Long id
  Integer manager_id
  Date inputdate
  Integer totalzakazcost
  Integer totalcarrcost
  Integer totalbenefit

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def getStatByMonth(dDate){
    def hsSql=[select:'',from:'',group:'',where:'']
    def hsLong=[:]

    hsSql.select="*, sum(carrcost) as totalcarrcost, sum(zakazcost) as totalzakazcost, sum(benefit) as totalbenefit"
    hsSql.from="v_managerstatcurr"
    hsSql.where=((!dDate||(dDate?.getMonth()==new Date().getMonth()&&dDate?.getYear()==new Date().getYear()))?"month(inputdate)=month(curdate()) and year(inputdate)=year(curdate())":"month(inputdate)=:month and year(inputdate)=:year and payorder_id>0")
    hsSql.group="manager_id, dayofyear(inputdate)"

    if(dDate&&(dDate?.getMonth()!=new Date().getMonth()||dDate?.getYear()!=new Date().getYear())) {
      hsLong['month'] = dDate.getMonth()+1
      hsLong['year'] = dDate?.getYear()+1900
    }
    return searchService.fetchData(hsSql,hsLong,null,null,null,ManagerStatCurr.class)
  }

  String toString(){
    "${totalzakazcost-totalcarrcost-totalbenefit}(${Math.round((totalzakazcost-totalcarrcost-totalbenefit)*100/totalzakazcost)}%)"
  }

  String toString(_kprofit){
    "${Math.round((totalzakazcost-totalcarrcost)*_kprofit-totalbenefit)}(${Math.round(Math.round((totalzakazcost-totalcarrcost)*_kprofit-totalbenefit)*100/totalzakazcost)}%)"
  }

}