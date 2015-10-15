<html>
  <head>
    <title>Административное приложение containerovoz.ru</title>
    <meta name="layout" content="admin" />
    <g:javascript>      
      function setActive(lId,iStatus){
        if(iStatus=="0"){
          if(confirm('Вы подтверждаете деактивацию?'))
            <g:remoteFunction action='activateSyscompany' onSuccess="\$('syscompany_submit_button').click()" params="'id='+lId+'&status=0'" />
        }else if(confirm('Вы подтверждаете активацию?'))
            <g:remoteFunction action='activateSyscompany' onSuccess="\$('syscompany_submit_button').click()" params="'id='+lId+'&status=1'" />
      }      
    </g:javascript>
    <style type="text/css">
      .contact-form select{width:180px}
    </style>
  </head>
	<body onload="\$('syscompany_submit_button').click()">
    <div class="menu admin" id="syscompanyfilter">
      <g:formRemote class="contact-form nopad" name="requestsForm" url="[action:'syscompanylist']" update="[success:'resultlist']">
        <fieldset>
          <label for="status" class="auto">Статус:</label>
          <g:select name="status" class="auto nopad" keys="${[1,0]}" from="${['Активные', 'Неактивные']}"/>
          <div class="btns fright">
            <input type="submit" class="button" id="syscompany_submit_button" value="Показать" />
            <g:link action="syscompanydetail" class="button">Добавить новую</g:link>
          </div>
        </fieldset>
      </g:formRemote>      
    </div>
    <div id="resultlist"></div>
  </body>
</html>
