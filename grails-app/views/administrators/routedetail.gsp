<html>
  <head>
    <title>Административное приложение</title>
    <meta name="layout" content="admin" />
    <g:javascript>
      function returnToList(){
        $("returnToListForm").submit();
      }
      function loadForm(iNumber){
        clearMessages();
        var lId=${route?.id?:0};
        <g:remoteFunction action='routetrackdetail' params="'id='+lId+'&ztype_id='+iNumber+'&copied=${copiedId?1:0}'" update="form_div" onLoading="\$('loader').show()" onLoaded="\$('loader').hide();"/>
      }
      function clearMessages(){
        $("errorlist").innerHTML='';
        $("errorlist").up('div').hide();
      }
      function setAnother(iId){
        $("city_start").value='';
        $("address_start").value='';
        if(iId==0){
          $("region_start").enable();
          $("full_address_start").show();
        }else{
          $("region_start").disable();
          $("full_address_start").hide();
        }
      }
      function setAnotherEnd(iId){
        $("city_end").value='';
        $("address_end").value='';
        if(iId==0){
          $("region_end").enable();
          $("full_address_end").show();
        }else{
          $("region_end").disable();
          $("full_address_end").hide();
        }
      }
      function copyAddressExport(){
        $("region_cust").selectedIndex=$("region_zat").selectedIndex;
        $("city_cust").value=$("city_zat").value;
        $("address_cust").value=$("address_zat").value;
      }
      function commonResponse(e,sErrorMsg){
        ['terminal','shortname','price_basic','weight1'].forEach(function(ids){
          if($(ids))
            $(ids).removeClassName('red');
        });
        jQuery("#slot input[type='button']").removeClass('red');        
        e.responseJSON.error.forEach(function(err){
          switch (err) {
            case 1: sErrorMsg+='<li>Не выбран терминал пункта А</li>';
                    $("terminal").addClassName('red');
                    break;
            case 3: sErrorMsg+='<li>Не задано название</li>';
                    $("shortname").addClassName('red');
                    break;
            case 4: sErrorMsg+='<li>Некорректный вес</li>';
                    $("weight1").addClassName('red');
                    break;
            case 5: sErrorMsg+='<li>Некорректная цена</li>';
                    $("price_basic").addClassName('red');
                    break;
            case 100: sErrorMsg+='<li>Ошибка сохранения в БД</li>';
                    break;
          }
        });
        return sErrorMsg;
      }
      function processSaveRouteResponse(e){
        if(e.responseJSON.error_ztype_id==1){
          clearMessages();
          var sErrorMsg='<li>Выберите тип маршрута</li>';
          $("ztype_id").addClassName('red');
          if(sErrorMsg.length){
            $("errorlist").innerHTML=sErrorMsg;
            $("errorlist").up('div').show();
          }
        } else if(!e.responseJSON.uId){
          $("ztype_id").removeClassName('red');
          switch (e.responseJSON.ztype_id) {
            case 1: processSaveRouteImportResponse(e);
                    break;
            case 2: processSaveRouteExportResponse(e)
                    break;
            case 3: processSaveRouteTransitResponse(e)
                    break;
          }
        } else {
          location.assign('${createLink(action:'routedetail')}'+'/'+e.responseJSON.uId);
        }
      }
      function processSaveRouteImportResponse(e){
        clearMessages();
        var sErrorMsg=commonResponse(e,'');
        if(sErrorMsg.length){
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        }
      }
      function processSaveRouteExportResponse(e){
        ['terminal_end'].forEach(function(ids){
          if($(ids))
            $(ids).removeClassName('red');
        });
        clearMessages();
        var sErrorMsg=commonResponse(e,'');
        e.responseJSON.error.forEach(function(err){
          switch (err) {
            case 2: sErrorMsg+='<li>Не выбран терминал пункта D</li>';
                    $("terminal_end").addClassName('red');
                    break;
          }
        });
        if(sErrorMsg.length){
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        }
      }
      function processSaveRouteTransitResponse(e){
        clearMessages();
        var sErrorMsg=commonResponse(e,'');
        if(sErrorMsg.length){
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        }
      }
    </g:javascript>
    <style type="text/css">
      .contact-form fieldset.bord{width:98%!important}
      .contact-form label{min-width:100px}     
      .contact-form input[type="text"]{width:244px!important}
      .contact-form input.mini{width:30px!important}      
      .contact-form select{width:262px!important}
      .contact-form select.auto{width:auto!important}
      @media screen and (-webkit-min-device-pixel-ratio:0){
        span#slot input.time[type="button"]{ margin-top:2px;vertical-align: top!important }
      }      
    </style>
  </head>
  <body onload="loadForm(${route?.ztype_id?:1});">
    <h1 class="fleft">${route&&!copiedId?'Маршрут №'+route.id:'Добавление нового маршрута'}</h1>
    <a class="link fright" href="javascript:void(0)" onclick="returnToList();">К списку маршрутов</a>
    <div class="clear"></div>
    <div class="error-box" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>
    </div>

    <g:formRemote class="contact-form" name="zakazForm" url="[action:'saveRouteDetail', id:(route&&!copiedId?route.id:0)]" onSuccess="processSaveRouteResponse(e)">
      <fieldset class="bord">
        <legend>Общие сведения</legend>
        <label for="ztype_id" class="auto">Тип:</label>
        <g:select class="auto" name="ztype_id" optionKey="id" optionValue="name" from="${ztype}" onChange="loadForm(this.value)" value="${route?.ztype_id?:0}"/>
        <label for="shortname">Короткое название:</label>
        <input type="text" id="shortname" name="shortname" value="${route&&!copiedId?route?.shortname:''}" maxlength="150"/>
        <label for="container">Тип контейнера:</label>
        <g:select style="width:200px!important" name="container" optionKey="id" optionValue="name" from="${container}" value="${route?.container}"/>
        <label for="weight1" class="auto">Вес в тоннах:</label>
        <input type="text" class="mini" size="2" id="weight1" name="weight1" value="${route?.weight1?:''}"/>
        <label for="price_basic">Ставка перевозчика:</label>
        <input type="text" id="price_basic" style="width:100px!important" name="price_basic" value="${route?.price_basic}"/>
      </fieldset>
      <h3 class="fleft">Информация о пунктах забора и выгрузки</h3>
      <div id="form_div"></div>
      <div class="btns">
        <input type="submit" class="button" value="Сохранить" />
      </div>
    </g:formRemote>
    <g:form id="returnToListForm" name="returnToListForm" url="${[action:'route',params:[fromDetails:1]]}">
    </g:form>
  </body>
</html>