<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ru" lang="ru">
  <head>
    <title>${infotext?.title?:''}</title>
    <meta http-equiv="content-language" content="ru" />
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />      
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />               
    <meta name="copyright" content="Navigator" />    
    <meta name="resource-type" content="document" />
    <meta name="document-state" content="dynamic" />
    <meta name="revisit" content="1" />
    <meta name="viewport" content="width=device-width; initial-scale=1.0">    
    <meta name="robots" content="index,follow,noarchive" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'reset.css')}" type="text/css" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'grid.css')}" type="text/css" />    
    <link rel="stylesheet" href="${resource(dir:'css',file:'superfish.css')}" type="text/css" />    
    <link rel="stylesheet" href="${resource(dir:'css',file:'style.css')}" type="text/css" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'font-awesome.min.css')}" type="text/css" />        
  </head>
  <body>
    <div class="content_tail">
      <!--==============================header=================================-->
      <div class="header-bg1">
        <div class="bg1">
          <header>
            <div class="main">
              <a class="logo" title="Containerovoz — главная страница" href="${g.createLink(uri:'',absolute:true)}">Containerovoz</a>
              <nav>
              <g:if test="${user}"><!--noindex-->
                <div class="user fright">
                  <span class="icon-lock icon-1x icon-light"></span> <span class="user-login" id="user">${user?.nickname?:''}</span>
                  <a class="icon-bell-alt icon-1x icon-light" title="Уведомления" href="${notice_unread_count==1&&user.type_id==2?createLink(controller:'carrier',action:'orderdetails',id:notice_unread_id):createLink(controller:user.type_id==2?'carrier':user.type_id==1?'shipper':'manager',action:user.type_id==2?'orders':user.type_id==1?'offers':'manager')}">
                  <g:if test="${notice_unread_count}">
                    <div class="new">${notice_unread_count}</div>
                  </g:if>
                  </a>
                  <a class="icon-envelope icon-1x icon-light" title="Сообщения" href="${message_unread_count==1&&user.type_id==2?createLink(controller:'carrier',action:'instructiondetails',id:message_unread_id):createLink(controller:user.type_id==2?'carrier':user.type_id==1?'shipper':'manager',action:user.type_id==2?'instructions':user.type_id==1?'requests':'manager')}">
                  <g:if test="${message_unread_count}">
                    <div class="new">${message_unread_count}</div>
                  </g:if>
                  </a>
                  <a class="icon-comment icon-1x icon-light" title="События" href="${g.createLink(controller:user.type_id==2?'carrier':user.type_id==1?'shipper':'manager',action:'monitoring',params:[type:1])}">
                  <g:if test="${events_unread_count}">
                    <div class="new">${events_unread_count}</div>
                  </g:if>
                  </a>                  
                  <a class="icon-signout icon-2x icon-light" title="Выход" href="${g.createLink(controller:'user',action:'logout')}"> </a>
                </div><!--/noindex-->
              </g:if>
                <ul class="sf-menu fleft">
                <g:each in="${topmenu}" var="item" status="i"><g:if test="${(i+1<topmenu.size()&&!user)||(i>0 && user)}">
                  <li class="${(controllerName==item?.controller && actionName==item?.action)?'current':''}">
                    <g:link controller="${item?.controller}" action="${item?.action}">${item?.name}</g:link>
                  </li>
                </g:if></g:each>  
                </ul> 
              </nav>
              <div class="clear"></div>
            </div>
          </header>
        </div>
      </div>
      <!--==============================content================================-->
      <section id="content">
        <div class="bg2" style="min-height:695px">
          <div class="page4">
            <div class="content-top">
              <div class="container_12">
                <div class="block3">
                  <h1 class="text5" nowrap>Извините, <span>${infotext?.header?:''}</span></h1>
                  <div class="text6">
                    <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
                  </div>              
                </div>
                <div class="clear"></div>
              </div>               
            </div>
          </div>
        </div>
      </section>
    </div>
    <!--==============================footer=================================-->
    <footer>
      <div class="wrapper"><!--noindex-->
        <div class="footer-text1">
          <noscript><div><img src="//mc.yandex.ru/watch/22476109" style="position:absolute; left:-9999px;" alt="" /></div></noscript>
        </div>
        <ul class="img-list img-list-top">
          <li><script type="text/javascript"><!--
            document.write("<a href='http://www.liveinternet.ru/click' rel='nofollow' target='_blank'><img src='//counter.yadro.ru/hit?t41.5;r"+
            escape(document.referrer)+((typeof(screen)=="undefined")?"":";s"+screen.width+"*"+screen.height+"*"+(screen.colorDepth?
            screen.colorDepth:screen.pixelDepth))+";u"+escape(document.URL)+";h"+escape(document.title.substring(0,80))+";"+Math.random()+
            "' alt='' title='LiveInternet' border='0' width='31' height='31'><\/a>")
            //--></script>
          </li>
        </ul><!--/noindex-->
        <div class="foot-text1">Navigator Co. © 2013 Все права защищены  | <a href="${g.createLink(controller:'index',action:'terms')}">Условия использования</a></div>
      </div>      
    </footer>            
  </body>
</html>
