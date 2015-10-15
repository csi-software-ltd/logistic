<html>
  <head>
    <title>Административное приложение</title>
    <meta name="layout" content="admin" />
    <g:javascript>
      function resetData(){
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
  <body onload="\$('route_submit_button').click();">
    <div class="menu admin">
      <g:formRemote class="contact-form nopad" name="allForm" url="[action:'routelist']" update="[success:'routelist']">
        <fieldset>
          <label for="modstatus" class="auto">Статус:</label>
          <g:select name="modstatus" value="${inrequest?.modstatus}" keys="${0..1}" from="${['неактивные','активные']}" noSelection="${['-100':'все']}" class="auto"/>
          <div class="btns">
            <input type="submit" class="button" id="route_submit_button" value="Показать" />
            <input type="button" class="button" value="Сброс" onclick="resetData()"/>
            <g:link action="routedetail" class="button">Добавить новый</g:link>
          </div>
        </fieldset>
      </g:formRemote>
    </div>
    <div id="routelist"></div>
  </body>
</html>
