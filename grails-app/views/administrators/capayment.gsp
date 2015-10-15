<html>
  <head>
    <title>Административное приложение containerovoz.ru</title>
    <meta name="layout" content="admin" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'kendo.default.min.css')}" type="text/css" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'kendo.common.min.css')}" type="text/css" />
    <g:javascript library="kendo.culture.ru-RU.min" />
    <g:javascript library="kendo.web.min" />
    <g:javascript>
      function returnToList(){
        $("returnToListForm").submit();
      }
      function contpay(sTripId,spClass,sIsSecond,sOrderId){
        $('paymentparams_trip_id').value = sTripId
        $('paymentparams_pclass').value = spClass
        $('paymentparams_is_second').value = sIsSecond
        $('paymentparams_payorder_id').value = sOrderId
        $('submit_button').click();
      }
    </g:javascript>
    <style type="text/css">
      .grid_6 .link{color:#fff;font-size:18px;margin-left:15px;text-decoration:underline}
      .contact-form input.mini{width:40px}
      table.list tbody td {background: none}
    </style>
  </head>
	<body onload="\$('capayment_submit_button').click()">
    <h1 class="fleft">Оплата перевозчикам</h1>
    <a class="link fright" href="javascript:void(0)" onclick="returnToList();">К списку ордеров</a>
    <div class="clear pad"></div>
    <div class="menu admin">
      <div class="clear"></div>
      <g:form class="contact-form nopad" name="capaymentForm" controller="administrators" action="capaymentreport" target="_blank">
        <fieldset>
          <label class="auto" for="client_id">Перевозчик:</label>
          <g:select name="client_id" style="width:200px" from="${clientnames.collect{it[0]}}" keys="${clientnames.collect{it[1]}}" noSelection="${['0':'Все']}" />
          <label class="auto" for="contnumber">Контейнер:</label>
          <input type="text" id="contnumber" name="contnumber"/>
          <div class="btns fright">
            <input type="submit" class="button" value="Отчет за сегодня" />
            <g:submitToRemote class="button" id="capayment_submit_button" value="Показать" url="[action:'nonpaydcontainers']" update="[success:'resultlist']"/>
            <input type="reset" class="button" value="Сброс"/>
          </div>
        </fieldset>
      </g:form>
      <g:formRemote url="${[action:'capay']}" class="contact-form nopad" name="capaymentparamsForm" onSuccess="\$('capayment_submit_button').click()">
        <label class="auto" for="norder">Номер платежа:</label>
        <input class="nopad" type="text" id="norder" name="norder"/>
        <label for="paydate">Дата платежа:</label>
        <g:datepicker name="paydate" value="${String.format('%td.%<tm.%<tY',new Date())}" />
        <input type="hidden" id="paymentparams_trip_id" name="id" value="0"/>
        <input type="hidden" id="paymentparams_pclass" name="pclass" value="0"/>
        <input type="hidden" id="paymentparams_is_second" name="is_second" value="0"/>
        <input type="hidden" id="paymentparams_payorder_id" name="payorder_id" value="0"/>
        <input type="submit" style="display:none" id="submit_button" class="button" value="Сохранить" />
      </g:formRemote>
    </div>
    <div id="resultlist"></div>
    <g:form id="returnToListForm" name="returnToListForm" url="${[action:'financial',params:[fromDetails:1]]}">
    </g:form>
  </body>
</html>