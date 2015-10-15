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
      function viewCell(iNum){
        var tabs = jQuery('.nav').find('li');
        for(var i=0; i<tabs.length; i++){
          if(i==iNum)
            tabs[i].addClassName('selected');
          else
            tabs[i].removeClassName('selected');
        }

        switch(iNum){
          case 0: getShSettl();break;
          case 1: getCaSettl();break;
          case 2: getCaPayments();break;
          case 3: getBenefitList();break;
        }
      }

      function getShSettl(){
        $('shippersettlements_submit_button').click();
      }
      function getCaSettl(){
        $('carriersettlements_submit_button').click();
      }
      function getCaPayments(){
        $('carrierpayments_submit_button').click();
      }
      function getBenefitList(){
        $('benefit_submit_button').click();
      }

      function processResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['summa','trip_id','norder'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Код счета"])}</li>'; break;
              case 2: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Поездка"])}</li>'; $("trip_id").addClassName('red'); break;
              case 3: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Сумма"])}</li>'; $("summa").addClassName('red'); break;
              case 4: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Поездка"])}</li>'; $("trip_id").addClassName('red'); break;
              case 5: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Номер платежа"])}</li>'; $("norder").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorcapayment").innerHTML=sErrorMsg;
          $("errorcapayment").up('div').show();
        } else {
          hideerrors("errorcapayment");
          getCaPayments();
        }
      }
      function editCaPayment(iId){
        hideerrors("errorcapayment");
        iId = iId || 0;
        $('payment_id').value = iId;
        $('paymentdetail_submit_button').click();
      }
      function deletecapayment(lId){
        <g:remoteFunction controller='administrators' action='deletecapayment' onSuccess="getCaPayments();" params="'id='+lId" />
      }
      function processEditBenefitPaymentResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['summa'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Код счета"])}</li>'; break;
              case 2: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Сумма"])}</li>'; $("summa").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorbenefitpayment").innerHTML=sErrorMsg;
          $("errorbenefitpayment").up('div').show();
        } else {
          hideerrors("errorbenefitpayment");
          getBenefitList();
        }
      }
      function editBenefitPayment(iId){
        hideerrors("errorbenefitpayment");
        iId = iId || 0;
        $('paybenefit_id').value = iId;
        $('editbenefitpayment_submit_button').click();
      }
      function deletebenefitpayment(lId){
        <g:remoteFunction controller='administrators' action='deletebenefitpayment' onSuccess="getBenefitList();" params="'id='+lId" />
      }
      function processOrderBenefitResponse(e){
        if(e.responseJSON.error){
          ['benefit'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          var sErrorMsg = '';
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: $("benefit").addClassName('red'); break;
            }
          });
        } else {
          getBenefitList();
        }
      }
      function hideerrors(sId){
        $(sId).up('div').hide();
      }
    </g:javascript>
    <style type="text/css">
      .contact-form label{min-width:130px}      
      .contact-form fieldset.bord{width:98%!important}
    </style>
  </head>
  <body onload="getShSettl()">
    <h1 class="fleft">Финансовые расчеты по счету № ${payorder.id}</h1>
    <a class="link fright" href="javascript:void(0)" onclick="returnToList();">К списку ордеров</a>
    <div class="clear"></div>
    <div class="error-box" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>
    </div>
    <form class="contact-form">
      <fieldset class="bord">
        <legend>Общие сведения</legend>
        <label for="syscompany">Системная компания:</label>
        <input type="text" id="syscompany" name="syscompany" value="${Syscompany.get(payorder.syscompany_id)?.name?:''}" />
      </fieldset>
      <fieldset class="bord">
        <legend>Данные отправителя</legend>
        <div class="grid_6 alpha">
          <label for="shipper">Отправитель:</label>
          <input type="text" id="shipper" name="shipper" value="${Client.get(payorder.client_id)?.fullname}" />
          <label for="contnumber">Кол-во контейнеров:</label>
          <input type="text" id="contnumber" name="contnumber" value="${payorder.contnumbers.split(',').size()}" />
          <label for="paystatus">Статус оплаты:</label>
          <input type="text" id="paystatus" name="paystatus" value="${payorder.paystatus==1?'частично оплачено':payorder.paystatus==2?'оплачено':'неоплачено'}" />
        </div>
        <div class="grid_6 omega">
          <label for="clientcompany">Компания:</label>
          <input type="text" id="clientcompany" name="clientcompany" value="${clientcompany?.payee?:''}" />
          <label for="nds">НДС отправителя:</label>
          <input type="text" id="nds" name="nds" value="${clientcompany?.nds?:'без НДС'}" />
          <label for="debt">Долг отправителя:</label>
          <input type="text" id="debt" name="debt" value="${debt>0&&payorder.maxpaydate?.before(new Date().clearTime())?debt:'нет'}" />
        </div>
      </fieldset>
    </form>
    <div class="tabs">
      <ul class="nav">
        <li class="selected"><a href="javascript:void(0)" onclick="viewCell(0)">Расчеты с отправителем</a></li>
        <li><a href="javascript:void(0)" onclick="viewCell(1)">Расчеты с перевозчиками</a></li>
        <li><a href="javascript:void(0)" onclick="viewCell(2)">Платежи перевозчикам</a></li>
        <li><a href="javascript:void(0)" onclick="viewCell(3)">Вознаграждение</a></li>
      </ul>
      <div class="tab-content">
        <div class="inner">
          <div id="details"></div>
        </div>
      </div>
    </div>
    <g:formRemote name="shippersettlementsForm" url="[action:'shpayments',id:payorder.id]" update="[success:'details']">
      <input type="submit" class="button" id="shippersettlements_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
    <g:formRemote name="carriersettlementsForm" url="[action:'casettlment',id:payorder.id]" update="[success:'details']">
      <input type="submit" class="button" id="carriersettlements_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
    <g:formRemote name="carrierpaymentsForm" url="[action:'capayments',id:payorder.id]" update="[success:'details']">
      <input type="submit" class="button" id="carrierpayments_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
    <g:formRemote name="benefitForm" url="[action:'benefitlist',id:payorder.id]" update="[success:'details']">
      <input type="submit" class="button" id="benefit_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
    <g:form id="returnToListForm" name="returnToListForm" url="${[action:'financial',params:[fromDetails:1]]}">
    </g:form>
  </body>
</html>
