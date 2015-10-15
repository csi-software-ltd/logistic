class TermFilters {

    def filters = {
        all(controller: 'administrators|user|jcaptcha|error|mobile', action:'carrierterms', invert: true) {
            before = {

            }
            after = { Map model ->
                if (actionName!='carrierterms'&&!session.admin&&model?.user) {
                    if (model.user.type_id==2&&!model.user.is_termconfirm)
                        redirect(controller: 'index', action: 'carrierterms')
                }
            }
            afterView = { Exception e ->

            }
        }
    }
}