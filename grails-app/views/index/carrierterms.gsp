<html>
  <head>
    <title>${infotext?.title?:''}</title>    
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />
    <meta name="layout" content="main" />
  </head>
  <body>
    <h1>${infotext?.header?:''}</h1>
    <g:form class="contact-form" name="confirmForm" url="[controller:'index',action:'termsconfirm']" method="post" onSuccess="processResponse(e)">
      <fieldset>
        <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
      <g:if test="${user?.type_id==2&&user?.is_termconfirm==0&&!session.admin}">
        <div class="btns">
          <input type="submit" class="button" value="Я согласен" />
          <a class="button" href="${g.createLink(controller:'user',action:'logout')}">Я не согласен</a>
        </div>
      </g:if>
      </fieldset>
    </g:form>
  </body>
</html>
