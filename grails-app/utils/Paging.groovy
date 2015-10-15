import org.codehaus.groovy.grails.commons.ConfigurationHolder

class Paging  {
  def static computeNavigation(iFrom,iNumberOfRecords,iNumberOfRecordsPerPage,iNumberOfPagePerList){
    def hsRes=[:]
    if((iFrom==0)||(iFrom>iNumberOfRecords))
    iFrom=1;
    
    def iNumRec=iNumberOfRecordsPerPage;//?? for what?
    if(iFrom+iNumRec-1>iNumberOfRecords)
    iNumRec=iNumberOfRecords-iFrom+1;
    def iCurrentRecord=iNumberOfRecordsPerPage+iFrom-1;
    if(iCurrentRecord>iNumberOfRecords)
    iCurrentRecord=iNumberOfRecords;
    //-------------------------------------
    def iWholePages  =Math.floor((iNumberOfRecords-1) / iNumberOfRecordsPerPage) + 1;
    def iCurrentPage =Math.floor((iCurrentRecord - 1) / iNumberOfRecordsPerPage) + 1;
    def iFirstPageInList = Math.floor((iCurrentPage - 1) / iNumberOfPagePerList) * iNumberOfPagePerList + 1;
    def iLastPageInList = iFirstPageInList + iNumberOfPagePerList - 1;
    if (iLastPageInList > iWholePages)
    iLastPageInList = iWholePages;
    
    hsRes['offset']=iFrom-1;
    hsRes['from']=iFrom;
    hsRes['to']=hsRes['offset']+iNumberOfRecordsPerPage;
    if(hsRes['to']>iNumberOfRecords)
    hsRes['to']=iNumberOfRecords;
    // echo(hsRes['offset'].' ');
    hsRes['numrec']=iNumRec; //-- ???
    hsRes['all']=iNumberOfRecords; //-- ???
    hsRes['exists']=(iNumberOfRecords>iNumberOfRecordsPerPage);
    hsRes['page_no']=iCurrentPage;
    hsRes['col_num']=0;
    
    if(hsRes['exists'])
    {
      hsRes['prev_set']=  (iFirstPageInList > iNumberOfPagePerList)?
      ((iFirstPageInList - iNumberOfPagePerList-1)*
      iNumberOfRecordsPerPage+1):
      -1;
      hsRes['next_set']=  (iLastPageInList < iWholePages)?
      (iLastPageInList)*iNumberOfRecordsPerPage+1:
      -1;
      hsRes['prev_page']=(iCurrentPage >1)?
      (iCurrentPage-2)*iNumberOfRecordsPerPage+1:
      -1;
      hsRes['next_page']= (iCurrentPage < iWholePages )?
      ((iCurrentPage)*iNumberOfRecordsPerPage+1):
      -1;
      
      if(hsRes['prev_set']>0) hsRes['col_num']++;
      if(hsRes['next_set']>0) hsRes['col_num']++;
      if(hsRes['prev_page']>0) hsRes['col_num']++;
      if(hsRes['next_page']>0) hsRes['col_num']++;
      
      hsRes['go']=[];
      hsRes['show']=[];
      def i=0;
      def iPno=iFirstPageInList;
      while(iPno <= iLastPageInList){       
        hsRes['show'][i]=iPno;
        if(iPno == iCurrentPage)
        hsRes['go'][i]=0;
        else if(iPno > iLastPageInList)
        hsRes['go'][i]=-1;
        else
        hsRes['go'][i]=((iPno-1)*iNumberOfRecordsPerPage+1);
        iPno++;
        i++;
      }
    }
    return hsRes;
  }    
}

