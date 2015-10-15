grails.project.groupId = appName // change this to alter the default package name and Maven publishing destination
grails.mime.file.extensions = true // enables the parsing of file extensions from URLs into the request format
grails.mime.use.accept.header = false
grails.mime.types = [
    all:           '*/*',
    atom:          'application/atom+xml',
    css:           'text/css',
    csv:           'text/csv',
    form:          'application/x-www-form-urlencoded',
    html:          ['text/html','application/xhtml+xml'],
    js:            'text/javascript',
    json:          ['application/json', 'text/json'],
    multipartForm: 'multipart/form-data',
    rss:           'application/rss+xml',
    text:          'text/plain',
    xml:           ['text/xml', 'application/xml']
]

// URL Mapping Cache Max Size, defaults to 5000
//grails.urlmapping.cache.maxsize = 1000

// What URL patterns should be processed by the resources plugin
grails.resources.adhoc.patterns = ['/images/*', '/css/*', '/js/*', '/plugins/*']

// The default codec used to encode data with ${}
grails.views.default.codec = "html" // none, html, base64
grails.views.gsp.encoding = "UTF-8"
grails.converters.encoding = "UTF-8"
grails.views.javascript.library = "prototype"
// enable Sitemesh preprocessing of GSP pages
//grails.views.gsp.sitemesh.preprocess = true
// scaffolding templates configuration
//grails.scaffolding.templates.domainSuffix = 'Instance'

// Set to false to use the new Grails 1.2 JSONBuilder in the render method
//grails.json.legacy.builder = false
// enabled native2ascii conversion of i18n properties files
grails.enable.native2ascii = true
// packages to include in Spring bean scanning
grails.spring.bean.packages = []
// whether to disable processing of multi part requests
//grails.web.disable.multipart=false

// request parameters to mask when logging exceptions
//grails.exceptionresolver.params.exclude = ['password']

// configure auto-caching of queries by default (if false you can cache individual queries with 'cache: true')
//grails.hibernate.cache.queries = false
grails.config.locations = [ "classpath:${appName}-config.properties"]
grails.resources.adhoc.patterns = ['/images/*', '/css/*', '/js/*', '/plugins/*']
grails.resources.adhoc.excludes = ['/plugins/fckeditor-0.9.5/js/fckeditor/editor/**']

grails {
   mail {     
     props = ["mail.smtp.auth":"true", 					   
              "mail.smtp.socketFactory.port":"465",
              "mail.smtp.socketFactory.class":"javax.net.ssl.SSLSocketFactory",
              "mail.smtp.socketFactory.fallback":"false"]
   }
}

/*
environments {
    development {
        grails.logging.jul.usebridge = true
    }
    production {
        grails.logging.jul.usebridge = false
        // TODO: grails.serverURL = "http://www.changeme.com"
    }
}
*/
import org.apache.log4j.DailyRollingFileAppender
// log4j configuration
log4j = {
  appenders {
    appender new DailyRollingFileAppender(
        name:"file", 
        datePattern:"'.'yyyy-MM-dd", 
        layout:pattern(conversionPattern:'%d [%p] {%c{2}} %m%n'),    
        file:"${logger.file}"); 
    appender new DailyRollingFileAppender(
        name:"stacktraceLog", 
        datePattern:"'.'yyyy-MM-dd", 
        layout:pattern(conversionPattern:'%d [%p] {%c{2}} %m%n'),
        file:"${logger.stack}"); 		
    appender new org.apache.log4j.jdbc.JDBCAppender(
        name:"DB",   
        URL:"${dataSource.url}",
        driver:"com.mysql.jdbc.Driver",
        user:"${dataSource.username}",
        password:"${dataSource.password}",
        sql:"INSERT INTO log (inputdate,level,message) VALUES('%d{yyyy.MM.dd HH:mm:ss}','%p','%m')"
    );
    console name:"logger", layout:pattern(conversionPattern: "%d [%t] %-5p %c(%l)  - %m%n")
  }
  root {  
      error 'stdout', 'file', 'DB'
      additivity = true
    }  
   error   'org.codehaus.groovy.grails.web.servlet',  //  controllers
      'org.codehaus.groovy.grails.web.pages', //  GSP
      'org.hibernate',
      'grails.app.services.org.grails.plugin.resource',
      'grails.app.taglib.org.grails.plugin.resource',
      'grails.app.resourceMappers.org.grails.plugin.resource',
      'grails.app.services.NavigationService',
      'grails.app.services.grails.plugin.rendering.document',
      'grails.app.resourceMappers.org.grails.plugin.cachedresources',
      'grails.app.resourceMappers.org.grails.plugin.zippedresources'
    error stacktraceLog:"StackTrace"
    warn 'org.mortbay.log'
    error 'grails.plugin'
    debug 'grails.app'
    //  trace "${logger.hibernatelevel}"  
    debug logger:"com.linkedin.grails" 
}

