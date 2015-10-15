<html>
  <head>
    <title>Административное приложение</title>
    <meta name="layout" content="admin" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'kendo.default.min.css')}" type="text/css" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'kendo.common.min.css')}" type="text/css" />
    <g:javascript library="kendo.culture.ru-RU.min" />
    <g:javascript library="kendo.web.min" />
    <g:javascript>
      function returnToList(){
        $("returnToListForm").submit();
      }
      function processResponse(e){
        if(e.responseJSON.error){
        } else {
          location.reload(true);
        }
      }
    </g:javascript>
    <style type="text/css">
      .contact-form label{min-width:170px!important}      
    </style>
  </head>
  <body>
    <h1 class="fleft">${'Счет №'+payorder.id}</h1>
    <a class="link fright" href="javascript:void(0)" onClick="returnToList();">К списку счетов</a>
    <div class="clear"></div>
    <div class="info-box" style="${(curclientcompany?.nds?:0)==(cursyscompany?.nds?:curclientcompany?.nds?:0)?'display:none':''}">
      <span class="icon icon-info-sign icon-3x"></span>
      <ul id="infolist">
        <li>НДС компании клиента и системной компании не совпадают</li>
      </ul>
    </div>
    <div class="error-box" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>
    </div>
    <g:formRemote class="contact-form" name="payorderDetailForm" url="[action:'savePayorderDetail', id:payorder.id]" method="post" onSuccess="processResponse(e)">
      <fieldset class="grid_6 alpha">
        <label for="syscompany_id">Сис. компания:</label>
        <g:select name="syscompany_id" value="${payorder.syscompany_id}" from="${Syscompany.list()}" optionKey="id" optionValue="name" noSelection="${['0':'Не задано']}"/>
        <label for="docdate">Дата передачи документов:</label>
        <g:datepicker class="normal nopad" name="docdate" value="${payorder.docdate?String.format('%td.%<tm.%<tY',payorder.docdate):''}" />
        <label for="clientcompany_id">Клиент. компания:</label>
        <g:select name="clientcompany_id" value="${payorder.clientcompany_id}" from="${clientcompanies}" optionKey="id" optionValue="payee" noSelection="${['0':'Не задано']}"/>
        <div class="btns">
          <input type="submit" id="submit_button" class="button" value="Сохранить"/>
        </div>
      </fieldset>
    </g:formRemote>
    <g:form id="returnToListForm" name="returnToListForm" url="${[action:'payorders']}">
    </g:form>
  </body>
</html>
