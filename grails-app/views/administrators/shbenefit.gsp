<html>
  <head>
    <title>Административное приложение containerovoz.ru</title>
    <meta name="layout" content="admin" />
    <g:javascript>
      function returnToList(){
        $("returnToListForm").submit();
      }
      function contpay(sOrderId,sCont){
        $('paymentparams_contnumber').value = sCont
        $('paymentparams_payorder_id').value = sOrderId
        $('submit_button').click();
      }
      function processResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['summa'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Сумма"])}</li>'; $("summa").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Сумма"])}</li>'; $("summa").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        } else {
          $("errorlist").up('div').hide();
          $('shbenefit_submit_button').click()
        }
      }
    </g:javascript>
    <style type="text/css">
      .grid_6 .link{color:#fff;font-size:18px;margin-left:15px;text-decoration:underline}
      .contact-form input.mini{width:40px}
      table.list tbody td {background: none}
    </style>
  </head>
	<body onload="\$('shbenefit_submit_button').click()">
    <h1 class="fleft">Оплата вознаграждения</h1>
    <a class="link fright" href="javascript:void(0)" onclick="returnToList();">К списку ордеров</a>
    <div class="clear pad"></div>
    <div class="error-box" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>
    </div>
    <div class="menu admin">
      <div class="clear"></div>
      <g:form class="contact-form nopad" name="shbenefitForm" controller="administrators" action="benefitreport" target="_blank">
        <fieldset>
          <label class="auto" for="client_id">Клиент:</label>
          <g:select name="client_id" style="width:200px" from="${clientnames.collect{it[0]}}" keys="${clientnames.collect{it[1]}}" noSelection="${['0':'Все']}" />
          <label class="auto" for="contnumber">Контейнер:</label>
          <input type="text" id="contnumber" name="contnumber"/>
          <div class="btns fright">
            <input type="submit" class="button" value="Отчет за сегодня" />
            <g:submitToRemote class="button" id="shbenefit_submit_button" value="Показать" url="[action:'nonbenefitcontainers']" update="[success:'resultlist']"/>
            <input type="reset" class="button" value="Сброс"/>
          </div>
        </fieldset>
      </g:form>
      <g:formRemote url="${[action:'benefitpay']}" class="contact-form nopad" name="benefitpaymentparamsForm" onSuccess="processResponse(e);">
        <label class="auto" for="summa">Сумма платежа:</label>
        <input class="nopad" type="text" id="summa" name="summa"/>
        <input type="hidden" id="paymentparams_payorder_id" name="id" value="0"/>
        <input type="hidden" id="paymentparams_contnumber" name="contnumber" value=""/>
        <input type="submit" style="display:none" id="submit_button" class="button" value="Сохранить" />
      </g:formRemote>
    </div>
    <div id="resultlist"></div>
    <g:form id="returnToListForm" name="returnToListForm" url="${[action:'financial',params:[fromDetails:1]]}">
    </g:form>
  </body>
</html>