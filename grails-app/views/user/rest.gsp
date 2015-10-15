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
    <g:if test="${inrequest?.error==0}">
      <div class="info-box">
        <span class="icon icon-info-sign icon-3x"></span>
        На ваш email направлено письмо со ссылкой на страницу восстановления пароля.
      </div>
    </g:if><g:else>
      <div class="error-box">
        <span class="icon icon-warning-sign icon-3x"></span>
        <ul>
          <g:if test="${inrequest?.error==1}"><li>Пользователя с таким именем не существует</li></g:if>
          <g:elseif test="${inrequest?.error==2}"><li>Ошибка в адресе email</li></g:elseif>
          <g:elseif test="${inrequest?.error==3}"><li>Ошибочный проверочный код</li></g:elseif>
          <g:elseif test="${inrequest?.error==4}"><li>Ошибка</li></g:elseif>
        </ul>
      </div> 
    </g:else>
    </div>    
  </body>
</html>
