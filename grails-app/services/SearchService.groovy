import org.codehaus.groovy.grails.commons.ConfigurationHolder

class SearchService {
  boolean transactional = false
  def sessionFactory
  // def m_oConnect=null <-- TODO? set one connection object?

  def fetchDataByPages(hsSql, hsFilter,
                hsLong,hsInt,hsString,hsList,lsNotUseInCount,
                iMax,iOffset,
                sCount,bComputeCount,
                clClassName,lsDictionaryIds=null,isEager=false){//set isEager=true if using eager fetched property in domain class and object will not be detached by session.clear() method
				
    def session=sessionFactory.getCurrentSession()
    def hsRes=[records:[],count:0]

    if(lsNotUseInCount==null) lsNotUseInCount=[]
    if(hsLong==null)   hsLong=[:]
    if(hsInt==null)    hsInt=[:]
    if(hsString==null) hsString=[:]
    if(hsList==null)   hsList=[:]
    if(hsFilter==null)  hsFilter=[:]
    if(hsFilter.string_par==null)  hsFilter.string_par=[:]
    if(hsFilter.long_par==null)    hsFilter.long_par=[:]
    if(hsFilter.list_par==null)    hsFilter.list_par=[:]

    def sFrom=  ' FROM '+hsSql.from+(hsFilter.from?:'')
    def sWhere= ' WHERE '+hsSql.where+(hsFilter.where?:'')
    def sSelect=' SELECT '+hsSql.select+(hsFilter.select?:'')
    def sOrder= ' ORDER BY '+(hsFilter.order?:'')+hsSql.order
	//def sGroup= ((hsSql.group!=null)?' GROUP BY '+hsSql.group :'')
    def sGroup= ((hsSql.group!=null)?' GROUP BY '+(hsFilter.group?:'')+hsSql.group :'')
    
    if(hsFilter.string_par.size()!=0)  hsString+=hsFilter.string_par
    if(hsFilter.long_par.size()!=0)    hsLong+=hsFilter.long_par
    if(hsFilter.list_par.size()!=0)    hsList+=hsFilter.list_par
    // int todo...

    try{
      def qSql
      if(bComputeCount){
        qSql=session.createSQLQuery("SELECT count("+sCount+")"+sFrom+sWhere+sGroup)
	
        for(hsElem in hsLong){
          if(!(hsElem.key in lsNotUseInCount))
            qSql.setLong(hsElem.key,hsElem.value);
        }
        for(hsElem in hsInt){
          if(!(hsElem.key in lsNotUseInCount))
            qSql.setInteger(hsElem.key,hsElem.value);
        }
        for(hsElem in hsString){
          if(!(hsElem.key in lsNotUseInCount))
            qSql.setString(hsElem.key,hsElem.value);
        }
        for(hsElem in hsList){
          if(!(hsElem.key in lsNotUseInCount))
            qSql.setParameterList(hsElem.key,hsElem.value);
        }
        hsRes.records=qSql.list()		
        if(hsRes.records==null)
          hsRes.records=[]	  		  
        else if(hsRes.records.size()!=0){
          if((sCount==''||sCount=='*') && hsSql.group)
            hsRes.count=hsRes.records.size()
          else
            hsRes.count=hsRes.records[0]            
          hsRes.records=[]
        }		
      }
      //--------------------------------
      if((lsDictionaryIds!=null)&&(hsRes.count!=0)){
        for(sField in lsDictionaryIds){
          qSql=session.createSQLQuery("SELECT DISTINCT "+sField+" "+sFrom+sWhere+sGroup)

          for(hsElem in hsLong){
            if(!(hsElem.key in lsNotUseInCount))
              qSql.setLong(hsElem.key,hsElem.value);
          }
          for(hsElem in hsInt){
            if(!(hsElem.key in lsNotUseInCount))
              qSql.setInteger(hsElem.key,hsElem.value);
          }
          for(hsElem in hsString){
            if(!(hsElem.key in lsNotUseInCount))
              qSql.setString(hsElem.key,hsElem.value);
          }
          for(hsElem in hsList){
            if(!(hsElem.key in lsNotUseInCount))
              qSql.setParameterList(hsElem.key,hsElem.value);
          }
          hsRes[sField]=qSql.list()		 
        }
      }

      if((hsRes.count==0) && bComputeCount)
        hsRes.records=[]
      else{
        qSql=session.createSQLQuery(sSelect+sFrom+sWhere+sGroup+sOrder)      
        if(iMax>0)
          qSql.setMaxResults(iMax )
        qSql.setFirstResult(iOffset)
        for(hsElem in hsLong)
          qSql.setLong(hsElem.key,hsElem.value);
        for(hsElem in hsInt)
          qSql.setInteger(hsElem.key,hsElem.value);
        for(hsElem in hsString)
          qSql.setString(hsElem.key,hsElem.value);
        for(hsElem in hsList)
          qSql.setParameterList(hsElem.key,hsElem.value);
        qSql.addEntity(clClassName)		
        hsRes.records=qSql.list()		
        if(!bComputeCount)
          hsRes.count=hsRes.records?.size()
      }
    }catch (Exception e) {
      log.debug("Error fetchDataByPages\n"+e.toString()+"\n"+
                sSelect+"\n"+sFrom+"\n"+sWhere+"\n"+sGroup+"\n"+sOrder);
      hsRes.count=0
      hsRes.records=[]
    }  
    if (!isEager)
      session.clear()

    return hsRes
  }
  //////////////////////////////////////////////////////////////////////////
  def fetchData(hsSql,hsLong,hsInt,hsString,hsList,clClassName=null,iMax=-1){
    def session=sessionFactory.getCurrentSession()
    def hsRes=[]

    if(hsLong==null)   hsLong=[:]
    if(hsInt==null)    hsInt=[:]
    if(hsString==null) hsString=[:]
    if(hsList==null)   hsList=[:]

    def sSelect=' SELECT '+hsSql.select
    def sFrom=  ' FROM '+hsSql.from
    def sWhere= ((hsSql.where!=null)?' WHERE '+hsSql.where:'')
    def sOrder= ((hsSql.order!=null)?' ORDER BY '+hsSql.order:'')
    //hsSql.order= ' ORDER BY '+(hsFilter.order?:'')+(hsSql.order?:'')
    def sGroup= ((hsSql.group!=null)?' GROUP BY '+hsSql.group :'')
    
    try{
      def qSql
      qSql=session.createSQLQuery(sSelect+sFrom+sWhere+sGroup+sOrder)
      for(hsElem in hsLong)
        qSql.setLong(hsElem.key,hsElem.value);
      for(hsElem in hsInt)
        qSql.setInteger(hsElem.key,hsElem.value);
      for(hsElem in hsString)
        qSql.setString(hsElem.key,hsElem.value);
      for(hsElem in hsList)
        qSql.setParameterList(hsElem.key,hsElem.value);
      if(clClassName!=null)
        qSql.addEntity(clClassName)
      if(iMax>0)
        qSql.setMaxResults(iMax)     
      session.clear()  
      return qSql.list()
    }catch (Exception e) {
      log.debug("Error fetchData\n"+e.toString()+"\n"+
                sSelect+"\n"+sFrom+"\n"+sWhere+"\n"+sGroup+"\n"+sOrder);
      return []
    }
    return []
  }
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  def getLastInsert(){
    def sSql="select last_insert_id()"
    def session = sessionFactory.getCurrentSession()    
    try{
      def qSql=session.createSQLQuery(sSql)
      def lsRecords=qSql.list()
      if(lsRecords.size()>0){
        session.clear()
        return lsRecords[0].toLong()
      }
    }catch (Exception e) {
      log.debug("Error SearchService::getLastInsert\n"+e.toString());
    }
    session.clear()
    return 0
  }

