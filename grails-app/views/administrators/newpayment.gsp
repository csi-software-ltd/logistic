<html>
  <head>
    <title>Административное приложение containerovoz.ru</title>
    <meta name="layout" content="admin" />
    <g:javascript>
      function returnToList(){
        $("returnToListForm").submit();
      }
      function togglecompanies(sClId){
        $('clientcompany_id').selectedIndex=0;
        jQuery("#clientcompany_id option").each(function(el){
          var el = jQuery(this);
          if(el.parent().is( "span" )) el.unwrap();
        });
        if(sClId!=0) jQuery("#clientcompany_id option[class!=cl"+sClId+"]").not('.cl0').wrap( "<span>" );
      }
      function orderpay(sOrderId){
        $('paymentparams_payorder_id').value = sOrderId
        $('submit_button').click();
      }
      function processResponse(e){
        ['platnumber','summa'].forEach(function(ids){
          $(ids).removeClassName('red');
        });
        if(e.responseJSON.error){
          var sErrorMsg = '';
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Номер платежа"])}</li>'; $("platnumber").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Сумма"])}</li>'; $("summa").addClassName('red'); break;
              case 3: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Сумма"])}</li>'; $("summa").addClassName('red'); break;
              case 4: sErrorMsg+='<li>${message(code:"error.not.unique.message",args:["Платеж","номером"])}</li>'; $("platnumber").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        } else {
          $("errorlist").up('div').hide();
          $('payments_submit_button').click()
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
    </g:javascript>
    <style type="text/css">
      .grid_6 .link{color:#fff;font-size:18px;margin-left:15px;text-decoration:underline}
      .contact-form input.mini{width:40px}
      table.list tbody td {background: none}
    </style>
  </head>
	<body onload="\$('payments_submit_button').click()">
    <h1 class="fleft">Новый платеж</h1>
    <a class="link fright" href="javascript:void(0)" onclick="returnToList();">К списку оплат</a>
    <div class="clear pad"></div>
    <div class="error-box" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>
    </div>
    <div class="menu admin">
      <div class="clear"></div>
      <g:formRemote class="contact-form nopad" name="paymentsForm" url="[action:'nonpaidorders']" update="[success:'resultlist']">
        <fieldset>
            <label class="auto" for="client_id">Клиент:</label>
            <g:select name="client_id" style="width:200px" from="${clientnames.collect{it[0]}}" keys="${clientnames.collect{it[1]}}" noSelection="${['0':'Все']}" onchange="togglecompanies(this.value)"/>
            <label class="auto" for="clientcompany_id">Компания:</label>
            <select name="clientcompany_id" id="clientcompany_id" style="width:246px">
              <option selected="selected" value="0" class="cl0">Все</option>
            <g:each in="${clientcompanies}">
              <option value="${it[1]}" class="cl${it[2]}">${it[0]}</option>
            </g:each>
            </select>
          <div class="btns fright">
            <g:submitButton class="button" name="payments_submit_button" id="payments_submit_button" value="Показать"/>
            <input type="reset" class="button" value="Сброс"/>
          </div>
        </fieldset>
      </g:formRemote>
      <g:formRemote url="${[action:'orderpay']}" class="contact-form nopad" name="orderpaymentparamsForm" onSuccess="processResponse(e)">
        <label class="auto" for="platnumber">Номер платежа:</label>
        <input class="nopad" type="text" id="platnumber" name="platnumber"/>
        <label class="auto" for="summa">Сумма платежа:</label>
        <input class="nopad" type="text" id="summa" name="summa"/>
        <input type="hidden" id="paymentparams_payorder_id" name="payorder_id" value="0"/>
        <input type="submit" style="display:none" id="submit_button" class="button" value="Сохранить" />
      </g:formRemote>
    </div>
    <div id="resultlist"></div>
    <g:form id="returnToListForm" name="returnToListForm" url="${[action:'payorders',params:[type:1]]}">
    </g:form>
  </body>
</html>