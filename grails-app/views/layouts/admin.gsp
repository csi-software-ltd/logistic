<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ru" lang="ru">
  <head>
    <title><g:layoutTitle default="Navigator" /></title>
    <meta http-equiv="content-language" content="ru" />
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />      
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />               
    <meta name="copyright" content="Navigator" />    
    <meta name="resource-type" content="document" />
    <meta name="document-state" content="dynamic" />
    <meta name="revisit" content="1" />
    <meta name="viewport" content="width=1000,maximum-scale=1.0" />     
    <meta name="robots" content="noindex,nofollow" /> 
    <link rel="stylesheet" href="${resource(dir:'css',file:'reset.css')}" type="text/css" />    
    <link rel="stylesheet" href="${resource(dir:'css',file:'grid.css')}" type="text/css" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'forms.css')}" type="text/css" />    
    <link rel="stylesheet" href="${resource(dir:'css',file:'style.css')}" type="text/css" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'font-awesome.min.css')}" type="text/css" />    
    <g:layoutHead />
    <g:javascript library="jquery-1.10.1.min" />    
    <g:javascript library="application" />
    <g:javascript library="prototype/prototype" />
    <g:if test="${admin?.menu?.find{it.id==12}}">
      <g:javascript library='prototype/autocomplete' />
    </g:if>
    <g:if test="${controllerName=='administrators' && actionName in ['terminaldetail','trackerdetail','orderdetail','monitoring','tripdetail','trackers']}">
      <script src="https://api-maps.yandex.ru/2.0/?load=package.standard,package.geoObjects&lang=ru-RU" type="text/javascript"></script>
    </g:if>
    <!--[if lt IE 7]>
  		<div class='aligncenter'><a href="http://www.microsoft.com/windows/internet-explorer/default.aspx?ocid=ie6_countdown_bannercode"><img src="http://storage.ie6countdown.com/assets/100/images/banners/warning_bar_0000_us.jpg" border="0"></a></div>  
    <![endif]-->
    <!--[if lt IE 9]>    
      <g:javascript library="html5" />
      <link rel="stylesheet" href="${resource(dir:'css',file:'ie.css')}" type="text/css" />   		  		
    <![endif]-->    
    <r:layoutResources/>
    <script type="text/javascript">
      jQuery(document).ready(function(){
        if(navigator.userAgent.search('Trident/7.0')>-1 || navigator.userAgent.search('MSIE')>-1)      
          jQuery('input[type="submit"],input[type="reset"],input[type="button"],a.button,.button').css('padding','7px 10px');
      });
    </script>		
  </head>
  <body onload="${pageProperty(name:'body.onload')}">
    <div class="content_tail">
      <!--==============================header=================================-->
      <div class="header-bg2">
        <div class="bg1">
          <header>
            <div class="main">
              <a class="logo" title="Containerovoz — главная страница" href="${g.createLink(uri:'',absolute:true)}">Containerovoz</a>
              <div class="fright pad-top3" style="width:253px">
              <g:if test="${admin}">
                <div class="fleft">
                  <g:form class="contact-form nopad" name="menuForm" url="[controller:'administrators',action:'menu']" method="post">
                    <label for="menu" class="auto" style="margin:0">Меню</label>&nbsp;
                    <select name="menu" id="menu" onchange="$('menuForm').submit();" style="width:205px!important">
                    <g:each in="${admin?.menu}" var="item">
                    <g:if test="${item.id!=15}">
                      <option value="${item.id}" <g:if test="${action_id==item.id}">selected="selected"</g:if>>${item.name}</option>
                    </g:if>
                    </g:each>
                    </select>
                  </g:form>
                <g:if test="${admin?.menu?.find{it.id==12}&&actionName!='contsearch'}">
                  <g:form class="contact-form nopad" name="contsearchForm" url="[controller:'administrators',action:'contsearch']" method="post">
                    <label for="contnomer" class="auto" style="margin:0">Контейнер</label>&nbsp;
                    <span class="input-append">
                      <input type="text" class="nopad normal" id="contnomer" name="cont" />
                      <span class="add-on" onclick="$('contsearch_submit_button').click()" style="height:13px"><i class="icon-search"></i></span>
                    </span>
                    <div id="cont_autocomplete" class="autocomplete" style="display:none"></div>
                    <input type="submit" id="contsearch_submit_button" style="display:none" value="Найти">
                  </g:form>
                </g:if>
                </div>
              </g:if>                    
              </div>
              <div class="fright pad-top3 padding-right1">
                <h4>Административное приложение</h4>
              <g:if test="${admin}">
                <div class="user fleft" style="padding:8px 0">
                  <span class="icon-lock icon-1x icon-light"></span> <span class="user-login" id="user">${admin?.login?:''}</span>
                <g:if test="${admin.menu.find{it.id==15}}">
                  <a class="icon-android icon-1x${admin.menu.find{it.id==15}.is_on?' active':''}" title="${admin.menu.find{it.id==15}.is_on?'Выключить автопилот':'Включить автопилот'}" onclick="autopilot(this)" href="javascript:void(0)"></a>
                </g:if>
                  <a class="icon-bell-alt icon-1x icon-light" title="Уведомления" href="${admin.notice_count==1?createLink(action:'orderdetail',id:admin.notice_id):createLink(action:'zakaz')}">
                  <g:if test="${admin.notice_count}">
                    <div class="new">${admin.notice_count}</div>
                  </g:if>
                  </a>
                  <a class="icon-comment icon-1x icon-light" title="Сообщения" href="${g.createLink(action:'monitoring',params:[type:1])}">
                  <g:if test="${admin.events_count}">
                    <div class="new">${admin.events_count}</div>
                  </g:if>
                  </a>
                  <a class="icon-bar-chart icon-1x icon-light" title="Статистика" onclick="showstat()" href="javascript:void(0)"> </a>
                  <a class="icon-signout icon-2x icon-light" title="Выход" href="${g.createLink(controller:'administrators',action:'logout')}"> </a>
                </div>
              </g:if>
              </div>              
              <div id="statcontainer" align="center" style="clear:both;width=100%;display:none">some text</div>
            </div>
          </header>
        </div>
      </div>
      <!--==============================content================================-->
      <section id="content">
        <div class="bg2" style="min-height:690px">
          <div class="content-top">
            <div class="container_12">             
            <g:if test="${session.attention_message && actionName!='index'}">                    
              <div class="container_12">
                <div class="error-box" style="margin-top:0">
                  <span class="icon icon-info-sign icon-3x"></span>
                  ${session.attention_message}
                </div>                                               
              </div>
            </g:if>
            <g:if test="${controllerName=='administrators' && !(actionName in ['index','profile','infotextadd','infotextedit','containerdetail','terminaldetail','clientdetail','userdetail','trackerdetail','orderdetail','tripdetail','contsearch','syscompanydetail','payorderdetail','findetail','routedetail','capayment','shbenefit','newpayment'])}">
              <g:each in="${admin?.menu}" var="item"><g:if test="${action_id==item.id}">
              <h1 class="padding-bottom">${item.name}</h1>
              </g:if></g:each>     
            </g:if>
              <g:layoutBody />            
              <div class="clear"></div>
            </div>
          </div>
        </div>
      </section>
    </div>    
    <r:layoutResources/>
  <g:if test="${admin?.menu?.find{it.id==12}}">
    <script type="text/javascript">
      new Autocomplete('contnomer', { serviceUrl:'${resource(dir:'administrators',file:'cont_autocomplete')}' });
    </script>
  </g:if>
  <g:if test="${admin?.menu?.find{it.id==15}}">
    <script type="text/javascript">
      function autopilot(el){
        jQuery(el).toggleClass('active');
        jQuery(el).attr('title',(jQuery(el).hasClass('active'))?'Выключить автопилот':'Включить автопилот');
        <g:remoteFunction url="${[controller:'administrators',action:'autopilot',params:[margin:admin.menu.find{it.id==15}.margin,is_on:2]]}" onSuccess="${actionName=='profile'?'location.reload(true)':''}" />
      }
    </script>
  </g:if>
    <script type="text/javascript">
      var toggle=0;
      function togglestat(){
        if(toggle==0){
          jQuery('.header-bg2').animate({ height: "120" }, 500);
          jQuery('#statcontainer').slideToggle();
          toggle = 1;
        } else {
          jQuery('.header-bg2').animate({ height: "100" }, 500);
          jQuery('#statcontainer').slideToggle();
          toggle = 0;
        }
      }
      function showstat(){
        <g:remoteFunction action="getstat" controller="administrators" update="[success:'statcontainer']" onComplete="togglestat()" />
      }
    </script>
  </body>
</html>
