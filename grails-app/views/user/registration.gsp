<html>
  <head>
    <title>${inrequest?.registration?infotext?.promotext1:infotext?.promotext2}</title>    
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />
    <meta name="layout" content="main" />
    <g:javascript>        
      function initialize(){
      <g:if test="${inrequest?.registration}">
        $('loginForm').hide();
        $('loginLink').hide();
        <g:if test="${!(flash?.error?:[]).contains(50)}">
          $('regForm').show();
          $('regLink').show();
        </g:if>                      
      </g:if><g:else>
        $('loginForm').show();
        $('loginLink').show();
        $('regForm').hide();
        $('regLink').hide();
      </g:else>        
      }
      function clearError(){
        if($('error')){
          $('error').update('');
          $('error').hide();
        }  
        if($('done')){
          $('done').update('');
          $('done').hide();
        } 
      }  
      function reloadCaptcha(){
        <g:remoteFunction controller='index' action='reloadCaptcha' onSuccess='processRelResponse(e)' />
      }
      function processRelResponse(e){
        $('captcha_picture').innerHTML = e.responseJSON.captcha;
        $('captcha_picture').firstChild.setStyle({width: '120px'});
      }      
    </g:javascript>
    <style type="text/css">
      .contact-form input.normal{width:212px!important}
      @media screen and (-webkit-min-device-pixel-ratio:0){
        .contact-form .input-prepend{width:255px!important}
      }
    </style>
  </head>
  <body onload="initialize()">
    <div class="grid_12">
      <h1 class="fleft suffix_2" id="h1">${inrequest?.registration?infotext?.promotext1:infotext?.promotext2}</h1>
      <a class="fleft" id="regLink" href="javascript:void(0)" onclick="$('loginLink').show();$('loginForm').show();$('regLink').hide();$('regForm').hide();$('h1').update('${infotext?.promotext2?:''}');clearError();" style="display:none">авторизация</a>
      <a class="fleft" id="loginLink" href="javascript:void(0)" onclick="$('loginLink').hide();$('loginForm').hide();$('regLink').show();$('regForm').show();$('h1').update('${infotext?.promotext1?:''}');clearError();" style="display:none">регистрация</a>    
      <div class="clear"></div>
    <g:if test="${flash?.error}">
      <div id="error" class="error-box">
        <span class="icon icon-warning-sign icon-3x"></span>
        <ul id="errorlist">                                                                                                                 
          <g:if test="${(flash?.error?:[]).contains(1)}"><li>Вы не заполнили обязательное поле &laquo;Имя Фамилия&raquo;</li></g:if>          
          <g:if test="${(flash?.error?:[]).contains(4)}"><li>Вы не заполнили обязательное поле &laquo;Email&raquo;</li></g:if>
          <g:if test="${(flash?.error?:[]).contains(6)}"><li>Вы не заполнили обязательное поле &laquo;Тип&raquo;</li></g:if>
          <g:if test="${(flash?.error?:[]).contains(2)}"><li>Вы не заполнили обязательное поле &laquo;Компания&raquo;</li></g:if>
          <g:if test="${(flash?.error?:[]).contains(5)}"><li>Некорректно заполнено поле &laquo;Email&raquo;</li></g:if>          
          <g:if test="${(flash?.error?:[]).contains(7)}"><li>Введенные пароли не совпадают</li></g:if>
          <g:if test="${(flash?.error?:[]).contains(8)}"><li>Слишком короткий пароль. Требуется не менее ${passwordlength} символов</li></g:if>
          <g:if test="${(flash?.error?:[]).contains(9)}"><li>Пользователь с таким email уже существует. Вам необходимо задать другой email или авторизоваться. Если Вы забыли свой пароль в системе, воспользуйтесь функцией восстановления пароля</li></g:if> 
          <g:if test="${(flash?.error?:[]).contains(10)}"><li>Пароль должен содержать английские буквы и цифры</li></g:if>                   
      <!--login-->
          <g:if test="${(flash?.error?:[]).contains(100)}"><li>Укажите пользователя</li></g:if>		
          <g:if test="${(flash?.error?:[]).contains(200)}"><li>Укажите пароль</li></g:if>
          <g:if test="${(flash?.error?:[]).contains(51)}"><li>Ошибка в пароле или пользователя не существует</li></g:if>
          <g:if test="${(flash?.error?:[]).contains(52)}"><li>Доступ временно заблокирован</li></g:if>          
          <g:if test="${(flash?.error?:[]).contains(400)}"><li>Некорректно заполнено поле &laquo;Имя&raquo;</li></g:if>          
          <g:if test="${(flash?.error?:[]).contains(99)}"><li>Неправильно введен проверочный код</li></g:if>                    
        </ul> 
      </div>
    </g:if>
    <!--<g:if test="${(flash?.error?:[]).contains(50)}">    
      <div class="info-box" id="done">
        <span class="icon icon-info-sign icon-3x"></span>
        <div id="infolist">${message(code:"notice.mailsend.message")}<br/>
          <a href="javascript:void(0)" onclick="$('loginForm').show();$('regForm').hide();$('h1').update('${infotext?.promotext2?:''}');clearError();">авторизация</a>
        </div>
      </div>
    </g:if>-->
      <g:form class="contact-form" id="loginForm" name="loginForm" method="post" url="[controller: 'user', action: 'login_user']" style="display:none">
        <fieldset class="grid_6">
          <label for="user">Логин:</label>
          <span class="input-prepend <g:if test="${(flash?.error?:[]).contains(100)||(flash?.error?:[]).contains(400)}">red</g:if>">
            <span class="add-on"><i class="icon-envelope"></i></span>
            <input type="text" name="user" id="user" value="${inrequest?.user?:''}" placeholder="Email или ваш ID" class="nopad normal" />
          </span><br/>
          <label for="password">Пароль:</label>
          <span class="input-prepend <g:if test="${(flash?.error?:[]).contains(200)||(flash?.error?:[]).contains(51)}">red</g:if>">
            <span class="add-on"><i class="icon-key"></i></span>
            <input type="password" name="password" id="password" value="${inrequest?.password?:''}" placeholder="Пароль" class="nopad normal" />
          </span>          
          <div id="captcha" style="${(session.user_enter_fail?:0)>user_max_enter_fail?'':'display: none'}">
            <label>Введите код, подтверждающий, что вы человек:</label><br/>            
            <div id="captcha_picture" class="button-right fleft">
              <jcaptcha:jpeg name="image" width="112"/>
            </div>
            <input type="text" class="mini" id="captcha_text" name="captcha" value="" style="border-width:1px" />
            <a class="button" href="javascript:void(0)" onclick="reloadCaptcha()" title="Обновить"><i class="icon-repeat"></i></a>            
          </div>
          <div class="button-top">
            <label for="remember">
              <input type="checkbox" value="1" name="remember" />&nbsp;запомнить
            </label>
            <input class="button" type="submit" value="Войти" />
            <g:link class="link inline" controller="user" action="restore">забыли пароль?</g:link>          
          </div>
        </fieldset>
      </g:form>                                      

      <g:form class="contact-form" name="regForm" id="regForm" url="${[controller:'user',action:'saveuser']}" method="post" style="display:none">
        <fieldset>
          <label for="name">Имя Фамилия</label>
          <input type="text" id="name" name="name" value="${inrequest?.name?:''}" placeholder="Имя Фамилия" <g:if test="${(flash?.error?:[]).contains(1)}">class="red"</g:if> autocomplete="off"/><br/>
          <label for="email">Email:</label>
          <input type="text" id="email" name="email" value="${inrequest?.email?:''}" placeholder="Еmail" <g:if test="${(flash?.error?:[]).contains(4)||(flash?.error?:[]).contains(5)}">class="red"</g:if> autocomplete="off"/>          
        </fieldset>
        <fieldset class="bord <g:if test="${(flash?.error?:[]).contains(6)}">red</g:if>">
          <legend>Тип</legend>
          <g:radio name="type_id" value="1" checked="${((inrequest?.type_id?:0)==1)?true:false}"/>Грузоотправитель<br/>
          <g:radio name="type_id" value="2" checked="${((inrequest?.type_id?:0)==2)?true:false}"/>Грузоперевозчик
        </fieldset>                  
        <fieldset>
          <label for="company">Компания:</label>
          <input type="text" id="company" name="company" value="${inrequest?.company?:''}" placeholder="Наименование компании" <g:if test="${(flash?.error?:[]).contains(2)}">class="red"</g:if> autocomplete="off"/><br/>
          <label for="password1">Пароль:</label>
          <input type="password" id="password1" name="password1" value="${inrequest?.password1?:''}" placeholder="Пароль" <g:if test="${(flash?.error?:[]).contains(7)||(flash?.error?:[]).contains(8)||(flash?.error?:[]).contains(10)}">class="red"</g:if> autocomplete="off" /><br/>
          <label for="password2">Повторите пароль:</label>
          <input type="password" id="password2" name="password2" value="${inrequest?.password2?:''}" placeholder="Повторите пароль" <g:if test="${(flash?.error?:[]).contains(7)||(flash?.error?:[]).contains(8)||(flash?.error?:[]).contains(10)}">class="red"</g:if> autocomplete="off"/>
          <div class="clear"></div>
          <div class="btns pad-top3 fleft">
            <input type="reset" class="button" value="очистить" />
            <input type="submit" class="button" id="submitbutton" value="Зарегистрироваться" />                      
          </div>
        </fieldset>
      </g:form>              
    </div>
  </body>
</html>  
