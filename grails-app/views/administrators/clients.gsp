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
      function unblock(iId){
        <g:remoteFunction controller='administrators' action='unblockclient' onSuccess="\$('form_submit_button').click();" params="'id='+iId" />
      }
    </g:javascript>
  </head>
  <body onload="\$('form_submit_button').click();">
    <div class="menu admin"> 
      <g:formRemote class="contact-form nopad" name="allForm" url="[action:'clientlist']" update="[success:'clientlist']">
        <fieldset>
          <label class="auto" for="client_id">Код:</label>
          <input type="text" class="mini" name="client_id" />
          <label class="auto" for="name">Email:</label>
          <input type="text" name="name" />
          <label class="auto" for="fullname">Название:</label>
          <input type="text" name="fullname"><br/>
          <label class="auto" for="tel">Телефон:</label>
          <input type="text" class="mini" name="tel">
          <label class="auto" for="type_id">Тип:</label>
          <g:select class="auto" name="type_id" value="" keys="${0..3}" from="${['все','грузоотправитель','грузоперевозчик','менеджер']}"/>
          <label class="auto" for="modstatus">Статус:</label>
          <g:select class="auto" name="modstatus" value="" keys="${-2..1}" from="${['все','неактивный','новый','активный']}"/>
          <label for="isblocked">Blocked:</label>
          <input type="checkbox" class="nopad auto" name="isblocked" value="1"/>
          <div class="btns fright">
            <input type="submit" class="button" id="form_submit_button" value="Показать" />
            <input type="reset" class="button" value="Сброс" />
            <g:link action="clientdetail" class="button">Добавить нового</g:link>
          </div>
        </fieldset>
      </g:formRemote>
    </div>
    <div id="clientlist"></div>
  </body>
</html>
