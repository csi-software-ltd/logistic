class ErrorController {
  def requestService

  def page_404 = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)

    return hsRes
  }

  def page_500 = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)

    return hsRes
  }

}