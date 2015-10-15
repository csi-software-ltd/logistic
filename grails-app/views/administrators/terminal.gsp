<html>
  <head>
    <title>Административное приложение</title>
    <meta name="layout" content="admin" />
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
  <body onload="\$('form_submit_button').click();">
    <div class="menu admin">
      <g:formRemote class="contact-form nopad" name="allForm" url="[action:'terminallist']" update="[success:'terminallist']">
        <fieldset>
          <label class="auto" for="terminal_id">Код терминала:</label>
          <input type="text" class="mini" name="terminal_id">
          <label class="auto" for="name">Название:</label>
          <input type="text" name="name">
          <label class="auto" for="is_main">Главный:</label>
          <g:select name="is_main" value="${container?.is_main}" keys="${-1..1}" from="${['все','не главный','главный']}" />
          <div class="btns">
            <input type="submit" class="button" id="form_submit_button" value="Показать" />
            <input type="reset" class="button" value="Сброс" />
            <g:link action="terminaldetail" class="button">Добавить новый</g:link>
          </div>
        </fieldset>
      </g:formRemote>
    </div>
    <div id="terminallist"></div>
  </body>
</html>
