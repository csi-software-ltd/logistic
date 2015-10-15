<html>
  <head>
    <title>${infotext?.title?:''}</title>    
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />
    <meta name="layout" content="main" />
  </head>
  <body>
              <div class="grid_8">
              	<h1>${infotext?.header?:''}</h1>
                <div class="img-top img-bottom1">
                  <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
                </div>
                <div class="clear"></div>
              </div>
              <div class="grid_4"><!--noindex-->
                <div class="box2-top">
                	<div class="border2">
                    <a href="<g:if test="${user}"><g:createLink controller='${user?.type_id==1?'shipper':(user?.type_id==2?'carrier':'manager')}' action='orders'/></g:if>
                      <g:else><g:createLink controller='user' action='registration'/></g:else>" class="box1">
                      <div class="padding">
                       	<div class="wrapper">
                         	<img src="${resource(dir:'flash/images',file:'tfile_image_'+(user?'2':'1')+'.png')}" alt="" class="img-indent4" />
                          <div class="extra-wrap">
                           	<div class="box-text1" style="padding-top:${user?'0':'15'}px">
                             	<em><g:if test="${user}">личный<br>кабинет</g:if><g:else>регистрация</g:else></em>
                            </div>
                          </div>
                        </div>
                      </div>
                    </a>
                  </div>
                </div><!--/noindex-->                       
                <div class="box3-pad">
                  <a href="<g:createLink controller='index' action='contact'/>" class="box3">
                    <div class="padding">
                      <div class="wrapper">
                        <img src="${resource(dir:'images',file:'box3-img.jpg')}" width="54" alt="" class="img-indent4" />
                        <div class="extra-wrap">
                          <div class="box3-text">
                            Вопросы? <span>напишите нам</span>
                          </div>
                        </div>
                      </div>                      
                    </div>
                  </a>
                </div>
                <g:rawHtml>${infotext?.itext2?:''}</g:rawHtml>
              </div>
              <div class="clear"></div>            
  </body>
</html>
