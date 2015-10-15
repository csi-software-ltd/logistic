class MirrorsFilters {

    def filters = {
        all(controller:'*', action:'*') {
            before = {
                if(!request.getRequestURL().toString().startsWith(grailsApplication.config.grails.serverURL.trim())) {
                    redirect(controller: controllerName, action: actionName, params:params, absolute:true, permanent:true)
                    return false
                }
            }
            after = { Map model ->

            }
            afterView = { Exception e ->

            }
        }
    }
}