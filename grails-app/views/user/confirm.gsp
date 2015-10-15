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
    <g:if test="${flash?.error==1}">
      <div class="error-box">
        <span class="icon icon-warning-sign icon-3x"></span>
        Неверная, либо неактивная ссылка        
      </div>
    </g:if><g:else>
      <div class="info-box">
        <span class="icon icon-info-sign icon-3x"></span>
        Email подтвержден
      </div>    
    </g:else>
    </div>
  </body>
</html>
