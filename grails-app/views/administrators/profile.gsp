<html>
  <head>
    <title>Административное приложение</title>
    <meta name="layout" content="admin" />
    <g:javascript>
      function initialize(){	  
      <g:if test="${temp_notification!=null}">
        alert('${temp_notification?.text}');	  
      </g:if>      	  
      }
      function processResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['margin'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Наценка"])}</li>'; $("margin").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        } else {
          location.reload(true);
        }
      }
      function processProfileResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['tel','email'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {             
              case 1: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Телефон"])}</li>'; $("tel").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Email"])}</li>'; $("email").addClassName('red'); break;
            }
          });
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        } else {
          location.reload(true);
        }
      }
    </g:javascript>
    <style type="text/css">
      .contact-form label{margin:0}      
    </style>
  </head>  
  <body onload="initialize()">
    <h1 class="padding-bottom2">Профиль пользователя</h1>
    <div class="error-box" style="${!flash?.error?'display:none':''}">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <g:if test="${flash?.error==1}"><li>Вы не заполнили обязательное поле &laquo;Новый пароль&raquo;</li></g:if>
        <g:if test="${flash?.error==2}"><li>Пароли не совпадают</li></g:if>
        <g:if test="${flash?.error==3}"><li>Слишком короткий пароль</li></g:if>
      </ul>
    </div>
  <g:if test="${admin?.menu?.find{it.id==15}}">
    <g:formRemote name="autopilotForm" class="contact-form" url="[controller:'administrators',action:'autopilot']" onSuccess="processResponse(e)">
      <fieldset>
        <div class="grid_5">
          <label>Автопилот:</label>
          <g:select name="is_on" from="${['Отключен','Включен']}" value="${admin.menu.find{it.id==15}.is_on}" keys="${0..1}"/>
        </div>
        <div class="grid_5">
          <label>Наценка:</label>
          <input type="text" id="margin" name="margin" value="${admin.menu.find{it.id==15}.margin}" />
        </div>
        <div class="grid_2">
          <div class="btns">
            <input type="submit" class="button" style="width:127px" value="Сохранить" />
          </div>    
        </div>
      </fieldset>
    </g:formRemote>
    <hr class="admin" />
  </g:if>
    <g:formRemote class="contact-form" name="profile" url="[controller:'administrators',action:'profilesave']" method="post" onSuccess="processProfileResponse(e)">
      <fieldset>
        <div class="grid_5">
          <label>Логин:</label>
          <input type="text" readonly value="${admin?.login}" /><br/>
          <label for="name">Имя:</label>
          <input type="text" name="name" value="${administrator?.name}" />
        </div>
        <div class="grid_5">
          <label>Группа:</label>
          <input type="text" readonly value="${groupname}" />
          <br/>
          <label for="email">Email:</label>
          <input type="text" id="email" name="email" value="${administrator?.email }" />
          <label for="email">Телефон:</label>
          <input type="text" id="tel" name="tel" value="${administrator?.tel }" />
        </div>
        <div class="grid_2 pad-top">
          <div class="btns">
            <input type="submit" class="button" value="Изменить профиль" />
          </div>    
        </div>
      </fieldset>
    </g:formRemote>
    <hr class="admin" />
    <g:form class="contact-form" url="[controller:'administrators',action:'changepass']" method="post">
      <fieldset>
        <div class="grid_5">
          <label for="pass">Новый пароль:</label>
          <input type="password" name="pass" <g:if test="${flash?.error in [1,2,3]}">class="red"</g:if> />
        </div>
        <div class="grid_5">
          <label for="confirm_pass">Повторить:</label>
          <input type="password" name="confirm_pass" <g:if test="${flash?.error==2}">class="red"</g:if> />
        </div>
        <div class="grid_2">
          <div class="btns">
            <input type="submit" class="button" style="width:127px" value="Изменить пароль" />
          </div>
        </div>
      </fieldset>
      <hr class="admin" />
      <small><i>
        Последний вход пользователя: <b>${(lastlog?.logtime!=null)?String.format('%td.%<tm.%<tY %<tH:%<tM',lastlog?.logtime):''}</b> с IP адреса <b>${lastlog?.ip}</b>
      <g:if test="${(unsuccess_log_amount)&&(unsuccess_log_amount > unsucess_limit)}">
        <br/><font color="red">Неуспешных попыток доступа за последние 7 дней: <b>${unsuccess_log_amount}</b></font>
      </g:if>
      </i></small>
    </g:form>  
  </body>
</html>
