<html>
  <head>
    <title>${infotext?.title?:''}</title>    
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />
    <meta name="layout" content="main" />
  </head>
  <body>
             	<div class="grid_4">
               	<h2>${infotext?.header?:''}</h2>
                <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
                <a class="button fright button-right" href="<g:createLink controller='index' action='howto'/>">подробнее</a>
                <div class="clear"></div>
              </div>
              <div class="grid_4">
                <div class="pad-left">
                  <h2>${infotext?.promotext1?:''}</h2>
                  <g:rawHtml>${infotext?.itext2?:''}</g:rawHtml>                  
                  <div class="clear"></div>
                </div>    
              </div>
              <article class="grid_4">
                <div class="pad-left">
                 	<h2>${infotext?.promotext2?:''}</h2>
                  <g:rawHtml>${infotext?.itext3?:''}</g:rawHtml>                  
                  <div class="clear"></div>
                </div>    
              </article>    
  </body>
</html>
