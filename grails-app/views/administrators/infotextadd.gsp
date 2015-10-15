<html>
  <head>
    <title>Административное приложение containerovoz.ru</title>
    <meta name="layout" content="admin" />
    <g:javascript>
    function returnToList(){
	    $("returnToListForm").submit();
    }
    </g:javascript>
  </head>  
  <body>  
    <h1>Добавление ${!inrequest?.type?'новой страницы':'шаблона письма'}</h1>
  <g:if test="${flash?.error}">
    <div class="error-box">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul>
        <g:if test="${flash?.error.contains(1)}"><li>Вы не заполнили обязательное поле &laquo;Контроллер&raquo;</li></g:if>
        <g:if test="${flash?.error.contains(2)}"><li>Вы не заполнили обязательное поле &laquo;Экшен&raquo;</li></g:if>
        <g:if test="${flash?.error.contains(3)}"><li>Вы не заполнили обязательное поле &laquo;Название&raquo;</li></g:if>
      </ul>
    </div>
  </g:if>
    <g:form class="contact-form" name="saveInfotextForm" url="[controller:'administrators',action:'saveinfotext']" method="post" useToken="true">      
      <fieldset>
      <g:if test="${!inrequest?.type}">
        <label for="itemplate_id">Меню:</label>
        <select id="itemplate_id" name="itemplate_id">
          <option value="0" <g:if test="${inrequest?.itemplate_id==0}">selected="selected"</g:if>>без шаблона</option>
        <g:each in="${itemplate}" var="item">            
          <option value="${item?.id}" <g:if test="${inrequest?.itemplate_id==item?.id}">selected="selected"</g:if>>${item?.name}</option>
        </g:each>
        </select><br/>
        <label for="npage">№ п/п в меню:</label>
        <input type="text" id="npage" name="npage" placeholder="0" value="${inrequest?.npage?:''}" /><br/>        
        <label for="tcontroller">Контроллер:</label>
        <input type="text" id="tcontroller" name="tcontroller" value="${inrequest?.tcontroller?:''}" placeholder="Контроллер" <g:if test="${(flash?.error?:[]).contains(1)}">class="red"</g:if> /><br/>        
      </g:if>
        <label for="taction">Экшен:</label>
        <input type="text" id="taction" name="taction" value="${inrequest?.taction?:''}" placeholder="Экшен" <g:if test="${(flash?.error?:[]).contains(2)}">class="red"</g:if> /><br/>
        <label for="name">Название:</label>
        <input type="text" id="name" name="name" value="${inrequest?.name?:''}" placeholder="Название" <g:if test="${(flash?.error?:[]).contains(3)}">class="red"</g:if> />
        <div class="clear"></div>
        <div class="btns fleft">
          <input type="submit" class="button" value="Добавить" />
          <input type="reset" class="button" onclick="returnToList()" value="Отмена" />
        </div>
      </fieldset>
      <input type="hidden" id="type" name="type" value="${inrequest?.type?:0}" />
    </g:form>
    <g:form name="returnToListForm" url="${[controller:'administrators',action:'infotext', params:[fromEdit:1, type:inrequest?.type?:0]]}">
    </g:form>    
  </body>
</html>
