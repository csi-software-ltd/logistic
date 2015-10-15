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
      <div class="header-bg1">
        <div class="bg1">
          <header>
            <div class="main">
              <a class="logo" title="Containerovoz — главная страница" href="${g.createLink(uri:'',absolute:true)}">Containerovoz</a>
              <div class="fright pad-top3" style="width:253px">
              </div>
              <div class="fright pad-top3 padding-right1">
                <h4>Административное приложение</h4>
              <g:if test="${admin}">
                <div class="user fleft" style="padding:8px 0">
                  <span class="icon-lock icon-1x icon-light"></span> <span class="user-login" id="user">${admin?.login?:''}</span>
                  <a class="icon-signout icon-2x icon-light" title="Выход" href="${g.createLink(controller:'administrators',action:'logout')}"> </a>
                </div>
              </g:if>
              </div>
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
              <g:layoutBody />
              <div class="clear"></div>
            </div>
          </div>
        </div>
      </section>
    </div>
    <r:layoutResources/>
  </body>
</html>