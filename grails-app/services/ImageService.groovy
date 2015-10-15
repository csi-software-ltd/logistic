class ImageService {

  boolean transactional = false
  static final THUMBPREFIX='t_'
  static scope = "request"

  def transient m_oController=null
  def transient m_sPathRes
  def transient m_bFolder
  
  /////////////////////////////////////////////////////////////////////////////////////////  
  private checkInit(){
    if(m_oController==null)
      log.debug("Does not set controller object in ImageService. Call imageService.init(this,....")
    return (m_oController==null)
  }
    
  /////////////////////////////////////////////////////////////////////////////////////////
  def init(oController,sPathRes,bFolder = false){ //!
    m_oController=oController
    m_sPathRes=sPathRes
    m_bFolder=bFolder

    if(m_sPathRes[-1]!=File.separatorChar)
      m_sPathRes+=File.separatorChar
  }
  /////////////////////////////////////////////////////////////////////////////////////////
  def rawUpload(sName) { //!
    def hsRes=[fileid:0,error:1] // 1 - UNSPECIFIC ERROR
    if(checkInit())
      return hsRes

    def fileImage
    try {
      fileImage= m_oController.request.getFile(sName)
    } catch (Exception e) {}

    if(!fileImage)
      return hsRes

    //RESERVED
    if(fileImage.originalFilename==null){
      hsRes.error = 2
      return hsRes
    }
    //CHECK CONTENT TYPE  //,"image/bmp","image/gif" - prohibited

    if(!(fileImage.getContentType() in ["image/pjpeg","image/jpeg","image/png","image/x-png","application/pdf"])){
      hsRes.error = 3
      return hsRes
    }

    try{
      hsRes.fileid = new Picture().updateData(fileImage)?.save(flush:true,failOnError:true)?.id?:0
      hsRes.error = 0
    } catch (Exception e) {
      log.debug("Cannot save picture\n"+e.toString())
    }

    return hsRes
  }
}