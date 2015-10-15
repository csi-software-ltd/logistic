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
  <body onload="\$('container_submit_button').click();">
    <div class="menu admin">
      <g:formRemote class="contact-form nopad" name="allForm" url="[action:'containerlist']" update="[success:'containerlist']">
        <fieldset>
          <label class="auto" for="name">Название:</label>
          <input type="text" name="name" />
          <label class="auto" for="ctype_id">Тип контейнера:</label>
          <select class="auto" name="ctype_id">
            <option value="0">все</option>
          <g:each in="${ctype}">
            <option value="${it.id}">${it.name}</option>
          </g:each>
          </select>
          <label class="auto" for="is_main">Главный:</label>
          <g:select name="is_main" value="${container?.is_main}" keys="${-1..1}" from="${['все','не главный','главный']}" />
          <div class="btns">
            <input type="submit" class="button" id="container_submit_button" value="Показать" />
            <input type="reset" class="button" value="Сброс" />          
            <g:link action="containerdetail" class="button">Добавить новый</g:link>
          </div>
        </fieldset>
      </g:formRemote>
    </div>
    <div id="containerlist"></div>
  </body>
</html>