  def getDistance(x1,y1,x2,y2){
    def sSql="select distance("+x1+","+y1+","+x2+","+y2+")"
    def session = sessionFactory.getCurrentSession()
    try{
      def qSql=session.createSQLQuery(sSql)
      def lsRecords=qSql.list()
      if(lsRecords.size()>0){
        //session.clear()
        return lsRecords[0].toDouble()
      }
    }catch (Exception e) {
      log.debug("Error SearchService::getDistance\n"+e.toString());
    }
    //session.clear()
    return 0
  }

  /////////////////////////////////////////////////////////////////////////////////////
  def findViewPortTile(aParam){
    def j=0;    
    def coordinates =[:]
    def aParamTmp=aParam.split(',')
    for(param in aParamTmp){
      def x1=-180000000;
      def x2=180000000;
      def y1=-85051128;
      def y2=85051128;   
    
      def y1cons=0;
      def y2cons=32;
      def yconsdel=0;
      def p1;
      def p2;
      def ydel;
    
      def consar=[-85051128,-83979259,-82676284,-81093213,-79171334,-76840816,-74019543,-70612614,-66513260,-61606396,-55776579,-48922499,-40979898,-31952162,-21943045,-11178401,0,11178401,21943045,31952162,40979898,48922499,55776579,61606396,66513260,70612614,74019543,76840816,79171334,81093213,82676284,83979259,85051128];
    
      def z=1;                     
    
      def L=param.length();
    
      def ZM=L;
      for(def i=0;i<L;++i) {        
        def test=param.getAt(i).toInteger();
      
        def xdel=Math.round((x1+x2)/2);        
        if(i<4){
          yconsdel=(y1cons+y2cons)/2;        
          ydel=consar[yconsdel.toInteger()];
        }else {
          ydel=Math.round((y1+y2)/2);
        }        
      
        switch(test) {
          case 0: p1=0; p2=1;break;
          case 1: p1=1; p2=1;break;
          case 2: p1=0; p2=0;break;
          case 3: p1=1; p2=0;break;
        }
        if(p1){ x1= xdel+1;
        }
        else{ x2= xdel;
        }
        if(p2){ y2= ydel; y2cons= yconsdel;
        }
        else  { y1= ydel+1; y1cons= yconsdel;
        }
      }    
      coordinates[j]=[]
      coordinates[j][0]=x1;
      coordinates[j][1]=y1;
      coordinates[j][2]=x2;
      coordinates[j][3]=y2;
      j++;
    }

    def minX=coordinates[0][0];
    def minY=coordinates[0][1];
    def maxX=coordinates[0][2];
    def maxY=coordinates[0][3];     

    for(def i=1;i<coordinates.size();i++){
      minX=(coordinates[i][0]>=minX)?minX:coordinates[i][0]
      minY=(coordinates[i][1]>=minY)?minY:coordinates[i][1]
      maxX=(coordinates[i][2]<=maxX)?maxX:coordinates[i][2]
      maxY=(coordinates[i][3]<=maxY)?maxY:coordinates[i][3]      
    }
    
    //def fincoord=[minX/10,minY/10,maxX/10,maxY/10] 
    def fincoord=[minX*10,minY*10,maxX*10,maxY*10]    
  //def fincoord=[minX,minY,maxX,maxY]
    return fincoord   
  }

}
