<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ru" lang="ru">
  <head>
    <title><g:layoutTitle default="Containerovoz Co."/></title>    
    <meta http-equiv="content-language" content="ru" />
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />      
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />               
    <meta name="copyright" content="Navigator" />    
    <meta name="resource-type" content="document" />
    <meta name="document-state" content="dynamic" />
    <meta name="revisit" content="1" />
    <meta name="viewport" content="width=device-width; initial-scale=1.0" />    
    <meta name="robots" content="index,follow,noarchive" />
    <meta name="yandex-verification" content="507641e8733918ed" />
    <meta name="google-site-verification" content="8doIfHhxIAWNQuVGXrmHq0vN6e0LVldfYc87g1OCzIg" />
    <meta name="cmsmagazine" content="55af4ed6d7e3fafc627c933de458fa04" />
    <g:layoutHead/>
    <link rel="shortcut icon" href="${resource(file:'favicon.ico',absolute:true)}" type="image/x-icon" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'reset.css')}" type="text/css" />    
    <link rel="stylesheet" href="${resource(dir:'css',file:'grid.css')}" type="text/css" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'forms.css')}" type="text/css" />    
    <link rel="stylesheet" href="${resource(dir:'css',file:'superfish.css')}" type="text/css" />    
    <link rel="stylesheet" href="${resource(dir:'css',file:'style.css')}" type="text/css" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'font-awesome.min.css')}" type="text/css" />    
    <g:javascript library="jquery-1.10.1.min" />    
    <g:javascript library="superfish" />    
    <g:javascript library="flashobject" />    
    <g:javascript library="application" />
    <g:javascript library="prototype/prototype" />
  <g:if test="${client && controllerName=='shipper' && !(actionName in ['orders','profile','contsearch'])}">
    <g:javascript library="prototype/autocomplete" />
  </g:if>
  <g:if test="${(controllerName=='carrier' && actionName in ['orderdetails','tripdetails','monitoring'])||(controllerName=='shipper' && actionName=='tripdetails')||(controllerName=='index' && actionName in ['contact','monitoringext'])}">
    <script src="https://api-maps.yandex.ru/2.0/?load=package.standard,package.geoObjects&lang=ru-RU" type="text/javascript"></script>
  </g:if>
  <!--[if lt IE 7]>
    <div class='aligncenter'><a href="http://www.microsoft.com/windows/internet-explorer/default.aspx?ocid=ie6_countdown_bannercode"><img src="http://storage.ie6countdown.com/assets/100/images/banners/warning_bar_0000_us.jpg" border="0"></a></div>  
    <link rel="stylesheet" href="${resource(dir:'css',file:'font-awesome-ie7.min.css')}" type="text/css" /> 
  <![endif]-->
  <!--[if lt IE 9]>
    <g:javascript library="html5" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'ie.css')}" type="text/css" />   		  		
  <![endif]-->    
    <r:layoutResources />
    <script type="text/javascript">
      jQuery(document).ready(function(){
        jQuery('ul.sf-menu').superfish({
          delay: 800,                            
          animation: {opacity:'show', height:'show'}, 
          speed: 'faster',                          
          autoArrows: false,                   
          dropShadows: false                         
        });                
        if(navigator.userAgent.search('Trident/7.0')>-1 || navigator.userAgent.search('MSIE')>-1)      
          jQuery('input[type="submit"],input[type="reset"],input[type="button"],a.button,.button').css('padding','7px 10px');
      });
    </script>		
	</head>
	<body onload="${pageProperty(name:'body.onload')}">
    <div class="content_tail">
      <!--==============================header=================================-->
      <div class="header-bg${(controllerName=='index' && actionName=='index')?'':'1'}">
        <div class="bg1">
          <header>
            <div class="main">
              <g:if test="${controllerName=='index' && actionName=='index'}"><h1 class="logo"></g:if>
              <g:else><a class="logo" title="Containerovoz — главная страница" href="${g.createLink(uri:'',absolute:true)}" rel="home"></g:else>
                Containerovoz
              <g:if test="${controllerName=='index' && actionName=='index'}"></h1></g:if><g:else></a></g:else>
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
                  <a class="icon-comment icon-1x icon-light" title="События" href="${createLink(controller:user.type_id==2?'carrier':user.type_id==1?'shipper':'manager',action:'monitoring',params:[type:1])}">
                  <g:if test="${events_unread_count}">
                    <div class="new">${events_unread_count}</div>
                  </g:if>
                  </a>
                <g:if test="${user?.type_id==1}">
                  <a class="icon-usd icon-1x icon-light" title="Неоплаченные счета" href="${createLink(controller:'shipper',action:'settlements')}">
                  <g:if test="${order_nonpaid_count}">
                    <div class="new">${order_nonpaid_count}</div>
                  </g:if>
                  </a>
                </g:if>
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
            <g:if test="${controllerName=='index' && actionName=='index'}">
              <hr noshade />
              <div class="flash">  
                <div id="head">
                  <img src="${resource(dir:'images',file:'flash.jpg')}" alt="" />
                </div><!--noindex-->
              <g:if test="${!user}">
                <script type="text/javascript">
                  var fo = new FlashObject("flash/header_cs2.swf", "head", "950", "295", "10.0.0", "");
                  fo.addParam("quality","high");
                  fo.addParam("wmode","transparent");
                  fo.addParam("scale","noscale");
                  fo.addParam("salign","t"); 
                  fo.addParam("pluginspage", "http://www.macromedia.com/go/getflashplayer"); 
                  fo.write("head");
                </script>
              </g:if>
                <hr noshade /><!--/noindex-->
                <div class="head-button container_12"><!--noindex-->
                  <div class="grid_4">
                    <div class="box2-top">
                      <div class="border2">                        
                        <a class="box" href="<g:if test="${user}">
                          <g:if test="${user?.type_id==1}"><g:createLink controller='shipper' action='order'/></g:if>
                            <g:elseif test="${user?.type_id==2}"><g:createLink controller='carrier' action='orders'/></g:elseif>
                            <g:elseif test="${user?.type_id==3}"><g:createLink controller='manager' action='orders'/></g:elseif>
                          </g:if><g:else><g:createLink controller='user' action='registration'/></g:else>">
                          <div class="padding">
                            <div class="wrapper">
                              <img src="${resource(dir:'flash/images',file:'tfile_image_1.png')}" alt="" class="img-indent4" />
                              <div class="extra-wrap">
                                <div class="box-text" style="padding-top:${user?.type_id==1?'0':'12'}px">
                                  <em><g:if test="${user}">
                                    <g:if test="${user?.type_id==1}">подать<br>заявку</g:if>
                                    <g:elseif test="${user?.type_id==2}">ваши заявки</g:elseif>
                                  </g:if><g:else>регистрация</g:else></em>
                                </div>
                              </div>
                            </div>
                          </div>
                        </a>
                      </div>
                    </div>
                  </div>
                  <div class="grid_4">
                    <div class="box2-top">
                      <div class="border2">
                        <a class="box" href="<g:if test="${user}"><g:createLink controller='${user?.type_id==1?'shipper':(user?.type_id==2?'carrier':'manager')}' action='orders'/></g:if><g:else><g:createLink controller='user' action='login'/></g:else>">
                          <div class="padding">
                            <div class="wrapper">
                              <img src="${resource(dir:'flash/images',file:'tfile_image_2.png')}" alt="" class="img-indent4" />
                              <div class="extra-wrap">
                                <div class="box-text">
                                  <em><g:if test="${user}">личный<br>кабинет</g:if><g:else>войти в<br>систему</g:else></em>
                                </div>
                              </div>
                            </div>
                          </div>
                        </a>
                      </div>
                    </div>                
                  </div><!--/noindex-->
                  <div class="grid_4">
                    <div class="box2-top">
                      <div class="border2">
                        <a class="box" href="<g:createLink controller='index' action='howto'/>">
                          <div class="padding">
                            <div class="wrapper">
                              <img src="${resource(dir:'flash/images',file:'tfile_image_3.png')}" alt="" class="img-indent4" />
                              <div class="extra-wrap">
                                <div class="box-text">
                                  <em>как это<br>работает?</em>
                                </div>
                              </div>
                            </div>
                          </div>
                        </a>
                      </div>
                    </div>                
                  </div>
                </div>
              </div>
            </g:if>
            </div>
          </header>
        </div>
      </div>
      <!--==============================content================================-->
      <section id="content">
        <div class="bg2" <g:if test="${!(controllerName=='index' && actionName=='index')}">style="min-height:695px"</g:if>>                  
          <div class="content-top">
            <g:if test="${session.attention_message && controllerName!='index' && controllerName!='user'}">
              <div class="container_12">
                <div class="error-box" style="margin-top:0">
                  <span class="icon icon-info-sign icon-3x"></span>
                  ${session.attention_message}
                </div>                                               
              </div>
            </g:if>
            <div class="container_12">
            <g:if test="${user && !(controllerName in ['index','user'])}"><!--noindex-->
              <div class="menu">
                <ul class="menu-nav">
                <g:each in="${user?.type_id==1?shippermenu:carriermenu}" var="item" status="i"><g:if test="${i==0}">
                  <li class="${(controllerName==item?.controller && actionName in ['orders','order','orderdetails'])?'selected':''}">
                    <g:link action="orders">Заявки</g:link>
                  </li></g:if><g:elseif test="${i==1}">
                  <li class="${(controllerName==item?.controller && actionName in ['offers','offerdetails','shipment'])?'selected':''}">
                    <g:link action="${user?.type_id==1?'offers':'shipment'}">Погрузки</g:link>
                  </li></g:elseif><g:elseif test="${i==2}">
                  <li class="${(controllerName==item?.controller && actionName in ['instructions', 'requests', 'instructiondetails'])?'selected':''}">
                    <g:link action="${user?.type_id==1?'requests':'instructions'}">Сдача</g:link>
                  </li></g:elseif><g:elseif test="${i==3}">
                  <li class="${(controllerName==item?.controller && actionName in ['monitoring','tripdetails'])?'selected':''}">
                    <g:link action="monitoring">Мониторинг</g:link>
                  </li></g:elseif><g:elseif test="${i==5}">
                  <li class="${(controllerName==item?.controller && actionName in ['profile','company'])?'selected':''}">
                    <g:link action="profile">Профиль</g:link>
                  </li></g:elseif><g:else>
                  <li class="${(controllerName==item?.controller && actionName==item?.action)?'selected':''}">
                    <g:link controller="${item?.controller}" action="${item?.action}">${item?.name}</g:link>
                  </li></g:else>
                </g:each>
                </ul>
              <g:if test="${client && controllerName=='shipper' && !(actionName in ['contsearch','orders','profile'])}">
                <g:form class="contact-form nopad fright" name="contsearchForm" url="[controller:'shipper',action:'contsearch']" method="post">
                  <label for="contnomer" class="auto" style="padding-bottom:0">Контейнер</label>
                  <span class="input-append nopad">
                    <input type="text" class="nopad normal" id="contnomer" name="cont" style="width:110px!important" />
                    <span class="add-on" onclick="$('contsearch_submit_button').click()" style="height:13px"><i class="icon-search"></i></span>
                  </span>
                  <div id="cont_autocomplete" class="autocomplete" style="display:none"></div>
                  <input type="submit" style="display:none" id="contsearch_submit_button" />                  
                </g:form>                
              </g:if>
              <g:if test="${user?.client_id!=0 && (actionName in ['profile','company','monitoring','shipment'] || (actionName=='orders'&&controllerName=='carrier'))}">
                <ul class="submenu-nav" style="clear:both">
                <g:if test="${actionName in ['profile','company']}">
                  <li class="${actionName=='profile'?'selected':''}"><g:link action="profile">Мой профиль</g:link></li>
                  <li class="${actionName=='company'?'selected':''}"><g:link action="company">Профиль комнании</g:link></li>
                </g:if><g:if test="${actionName=='monitoring'}">
                  <li class="${actionName=='monitoring'?'selected':''}"><a class="link" href="javascript:void(0)" onclick="initialize(0)" id="trip">Поездки</a></li>
                  <li><a class="link" href="javascript:void(0)" onclick="initialize(1)" id="tripevent">События</a></li>
                  <li><a class="link" href="javascript:void(0)" onclick="initialize(2)" id="mycars">Мои машины</a></li>
                </g:if><g:if test="${actionName=='shipment'}">
                  <li class="${actionName=='shipment'?'selected':''}"><a class="link" href="javascript:void(0)" onclick="initialize(0)" id="shipmentnew">Новые погрузки</a></li>
                  <li><a class="link" href="javascript:void(0)" onclick="initialize(1)" id="shipmentold">Прошлые погрузки</a></li>
                  <li><a class="link" href="javascript:void(0)" onclick="initialize(2)" id="shipmentcancel">Отмененные погрузки</a></li>
                </g:if><g:if test="${actionName=='orders'}">
                  <li class="${actionName=='shipment'?'selected':''}"><a class="link" href="javascript:void(0)" onclick="initialize(-100)" id="ordersall">Все</a></li>
                  <li><a class="link" href="javascript:void(0)" onclick="initialize(0)" id="ordersnew">Новые</a></li>
                  <li><a class="link" href="javascript:void(0)" onclick="initialize(1)" id="ordersaccept">Акцепт</a></li>
                  <li><a class="link" href="javascript:void(0)" onclick="initialize(2)" id="ordersassigned">Назначен</a></li>
                  <li><a class="link" href="javascript:void(0)" onclick="initialize(-1)" id="orderscancell">Отказ</a></li>
                  <li><a class="link" href="javascript:void(0)" onclick="initialize(-2)" id="ordersarchive">Архив</a></li>
                  <li><a class="link" href="javascript:void(0)" onclick="initialize(-101)" id="freecars">Свободные машины</a></li>
                </g:if>
                </ul>
              </g:if>                
              </div><!--/noindex-->
            </g:if>
              <g:layoutBody/>
              <div class="clear"></div>
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
        <div class="foot-text1">Navigator Co. © 2013 Все права защищены  | <a href="${g.createLink(controller:'index',action:'terms')}">Условия использования</a>  | <a href="${g.createLink(controller:'index',action:'carrierterms')}">Условия перевозчика</a></div>
      </div>      
    </footer><!--noindex-->            
		<r:layoutResources />
  <g:if test="${client && controllerName=='shipper' && !(actionName in ['contsearch','orders','profile'])}">
    <script type="text/javascript">
      new Autocomplete('contnomer', { serviceUrl:'${resource(dir:'shipper',file:'cont_autocomplete')}' });
    </script>
  </g:if>  
    <script type="text/javascript">
      var _gaq = _gaq || [];
      _gaq.push(['_setAccount', 'UA-44545306-3']);
      _gaq.push(['_setDomainName', 'containerovoz.ru']);
      _gaq.push(['_trackPageview']);      
      (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
      })();    
      (function (d, w, c) {
        (w[c] = w[c] || []).push(function() {
          try {
            w.yaCounter22476109 = new Ya.Metrika({id:22476109,webvisor:true,clickmap:true,accurateTrackBounce:true});
          } catch(e) { }
        });
        var n = d.getElementsByTagName("script")[0],
        s = d.createElement("script"),
        f = function () { n.parentNode.insertBefore(s, n); };
        s.type = "text/javascript";
        s.async = true;
        s.src = (d.location.protocol == "https:" ? "https:" : "http:") + "//mc.yandex.ru/metrika/watch.js";
        if (w.opera == "[object Opera]") {
          d.addEventListener("DOMContentLoaded", f, false);
        } else { f(); }
      })(document, window, "yandex_metrika_callbacks");
    </script><!--/noindex-->    
	</body>
</html>
