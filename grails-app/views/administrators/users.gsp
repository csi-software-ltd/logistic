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
      function setBan(iId,banned){
        <g:remoteFunction controller='administrators' action='banned' onSuccess="\$('user_submit_button').click();" params="'id='+iId+'&banned='+banned" />
      }
      function loginAsUser(iId){
        <g:remoteFunction controller='administrators' action='loginAsUser' onSuccess='processResponse(e)' params="'id='+iId" />
      }
      function processResponse(e){
        window.open('${createLink(controller:"carrier",action:"profile")}');
      }
    </g:javascript>
    <style type="text/css">
      .contact-form input[type="text"],.contact-form select{width:220px}
      .contact-form input.mini{width:60px}            
    </style>    
  </head>
  <body onload="\$('user_submit_button').click();">
    <div class="menu admin">    
      <g:formRemote class="contact-form nopad" name="allForm" url="[action:'userlist']" update="[success:'userlist']">
        <fieldset>
          <label class="auto" for="user_id">Код:</label>
          <input type="text" class="mini" name="user_id" />
          <label class="auto" for="client_id">Код клиента:</label>
          <input type="text" class="mini" name="client_id" />
          <label class="auto" for="name">Имя:</label>
          <input type="text" name="name" />
          <label class="auto" for="email">Email:</label>
          <input type="text" name="email" /><br/>
          <label class="auto" for="company">Компания:</label>
          <input type="text" name="company" />
          <label class="auto" for="modstatus">Cтатус:</label>
          <select name="modstatus">
            <option value="0">неподтвержден</option>
            <option value="1">активен</option>
            <option value="-1">забанен</option>
            <option value="-2">все</option>
          </select>
          <label class="auto" for="type_id">Тип пользователя:</label>
          <select class="auto" name="type_id">
            <option value="0">все</option>
            <option value="1">грузоотправитель</option>
            <option value="2">перевозчик</option>
            <option value="3">менеджер</option>
          </select>
          <div class="btns">
            <input type="submit" class="button" id="user_submit_button" value="Показать">        
            <input type="reset" class="button" value="Сброс" />
            <g:link action="userdetail" class="button">Добавить нового</g:link>
          </div>
        </fieldset>   
      </g:formRemote>
    </div>
    <div id="userlist"></div>
  </body>
</html>
