<html>
  <head>
    <title>Административное приложение</title>
    <meta name="layout" content="admin" />
    <g:javascript>
      function resetData(){
        $('zakaz_id').value='';
        $('shipper').value='';
        $('unloading').value='';
        $('modstatus').selectedIndex=0;
      }
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
  <body onload="\$('zakaz_submit_button').click();">
    <div class="menu admin">
      <g:formRemote class="contact-form nopad" name="allForm" url="[action:'zakazlist']" update="[success:'zakazlist']">
        <fieldset>
          <label for="zakaz_id" class="auto">Код:</label>
          <input type="text" id="zakaz_id" name="zakaz_id" class="mini" value="${inrequest?.zakaz_id}"/>
          <label for="shipper" class="auto">Отправитель:</label>
          <input type="text" id="shipper" name="shipper" class="mini" value="${inrequest?.shipper}"/>
          <label for="modstatus" class="auto">Статус:</label>
          <g:select name="modstatus" value="${inrequest?.modstatus}" from="${zakazstatus}" optionKey="id" optionValue="modstatus" noSelection="${['-100':'все']}" class="auto"/>
          <label for="unloading" class="auto">Выгрузка:</label>
          <input type="text" id="unloading" name="unloading" class="mini" value="${inrequest?.unloading}"/>
          <div class="btns">
            <input type="submit" class="button" id="zakaz_submit_button" value="Показать" />
            <input type="button" class="button" value="Сброс" onclick="resetData()"/>          
            <g:link action="orderdetail" class="button">Добавить новый</g:link>
          </div>
        </fieldset>
      </g:formRemote>
    </div>
    <div id="zakazlist"></div>
  </body>
</html>
