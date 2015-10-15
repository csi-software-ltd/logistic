<html>
  <head>
    <title>${infotext?.title?:''}</title>    
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />
    <meta name="layout" content="main" />
    <g:javascript>
      function processResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['name','nickname','password1','password2','teldiv'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Ник"])}</li>'; $("nickname").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Имя"])}</li>'; $("name").addClassName('red'); break;
              case 4: sErrorMsg+='<li>Пароли не совпадают</li>'; $("password2").addClassName('red'); $("password1").addClassName('red'); break;
              case 5: sErrorMsg+='<li>Короткий пароль</li>'; $("password2").addClassName('red'); $("password1").addClassName('red'); break;
              case 6: sErrorMsg+='<li>Некорректный пароль</li>'; $("password2").addClassName('red'); $("password1").addClassName('red'); break;
              case 9: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Телефон"])}</li>'; $("teldiv").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        } else {
          location.reload(true);
        }
      }
      function showmailsendmessage(){
        $("mailnotice").show();
        $("mailnotice").up('div').show();
      }
      function changepass(){
        $("is_changepass").value='1';
        jQuery("#passline").slideDown();
      }
      function sendConfirmationMail(elem){
        <g:remoteFunction action='sendUserConfirmMail' onSuccess="showmailsendmessage();"/>
        elem.hide();
      }
      function sendConfirmationSMS(elem){
        <g:remoteFunction action='sendVerifyTel'/>
        elem.hide();
        $("telconfirm").show();
      }
      function confirmtel(){
        var code = $("smscode").value
        <g:remoteFunction action='verifySms' onSuccess="processSmsResponse(e);" params="'smscode='+code"/>
      }
      function processSmsResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='${message(code:"error.incorrect.message",args:["Код"])}'; $("smscode").addClassName('red'); break;
              case 100: sErrorMsg+='${message(code:"error.bderror.message")}'; break;
            }
          });
          $("smscodemessage").innerHTML=sErrorMsg;
        } else {
          location.reload(true);
        }
      }
    </g:javascript>    
  </head>
  <body>
    <h1>${infotext?.header?:''}</h1>
    <div class="error-box" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>      
    </div>
    <div class="info-box" style="${(!user.is_needtochangepassword && !from_reg && (user_internal || user.is_emailcheck) && user.is_telcheck)?'display:none':''}">
      <span class="icon icon-info-sign icon-3x"></span>
      <ul id="infolist">
        <li style="${!user.is_needtochangepassword?'display:none':''}">${message(code:"notice.needtochangepassword.message")}</li>
        <li id="mailnotice" <g:if test="${!from_reg}">style="display:none"</g:if>>${message(code:"notice.mailsend.message")}</li>
        <li id="mailchecknotice" <g:if test="${(user_internal || user.is_emailcheck)}">style="display:none"</g:if>>${message(code:"notice.mailcheck.message")}</li>        
        <li id="telchecknotice" <g:if test="${user.is_telcheck}">style="display:none"</g:if>>${message(code:"notice.telcheck.message")}</li>        
      </ul>
    </div>    
    <g:formRemote class="contact-form" name="userDetailForm" url="[action:'saveUserProfile']" method="post" onSuccess="processResponse(e)">
      <fieldset>
        <div class="grid_6 fleft">  
          <label for="name">Имя:</label>
          <input type="text" id="name" name="name" value="${user.name}" autocomplete="off"/>
          <label for="nickname">Ник:</label>
          <input type="text" id="nickname" name="nickname" value="${user.nickname}" autocomplete="off"/>
        </div>
        <div class="grid_6 fright">
          <label for="email">Email:</label>
          <div class="input-append">            
            <input type="text" class="nopad normal" name="email" readonly value="${user?.email}" autocomplete="off"/>
            <span class="add-on"><i class="icon-${!user.is_emailcheck?'remove':'ok'}" title="${!user.is_emailcheck?'неподтвержден':'подтвержден'}"></i></span>
          </div>            
        <g:if test="${!user_internal && (user.is_emailcheck?:0)==0}">
          <a class="button" href="javascript:void(0)" onclick="sendConfirmationMail(this)" title="Запросить письмо на подтверждение"><i class="icon-ok"></i></span></a>
        </g:if>          
          <label for="tel">Телефон:</label>
          <div class="input-append" id="teldiv">            
            <input type="text" class="nopad normal" id="tel" name="tel" value="${user.tel}" autocomplete="off" placeholder="например: +79111234567"/>
            <span class="add-on"><i id="telicon" class="icon-${!user?.is_telcheck?'remove':'ok'}" title="${!user?.is_telcheck?'неподтвержден':'подтвержден'}"></i></span>
          </div>
        <g:if test="${user.tel && (user.is_telcheck?:0)==0&&!isSMSsend}">
          <a class="button" href="javascript:void(0)" onclick="sendConfirmationSMS(this)" title="Подтвердить"><i class="icon-ok"></i></a>
        </g:if>        
          <fieldset class="bord" id="telconfirm" style="width:438px;${!isSMSsend||(user.is_telcheck?:0)==1?'display:none':''}">
            <legend>Подтверждение телефона</legend>
            <label id="smscodemessage">Вам выслан код подтверждения по SMS. Пожалуйста, введите его ниже.</label><br/>
            <label for="smscode">Код подтверждения:</label>
            <input type="text" class="mini" id="smscode" value="" style="border-width:1px" />
            <a class="button" href="javascript:void(0)" onclick="confirmtel()" title="Подтвердить"><i class="icon-ok"></i></a><br/>
          </fieldset>
          <label for="tel1">Телефон2:</label>
          <input type="text" name="tel1" value="${user.tel1}" autocomplete="off"/>
        </div>
        <div class="grid_6 fleft">
          <fieldset class="bord" style="width:366px;margin-left:10px">
            <legend>Настройки</legend>
            <input type="checkbox" id="is_news" name="is_news" value="1" <g:if test="${user.is_news}">checked</g:if> />
            <label class="nopad" for="is_news">Новости системы</label><br/>
            <input type="checkbox" id="is_zayavka" name="is_zayavka" value="1" <g:if test="${user.is_zayavka}">checked</g:if> />
            <label class="nopad" for="is_zayavka">Уведомления по заявкам</label><br/>
            <input type="checkbox" id="is_noticeemail" name="is_noticeemail" value="1" <g:if test="${user.is_noticeemail}">checked</g:if> />
            <label class="nopad" for="is_noticeemail">Уведомления по email</label><br/>
            <input type="checkbox" id="is_noticeSMS" name="is_noticeSMS" value="1" <g:if test="${user.is_noticeSMS}">checked</g:if> />
            <label class="nopad" for="is_noticeSMS">Уведомления по SMS</label>
          </fieldset>
        </div>
        <div class="grid_6 pad-top fright" id="passline" style="${!user.is_needtochangepassword?'display:none':''}">
          <label for="password">Пароль:</label>
          <input type="password" id="password1" name="password1" />
          <label for="password2">Повтор пароля:</label>
          <input type="password" id="password2" name="password2" />
        </div>
        <div class="clear"></div>
        <div class="btns">
          <input type="submit" id="submit_button" class="button" value="Сохранить" />
          <input type="reset" class="button" value="Сброс" />
          <input type="button" class="button" onclick="changepass();" value="Сменить пароль"/>
        </div>
      </fieldset>
      <input type="hidden" id="is_changepass" name="is_changepass" value="0"/>
    </g:formRemote>        
  </body>
</html>
