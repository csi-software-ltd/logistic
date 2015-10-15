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
                 	<figure>
                    <img class="border1 img-indent1 indent-bot" src="${resource(dir:'images',file:'page2-img2.jpg')}" alt="" />                    
                  </figure>
                  <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
                </div>
                <div class="clear"></div>
              </div>
              <div class="grid_4 padding-top1">
                <div class="box2-top">
                	<div class="border2">
                    <a href="<g:createLink controller='index' action='howto'/>" class="box1">
                      <div class="padding">
                       	<div class="wrapper">
                         	<img src="${resource(dir:'flash/images',file:'tfile_image_3.png')}" alt="" class="img-indent4" />
                          <div class="extra-wrap">
                           	<div class="box-text1">
                             	<em>как это<br>работает?</em>
                            </div>
                          </div>
                        </div>
                      </div>
                    </a>
                  </div>
                </div><!--noindex-->
                <div class="box2-top1">
                	<div class="border2">
                    <a class="box1" href="<g:if test="${user}"><g:createLink controller='${user?.type_id==1?'shipper':(user?.type_id==2?'carrier':'manager')}' action='orders'/></g:if><g:else><g:createLink controller='user' action='login'/></g:else>">
                     	<div class="padding">
                       	<div class="wrapper">
                          <img src="${resource(dir:'flash/images',file:'tfile_image_2.png')}" alt="" class="img-indent4" />
                          <div class="extra-wrap">
                           	<div class="box-text1">
                             	<em><g:if test="${user}">личный<br>кабинет</g:if><g:else>войти в<br>систему</g:else></em>
                            </div>
                          </div>
                        </div>
                      </div>
                    </a>
                  </div>
                </div><!--/noindex-->
                <div class="box2-top1">
                  <div class="border2">
                    <a class="box2" href="https://play.google.com/store/apps/details?id=ru.trace.lg" target="_blank">
                      <div class="padding">
                        <div class="wrapper">
                          <img src="${resource(dir:'images',file:'android.png')}" width="54" alt="" class="img-indent4" />
                          <div class="extra-wrap">
                            <div class="box-text1">
                              <em>мобильное приложение</em>
                            </div>
                          </div>
                        </div>                      
                      </div>
                    </a>                  
                  </div>
                </div>
                <g:rawHtml>${infotext?.itext2?:''}</g:rawHtml>
              </div>
              <div class="clear"></div>            
  </body>
</html>
