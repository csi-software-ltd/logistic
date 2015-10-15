<html>
  <head>
    <title>${infotext?.title?:''}</title>    
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />
    <meta name="layout" content="main" />
  </head>
  <body>
    <div class="block3">
      <h1 class="text5">${infotext?.header?:''}</h1>
      <div class="text6">
        <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
      </div>              
    </div>
    <div class="clear"></div>    
  </body>
</html>   
