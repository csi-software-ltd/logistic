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
          ['name','nickname','fullname','password1','password2','email','teldiv'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Имя"])}</li>'; $("name").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Ник"])}</li>'; $("nickname").addClassName('red'); break;
              case 3: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Название клиента"])}</li>'; $("fullname").addClassName('red'); break;
              case 4: sErrorMsg+='<li>Пароли не совпадают</li>'; $("password2").addClassName('red'); $("password1").addClassName('red'); break;
              case 5: sErrorMsg+='<li>${message(code:"error.min.size.message",args:["Пароль","6"])}</li>'; $("password2").addClassName('red'); $("password1").addClassName('red'); break;
              case 6: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Пароль"])}</li>'; $("password2").addClassName('red'); $("password1").addClassName('red'); break;
              case 7: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Email"])}</li>'; $("email").addClassName('red'); break;
              case 8: sErrorMsg+='<li>${message(code:"error.not.unique.message",args:["Пользователь","Email"])}</li>'; $("email").addClassName('red'); break;
              case 9: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Телефон"])}</li>'; $("teldiv").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
              case 101: sErrorMsg+='<li>${message(code:"error.not.unique.message",args:["Клиент","Email"])}</li>'; $("email").addClassName('red'); break;
            }
          });
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        } else {
          location.assign('${createLink(action:'userdetail')}'+'/'+e.responseJSON.uId);
        }
      }
      function togglefullname(lId){
        if(lId=='0') { $("fullname").show();$("clientlink").hide(); } else { $("fullname").hide();$("fullname").value='';$("clientlink").show();$("link_client_id").value=lId; }
      }
      function confirmUser(){
        $("is_confirm").value='1';
        $("submit_button").click();
      }
      function changepass(){
        $("is_changepass").value='1';
        jQuery("#passline").slideDown();
      }
      function setBan(iId,banned){
        <g:remoteFunction controller='administrators' action='banned' onSuccess="location.reload(true)" params="'id='+iId+'&banned='+banned" />
      }
    <g:if test="${user}">
      function confirmTel(node){
        <g:remoteFunction action='confirmTel' id="${user.id}" onSuccess="node.hide();\$('tel').style='';\$('telicon').removeClassName('icon-remove');\$('telicon').addClassName('icon-ok');" />
      }
    </g:if>
    </g:javascript>    
  </head>
  <body>
    <h1 class="padding-bottom">${user?'Пользователь №'+user.id:'Добавление нового пользователя'}</h1>
    <a class="link fright" href="javascript:void(0)" onclick="returnToList();">К списку пользователей</a>
    <div class="clear"></div>
    <div class="error-box" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>
    </div>  
    <g:formRemote class="contact-form" name="userDetailForm" url="[action:'saveUserDetails', id:user?.id?:0]" method="post" onSuccess="processResponse(e)" autocomplete="off">
      <fieldset>
        <div class="grid_12 col-2">
          <label class="auto">Дата регистрации:&nbsp;</label>
          <input type="text" class="mini" disabled value="${String.format('%td.%<tm.%<tY',user?.inputdate?:new Date())}" />
          <label class="auto">Дата модификации:</label>
          <input type="text" class="mini" disabled value="${String.format('%td.%<tm.%<tY',user?.lastdate?:new Date())}" />
          <label for="status" style="margin-left:15px">Статус:</label>
          <input type="text" disabled value="${user?.modstatus==1?'активный':user?.modstatus==0?'неподтвержден':user?.modstatus==-1?'забанен':'новый'}" />
        </div>
      </fieldset>
      <hr class="admin"/>        
      <fieldset>
        <div class="grid_6 alpha">  
          <label for="name">Имя пользователя:</label>
          <input type="text" id="name" name="name" value="${user?.name}" />
          <label for="nickname">Ник пользователя:</label>
          <input type="text" id="nickname" name="nickname" value="${user?.nickname}" />
          <label for="description">Описание:</label>
          <textarea name="description">${user?.description}</textarea>          
        </div>
        <div class="grid_6 omega">          
          <label for="type_id">Тип:</label>
          <g:select name="type_id" value="${user?.type_id?:1}" keys="${1..3}" from="${['грузоотправитель','грузоперевозчик','менеджер']}" />        
          <label for="company">Компания:</label>
          <input type="text" name="company" value="${user?.company}" />
          <label for="email">Email:</label>
          <div class="input-append"> 
            <input type="text" class="nopad normal" ${user?'readonly':''} id="email" name="email" value="${user?.email}" />
            <span class="add-on"><i class="icon-${!user?.is_emailcheck?'remove':'ok'}" title="${!user?.is_emailcheck?'неподтвержден':'подтвержден'}"></i></span>
          </div>            
          <label for="tel">Телефон:</label>
          <div class="input-append" id="teldiv">
            <input type="text" class="nopad normal" id="tel" name="tel" value="${user?.tel}" placeholder="например: +79111234567"/>
            <span class="add-on"><i id="telicon" class="icon-${!user?.is_telcheck?'remove':'ok'}" title="${!user?.is_telcheck?'неподтвержден':'подтвержден'}"></i></span>
          </div>
        <g:if test="${(user?.is_telcheck?:0)==0&&user?.tel}">
          <a class="button" href="javascript:void(0)" onclick="confirmTel(this)" title="Активировать"><i class="icon-ok"></i></a>
        </g:if>
          <label for="tel1">Телефон2:</label>
          <input type="text" name="tel1" value="${user?.tel1}" />          
        </div>
        <div class="grid_12 alpha" style="margin-bottom:15px">
          <label for="client_id">Название клиента:</label>
          <g:select class="nopad" onchange="togglefullname(this.value)" name="client_id" value="${user?.client_id?:0}" from="${Client.list()}" optionValue="fullname" optionKey="id" noSelection="${['0':'новый клиент']}"/>
          <input type="text" class="nopad" name="fullname" id="fullname" style="${user?.client_id?'display:none':''}" value="" />
          <a id="clientlink" style="${!user?.client_id?'display:none':''}" href="javascript:void(0)" onclick="$('toClientEditForm').submit();">Редактировать</a>
        </div>
        <div class="grid_6 alpha">
          <fieldset class="bord">
            <legend>Настройки</legend>
            <input type="checkbox" id="is_am" name="is_am" value="1" <g:if test="${user?.is_am}">checked</g:if> />
            <label class="nopad" for="is_am">Главный пользователь</label><br/>
            <input type="checkbox" id="is_zayavka" disabled value="1" <g:if test="${user?.is_zayavka}">checked</g:if> />
            <label class="nopad" disabled for="is_zayavka">Уведомления по заявкам</label><br/>          
            <input type="checkbox" id="is_noticeemail" disabled value="1" <g:if test="${user?.is_noticeemail}">checked</g:if> />
            <label class="nopad" disabled for="is_noticeemail">Уведомления по email</label><br/>
            <input type="checkbox" id="is_noticeSMS" disabled value="1" <g:if test="${user?.is_noticeSMS}">checked</g:if> />
            <label class="nopad" disabled for="is_noticeSMS">Уведомления по SMS</label>
          </fieldset>
        </div>
        <div class="grid_6 pad-top" id="passline" style="${user?'display:none':''}">
          <label for="password">Пароль:</label>
          <input type="password" id="password1" name="password1" />
          <label for="password2">Повтор пароля:</label>
          <input type="password" id="password2" name="password2" />
        </div>
        <div class="clear"></div>
        <div class="btns">
          <input type="submit" id="submit_button" class="button" value="Сохранить" />
        <g:if test="${user?.modstatus!=1}">
          <input type="button" onclick="confirmUser()" class="button" value="Подтвердить" />
        </g:if>
        <input type="reset" class="button" value="Сброс" />
        <g:if test="${user?.modstatus!=-1}">
          <input type="button" class="button" onClick="setBan(${user?.id},-1);" value="Забанить" />
        </g:if><g:elseif test="${user}">
          <input type="button" class="button" onClick="setBan(${user?.id},0);" value="Активировать"/>
        </g:elseif><g:if test="${user}">
          <input type="button" class="button" onClick="changepass();" value="Сменить пароль"/>
        </g:if>
        </div>  
      </fieldset>      
      <input type="hidden" id="is_confirm" name="is_confirm" value="0"/>
      <input type="hidden" id="is_changepass" name="is_changepass" value="0"/>      
    </g:formRemote>
    <g:form  id="returnToListForm" name="returnToListForm" url="${[action:'users']}">
    </g:form>
    <g:form  id="toClientEditForm" name="toClientEditForm" url="${[action:'clientdetail']}">
      <input type="hidden" id="link_client_id" name="id" value="${user?.client_id?:0}"/>
    </g:form>
  </body>
</html>
