<html>
  <head>
    <title>Административное приложение containerovoz.ru</title>
    <meta name="layout" content="admin" />
    <g:javascript>
      function initialize(iParam){
        switch(iParam){
          case 0:
            sectionColor('infotext');
            $('homelist').show();
            $('placeList').hide();          
            $('user_submit_button').click();
            $('companystat').setStyle({height: '450px'}); 
            break;
          case 1:
            sectionColor('mail');
            $('homelist').hide();
            $('placeList').show();
            $('mail_submit_button').click();
            $('companystat').setStyle({height: '575px'}); 
            break;
        }
      }	  
      function clickPaginate(event){
        event.stop();
        var link = event.element();
        if(link.href == null){
          return;
        }    
        new Ajax.Updater(
          { success: $('ajax_wrap') },
          link.href,
          { evalScripts: true });		  
      }        
      function resetData(){
        $('inf_action').setValue('');
        $('inf_controller').setValue('');
        $('itemplate_id').selectedIndex = 0;
      }      
      function sectionColor(sSection){
        $('infotext').style.color = 'black';
        $('mail').style.color = 'black';
        $(sSection).style.color = '#0080F0';
      }
    </g:javascript>
    <style type="text/css">
      .grid_4 .link{color:#fff;font-size:18px;margin-left:15px;text-decoration:underline}      
      .contact-form input[type="text"],.contact-form select{width:180px}      
    </style>    
  </head>  
	<body onload="initialize(${type})">
    <div class="menu admin">      
      <div class="grid_4 p3 fright" align="right">
        <a class="link" href="javascript:void(0)" onclick="initialize(0)" id="infotext">Инфотексты</a>
        <a class="link" href="javascript:void(0)" onclick="initialize(1)" id="mail">Шаблоны писем</a>
      </div>      
      <div class="clear"></div>      
      <div id="homelist">
        <g:formRemote class="contact-form nopad" name="allForm" url="[action:'infotextlist']" update="[success:'companystat']">
          <fieldset>
            <label class="auto" for="menu">Меню:</label>
            <select id="itemplate_id" name="itemplate_id">
              <option value="-1" <g:if test="${inrequest?.itemplate_id==-1}">selected="selected"</g:if>></option>
              <option value="0" <g:if test="${inrequest?.itemplate_id==0}">selected="selected"</g:if>>без шаблона</option>
            <g:each in="${itemplate}" var="item">            
              <option value="${item?.id}" <g:if test="${inrequest?.itemplate_id==item?.id}">selected="selected"</g:if>>${item?.name}</option>
            </g:each>
            </select>
            <label class="auto" for="inf_controller">Контроллер:</label>
            <input type="text" id="inf_controller" name="inf_controller" value="${inrequest?.inf_controller}" />
            <label class="auto" for="inf_action">Экшен:</label>
            <input type="text" id="inf_action" name="inf_action" value="${inrequest?.inf_action}" />
            <div class="btns">                
              <input type="submit" class="button" id="user_submit_button" value="Показать" />
              <input type="button" class="button" value="Сброс" onclick="resetData();location.reload(true)" />
              <g:link controller="administrators" action="infotextadd" class="button">Добавить новую</g:link>
            </div>
          </fieldset>
        </g:formRemote>
      </div>
      <div id="placeList">
        <g:formRemote class="contact-form nopad" name="allForm" url="[action:'infotextlist', id:1]" update="[success:'companystat']">
          <fieldset>
            <label class="auto" for="inf_action">Экшен:</label>
            <input type="text" id="inf_action" name="inf_action" value="${inrequest?.inf_action}" />
            <div class="btns">
              <g:link controller="administrators" action="infotextadd" params="[type:'1']" class="button">Добавить шаблон</g:link>
              <input type="submit" class="button" id="mail_submit_button" value="Показать" />
              <input type="button" class="button" value="Сброс" onclick="$('inf_action').setValue('');" />
            </div>
          </fieldset>
        </g:formRemote>
      </div>    
    </div>
    <div id="companystat"></div>    
  </body>
</html>
