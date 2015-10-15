<html>
  <head>
    <title>Административное приложение containerovoz.ru</title>
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
      function readmessage(lId){
        if(confirm('Вы подтверждаете прочтение?'))
          <g:remoteFunction action='readmessage' onSuccess="\$('guestbook_submit_button').click()" params="'id='+lId" />
      }
      function deletemessage(lId){
        if(confirm('Точно удалить?'))
          <g:remoteFunction action='deletemessage' onSuccess="\$('guestbook_submit_button').click()" params="'id='+lId" />
      }
    </g:javascript>
    <style type="text/css">
      .contact-form select{width:180px}
    </style>
  </head>
	<body onload="\$('guestbook_submit_button').click()">
    <div class="menu admin">
      <div id="tripfilter">
        <g:formRemote class="contact-form nopad" name="requestsForm" url="[action:'guestbooklist']" update="[success:'resultlist']">
          <fieldset>
            <label for="status" class="auto">Статус:</label>
            <g:select name="status" class="auto nopad" keys="${0..1}" from="${['Непрочитанные', 'Прочитанные']}"/>
            <input type="submit" class="button" id="guestbook_submit_button" value="Показать" />
          </fieldset>
        </g:formRemote>
      </div>
    </div>
    <div id="resultlist"></div>
  </body>
</html>
