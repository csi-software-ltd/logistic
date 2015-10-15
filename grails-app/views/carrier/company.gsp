<html>
  <head>
    <title>${infotext?.title?:''}</title>    
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />
    <meta name="layout" content="main" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'kendo.default.min.css')}" type="text/css" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'kendo.common.min.css')}" type="text/css" />
    <g:javascript library="kendo.culture.ru-RU.min" />
    <g:javascript library="kendo.web.min" />
    <g:javascript>
      function viewCell(iNum){
        var tabs = jQuery('.nav').find('li');
        for(var i=0; i<tabs.length; i++){
        if(i==iNum)
          tabs[i].addClassName('selected');
        else
          tabs[i].removeClassName('selected');
        }        
        switch(iNum){
          case 0: getDriverList();break;
          case 1: getCarsList();break;
          case 2: getTrailerList();break;
          case 3: getGeographicExc();break;
          case 4: getAcceptableContList();break;
        }
      }
      function getAcceptableContList(){
        $('cont_submit_button').click();
      }
      function getGeographicExc(){
        $('geo_submit_button').click();
      }
      function getTrailerList(){
        $('trailer_submit_button').click();
      }
      function getDriverList(){
        $('driver_submit_button').click();
      }
      function getCarsList(){
        $('car_submit_button').click();
      }
      function hideerrors(sId){
        $(sId).up('div').hide();
      }
      <!--driver-->
      function editDriver(iId){
        iId = iId || 0;
        $('driver_id').value = iId;
        $('driverDetail_submit_button').click();
      }
      function setDriverStatus(lId,iStatus){
        <g:remoteFunction action='driverstatus' onSuccess="getDriverList();" params="'id='+lId+'&status='+iStatus" />
      }
      function processDriverEditResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['driver_name','fullname','tel'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Имя"])}</li>'; $("driver_name").addClassName('red'); break;
              case 3: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Телефон"])}</li>'; $("tel").addClassName('red'); break;
              case 4: sErrorMsg+='<li>${message(code:"error.blank.message",args:["ФИО"])}</li>'; $("fullname").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errordriverlist").innerHTML=sErrorMsg;
          $("errordriverlist").up('div').show();
        } else {
          jQuery('#driverEditForm').slideUp(300, function() {getDriverList();});
        }
      }
      <!--car-->
      function editCar(iId){
        iId = iId || 0;
        $('car_id').value = iId;
        $('carDetail_submit_button').click();
      }
      function setCarStatus(lId,iStatus){
        <g:remoteFunction action='carstatus' onSuccess="getCarsList();" params="'id='+lId+'&status='+iStatus" />
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
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorcarlist").innerHTML=sErrorMsg;
          $("errorcarlist").up('div').show();
        } else {
          jQuery('#carEditForm').slideUp(300, function() {getCarsList();});
        }
      }
      <!--trailer-->
      function editTrailer(iId){
        iId = iId || 0;
        $('trailer_id').value = iId;
        $('trailerDetail_submit_button').click();
      }
      function setTrailerStatus(lId,iStatus){
        <g:remoteFunction action='trailerstatus' onSuccess="getTrailerList();" params="'id='+lId+'&status='+iStatus" />
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
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errortrailerlist").innerHTML=sErrorMsg;
          $("errortrailerlist").up('div').show();
        } else {
          jQuery('#trailerEditForm').slideUp(300, function() {getTrailerList();});
        }
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
    </g:javascript>
    <style type="text/css">
      span.button{margin-bottom:3px!important}
      span.button:hover > a[class^="icon-"]{color:#fff}
    </style>
  </head>
  <body onload="getDriverList()">  
    <h1>${infotext?.header?:''}</h1>
    <fieldset class="contact-form">
      <div class="grid_6 alpha">
        <label for="fullname">Название:</label>
        <input type="text" disabled value="${client?.fullname}" />
        <label for="name">Email:</label>
        <input type="text" disabled value="${client?.name}" />
        <label for="payee">Получатель:</label>
        <input type="text" disabled value="${requisites?.payee}" />
        <label for="inn">ИНН:</label>
        <input type="text" disabled value="${requisites?.inn}" />
        <label for="kpp">КПП:</label>
        <input type="text" disabled value="${requisites?.kpp}" />
        <label for="bankname">Название банка:</label>
        <input type="text" disabled value="${requisites?.bankname}" />
        <label for="bik">БИК:</label>
        <input type="text" disabled value="${requisites?.bik}" />
      </div>
      <div class="grid_6 omega">
        <label for="ctype_id">Тип компании:</label>
        <g:select name="ctype_id" value="${requisites?.ctype_id}" keys="${1..3}" from="${['ООО', 'ИП', 'ЗАО']}" noSelection="${['0':'Не задано']}" disabled="disabled" />
        <label for="nds">НДС, %:</label>
        <input type="text" disabled value="${requisites?.nds}" />
        <label for="corraccount">Корр. счет:</label>
        <input type="text" disabled value="${requisites?.corraccount}" />
        <label for="settlaccount">Расчетный счет:</label>
        <input type="text" disabled value="${requisites?.settlaccount}" />
        <label for="ogrn">ОГРН:</label>
        <input type="text" disabled value="${requisites?.ogrn}" />
        <label for="license">Лицензия:</label>
        <input type="text" disabled value="${requisites?.license}" />
        <label for="address">Адрес:</label>
        <input type="text" disabled value="${requisites?.address}" />
      </div>
    </fieldset>
    <div class="tabs">
      <ul class="nav">
        <li class="selected"><a href="javascript:void(0)" onclick="viewCell(0)">Водители</a></li>
        <li><a href="javascript:void(0)" onclick="viewCell(1)">Машины</a></li>
        <li><a href="javascript:void(0)" onclick="viewCell(2)">Прицепы</a></li>
        <li><a href="javascript:void(0)" onclick="viewCell(3)">Ограничения доставки</a></li>
        <li><a href="javascript:void(0)" onclick="viewCell(4)">Допустимые контейнеры</a></li>
      </ul>
      <div class="tab-content">
        <div class="inner">
          <div id="details"></div>
        </div>
      </div>
    </div>  
    <g:formRemote name="driverForm" url="[action:'driverlist']" update="[success:'details']">
      <input type="submit" class="button" id="driver_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
    <g:formRemote name="carsForm" url="[action:'carlist']" update="[success:'details']">
      <input type="submit" class="button" id="car_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
    <g:formRemote name="trailersForm" url="[action:'trailerlist']" update="[success:'details']">
      <input type="submit" class="button" id="trailer_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
    <g:formRemote name="geoExcForm" url="[action:'geoexceptionlist']" update="[success:'details']">
      <input type="submit" class="button" id="geo_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
    <g:formRemote name="contAccForm" url="[action:'acceptablecontlist']" update="[success:'details']">
      <input type="submit" class="button" id="cont_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
  </body>
</html>
