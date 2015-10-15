class Adminmenu {
  def searchService

  static constraints = {
  }

  static mapping = {
    version false
  }

  Integer id
  String name
  Integer is_on
  Integer margin

  def csiGetMenu(iGroupId){
    def oAdmingroup = Admingroup.get(iGroupId)
    def lsMenuItemIds = oAdmingroup.menu.tokenize(',')
    def hsSql = [select :'*',
                 from   :'adminmenu',
                 where  :'id in (:ids)',
                 order  :'id']
    def hsList = [ids:lsMenuItemIds]
    return searchService.fetchData(hsSql,null,null,null,hsList,Adminmenu.class)
  }

  Adminmenu setAutopilotData(_request){
    is_on = _request.is_on==2?++is_on%2:_request.is_on?:0
    margin = _request.margin?:margin
    this
  }

}