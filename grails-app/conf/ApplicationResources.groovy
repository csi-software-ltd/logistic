modules = {
  application {
      resource url:'js/application.js'
  }
  'prototype/prototype' {    
    dependsOn 'application'
      resource url:'js/prototype/prototype.js', disposition: 'head'
  }
  'prototype/effects' {
      resource url:'js/prototype/effects.js', disposition: 'head'
  }
  'prototype/controls' {
    dependsOn 'prototype/effects'
      resource url:'js/prototype/controls.js', disposition: 'head'
  }
  'prototype/autocomplete' {
      resource url:'js/prototype/autocomplete.js', disposition: 'head'
  }
  'prototype/scriptaculous' {
    dependsOn 'prototype/prototype'
    dependsOn 'prototype'
      resource url:'js/prototype/scriptaculous.js', disposition: 'head'
  }
  'jquery-1.10.1.min' {
    resource url:'js/jquery-1.10.1.min.js', disposition: 'head'
  }
  'superfish' {
    resource url:'js/superfish.js', disposition: 'head'
  }  
  'flashobject' {
    resource url:'js/flashobject.js', disposition: 'head'
  }
  'html5' {
    resource url:'js/html5.js', disposition: 'head'
  }  
  'kendo.culture.ru-RU.min' {
    dependsOn 'jquery-1.10.1.min'
    dependsOn 'kendo.web.min'
    resource url:'js/kendo.culture.ru-RU.min.js', disposition: 'head'
  }
  'kendo.web.min' {
    dependsOn 'jquery-1.10.1.min'
    resource url:'js/kendo.web.min.js', disposition: 'head'
  }
  'dropzone' {
    resource url:'js/dropzone.min.js', disposition: 'head'
  }
}