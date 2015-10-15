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
      function declineOffer(lId){
        if (confirm('Отклонить предложение?'))
          <g:remoteFunction action="offerdecline" params="'id='+lId" class="button" title="Отказать" onSuccess="\$('offers_submit_button').click()"><i class="icon-remove"></i></g:remoteFunction>
      }
    </g:javascript>    
  </head>
  <body onload="\$('offers_submit_button').click()">
    <h1 class="fleft">${infotext?.header?:''}</h1>    
    <g:formRemote name="offersForm" url="[action:'offerlist']" update="[success:'offerlist']" onLoading="\$('loader').show()" onLoaded="\$('loader').hide()">
      <input type="submit" class="button" id="offers_submit_button" value="Найти" style="display:none"/>
      <img src="${resource(dir:'images',file:'loader.gif')}" alt="" id="loader" style="display:none" />      
    </g:formRemote>
    <div class="clear"></div>
    <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
    <div id="offerlist">
    </div>
  </body>
</html>
