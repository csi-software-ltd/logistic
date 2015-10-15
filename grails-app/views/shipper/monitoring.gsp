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
      function initialize(iParam){
        switch(iParam){
          case 0:
            sectionSelected('trip');
            $('tripForm').show();
            $('tripeventForm').hide();
            $('trip_submit_button').click();
            break;
          case 1:
            sectionSelected('tripevent');
            $('tripForm').hide();
            $('tripeventForm').show();
            $('tripevent_submit_button').click();
            break;
        }
      }
      function sectionSelected(sSection){
        $('trip').up('li').removeClassName('selected');
        $('tripevent').up('li').removeClassName('selected');
        $(sSection).up('li').addClassName('selected');
      }
    </g:javascript>    
  </head>
  <body onload="initialize(${type})">
    <h1>${infotext?.header?:''}</h1>    
    <div class="clear"></div>
    <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
    <g:formRemote class="contact-form" name="tripForm" url="[action:'triplist']" update="[success:'resultlist']" onLoading="\$('loader').show()" onLoaded="\$('loader').hide()">
      <fieldset>
        <label for="trip_modstatus" class="auto">Статус:</label>
        <g:select name="trip_modstatus" class="auto nopad" value="${inrequest?.trip_modstatus}" from="${tripstatus}" optionKey="id" optionValue="status" noSelection="${['-100':'Все']}"/>
        <label for="container" class="auto">Контейнер:</label>
        <input type="text" id="container" name="container" class="mini nopad" value="${inrequest?.container}"/>
        <label for="trip_id" class="auto">Код:</label>
        <input type="text" id="trip_id" name="trip_id" class="mini nopad" value="${inrequest?.trip_id}"/>
        <label for="zakaz_id" class="auto">Заказ:</label>
        <input type="text" id="zakaz_id" name="zakaz_id" class="mini nopad" value="${inrequest?.zakaz_id}"/>        
        <input type="submit" class="button" id="trip_submit_button" value="Найти" style="margin-left:10px"/>        
        <img src="${resource(dir:'images',file:'loader.gif')}" alt="" id="loader" style="display:none" />
      </fieldset>
    </g:formRemote>
    <g:formRemote class="contact-form" name="tripeventForm" url="[action:'eventlist']" update="[success:'resultlist']" onLoading="\$('loader2').show()" onLoaded="\$('loader2').hide()" style="display:none">
      <fieldset>
        <label for="trip_id" class="auto">Код:</label>
        <input type="text" id="trip_id" name="trip_id" class="mini nopad" value="${inrequest?.trip_id}"/>
        <label for="trip_modstatus" class="auto">Статус поездки:</label>
        <g:select name="trip_modstatus" class="auto nopad" value="${inrequest?.trip_modstatus}" from="${tripstatus}" optionKey="id" optionValue="status" noSelection="${['-100':'Все']}"/>
        <label for="eventtype" class="auto">Тип события:</label>
        <g:select name="eventtype" class="auto nopad" optionKey="id" optionValue="name" from="${tripeventtype}" noSelection="${['-100':'все']}" value="${inrequest?.eventtype}"/>
        <input type="submit" class="button" id="tripevent_submit_button" value="Найти" style="margin-left:10px"/>
        <img src="${resource(dir:'images',file:'loader.gif')}" alt="" id="loader2" style="display:none" />
      </fieldset>
    </g:formRemote>
    <div id="resultlist">
    </div>
  </body>
</html>
