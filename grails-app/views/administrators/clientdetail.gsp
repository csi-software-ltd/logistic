<html>
  <head>
    <title>Административное приложение</title>
    <meta name="layout" content="admin" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'kendo.default.min.css')}" type="text/css" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'kendo.common.min.css')}" type="text/css" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'dropzone.css')}" type="text/css" />
    <g:javascript library="kendo.culture.ru-RU.min" />
    <g:javascript library="kendo.web.min" />
    <g:javascript library='prototype/autocomplete' />
    <g:javascript library='dropzone' />
    <g:javascript>
    <g:if test="${client?.type_id==1}">
      Dropzone.options.uploadform = {
        parallelUploads: 1
      }
    </g:if>
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
          case 0: getRequisites();break;
          case 1: getDriverList();break;
          case 2: getCarsList();break;
          case 3: getTrailerList();break;
          case 4: getGeographicExc();break;
          case 5: getAcceptableContList();break;
          case 6: getPaytaxList();break;
        }
      }

      function getAcceptableContList(){
        if(${client?1:0}) $('cont_submit_button').click();
      }
      function getGeographicExc(){
        if(${client?1:0}) $('geo_submit_button').click();
      }
      function getTrailerList(){
        if(${client?1:0}) $('trailer_submit_button').click();
      }
      function getRequisites(){
        if(${client?1:0}) $('clientrequisites_submit_button').click();
      }
      function getDriverList(){
        if(${client?1:0}) $('driver_submit_button').click();
      }
      function getCarsList(){
        if(${client?1:0}) $('car_submit_button').click();
      }
      function getPaytaxList(){
        if(${client?1:0}) $('paytax_submit_button').click();
      }
      function setStatus(iStatus){
        $('is_confirm').value = iStatus;
        $('submit_button').click();
      }
      function processResponse(e){
        if(e.responseJSON.error){
          $('is_confirm').value = 0;
          var sErrorMsg = '';
          ['name','fullname'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Email"])}</li>'; $("name").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Название"])}</li>'; $("fullname").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
              case 101: sErrorMsg+='<li>${message(code:"error.not.unique.message",args:["Клиент","Email"])}</li>'; $("name").addClassName('red'); break;
            }
          });
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        } else {
          location.assign('${createLink(action:'clientdetail')}'+'/'+e.responseJSON.uId);
        }
      }
      function processEditRequisitesResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['inn','kpp','bik','corraccount','settlaccount','payee','nagr','agrdate','syscompany_id','payterm','shortbenefit','longbenefit'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Получатель платежа"])}</li>'; $("payee").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Код клиента"])}</li>'; break;
              case 3: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["ИНН"])}</li>'; $("inn").addClassName('red'); break;
              case 4: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["КПП"])}</li>'; $("kpp").addClassName('red'); break;
              case 5: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["БИК"])}</li>'; $("bik").addClassName('red'); break;
              case 6: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Корр. счет"])}</li>'; $("corraccount").addClassName('red'); break;
              case 7: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Расчетный счет"])}</li>'; $("settlaccount").addClassName('red'); break;
              case 8: sErrorMsg+='<li>${message(code:"error.blank.message",args:["ИНН"])}</li>'; $("inn").addClassName('red'); break;
              
              case 11: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Номер договора"])}</li>'; $("nagr").addClassName('red'); break;
              case 12: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Дата договора"])}</li>'; $("agrdate").addClassName('red'); break;
              case 21: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Дата договора"])}</li>'; $("agrdate").addClassName('red'); break;
              case 13: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Компания системы"])}</li>'; $("syscompany_id").addClassName('red'); break;
              case 14: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Срок оплаты в днях"])}</li>'; $("payterm").addClassName('red'); break;
              case 41: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Срок оплаты в днях"])}</li>'; $("payterm").addClassName('red'); break;
              case 51: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Размер вознаграждения по коротким маршрутам"])}</li>'; $("shortbenefit").addClassName('red'); break;
              case 61: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Размер вознаграждения по длинным маршрутам"])}</li>'; $("longbenefit").addClassName('red'); break;                            

              
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorClientRequisites").innerHTML=sErrorMsg;
          $("errorClientRequisites").up('div').show();
        } else {
          hideerrors("errorClientRequisites");
          getRequisites();
        }
      }
      function processDriverEditResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['driver_name','tel','driverfullname'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          ['docdata'].forEach(function(ids){
            $(ids).up('span').removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Имя"])}</li>'; $("driver_name").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Код клиента"])}</li>'; break;
              case 3: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Телефон"])}</li>'; $("tel").addClassName('red'); break;
              case 4: sErrorMsg+='<li>${message(code:"error.blank.message",args:["ФИО"])}</li>'; $("driverfullname").addClassName('red'); break;
              case 5: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Дата выдачи"])}</li>'; $("docdata").up('span').addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errordriverlist").innerHTML=sErrorMsg;
          $("errordriverlist").up('div').show();
        } else {
          jQuery('#driverEditForm').slideUp(300, function() {getDriverList();});
        }
      }
      function processCarEditResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['car_gosnomer'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Госномер"])}</li>'; $("car_gosnomer").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Код клиента"])}</li>'; break;
              case 3: sErrorMsg+='<li>${message(code:"error.not.unique.message",args:["Тягач","госномером"])}</li>'; $("car_gosnomer").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorcarlist").innerHTML=sErrorMsg;
          $("errorcarlist").up('div').show();
        } else {
          jQuery('#carEditForm').slideUp(300, function() {getCarsList();});
        }
      }
      function processTrailerEditResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['trailnumber'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Госномер"])}</li>'; $("trailnumber").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Код клиента"])}</li>'; break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errortrailerlist").innerHTML=sErrorMsg;
          $("errortrailerlist").up('div').show();
        } else {
          jQuery('#trailerEditForm').slideUp(300, function() {getTrailerList();});
        }
      }
      function processContactResponse(e){
        var sErrorMsg = '';
        ['nagr','agrdate','syscompany_id','payterm','shortbenefit','longbenefit'].forEach(function(ids){
          $(ids).removeClassName('red');
        });
        if(e.responseJSON.error){         
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 11: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Номер договора"])}</li>'; $("nagr").addClassName('red'); break;
              case 12: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Дата договора"])}</li>'; $("agrdate").addClassName('red'); break;
              case 21: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Дата договора"])}</li>'; $("agrdate").addClassName('red'); break;
              case 13: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Компания системы"])}</li>'; $("syscompany_id").addClassName('red'); break;
              case 14: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Срок оплаты в днях"])}</li>'; $("payterm").addClassName('red'); break;
              case 41: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Срок оплаты в днях"])}</li>'; $("payterm").addClassName('red'); break;
              case 51: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Размер вознаграждения по коротким маршрутам"])}</li>'; $("shortbenefit").addClassName('red'); break;
              case 61: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Размер вознаграждения по длинным маршрутам"])}</li>'; $("longbenefit").addClassName('red'); break;                            
              //case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorContract").innerHTML=sErrorMsg;
          $("errorContract").up('div').show();
        } else {
          $("errorContract").innerHTML='';
          $("errorContract").up('div').hide();
        }
      }
      function hideerrors(sId){
        $(sId).up('div').hide();
      }
      function editDriver(iId){
        iId = iId || 0;
        $('driver_id').value = iId;
        $('driverDetail_submit_button').click();
      }
      function setDriverStatus(lId,iStatus){
        <g:remoteFunction controller='administrators' action='driverstatus' onSuccess="getDriverList();" params="'id='+lId+'&status='+iStatus" />
      }
      function editCar(iId){
        iId = iId || 0;
        $('car_id').value = iId;
        $('carDetail_submit_button').click();
      }
      function setCarStatus(lId,iStatus){
        <g:remoteFunction controller='administrators' action='carstatus' onSuccess="getCarsList();" params="'id='+lId+'&status='+iStatus" />
      }
      function editTrailer(iId){
        iId = iId || 0;
        $('trailer_id').value = iId;
        $('trailerDetail_submit_button').click();
      }
      function setTrailerStatus(lId,iStatus){
        <g:remoteFunction controller='administrators' action='trailerstatus' onSuccess="getTrailerList();" params="'id='+lId+'&status='+iStatus" />
      }
      function editRequisites(iId){
        hideerrors("errorClientRequisites");
        iId = iId || 0;
        $('requisites_id').value = iId;
        $('requisitesDetail_submit_button').click();
      }
      function setRequisitesStatus(lId,iStatus){
        <g:remoteFunction controller='administrators' action='requisitesstatus' onSuccess="getRequisites();" params="'id='+lId+'&status='+iStatus" />
      }
      <!--excluded regions-->
      function processExcludeRegionResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorexcregionlist").innerHTML=sErrorMsg;
          $("errorexcregionlist").up('div').show();
        } else {
          jQuery('#selectExcRegionForm').slideUp(300, function() {getGeographicExc();});
        }
      }
      function checkallregion(){
        jQuery('#regionset input[type="checkbox"]').each(function(){
          this.checked = true;
        });
      }
      function hideregion(sId,bRefr){
        if (bRefr) jQuery('#spanreg'+sId).fadeOut(400, function() {getGeographicExc();});
        else jQuery('#spanreg'+sId).fadeOut(400, function() {
          if(!jQuery('#resultList span:visible').length) getGeographicExc();
        });
      }
      <!--acceptable containers-->
      function processAcceptContResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("erroracceptcontlist").innerHTML=sErrorMsg;
          $("erroracceptcontlist").up('div').show();
        } else {
          jQuery('#selectAcceptContForm').slideUp(300, function() {getAcceptableContList();});
        }
      }
      function checkallcont(){
        jQuery('#containerset input[type="checkbox"]').each(function(){
          this.checked = true;
        });
      }
      function hidecont(sId,bRefr){
        if (bRefr) jQuery('#spancont'+sId).fadeOut(400, function() {getAcceptableContList();});
        else jQuery('#spancont'+sId).fadeOut(400, function() {
          if(!jQuery('#resultList span:visible').length) getAcceptableContList();
        });
      }
      <!--limiting params-->
      function processLimitingParamsResponse(e){
        if(e.responseJSON.error){
          ['shipweight'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          var sErrorMsg = '';
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: $("shipweight").addClassName('red'); break;
            }
          });
        } else {
          getGeographicExc();
        }
      }
      <!--photo upload-->
      function startSubmit(sName){
        $(sName).submit();
      }
      function stopUpload(sNum,sFilename,iErrNo) {
        if(iErrNo==0){
          $('upload_'+sNum).hide();
          $('error_'+sNum).hide();
          $('viewscan_'+sNum).href=sFilename;
          $('result_'+sNum).show();
        }else{
          var sText="Ошибка загрузки";
          switch(iErrNo){
            case 1: sText="Удивительная ошибка загрузки"; break;
            case 2: sText="Ошибка загрузки"; break;
            case 3: sText="Неверный тип файла. Используйте JPG или PNG"; break;
            case 4: sText="Ошибка сохранения в БД"; break;
          }
          $('error_'+sNum).update(sText);
          $('error_'+sNum).show();
        }
        return true;
      }
      function reloadImage(sNum){
        $('upload_'+sNum).show();
        $('result_'+sNum).hide();
      }
      <!--paytax-->
      function editPaytax(iId){
        hideerrors("errorpaytax");
        jQuery('.info-box').hide();
        iId = iId || 0;
        $('paytax_id').value = iId;
        $('paytaxdetail_submit_button').click();
      }
      function deletepaytax(lId){
        <g:remoteFunction controller='administrators' action='paytaxdelete' onSuccess="getPaytaxList();" params="'id='+lId" />
      }
      function processPaytaxResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['paydate_month','summa'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Сумма"])}</li>'; $("summa").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Код клиента"])}</li>'; break;
              case 3: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Дата"])}</li>'; $("paydate_month").addClassName('red'); break;
              case 4: sErrorMsg+='<li>${message(code:"error.already.exists.message",args:["Платеж за этот месяц"])}</li>'; $("paydate_month").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorpaytax").innerHTML=sErrorMsg;
          $("errorpaytax").up('div').show();
        } else {
          hideerrors("errorpaytax");
          getPaytaxList();
        }
      }
      function recalculatePaydate(){
        <g:remoteFunction controller='administrators' action='updateMaxPaydate' id="${client?.id?:0}" onSuccess="alert('ok');"/>
      }
    </g:javascript>
    <style type="text/css">
      .contact-form label{min-width:130px}
      span.button{margin-bottom:3px!important}
      span.button:hover > a[class^="icon-"]{color:#fff}
      .smallselect select{width: 120px}
    </style>
  </head>
  <body onload="getRequisites()">
    <h1 class="fleft">${client?'Клиент №'+client.id:'Добавление нового клинта'}</h1>
    <a class="link fright" href="javascript:void(0)" onClick="returnToList();">К списку клиентов</a>
    <div class="clear"></div>
    <div class="error-box" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>
    </div>
    <g:formRemote class="contact-form" name="clientMainDetailForm" url="[action:'saveMainClientDetail', id:client?.id?:0]" method="post" onSuccess="processResponse(e)">
      <fieldset>
        <div class="grid_6">
          <label for="fullname">Название:</label>
          <input type="text" id="fullname" name="fullname" value="${client?.fullname}" />
          <label for="name">Email:</label>
          <input type="text" <g:if test="${client}">readonly</g:if> id="name" name="name" value="${client?.name}" />
          <label for="type_id">Менеджер:</label>
          <g:select name="admin_id" value="${client?.admin_id}" from="${managers}" noSelection="${['0':'Не задано']}" optionKey="id" optionValue="name"/>
          <label for="comment">Комментарий:</label>
          <textarea id="comment" name="comment" rows="3">${client?.comment}</textarea>
        </div>
        <div class="grid_6">
          <label for="type_id">Тип клиента:</label>
          <g:select name="type_id" value="${client?.type_id?:1}" keys="${1..3}" from="${['Грузоотправитель', 'Грузоперевозчик', 'Менеджер']}"/>
          <label for="modstatus">Статус:</label>
          <input type="text" disabled value="${client?.modstatus==1?'активный':client?.modstatus==0?'новый':'неактивный'}"/>
        </div>
        <div class="btns">
          <input type="submit" id="submit_button" class="button" value="Сохранить" />
        <g:if test="${client?.modstatus in [0,-1]}">
          <input type="button" class="button" value="Активировать" onclick="setStatus(1)" />
        </g:if><g:elseif test="${client?.modstatus in [0,1]}">
          <input type="button" class="button" value="Деактивировать" onclick="setStatus(-1)" />
        </g:elseif>
          <input type="reset" class="button" value="Сброс" />
        <g:if test="${client?.type_id==2&&admin?.menu?.find{it.id==18}}">
          <input type="button" class="button" value="Пересчитать сроки оплаты" onclick="recalculatePaydate()"/>
        </g:if>
        </div>
      </fieldset>
      <input type="hidden" id="is_confirm" name="is_confirm" value="0" />
    </g:formRemote>
  <g:if test="${client?.type_id==1}">
    <div class="contact-form">
      <fieldset class="bord" style="width:98%">
        <legend>Загрузите сканы договора</legend>
        <g:form action="dogupload" id="${client.id}" class="dropzone" name="uploadform">
        </g:form>
      <g:if test="${client.docpages}">Просмотреть договор:</g:if>
      <g:each in="${client.docpages.split(',')}">
        <a class="icon-file-text icon-dark icon-1x icon-fixed-width" href="${createLink(controller:'index',action:'showpicture',id:it,params:[code:Tools.generateModeParam(it)])}" target="_blank"></a>
      </g:each>
      </fieldset>
    </div>
  </g:if>
  <g:if test="${client}">
    <div class="tabs">
      <ul class="nav">
        <li class="selected"><a href="javascript:void(0)" onclick="viewCell(0)">Реквизиты</a></li>       
      <g:if test="${client.type_id==2}" >
        <li><a href="javascript:void(0)" onclick="viewCell(1)">Водители</a></li>
        <li><a href="javascript:void(0)" onclick="viewCell(2)">Машины</a></li>
        <li><a href="javascript:void(0)" onclick="viewCell(3)">Прицепы</a></li>
        <li><a href="javascript:void(0)" onclick="viewCell(4)">Ограничения доставки</a></li>
        <li><a href="javascript:void(0)" onclick="viewCell(5)">Допустимые контейнеры</a></li>
        <li><a href="javascript:void(0)" onclick="viewCell(6)">Абонентская плата</a></li>
      </g:if>
      </ul>
      <div class="tab-content">
        <div class="inner">
          <div id="details"></div>
        </div>
      </div>
    </div>
    <g:formRemote name="clientrequisitesForm" url="[action:'clientrequisites',id:client.id]" update="[success:'details']">
      <input type="submit" class="button" id="clientrequisites_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
    <g:formRemote name="driverForm" url="[action:'driverlist',id:client.id]" update="[success:'details']">
      <input type="submit" class="button" id="driver_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
    <g:formRemote name="carsForm" url="[action:'carlist',id:client.id]" update="[success:'details']">
      <input type="submit" class="button" id="car_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
    <g:formRemote name="trailersForm" url="[action:'trailerlist',id:client.id]" update="[success:'details']">
      <input type="submit" class="button" id="trailer_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
    <g:formRemote name="geoExcForm" url="[action:'geoexceptionlist',id:client.id]" update="[success:'details']">
      <input type="submit" class="button" id="geo_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
    <g:formRemote name="contAccForm" url="[action:'acceptablecontlist',id:client.id]" update="[success:'details']">
      <input type="submit" class="button" id="cont_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
    <g:formRemote name="taxForm" url="[action:'paytaxlist',id:client.id]" update="[success:'details']">
      <input type="submit" class="button" id="paytax_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
  </g:if>
    <g:form id="returnToListForm" name="returnToListForm" url="${[action:'clients']}">
    </g:form>
  </body>
</html>
