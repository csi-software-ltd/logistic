<html>
  <head>
    <title>Административное приложение containerovoz.ru</title>
    <meta name="layout" content="admin" />
    <g:javascript>
      function initialize(iParam){
        $('upload_target').hide();
        $('upload_target2').hide();
        switch(iParam){
          case 0:
            sectionColor('orders');
            $('orderfilter').show();
            $('paymentfilter').hide();
            $('orders_submit_button').click();
            break;
          case 1:
            sectionColor('payment');
            $('orderfilter').hide();
            $('paymentfilter').show();
            $('payments_submit_button').click();
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
      function sectionColor(sSection){
        $('orders').style.color = 'black';
        $('payment').style.color = 'black';
        $(sSection).style.color = '#0080F0';
      }
      function togglecompanies(sClId){
        $('clientcompany_id').selectedIndex=0;
        jQuery("#clientcompany_id option").each(function(el){
          var el = jQuery(this);
          if(el.parent().is( "span" )) el.unwrap();
        });
        if(sClId!=0) jQuery("#clientcompany_id option[class!=cl"+sClId+"]").not('.cl0').wrap( "<span>" );
      }
      function confirmDocument(lId,element){
        if(confirm('Вы подтверждаете передачу документов?'))
          <g:remoteFunction action='documenttransfer' onSuccess="updatebutton(element,2,lId)" params="'id='+lId" />
      }
      function cancellConfirmDocument(lId,element){
        if(confirm('Отменить передачу документов?'))
          <g:remoteFunction action='cancelltransfer' onSuccess="updatebutton(element,3,lId)" params="'id='+lId" />
      }
      function confirmAct(lId,element){
        if(confirm('Вы подтверждаете передачу акта выполненных работ?'))
          <g:remoteFunction action='orderactconfirm' onSuccess="updatebutton(element,0,lId)" params="'id='+lId" />
      }
      function cancellConfirmAct(lId,element){
        if(confirm('Отменить передачу акта?'))
          <g:remoteFunction action='cancellorderract' onSuccess="updatebutton(element,1,lId)" params="'id='+lId" />
      }
      function updatebutton(el,type,lId){
        switch(type){
          case 0:
            $(el).onclick=function(){cancellConfirmAct(lId,el)};
            $(el).innerHTML='<span class="icon-stack"><i class="icon-bookmark icon-stack-base icon-light"></i><i class="icon-ban-circle" style="left:-2px;color:red;opacity:.7"></i></span>';
            break;
          case 1:
            $(el).onclick=function(){confirmAct(lId,el)};
            $(el).innerHTML='<i class="icon-bookmark"></i>';
            break;
          case 2:
            $(el).onclick=function(){cancellConfirmDocument(lId,el)};
            $(el).innerHTML='<span class="icon-stack"><i class="icon-suitcase icon-stack-base icon-light"></i><i class="icon-ban-circle" style="left:-2px;color:red;opacity:.7"></i></span>';
            break;
          case 3:
            $(el).onclick=function(){confirmDocument(lId,el)};
            $(el).innerHTML='<i class="icon-suitcase"></i>';
            break;
        }
      }
    </g:javascript>
    <style type="text/css">
      .grid_4 .link{color:#fff;font-size:18px;margin-left:15px;text-decoration:underline}
      .contact-form input.mini{width:40px}
      .icon-stack{width:15px;height:1em;line-height:1em;}
      .icon-stack [class^="icon-"],.icon-stack [class*=" icon-"]{font-size:2em;*line-height:1em;}
      .icon-stack .icon-stack-base{font-size:1em;*line-height:1em;}
    </style>
  </head>
	<body onload="initialize(${type})">
    <div class="menu admin">
      <div class="grid_4 p3 fright" align="right">
        <a class="link" href="javascript:void(0)" onclick="initialize(0)" id="orders">Счета</a>
        <a class="link" href="javascript:void(0)" onclick="initialize(1)" id="payment">Оплаты</a>
      </div>
      <div class="clear"></div>
      <div id="orderfilter" style="display:none">
        <g:formRemote class="contact-form nopad" name="allForm" url="[action:'payorderlist']" update="[success:'resultlist']">
          <fieldset>
            <label class="auto" for="norder">Счет:</label>
            <input type="text" id="norder" name="norder" value=""/>
            <label class="auto" for="syscompany_id">Сис. компания:</label>
            <g:select name="syscompany_id" style="width:246px" from="${Syscompany.list()}" optionKey="id" optionValue="name" noSelection="${['0':'Все']}"/>
            <label class="auto" for="modstatus">Статус:</label>
            <select id="modstatus" name="modstatus" class="auto">
              <option value="-100">все</option>
              <option value="0">новые</option>
              <option value="1">подтвержденные</option>
              <option value="2">синхронизированые</option>
            </select><br/>
            <label class="auto" for="client_id">Клиент:</label>
            <g:select name="client_id" style="width:200px" from="${clientnames.collect{it[0]}}" keys="${clientnames.collect{it[1]}}" noSelection="${['0':'Все']}" onchange="togglecompanies(this.value)"/>
            <label class="auto" for="clientcompany_id">Компании:</label>
            <select name="clientcompany_id" id="clientcompany_id" style="width:246px">
              <option value="0" class="cl0">Все</option>
            <g:each in="${clientcompanies}">
              <option value="${it[1]}" class="cl${it[2]}">${it[0]}</option>
            </g:each>
            </select>
            <label class="auto" for="is_docdate">Документы:</label>
            <select id="is_docdate" name="is_docdate" class="auto">
              <option value="-100">пофиг</option>
              <option value="0">нет</option>
              <option value="1">да</option>
            </select>
            <label class="auto" for="is_act">Акты:</label>
            <select id="is_act" name="is_act" class="auto">
              <option value="-100">пофиг</option>
              <option value="0">нет</option>
              <option value="1">да</option>
            </select>
            <div class="btns">
              <g:link class="button" controller="administrators" action="unloadingOrders">Экспорт в 1C</g:link>
              <g:remoteLink class="button" controller="administrators" action="generateorders" onSuccess="alert('ok');\$('orders_submit_button').click();">Формирануть счета</g:remoteLink>
              <input type="submit" class="button" id="orders_submit_button" value="Показать" />
              <input type="reset" class="button" value="Сброс" />
            </div>            
          </fieldset>
        </g:formRemote>
        <div class="fleft" style="margin:-20px 10px 0;position:absolute;z-index:100">
          <g:form name="import" method="post" url="${[action:'uploadingOrders']}" enctype="multipart/form-data" target="upload_target">
            <label for="file" style="padding-right:10px">Импорт счетов 1С:</label>
            <input type="file" name="file" id="file" size="23" accept="application/xml" onchange="$('xmlimport_submit_button').click()"/>
            <input type="hidden" name="type" value="Orders">
            <input type="submit" id="xmlimport_submit_button" style="display:none">
          </g:form>
        </div>
        <iframe id="upload_target" name="upload_target" src="#" style="display:none;width:900px;height:40px;border:none;"></iframe>
      </div>
      <div id="paymentfilter" style="display:none">
        <g:formRemote class="contact-form nopad" name="allForm" url="[action:'paymentlist']" update="[success:'resultlist']">
          <fieldset>
            <label class="auto" for="norder">Счет:</label>
            <input type="text" id="norder" name="norder" value="" class="mini"/>
            <label class="auto" for="platnumber">№ платежки:</label>
            <input type="text" id="platnumber" name="platnumber" value="" class="mini"/>
            <label class="auto" for="clientpayment_id">Клиент:</label>
            <g:select name="clientpayment_id" style="width:200px" from="${clientnames.collect{it[0]}}" keys="${clientnames.collect{it[1]}}" noSelection="${['0':'Все']}"/>
            <label class="auto" for="modstatus">Статус:</label>
            <select id="modstatus" name="modstatus" class="auto">
              <option value="-100">все</option>
              <option value="0">нераспознанные</option>
              <option value="1">квитанции</option>
              <option value="2">подтвержденные</option>
            </select><br/>
            <span class="button-top fleft">
              <label for="is_fix" class="nopad auto">Корректировка:</label>
              <input type="checkbox" id="is_fix" name="is_fix" value="1"/>            
            </span>
            <div class="btns fright">
              <g:link class="button" controller="administrators" action="unloadingPayments">Экспорт в 1C</g:link>
              <g:link action="newpayment" class="button">Новая</g:link>
              <input type="submit" class="button" id="payments_submit_button" value="Показать" />
              <input type="reset" class="button" value="Сброс" />
            </div>
          </fieldset>
        </g:formRemote>
        <div class="fleft" style="margin:-30px 10px 0 175px;position:absolute;z-index:100">
          <g:form name="import" method="post" url="${[action:'uploadingOrders']}" enctype="multipart/form-data" target="upload_target2">
            <label for="file" style="margin-right:10px">Импорт платежей 1С:</label>
            <input type="file" name="file" id="file" size="23" accept="application/xml" onchange="$('xmlplatimport_submit_button').click()"/>
            <input type="hidden" name="type" value="Payments">
            <input type="submit" id="xmlplatimport_submit_button" style="display:none">
          </g:form>
        </div>
        <iframe id="upload_target2" name="upload_target2" src="#" style="display:none;width:900px;height:40px;border:none;"></iframe>
      </div>
    </div>
    <div id="resultlist"></div>
  </body>
</html>
