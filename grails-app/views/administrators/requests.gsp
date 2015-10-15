<html>
  <head>
    <title>Административное приложение containerovoz.ru</title>
    <meta name="layout" content="admin" />
    <g:javascript>
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
      function confirmDocument(lId){
        if(confirm('Вы подтверждаете сдачу?'))
          <g:remoteFunction action='documentconfirm' onSuccess="\$('requests_submit_button').click()" params="'id='+lId" />
      }
      function cancellConfirmDocument(lId){
        if(confirm('Отменить сдачу документов?'))
          <g:remoteFunction action='documentcancell' onSuccess="\$('requests_submit_button').click()" params="'id='+lId" />
      }
    </g:javascript>
    <style type="text/css">
      .contact-form select{width:180px}
      .box-iframe,#map_canvas{width:930px;height:400px}      
    </style>
  </head>
	<body onload="\$('requests_submit_button').click()">
    <div class="menu admin">
      <div id="tripfilter">
        <g:formRemote class="contact-form nopad" name="requestsForm" url="[action:'requestlist']" update="[success:'resultlist']">
          <fieldset>
            <label for="trip_id" class="auto">Код:</label>
            <input type="text" id="trip_id" name="trip_id" style="width:50px" value="${inrequest?.trip_id}"/>
            <label for="zakaz_id" class="auto">Заказ:</label>
            <input type="text" id="zakaz_id" name="zakaz_id" style="width:50px" value="${inrequest?.zakaz_id}"/>
            <label class="auto" for="cargosnomer">Тягач:</label>
            <input type="text" id="cargosnomer" name="cargosnomer" class="mini" value="${inrequest?.cargosnomer}" />
            <label for="container" class="auto">Контейнер:</label>
            <input type="text" id="container" name="container" class="mini" value="${inrequest?.container}"/>
            <label for="shipper" class="auto">Отправитель:</label>
            <input type="text" id="shipper" name="shipper" class="mini" value="${inrequest?.shipper}"/><br/>
            <label for="modstatus" class="auto">Статус поездки:</label>
            <select id="modstatus" class="auto nopad" name="modstatus">
              <option value="-101" <g:if test="${inrequest?.modstatus==-101}">selected="selected"</g:if>>активные</option>
            <g:each in="${tripstatus}">
              <option value="${it.id}" <g:if test="${inrequest?.modstatus==it.id}">selected="selected"</g:if>>${it.status}</option>
            </g:each>
              <option value="-100" <g:if test="${inrequest?.modstatus==-100}">selected="selected"</g:if>>все</option>
            </select>
            <label for="taskstatus" class="auto">Статус сдачи:</label>
            <g:select name="taskstatus" class="auto nopad" value="${inrequest?.taskstatus}" from="${taskstatus+[id:-101,status:'Документы не сданы']}" optionKey="id" optionValue="status" noSelection="${['-100':'Все']}"/>
            <div class="btns fright">
              <input type="submit" class="button" id="requests_submit_button" value="Показать" />
              <input type="reset" class="button" value="Сброс" />
            </div>
          </fieldset>
        </g:formRemote>
      </div>
    </div>
    <div id="resultlist"></div>
  </body>
</html>
