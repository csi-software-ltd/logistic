<html>
  <head>
    <title>${infotext?.title?:''}</title>
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />
    <meta name="layout" content="main" />
    <g:javascript>
      function clickPaginate(event){
        event.stop();
        var link = event.element();
        if(link.href == null){
          return;
        }
        new Ajax.Updater(
          { success: $('ajax_wrap') },
          link.href,
          { evalScripts: true });
      }
    </g:javascript>
  </head>
  <body onload="\$('settl_submit_button').click()">
    <h1 class="h4-bot1">${infotext?.header?:''}</h1><g:link class="button" action="orderxls" target="_blank" style="float:right;margin-top:-35px">Экспорт в Excel</g:link>
    <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
    <g:formRemote name="settlForm" url="[action:'settllist']" update="[success:'settllist']" onLoading="\$('loader').show()" onLoaded="\$('loader').hide()">
      <input type="submit" class="button" id="settl_submit_button" value="Найти" style="display:none"/>
      <img src="${resource(dir:'images',file:'loader.gif')}" alt="" id="loader" style="display:none" />
    </g:formRemote>
    <div id="settllist"></div>
  </body>
</html>