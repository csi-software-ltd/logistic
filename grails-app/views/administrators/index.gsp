<html>
  <head>
    <title>Административное приложение</title>
    <meta name="layout" content="admin" />
    <style type="text/css">.contact-form input.normal{width:212px!important}</style>
  </head>  
  <body>    
  <g:if test="${redir}">
    <g:form url="[controller:'administrators',action:'index']" method="post" name="indexForm" id="indexForm">
      <input type="submit" style="display:none" />
    </g:form>
    <script type="text/javascript">
      eval("$('indexForm').submit();");
    </script>
  </g:if><g:else>
    <div class="grid_3">&nbsp;</div>
    <div class="grid_6">
      <h3>Войти в панель управления</h3>
    <g:if test="${flash?.error}">
      <div class="error-box">
        <span class="icon icon-warning-sign icon-3x"></span>
        <ul>
          <g:if test="${flash.error==1}"><li>Не введен логин</li></g:if>
          <g:elseif test="${flash.error==2}"><li>Пароль введен неверно, или администратора с таким логином не существует</li></g:elseif>
          <g:elseif test="${flash.error==3}"><li>Доступ временно заблокирован</li></g:elseif>      
        </ul>
      </div>
    </g:if>      
      <g:form class="contact-form" url="[controller:'administrators',action:'login']" method="post">
        <fieldset>
          <label for="login">Логин:</label>
          <span class="input-prepend <g:if test="${flash?.error==1}">red</g:if>">
            <span class="add-on"><i class="icon-lock"></i></span>
            <input type="text" class="nopad normal" name="login" id="login" placeholder="Логин"/>
          </span>
          <label for="password">Пароль:</label>
          <span class="input-prepend <g:if test="${flash?.error==2}">red</g:if>">
            <span class="add-on"><i class="icon-key"></i></span>
            <input type="password" class="nopad normal" name="password" placeholder="Пароль" />
          </span>
          <div class="btns padding-right1">
            <input type="submit" class="button" value="Войти" />
          </div>
        </fieldset>
      </g:form>    
    </div>    
    </g:else>
  </body>
</html>
