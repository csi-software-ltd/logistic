<html>
  <head>
    <title>Административное приложение</title>
    <meta name="layout" content="admin" />
    <g:javascript>
      function returnToList(){
        $("returnToListForm").submit();
      }
      function processResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['name','shortname','length','width','hight','volume'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Название"])}</li>'; $("name").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Короткое название"])}</li>'; $("shortname").addClassName('red'); break;
              case 3: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Длина"])}</li>'; $("length").addClassName('red'); break;
              case 4: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Ширина"])}</li>'; $("width").addClassName('red'); break;
              case 5: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Высота"])}</li>'; $("hight").addClassName('red'); break;
              case 6: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Объем"])}</li>'; $("volume").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        } else {
          location.assign('${createLink(action:'containerdetail')}'+'/'+e.responseJSON.uId);
        }
      }
    </g:javascript>
    <style type="text/css">      
      .contact-form label{min-width:130px}            
    </style>
  </head>
  <body>
    <h1><g:if test="${container}">Контейнер типа ${container.name} (${container.shortname})</g:if>
    <g:else>Добавление нового типа контейнеров</g:else></h1>
    <a class="link fright" href="javascript:void(0)" onclick="returnToList();">К списку типов</a>
    <div class="clear"></div>
    <div class="error-box" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>
    </div>    
    <g:formRemote class="contact-form" name="containerDetailForm" url="[action:'saveContainerDetail', id:container?.id?:0]" method="post" onSuccess="processResponse(e)">      
      <fieldset>
        <div class="grid_6">
          <label for="name">Название типа:</label>
          <input type="text" id="name" name="name" value="${container?.name}" />
          <label for="name2">Название2:</label>
          <input type="text" id="name2" name="name2" value="${container?.name2}" />
          <label for="shortname">Короткое название:</label>
          <input type="text" id="shortname" name="shortname" value="${container?.shortname}" />
          <label for="ctype_id">Тип:</label>
          <g:select name="ctype_id" value="${container?.ctype_id}" from="${ctype}" optionKey="id" optionValue="name" />
          <label for="picture">Фото:</label>
          <input type="text" name="picture" value="${container?.picture}" />
          <label for="is_main">Приоритет:</label>
          <g:select name="is_main" value="${container?.is_main}" keys="${0..1}" from="${['не главный','главный']}" />
        </div>
        <div class="grid_6" style="margin:0">
          <label for="length">Длина:</label>
          <input type="text" id="length" name="length" value="${container?.length}" />
          <label for="width">Ширина:</label>
          <input type="text" id="width" name="width" value="${container?.width}" />
          <label for="height">Высота:</label>
          <input type="text" id="hight" name="hight" value="${container?.hight}" />
          <label for="volume">Объем:</label>
          <input type="text" id="volume" name="volume" value="${container?.volume}" />
          <label for="capacity">Грузоподъемность:</label>
          <input type="text" id="capacity" name="capacity" value="${container?.capacity}" />          
        </div>
      </fieldset>
      <div class="btns">
        <input type="submit" id="submit_button" class="button" value="Сохранить" />
        <input type="reset" class="button" value="Сброс" />
      </div>
    </g:formRemote>
    <g:form  id="returnToListForm" name="returnToListForm" url="${[action:'container']}">
    </g:form>
  </body>
</html>
