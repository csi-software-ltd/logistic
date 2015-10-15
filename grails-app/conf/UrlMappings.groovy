class UrlMappings {

	static mappings = {
		"/$controller/$action?/$id?"{
			constraints {
				// apply constraints here
			}
		}
		"/"(controller : "index", action:"index")
		"/administrators"(controller : "administrators", action:"index")
		"/user/registration"{
			controller = "user"
			action = "registration"
			registration = 1
		}
		"/carrier/instructiondetails/$id"(controller : "carrier", action:"instructiondetails")
		"/carrier/forward/$id"{
			controller = "carrier"
			action = "instructiondetails"
			forward = 1
		}
		"/monitoring/$id/$code"{
			controller = "index"
			action = "monitoringext"
			constraints {
				id(matches:/\d+/)
			}
		}
		"/scan/$id/$code"{
			controller = "index"
			action = "showpicture"
			constraints {
				id(matches:/\d+/)
			}
		}
		"/user/login"(controller : "user", action:"registration")
		"/robots.txt"(controller:'index',action:'robots')
    "/favicon.ico"(uri:"/favicon.ico")
		"404"(controller : "error", action:'page_404')
		"403"(controller : "error", action:'page_404')
		"500"(controller : "error", action:'page_500')
	}

}