<html>
  <head>
    <title>${infotext?.title?:''}</title>  
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />       
    <meta name="layout" content="main" />
  </head>
  <body>
    <div class="grid_12">
      <h1>${infotext?.header?:''}</h1>
      <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
    <g:if test="${inrequest.error==-1}">
      <div class="info-box">
        <span class="icon icon-info-sign icon-3x"></span>
        Пароль изменен
      </div>
    </g:if><g:else>
      <g:if test="${inrequest.error}">
      <div class="error-box">
        <span class="icon icon-warning-sign icon-3x"></span>
        <ul>
          <g:if test="${inrequest?.error==1}"><li>Введенные пароли не совпадают</li></g:if>
          <g:elseif test="${inrequest?.error==2}"><li>Слишком короткий пароль</li></g:elseif>
          <g:elseif test="${inrequest?.error==3}"><li>Пароль должен содержать английские буквы и цифры</li></g:elseif>
          <g:elseif test="${inrequest?.error==3}"><li>Возникла непредвиденная ошибка</li></g:elseif>
        </ul>
      </div>
      </g:if>
      <g:form class="contact-form" url="[controller:'user',action:'passwsetup']" method="post" useToken="true">
        <fieldset>
          <label for="password1">Пароль:</label>
          <input type="password" name="password1" value="" <g:if test="${inrequest?.error==2}">class="red"</g:if> /><br/>
          <label for="password2">Повторите пароль:</label>
          <input type="password" name="password2" value="" <g:if test="${inrequest?.error == 1}">class="red"</g:if>/>
          <div class="clear"></div>
          <div class="btns pad-top3 fleft">
            <input type="submit" class="button" value="Изменить пароль"/>
          </div>
        </fieldset>
      </g:form>
    </g:else>
    </div>
  </body>
</html>
