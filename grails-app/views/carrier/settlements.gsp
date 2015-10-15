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
  <body onload="\$('carrier_submit_button').click()">
    <h1>${infotext?.header?:''}</h1>
    <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
    <form class="contact-form" name="carrierForm" action="settlpdf" target="_blank">
      <fieldset>
        <label class="auto" for="trip_id">Поездка:</label>
        <input type="text" id="trip_id" name="trip_id" value="" class="mini"/>
        <label class="auto" for="contnumber">Контейнер:</label>
        <input type="text" class="mini" id="contnumber" name="contnumber" value="" />
        <label class="auto" for="driver_id">Водитель:</label>
        <g:select style="width:170px" name="driver_id" from="${Driver.findAllByClient_id(client.id)}" optionKey="id" optionValue="name" noSelection="${['0':'Любой']}"/>
        <label class="auto" for="year">Год:</label>
        <g:select class="auto" name="year" from="${2013..new Date().getYear()+1900}" value="${new Date().getYear()+1900}"/>
        <div class="btns fright">
          <input type="submit" class="button" value="Сверка"/>
          <g:submitToRemote id="carrier_submit_button" class="button" value="Показать" url="[action:'carriersettlements']" update="[success:'resultlist']" />
          <input type="reset" class="button" value="Сброс"/>
        </div>
      </fieldset>
    </form>
    <div id="resultlist"></div>
  </body>
</html>
