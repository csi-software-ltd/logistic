import org.codehaus.groovy.grails.commons.ConfigurationHolder
class RawHtmlTagLib {

  def rawHtml = { attrs, body ->
    if (attrs.noline)
      out << body().replaceAll('\r\n','').decodeHTML()
    else
      out << body().decodeHTML()
  }

  def descrToHtml = { attrs, body ->
    out << ('<p>'+body().replaceAll('\r\n\r\n\r\n','</p><br/><br/><p>').replaceAll('\r\n\r\n','</p><br/><p>').replaceAll('\r\n','</p><p>')+'</p>').decodeHTML()
  }

  def userName = { attrs, body ->
    out << body().replace('.','·').replace('@','<img class="favicon" src="'+
        ConfigurationHolder.config.grails.serverURL+'/images/favicon.gif" border="0">')
  }
  
  def shortString = { attributes ->
    String text = attributes.text
    int length  = attributes.length ? Integer.parseInt(attributes.length) : 100
    
    if ( text ) {
      if ( text.length() < length )
        out << text.encodeAsHTML()
      else {
        text = text[0..length-1]
        /*if ( text.lastIndexOf('. ') != -1 )
          out << text[0 .. text.lastIndexOf('. ') ]
        else if ( text.lastIndexOf(' ') != -1 )
          out << text[0 .. text.lastIndexOf(' ')] << '&hellip;'
        else*/
          out << text << '&hellip;'
      }
    }
  }

  def datepicker = { attrs -> 
    String name = attrs.name
    String value = attrs.value   
    String result =''

    result = '<input id="'+name+'" name="'+name+'" value="'+value+'" '+(attrs.disabled=='true'?'disabled="disabled"':'')+(attrs.style?'style="'+attrs.style+'"':'')+'/>\n<script type="text/javascript">\nvar '+name+' = jQuery("#'+name+'").kendoDatePicker({\nculture: "ru-RU"'

    if(attrs.change=='1')
      result += ',\nchange: onChange_'+name
    else if(attrs.onchange)
      result += ',\nchange: function onchange() { '+attrs.onchange.replace('\'','"')+' }'
    if(attrs.max){
      def max = attrs.max.split('\\.')
      result += ',\nmax: new Date ('+max[2]+', '+(max[1].toInteger()-1)+', '+max[0]+')'
    }

    result += '\n});\n</script>'

    out << result
  }

  def intnumber = { attrs ->
    Long value = attrs.value

    out << formatNumber(number:value,format:"###,##0")
  }

}