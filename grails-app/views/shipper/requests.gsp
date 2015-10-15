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
  <body onload="\$('requests_submit_button').click()">
    <h1>${infotext?.header?:''}</h1>
    <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
    <g:formRemote class="contact-form" name="requestForm" url="[action:'requestlist']" update="[success:'resultlist']" onLoading="\$('loader').show()" onLoaded="\$('loader').hide()">
      <fieldset>
        <label for="trip_modstatus" class="auto">Статус поездки:</label>
        <g:select name="trip_modstatus" class="auto nopad" value="${inrequest?.trip_modstatus}" from="${tripstatus}" optionKey="id" optionValue="status" noSelection="${['-100':'Все']}"/>
        <label for="trip_taskstatus" class="auto">Статус сдачи:</label>
        <g:select name="trip_taskstatus" class="auto nopad" value="${inrequest?.trip_taskstatus}" from="${taskstatus}" optionKey="id" optionValue="status" noSelection="${['-100':'Все']}"/>
        <label for="trip_id" class="auto">Код:</label>
        <input type="text" id="trip_id" name="trip_id" style="width:50px" class="nopad" value="${inrequest?.trip_id}"/>
        <label for="zakaz_id" class="auto">Заказ:</label>
        <input type="text" id="zakaz_id" name="zakaz_id" style="width:50px" class="nopad" value="${inrequest?.zakaz_id}"/>        
        <input type="submit" class="button" id="requests_submit_button" value="Найти" style="margin-left:10px"/>
        <img src="${resource(dir:'images',file:'loader.gif')}" alt="" id="loader" style="display:none" />
      </fieldset>
    </g:formRemote>
    <div id="resultlist">
    </div>
  </body>
</html>
