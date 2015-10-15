<html>
  <head>
    <title>Административное приложение containerovoz.ru</title>
    <meta name="layout" content="admin" />
    <g:javascript>
      function initialize(iParam){
        switch(iParam){
          case 0:
            sectionColor('shipper');
            $('shipperfilter').show();
            $('carrierfilter').hide();
            $('profitfilter').hide();
            $('shipper_submit_button').click();
            break;
          case 1:
            sectionColor('carrier');
            $('shipperfilter').hide();
            $('carrierfilter').show();
            $('profitfilter').hide();
            $('carrier_submit_button').click();
            break;
          case 2:
            sectionColor('profit');
            $('shipperfilter').hide();
            $('carrierfilter').hide();
            $('profitfilter').show();
            $('profit_submit_button').click();
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
        $('shipper').style.color = 'black';
        $('carrier').style.color = 'black';
        $('profit').style.color = 'black';
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
      function clearshparams(){
        $('norder').value = '';
        $('debt').checked = false;
        $('benefit').checked = false;
        $('overpayment').checked = false;
        $('syscompany_id').selectedIndex = 0;
        $('admin_id').selectedIndex = 0;
        $('sort').selectedIndex = 0;
        $('client_id').selectedIndex = 0;
        togglecompanies(0);
      }
      function clearcaparams(){
        $('carrier_carrier').value = '';
        $('zakaz_id_carrier').value = '';
        $('trip_id').value = '';
        $('contnumber').value = '';
        $('daydiff').value = '';
        $('debt_carrier').checked = false;
        $('is_tracker').checked = false;
        $('admin_id_carrier').selectedIndex = 0;
        $('sort_carrier').selectedIndex = 0;
      }
      function clearprparams(){
        $('zakaz_id_profit').value = '';
        $('shipperdebt').checked = false;
        $('carrierdebt').checked = false;
        $('admin_id_profit').selectedIndex = 0;
        $('client_id_profit').selectedIndex = 0;
      }
    </g:javascript>
    <style type="text/css">
      .grid_6 .link{color:#fff;font-size:18px;margin-left:15px;text-decoration:underline}
      .contact-form input.mini{width:40px}
      .box-iframe,#map_canvas{width:950px;height:400px}
      table.list tbody td {background: none}
    </style>
  </head>
	<body onload="initialize(${type})">
    <div class="menu admin">
      <div class="grid_6 p3 fright" align="right">
        <a class="link" href="javascript:void(0)" onclick="initialize(0)" id="shipper">Отправители</a>
        <a class="link" href="javascript:void(0)" onclick="initialize(1)" id="carrier">Перевозчики</a>
        <a class="link" href="javascript:void(0)" onclick="initialize(2)" id="profit">Доходы системы</a>
      </div>
      <div class="clear"></div>
      <div id="shipperfilter" style="display:none">
        <g:formRemote class="contact-form nopad" name="shipperForm" url="[action:'shippersettlements']" update="[success:'resultlist']">
          <fieldset>
            <label class="auto" for="client_id">Клиент:</label>
            <g:select name="client_id" style="width:200px" from="${clientnames.collect{it[0]}}" keys="${clientnames.collect{it[1]}}" noSelection="${['0':'Все']}" value="${inrequest?.shsettlparams?.client_id?:0}" onchange="togglecompanies(this.value)"/>
            <label class="auto" for="clientcompany_id">Компания:</label>
            <select name="clientcompany_id" id="clientcompany_id" style="width:246px">
              <option <g:if test="${!inrequest?.shsettlparams?.clientcompany_id}">selected="selected"</g:if> value="0" class="cl0">Все</option>
            <g:each in="${clientcompanies}">
              <option <g:if test="${inrequest?.shsettlparams?.clientcompany_id==it[1]}">selected="selected"</g:if> value="${it[1]}" class="cl${it[2]}">${it[0]}</option>
            </g:each>
            </select>
            <label class="auto" for="norder">Счет:</label>
            <input type="text" id="norder" name="norder" value="${inrequest?.shsettlparams?.norder?:''}"/><br/>
            <label for="debt" class="auto">Долг:</label>
            <input type="checkbox" id="debt" name="debt" <g:if test="${inrequest?.shsettlparams?.debt}">checked</g:if> value="1"/>
            <label for="benefit">Неоплаченные откаты:</label>
            <input type="checkbox" class="nopad auto" id="benefit" name="benefit" <g:if test="${inrequest?.shsettlparams?.benefit}">checked</g:if> value="1"/>
            <label class="auto" for="syscompany_id">Сис. компания:</label>
            <g:select name="syscompany_id" style="width:200px" from="${Syscompany.list()}" optionKey="id" optionValue="name" noSelection="${['0':'Все']}" value="${inrequest?.shsettlparams?.syscompany_id?:0}"/>
            <label class="auto" for="admin_id">Менеджер:</label>
            <g:select name="admin_id" style="width:200px" from="${Admin.list()}" optionKey="id" optionValue="name" noSelection="${['0':'Любой']}" value="${inrequest?.shsettlparams?.admin_id?:0}"/><br/>
            <label for="overpayment" class="auto">Переплата:</label>
            <input type="checkbox" id="overpayment" name="overpayment" <g:if test="${inrequest?.shsettlparams?.overpayment}">checked</g:if> value="1"/>
            <label class="auto" for="sort">Сортировать по:</label>
            <select id="sort" name="sort" class="auto">
              <option <g:if test="${!inrequest?.shsettlparams?.sort}">selected="selected"</g:if> value="0">Заказам</option>
              <option <g:if test="${inrequest?.shsettlparams?.sort==1}">selected="selected"</g:if> value="1">Счетам</option>
              <option <g:if test="${inrequest?.shsettlparams?.sort==2}">selected="selected"</g:if> value="2">Срок оплаты</option>
            </select>
            <div class="btns fright">
              <g:link action="shbenefit" class="button">Вознаграждения</g:link>
              <input type="submit" class="button" id="shipper_submit_button" value="Показать" />
              <input type="button" class="button" value="Сброс" onclick="clearshparams()"/>
            </div>
          </fieldset>
        </g:formRemote>
      </div>
      <div id="carrierfilter" style="display:none">
        <g:form class="contact-form nopad" name="carrierForm" action="carriersettlementsXLS" target="_blank">
          <fieldset>
            <label class="auto" for="carrier_carrier">Перевозчик:</label>
            <input type="text" id="carrier_carrier" name="carrier" value="${inrequest?.casettlparams?.carrier?:''}" class="mini"/>
            <label class="auto" for="zakaz_id_carrier">Заказ:</label>
            <input type="text" id="zakaz_id_carrier" name="zakaz_id" value="${inrequest?.casettlparams?.zakaz_id?:''}" class="mini"/>
            <label class="auto" for="trip_id">Поездка:</label>
            <input type="text" id="trip_id" name="trip_id" value="${inrequest?.casettlparams?.trip_id?:''}" class="mini"/>
            <label class="auto" for="contnumber">Контейнер:</label>
            <input type="text" id="contnumber" name="contnumber" value="${inrequest?.casettlparams?.contnumber?:''}" class="auto"/>
            <label for="debt_carrier" class="auto">Долг:</label>
            <input type="checkbox" id="debt_carrier" name="debt" <g:if test="${inrequest?.casettlparams?.debt}">checked</g:if> value="1"/><br/>
            <label class="auto" for="admin_id_carrier">Менеджер:</label>
            <g:select name="admin_id_carrier" style="width:246px" from="${Admin.list()}" optionKey="id" optionValue="name" noSelection="${['0':'Любой']}" value="${inrequest?.casettlparams?.admin_id_carrier?:0}"/>
            <label class="auto" for="sort_carrier">Сортировать по:</label>
            <select id="sort_carrier" name="sort" class="auto">
              <option <g:if test="${!inrequest?.casettlparams?.sort}">selected="selected"</g:if> value="0">Поездкам</option>
              <option <g:if test="${inrequest?.casettlparams?.sort==1}">selected="selected"</g:if> value="1">Сроку оплаты</option>
              <option <g:if test="${inrequest?.casettlparams?.sort==2}">selected="selected"</g:if> value="2">Дате оплаты</option>
            </select>
            <label class="auto" for="daydiff">Давность долга, дней:</label>
            <input type="text" id="daydiff" name="daydiff" value="${inrequest?.casettlparams?.daydiff?:''}" class="mini"/>
            <label for="is_tracker" class="auto">Трекерные:</label>
            <input type="checkbox" id="is_tracker" name="is_tracker" <g:if test="${inrequest?.casettlparams?.is_tracker}">checked</g:if> value="1"/><br/>
            <div class="btns fright">
              <g:link action="capayment" class="button">Оплатить</g:link>
              <input type="button" class="button" id="xlscarrier_submit_button" value="Экспорт в XLS" onclick="$('carrierForm').submit()"/>
              <g:submitToRemote class="button" id="carrier_submit_button" value="Показать" url="[action:'carriersettlements']" update="[success:'resultlist']"/>
              <input type="button" class="button" value="Сброс" onclick="clearcaparams()"/>
            </div>
          </fieldset>
        </g:form>
        <div class="fleft" style="margin:-25px 10px 0 10px;position:absolute;z-index:100">
          <g:form name="import" method="post" url="${[action:'uploadingCarrierPayments']}" enctype="multipart/form-data" target="upload_target">
            <label for="file" style="margin-right:10px">Импорт платежей:</label>
            <input type="file" name="file" id="file" size="23" accept="text/comma-separated-values" onchange="$('csvplatimport_submit_button').click()"/>
            <input type="submit" id="csvplatimport_submit_button" style="display:none">
          </g:form>
        </div>
        <iframe id="upload_target" name="upload_target" src="#" style="display:none;width:900px;height:40px;border:none;"></iframe>
      </div>
      <div id="profitfilter" style="display:none">
        <g:formRemote class="contact-form nopad" name="profitForm" url="[action:'profitsettlements']" update="[success:'resultlist']">
          <fieldset>
            <label class="auto" for="zakaz_id_profit">Заказ:</label>
            <input type="text" id="zakaz_id_profit" name="zakaz_id" value="${inrequest?.prsettlparams?.zakaz_id?:''}" class="mini"/>
            <label class="auto" for="client_id_profit">Клиент:</label>
            <g:select name="client_id_profit" style="width:200px" from="${clientnames.collect{it[0]}}" keys="${clientnames.collect{it[1]}}" noSelection="${['0':'Все']}" value="${inrequest?.prsettlparams?.client_id_profit?:0}"/>
            <label class="auto" for="admin_id_profit">Менеджер:</label>
            <g:select name="admin_id_profit" style="width:200px" from="${Admin.list()}" optionKey="id" optionValue="name" noSelection="${['0':'Любой']}" value="${inrequest?.prsettlparams?.admin_id_profit?:0}"/>
            <label for="shipperdebt" class="auto">Долг:</label>
            <input type="checkbox" id="shipperdebt" name="shipperdebt" <g:if test="${inrequest?.prsettlparams?.shipperdebt}">checked</g:if> value="1"/>
            <label for="carrierdebt" class="auto">Долг перевозчикам:</label>
            <input type="checkbox" id="carrierdebt" name="carrierdebt" <g:if test="${inrequest?.prsettlparams?.carrierdebt}">checked</g:if> value="1"/>
            <div class="btns fright">
              <input type="submit" class="button" id="profit_submit_button" value="Показать" />
              <input type="button" class="button" value="Сброс" onclick="clearprparams()"/>
            </div>            
          </fieldset>
        </g:formRemote>
      </div>
    </div>
    <div id="resultlist"></div>
  </body>
</html>