/* upgrade comment FROM >>>>>>>>>>>>>>>> */
import java.awt.Font
import java.awt.Color

import com.octo.captcha.service.multitype.GenericManageableCaptchaService
import com.octo.captcha.engine.GenericCaptchaEngine
import com.octo.captcha.image.gimpy.GimpyFactory
import com.octo.captcha.component.word.wordgenerator.RandomWordGenerator
import com.octo.captcha.component.image.wordtoimage.ComposedWordToImage
import com.octo.captcha.component.image.fontgenerator.RandomFontGenerator
import com.octo.captcha.component.image.backgroundgenerator.GradientBackgroundGenerator
import com.octo.captcha.component.image.color.SingleColorGenerator
import com.octo.captcha.component.image.textpaster.NonLinearTextPaster

jcaptchas {
  image = new GenericManageableCaptchaService(
      new GenericCaptchaEngine(
          new GimpyFactory(
              new RandomWordGenerator(
                  "abcdefghjkmnpqrstuvwxyz0123456789"
                  //"0123456789"
              ),
              new ComposedWordToImage(
                  new RandomFontGenerator(
                      20, // min font size
                      30, // max font size
                      [new Font("Arial", 0, 10)] as Font[]
                  ),
                  new GradientBackgroundGenerator(
                      150, // width
                      50, // height
                      new SingleColorGenerator(new Color(246, 246, 246)),
                      new SingleColorGenerator(new Color(246, 246, 246))
                  ),
                  new NonLinearTextPaster(
                      6, // minimal length of text
                      6, // maximal length of text
                      new Color(0,0,0)
                  )))),
     180, // minGuarantedStorageDelayInSeconds
     180000 // maxCaptchaStoreSize
   )
}
/* upgrade comment TO <<<<<<<<<<<<<<< */
/*
compress {
    // just in case for some reason you want to disable the filter
    enabled = true
    debug = false
    statsEnabled = true
    compressionThreshold = 1024
    // filter's url-patterns
    urlPatterns = ["/*"]
    // include and exclude are mutually exclusive
    includePathPatterns = []
    excludePathPatterns = [".*\\.gif", ".*\\.ico", ".*\\.jpg", ".*\\.swf"]
    // include and exclude are mutually exclusive
    includeContentTypes = []
    excludeContentTypes = ["image/png"]
    // include and exclude are mutually exclusive
    includeUserAgentPatterns = []
    excludeUserAgentPatterns = [".*MSIE 4.*"]
    // probably don't want these, but their available if needed
    javaUtilLogger = ""
    jakartaCommonsLogger = ""

    development {
        debug = true
        compressionThreshold = 2048
    }
    production {
        statsEnabled = false
    }
}*/

fckeditor { 
	upload {//in properties file>>
		basedir = 
		baseurl = 
		overwrite = false
		
		image {
			browser = true
			upload = true
			allowed = ['jpg', 'gif', 'jpeg', 'png'] 
			denied = []
		}		
	}
}
