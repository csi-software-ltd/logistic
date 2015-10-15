<html>
  <head>
    <title>Административное приложение</title>
    <meta name="layout" content="admin" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'kendo.default.min.css')}" type="text/css" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'kendo.common.min.css')}" type="text/css" />
    <g:javascript library="kendo.culture.ru-RU.min" />
    <g:javascript library="kendo.web.min" />
    <g:javascript library='prototype/autocomplete' />
    <g:javascript>
      var iKol=0, is_vartrailer=0,
          ADDRESS_SEARCH_ZOOM=10,
          iXA=${zakaz?.xA?:zakaz?.terminal?Terminal.get(zakaz.terminal)?.x:0}, iYA=${zakaz?.yA?:zakaz?.terminal?Terminal.get(zakaz.terminal)?.y:0},
          iXB=${zakaz?.xB?:0}, iYB=${zakaz?.yB?:0},
          iXC=${zakaz?.xC?:0}, iYC=${zakaz?.yC?:0},
          iXD=${zakaz?.xD?:0}, iYD=${zakaz?.yD?:0},
          map=null, gBounds=null, placemarkA=null, placemarkB=null, placemarkC=null, placemarkD=null;
      function returnToList(){
        $("returnToListForm").submit();
      }
      function init(){
        new Autocomplete('shipper', { serviceUrl:'${resource(dir:'administrators',file:'shipper_autocomplete')}' });
        loadWeightForm($("zcol").value);
        if(${!(zakaz?.modstatus in [1,2,3])?true:false}) getVariants();
        else if(${zakaz?.modstatus in [1,2]?true:false}) getOffers();
        else getTrips();
        Yandex();
      }
      //map>>
      function showMap(){
        jQuery('.box-iframe').slideDown(300, function() {
          if(gBounds.getBounds()!=null)
            map.setBounds(gBounds.getBounds());
          map.setCenter(map.getCenter(), map.getZoom(), { checkZoomRange: true });
        });
        jQuery('#map_hide').show();
        jQuery('#map_show').hide();
      }
      function hideMap(){
        jQuery('.box-iframe').slideUp();
        jQuery('#map_show').show();
        jQuery('#map_hide').hide();
      }
      function Yandex(){
        ymaps.ready(function()  {
          var mY = iYA || 5993904
          var mX = iXA || 3031579
          map = new ymaps.Map("map_canvas",{center:[mY/100000,mX/100000],zoom:ADDRESS_SEARCH_ZOOM,behaviors:["default","scrollZoom"]});
          map.controls.add("smallZoomControl").add("scaleLine");
          gBounds = new ymaps.GeoObjectCollection();
          for (var i = 1; i <=4 ; i++) {
            setplacemark(i);
          };
          map.geoObjects.add(gBounds);
          if(gBounds.getBounds()!=null)
            map.setBounds(gBounds.getBounds());
        });
      }
      function setplacemark(iId,isDraggable){
        isDraggable = isDraggable || false
        switch (iId) {
          case 1:
            if(iXA!=0){
              placemarkA = new ymaps.Placemark([iYA/100000,iXA/100000],{iconContent: '<span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-A icon-light"></i></span>'},{
                draggable: isDraggable,
                hasBalloon: false                
              });
              if (isDraggable) {
                placemarkA.events.add("dragend", function (result) { 
                  var coordinates =  this.geometry.getCoordinates();
                  var x=Math.round(coordinates[1]*100000);
                  var y=Math.round(coordinates[0]*100000);
                  $('yA').value = y; // и добавляем в поля широту
                  $('xA').value = x; // и долготу
                },placemarkA);
              };
              gBounds.add(placemarkA);
            } break;
          case 2:
            if(iXB!=0){
              placemarkB = new ymaps.Placemark([iYB/100000,iXB/100000],{iconContent: '<span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-B icon-light"></i></span>'},{
                draggable: isDraggable,
                hasBalloon: false                
              });
              if (isDraggable) {
                placemarkB.events.add("dragend", function (result) { 
                  var coordinates =  this.geometry.getCoordinates();
                  var x=Math.round(coordinates[1]*100000);
                  var y=Math.round(coordinates[0]*100000);
                  $('yB').value = y; // и добавляем в поля широту
                  $('xB').value = x; // и долготу
                },placemarkB);
              };
              gBounds.add(placemarkB);
            } break;
          case 3:
            if(iXC!=0){
              placemarkC = new ymaps.Placemark([iYC/100000,iXC/100000],{iconContent: '<span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-C icon-light"></i></span>'},{
                draggable: isDraggable,
                hasBalloon: false                
              });
              if (isDraggable) {
                placemarkC.events.add("dragend", function (result) { 
                  var coordinates =  this.geometry.getCoordinates();
                  var x=Math.round(coordinates[1]*100000);
                  var y=Math.round(coordinates[0]*100000);
                  $('yC').value = y; // и добавляем в поля широту
                  $('xC').value = x; // и долготу
                },placemarkC);
              };
              gBounds.add(placemarkC);
            } break;
          case 4:
            if(iXD!=0){
              placemarkD = new ymaps.Placemark([iYD/100000,iXD/100000],{iconContent: '<span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-D icon-light"></i></span>'},{
                draggable: isDraggable,
                hasBalloon: false                
              });
              if (isDraggable) {
                placemarkD.events.add("dragend", function (result) { 
                  var coordinates =  this.geometry.getCoordinates();
                  var x=Math.round(coordinates[1]*100000);
                  var y=Math.round(coordinates[0]*100000);
                  $('yD').value = y; // и добавляем в поля широту
                  $('xD').value = x; // и долготу
                },placemarkD);
              };
              gBounds.add(placemarkD);
            } break;
        }
      }
      function geocodeAddress(address,iId) {
        switch (iId) {
          case 1: doGeocode(address,placemarkA,'A'); break;
          case 2: doGeocode(address,placemarkB,'B'); break;
          case 3: doGeocode(address,placemarkC,'C'); break;
          case 4: doGeocode(address,placemarkD,'D'); break;
        }
      }
      function geocodeUpdatePlacemark(sId,placemark) {
        switch (sId) {
          case 'A': placemarkA = placemark; break;
          case 'B': placemarkB = placemark; break;
          case 'C': placemarkC = placemark; break;
          case 'D': placemarkD = placemark; break;
        }
      }
      function doGeocode(address,placemark,sId) {
        var geocoder2 = ymaps.geocode(address, {results: 1, boundedBy: map.getBounds()});
        // Результат поиска передается в callback-функцию
        geocoder2.then(function (res) {
          if (placemark) {
            gBounds.remove(placemark);
          };
          if (res.geoObjects.getLength()) {
            placemark = res.geoObjects.get(0);
            placemark.properties.set({iconContent: '<span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-'+sId+' icon-light"></i></span>'}); 
            placemark.options.set({draggable: true});
            map.setZoom(ADDRESS_SEARCH_ZOOM);
            map.panTo(placemark.geometry.getCoordinates(),{flying:false});
            gBounds.add(placemark);
            var x = Math.round(placemark.geometry.getCoordinates()[1]*100000);
            var y = Math.round(placemark.geometry.getCoordinates()[0]*100000);
            $('y'+sId).value = y;
            $('x'+sId).value = x;
            placemark.events.add("dragend", function (result) { 
              var coordinates =  this.geometry.getCoordinates();
              var x=Math.round(coordinates[1]*100000);
              var y=Math.round(coordinates[0]*100000);
              $('y'+sId).value = y; // и добавляем в поля широту
              $('x'+sId).value = x; // и долготу
            },placemark);
            geocodeUpdatePlacemark(sId,placemark);
          }else {
            geocodeUpdatePlacemark(sId,null);
            alert('Заданный адрес не найден');
          }
        },
        function (error) {
          alert(error);
        });
      }
      function removePlacemark(sId){
        switch (sId) {
          case 'C':
            if (placemarkC) {
              gBounds.remove(placemarkC);
              placemarkC = null;
              $('yC').value = 0;
              $('xC').value = 0;
            }; break;
          case 'D':         
            if (placemarkD) {
              gBounds.remove(placemarkD);
              placemarkD = null;
              $('yD').value = 0;
              $('xD').value = 0;
            }; break;
        }
      }
      function removeAllplacemark(){
        if (placemarkA) {
          gBounds.remove(placemarkA);
          placemarkA = null;
        };
        if (placemarkB) {
          gBounds.remove(placemarkB);
          placemarkB = null;
        };
        if (placemarkC) {
          gBounds.remove(placemarkC);
          placemarkC = null;
        };
        if (placemarkD) {
          gBounds.remove(placemarkD);
          placemarkD = null;
        };
        iXA = iXB = iXC = iXD = iYA = iYB = iYC = iYD = 0;
      }
      //map<<
      function loadForm(iNumber,iFirst){
        iFirst = iFirst || 0
        clearMessages();
        if (!iFirst) {
          removeAllplacemark();
        };
        var lId=${zakaz?.id?:0};
        <g:remoteFunction action='ordertrackdetail' params="'id='+lId+'&ztype_id='+iNumber+'&copied=${copiedId?1:0}'" update="form_div" onLoading="\$('loader').show()" onLoaded="\$('loader').hide();"/>
      }
      function clearMessages(){
        $("errorlist").innerHTML='';
        $("errorlist").up('div').hide();
      }
      function loadWeightForm(iNumber){
        ['weight1','weight2','weight3','weight4','weight5','addzcol'].forEach(function(ids){
          $(ids).hide();
        });
        switch (iNumber) {
          case '1': iKol=1; $('weight1').show(); break;
          case '2': iKol=2; $('weight1').show();$('weight2').show(); break;
          case '3': iKol=3; $('weight1').show();$('weight2').show();$('weight3').show(); break;
          case '4': iKol=4; $('weight1').show();$('weight2').show();$('weight3').show();$('weight4').show(); break;
          case '5': iKol=5; $('weight1').show();$('weight2').show();$('weight3').show();$('weight4').show();$('weight5').show(); break;
          default:  iKol=1; $('weight1').show(); $('addzcol').show(); break;
        }
        changeTrailerType($("container").value);
      }
      function setTrailerType(){
        if(is_vartrailer){
          $("trailertype_div").show();
          if(${!zakaz}){
            <g:each in="${trailertype}" var="item" status="i">
              <g:if test="${item.active}">
                $("trailertype${i}").checked=true; 
              </g:if>
              <g:else>
                $("trailertype${i}").checked=false;
              </g:else>
            </g:each>
          }
        }else{
          $("trailertype_div").hide();
          jQuery('#trailertype_div input[type="checkbox"]').each(function(){
            this.checked = false;
          });
        }
      }
      function changeTrailerType(iId){
      <g:each in="${container}">
        if(iId==${it?.id?:0}){
          is_vartrailer=${it?.is_vartrailer?:0};
        }
      </g:each>
        setTrailerType();
      }
      function setDateEnd(){
        if($("date_end"))
          $("date_end").value=$("zdate").value;
      }
      function setSlot(iId){
        <g:remoteFunction action='getslot' update="[success:'slot']" params="\'id=\'+iId" />
      }
      function setSlotEnd(iId){
        <g:remoteFunction action='getslot' update="[success:'slot_end_span']" params="'id='+iId+'&end=1'" />
      }
      function setAnother(iId){
        $("city_start").value='';
        $("address_start").value='';
        $("prim_start").value='';
        $("xA").value='0';
        $("yA").value='0';
        if(map && placemarkA){
          gBounds.remove(placemarkA);
          placemarkA = null;
        }
        if(iId==0){
          $("region_start").enable();
          $("full_address_start").show();
        }else{
          $("region_start").disable();
          $("full_address_start").hide();
        <g:each in="${terminal}">
          if(iId==${it?.id?:0}){
            iXA = ${it.x};
            iYA = ${it.y};
          }
        </g:each>
          setplacemark(1);
          if(gBounds.getBounds()!=null)
            map.setBounds(gBounds.getBounds());
          map.setCenter(map.getCenter(), map.getZoom(), { checkZoomRange: true });
        }
      }
      function setAnotherEnd(iId){
        $("city_end").value='';
        $("address_end").value='';
        $("prim_end").value='';
        $("xD").value='0';
        $("yD").value='0';
        if(map && placemarkD){
          gBounds.remove(placemarkD);
          placemarkD = null;
        }
        if(iId==0){
          $("region_end").enable();
          $("full_address_end").show();
        }else{
          $("region_end").disable();
          $("full_address_end").hide();
        <g:each in="${terminal}">
          if(iId==${it?.id?:0}){
            iXD = ${it.x};
            iYD = ${it.y};
          }
        </g:each>
          setplacemark(4);
          if(gBounds.getBounds()!=null)
            map.setBounds(gBounds.getBounds());
          map.setCenter(map.getCenter(), map.getZoom(), { checkZoomRange: true });
        }
      }
      function showAddVigruzka(){
        $("region_dop").enable();
        jQuery('#addVigruzka').slideDown();
        if($("vozvrat"))
          $("vozvrat").update("<span class='icon-stack'><i class='icon-circle icon-stack-base'></i><i class='icon-D icon-light'></i></span> Возврат порожнего контейнера");
        $("add_vigruska_link").hide();
        $("hide_vigruska_link").show();
      }
      function hideAddVigruzka(sId){
        $("region_dop").disable();
        $("region_dop").selectedIndex=0;
        jQuery('#addVigruzka').slideUp();
        if($("vozvrat"))
          $("vozvrat").update("<span class='icon-stack'><i class='icon-circle icon-stack-base'></i><i class='icon-C icon-light'></i></span> Возврат порожнего контейнера");
        $("add_vigruska_link").show();
        $("hide_vigruska_link").hide();
        jQuery('#addVigruzka input[value]').val('');
        removePlacemark(sId);
      }
      function syncSlotEnd(){
        $("slot_end").selectedIndex=$("slot_start").selectedIndex;
      }
      function syncSlotEnd1(){
        $("slot_end_end").selectedIndex=$("slot_start_end").selectedIndex;
      }
      function copyAddressExport(){
        $("region_cust").selectedIndex=$("region_zat").selectedIndex;
        $("city_cust").value=$("city_zat").value;
        $("address_cust").value=$("address_zat").value;
        $("xC").value=$("xB").value;
        $("yC").value=$("yB").value;
        if(map && placemarkC){
          gBounds.remove(placemarkC);
          placemarkC = null;
        }
        iXC = Math.round(placemarkB.geometry.getCoordinates()[1]*100000);
        iYC = Math.round(placemarkB.geometry.getCoordinates()[0]*100000);
        setplacemark(3,true);
      }
      function commonResponse(e,sErrorMsg){
        ['slot_start','slot_end','price','terminal','weight1','weight2','weight3','weight4','weight5','date_start','zdate','shipper','idle','price_basic','noticetel','noticetime','manager_id','addzcol'].forEach(function(ids){
          if($(ids))
            $(ids).removeClassName('red');
        });
        jQuery("#slot input[type='button']").removeClass('red');        
        e.responseJSON.admin_error.forEach(function(err){
          switch (err) {
            case 1: sErrorMsg+='<li>Некорректный грузоотправитель</li>';
                    $("shipper").addClassName('red');
                    break;
            case 2: sErrorMsg+='<li>Не задана ставка для перевозчика</li>';
                    $("price_basic").addClassName('red');
                    break;
            case 3: sErrorMsg+='<li>${message(code:"error.invalid.max.message",args:["Ставка перевозчика","Ставка"])}</li>';
                    $("price_basic").addClassName('red');
                    break;
            case 4: sErrorMsg+='<li>${message(code:"error.invalid.min.message",args:["Ставка перевозчика","0"])}</li>';
                    $("price_basic").addClassName('red');
                    break;
            case 5: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Менеджер"])}</li>';
                    $("manager_id").addClassName('red');
                    break;
          }
        });
        e.responseJSON.price_error.forEach(function(err){
          switch (err) {
            case 1: sErrorMsg+='<li>${message(code:"error.invalid.range.message",args:["Ставка в рублях","0","1000000"])}</li>';
                    $("price").addClassName('red');
                    break;
            case 2: sErrorMsg+='<li>${message(code:"error.invalid.range.message",args:["Простой в рублях","0","1000000"])}</li>';
                    $("idle").addClassName('red');
                    break;
          }
        });
        var iWeightError=0;
        e.responseJSON.weight_error.forEach(function(err){
          switch (err) {
            case 1: iWeightError++;
                    $("weight1").addClassName('red');
                    break;
            case 2: iWeightError++;
                    $("weight2").addClassName('red');
                    break;
            case 3: iWeightError++;
                    $("weight3").addClassName('red');
                    break;
            case 4: iWeightError++;
                    $("weight4").addClassName('red');
                    break;
            case 5: iWeightError++;
                    $("weight5").addClassName('red');
                    break;
            case 6: sErrorMsg+='<li>Некорректное кол-во контейнеров</li>';
                    $("addzcol").addClassName('red');
                    break;
          }
        });
        if(iWeightError)
          sErrorMsg+='<li>Вес в тоннах, ограничения, больше 0 и меньше 50</li>';
        e.responseJSON.error.forEach(function(err){
          switch (err) {
            case 1: sErrorMsg+='<li>Не выбран терминал пункта А</li>';
                    $("terminal").addClassName('red');
                    break;
            case 100: sErrorMsg+='<li>Ошибка сохранения в БД</li>';
                    break;
          }
        });
        e.responseJSON.date_error.forEach(function(err){
          switch (err) {
            case 1: sErrorMsg+='<li>Ошибка преобразования даты</li>';
                    break;
            case 3: sErrorMsg+='<li>${message(code:"error.invalid.min.message",args:["Дата доставки","Дата загрузки"])}</li>';
                    $("zdate").up('span').addClassName('red');
                    break;
            case 2: sErrorMsg+='<li>Дата загрузки должна быть актуальна</li>';
                    $("date_start").up('span').addClassName('red');
                    break;
          }
        });
        e.responseJSON.slot_error.forEach(function(err){
          switch (err) {
            case 1: sErrorMsg+='<li>Некорректный диапазон времени забора груза</li>';
                    if($("slot_start"))
                      $("slot_start").addClassName('red');
                    if($("slot_end"))
                      $("slot_end").addClassName('red');
                    break;
            case 2: sErrorMsg+='<li>Начало диапазона времени забора груза - целое число 0-23</li>';
                    if($("slot_start"))
                      $("slot_start").addClassName('red');
                    break;
            case 3: sErrorMsg+='<li>Конец диапазона времени забора груза - целое число 0-23</li>';
                    if($("slot_end"))
                      $("slot_end").addClassName('red');
                    break;
            case 4: sErrorMsg+='<li>Ошибка справочника времени забора груза</li>';
                    if($("slot_start"))
                      $("slot_start").addClassName('red');
                    if($("slot_end"))
                      $("slot_end").addClassName('red');
                    break;
            case 5: sErrorMsg+='<li>Не заданы слоты</li>';
                    jQuery("#slot input[type='button']").addClass('red');
                    break;                      
          }
        });
        e.responseJSON.notice_error.forEach(function(err){
          switch (err) {
            case 1: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Телефон для оповещения"])}</li>';
                    $("noticetel").addClassName('red');
                    break;
            case 2: sErrorMsg+='<li>Время оповещения - целое число 0-23</li>';
                    $("noticetime").addClassName('red');
                    break;
          }
        });
        return sErrorMsg;
      }
      function processSaveZakazResponse(e){
        if(e.responseJSON.error_ztype_id==1){
          clearMessages();
          var sErrorMsg='<li>Выберите тип заявки</li>';
          $("ztype_id").addClassName('red');
          if(sErrorMsg.length){
            $("errorlist").innerHTML=sErrorMsg;
            $("errorlist").up('div').show();
          }
        } else if(!e.responseJSON.uId){
          $("ztype_id").removeClassName('red');
          switch (e.responseJSON.ztype_id) {
            case 1: processSaveZakazImportResponse(e);
                    break;
            case 2: processSaveZakazExportResponse(e)
                    break;
            case 3: processSaveZakazTransitResponse(e)
                    break;
          }
        } else {
          location.assign('${createLink(action:'orderdetail')}'+'/'+e.responseJSON.uId);
        }
      }
      function processSaveZakazImportResponse(e){
        clearMessages();
        var sErrorMsg=commonResponse(e,'');
        if(sErrorMsg.length){
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        }
      }
      function processSaveZakazExportResponse(e){
        ['slot_start_end','slot_end_end','terminal_end','timestart_zat','timeend_zat','date_zat'].forEach(function(ids){
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
        e.responseJSON.date_error.forEach(function(err){
          switch (err) {
            case 4: sErrorMsg+='<li>${message(code:"error.invalid.min.message",args:["Дата затарки","Дата загрузки"])}</li>';
                    $("date_zat").up('span').addClassName('red');
                    break;
          }
        });
        e.responseJSON.timezat_error.forEach(function(err){
          switch (err) {
            case 1: sErrorMsg+='<li>Начало диапазона времени затарки - целое число 0-23</li>';
                    if($("timestart_zat"))
                      $("timestart_zat").addClassName('red');
                    break;
          }
        });
        if(sErrorMsg.length){
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        }
      }
      function processSaveZakazTransitResponse(e){
        ['date_cust'].forEach(function(ids){
          if($(ids))
            $(ids).removeClassName('red');
        });
        clearMessages();
        var sErrorMsg=commonResponse(e,'');
        e.responseJSON.transiterrors.forEach(function(err){
          switch (err) {
            case 1: sErrorMsg+='<li>${message(code:"error.invalid.min.message",args:["Дата на таможне","Дата загрузки"])}</li>';
                    $('date_cust').up('span').addClassName('red');
                    break;
          }
        });
        if(sErrorMsg.length){
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        }
      }
      function setSlotList(lId){      
        var tmp=[];
        if($("slotlist").value.length)
          tmp=$("slotlist").value.split(',');                 
          
        var bFlag=0;
        var i=0;
        tmp.forEach(function(it){ 
          if(it==lId){
            tmp.splice(i,1);
            bFlag=1;
          }  
          i++;
        });
        if(!bFlag)
          tmp.push(lId);     
          
        $("slotlist").value=tmp.toString();
      }
      function toggleButton(t){
        if(jQuery(t).hasClass('button'))
          $(t).removeClassName('button');
        else  
          $(t).addClassName('button');
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
          case 0: getVariants();break;
          case 1: getOffers();break;
          case 2: getTrips();break;
        }
      }
      function getVariants(){
        if(${zakaz&&!copiedId}) $('zakazvariants_submit_button').click();
      }
      function getOffers(){
        if(${zakaz&&!copiedId}) $('zakazoffers_submit_button').click();
      }
      function getTrips(){
        if(${zakaz&&!copiedId}) $('zakaztrip_submit_button').click();
      }
      function processResponseAssign(e){
        if(e.responseJSON.error&&e.responseJSON.errorcode==1)
          alert('Невозможно назначить. Суммарное кол-во контейнеров по перевозчикам превышает количество в заявке.')
        else if(e.responseJSON.error&&e.responseJSON.errorcode==2)
          alert('Невозможно назначить. Суммарное кол-во контейнеров по машинам не соответствует заявленному перевозчиком')
        else
          location.reload(true);
      }
      function processPartitonResponse(e){
        if(e.responseJSON.error){
          location.reload(true)
        } else {
          location.assign('${createLink(action:'orderdetail')}'+'/'+e.responseJSON.uId);
        }
      }
      function loginAsCarrier(iId,lOfferId){
        <g:remoteFunction controller='administrators' action='loginAsUser' onSuccess='processResponseCarrier(lOfferId)' params="'id='+iId" />
      }
      function loginAsShipper(iId){
        <g:remoteFunction controller='administrators' action='loginAsUser' onSuccess='processResponseShipper(e)' params="'id='+iId" />
      }
      function processResponseCarrier(lOfferId){
        window.open('${createLink(controller:"carrier",action:"orderdetails")}'+'/'+lOfferId);
      }
      function processResponseShipper(e){
        window.open('${createLink(controller:"shipper",action:"offerdetails",id:zakaz?.id)}');
      }
      function updateDate(){
        var date = $('date_start').value.split('.');
        var nextdate = new Date(new Date(date[2],date[1]-1,date[0]).getTime()+(24 * 60 * 60 * 1000));
        var datepicker = null;
        if($("zdate")) datepicker = jQuery("#zdate").data("kendoDatePicker");
        else if ($("date_cust")) datepicker = jQuery("#date_cust").data("kendoDatePicker");
        else if ($("date_zat")) datepicker = jQuery("#date_zat").data("kendoDatePicker");
        if(datepicker) datepicker.value(nextdate);
      }
      function togglecheck(){
        if(document.getElementById('groupcheckbox').checked)
          jQuery('#sendZakazOfferForm :checkbox:not(:checked)').each(function(){ this.checked=true; });
        else
          jQuery('#sendZakazOfferForm :checkbox:checked').each(function(){ this.checked=false; });
      }
    </g:javascript>
    <style type="text/css">
      .contact-form fieldset.bord{width:98%!important}
      .contact-form label{min-width:100px}     
      .contact-form input[type="text"]{width:244px!important}
      .contact-form input.mini{width:30px!important}      
      .contact-form select{width:262px!important}
      .contact-form select.auto{width:auto!important}
      .k-datepicker,.data{margin-bottom:10px!important}
      .box-iframe,#map_canvas{width:950px;height:250px}       
      .ymaps-image-with-content-content .icon-stack{top:-5px;left:-5px}
      .ymaps-image-with-content-content .icon-stack .icon-circle{color:#086ac5}
      @media screen and (-webkit-min-device-pixel-ratio:0){
        span#slot input.time[type="button"]{ margin-top:2px;vertical-align: top!important }
      }      
    </style>
  </head>
  <body onload="loadForm(${zakaz?.ztype_id?:1},1);init();">
    <h1 class="fleft">${zakaz&&!copiedId?'Заказ №'+zakaz.id+' ('+Zakazstatus.get(zakaz.modstatus)?.modstatus+')':'Добавление нового заказа'}<g:if test="${zakaz?.base_id&&!copiedId}">&nbsp;-&nbsp;<i class="icon-cog icon-large"></i></g:if></h1>
    <a class="link fright" href="javascript:void(0)" onclick="returnToList();">К списку заказов</a>
    <div class="clear"></div>
    <div class="error-box" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>
    </div>
    
    <g:formRemote class="contact-form" name="zakazForm" url="[action:'saveZakazDetail', id:(zakaz&&!copiedId?zakaz.id:0)]" onSuccess="processSaveZakazResponse(e)">
      <fieldset>
        <label for="ztype_id" class="auto">Тип:</label>
        <g:select class="auto" name="ztype_id" optionKey="id" optionValue="name" from="${ztype}" onChange="loadForm(this.value)" value="${zakaz?.ztype_id?:0}" disabled="${zakaz&&!copiedId?'true':'false'}"/>
        <label for="shipper">Грузоотправитель:</label>
        <input type="text" id="shipper" name="shipper" ${zakaz?.shipper?'readonly':''} value="${Client.get(zakaz?.shipper?:0)?.fullname?:''}" placeholder="укажите грузоотправителя"/>
        <div id="shipper_autocomplete" class="autocomplete" style="display:none"></div>
        <img src="${resource(dir:'images',file:'loader.gif')}" alt="" id="loader" style="position:absolute;display:none" />
        <label for="price_basic">Ставка перевозчика:</label>
        <input type="text" id="price_basic" style="width:100px!important" name="price_basic" value="${zakaz?.price_basic}"/>
        <label for="is_debate" class="auto" style="margin:0">
          <input type="checkbox" name="is_debate" value="1" <g:if test="${zakaz?.is_debate}">checked</g:if> />
          обсуждение цены
        </label><br/>
        <label for="inputdate" disabled>Дата создания:</label>
        <input type="text" id="inputdate" style="width:105px!important" readonly value="${String.format('%tF %<tH:%<tM',zakaz?.inputdate?:new Date())}"/>
        <label for="actual_time" disabled>Время действия:</label>
        <input type="text" id="actual_time" style="width:105px!important" readonly value="${actualTime>0&&!copiedId?Tools.getDayString(actualTime):'истекло'}"/>
        <label for="is_mobile" class="auto" disabled>
          <input type="checkbox" value="1" disabled <g:if test="${zakaz?.is_mobile}">checked</g:if> />
          мобильная версия
        </label>
        <label for="distance" class="auto" disabled>Расстояние, км:</label>
        <input type="text" id="distance" style="width:145px!important" disabled value="${zakaz?.distance?:'заказ не геокодирован'}"/>
      </fieldset>      
      <fieldset class="bord">
        <legend>Общие сведения</legend>
        <label for="container">Тип контейнера:</label>
        <g:select name="container" optionKey="id" optionValue="name" from="${container}" onChange="changeTrailerType(this.value)" value="${zakaz?.container}"/>
        <label for="zcol" class="auto">Количество:</label>
        <g:select name="zcol" from="${[1,2,3,4,5,'5+']}" onChange="loadWeightForm(this.value)" class="auto" value="${zakaz?.zcol<6?zakaz?.zcol:'5+'}"/>
        <input type="text" class="mini" size="2" id="addzcol" name="addzcol" value="${zakaz?.zcol}" style="display:none"/>
        <label for="weight1_id" class="auto">Вес в тоннах:</label>
        <input type="text" class="mini" size="2" id="weight1" name="weight1" value="${zakaz?.weight1?:''}"/> 
        <input type="text" class="mini" size="2" id="weight2" name="weight2" value="${zakaz?.weight2?:''}" style="display:none" />
        <input type="text" class="mini" size="2" id="weight3" name="weight3" value="${zakaz?.weight3?:''}" style="display:none" />
        <input type="text" class="mini" size="2" id="weight4" name="weight4" value="${zakaz?.weight4?:''}" style="display:none" />
        <input type="text" class="mini" size="2" id="weight5" name="weight5" value="${zakaz?.weight5?:''}" style="display:none"/><br/>
        <label for="price">Ставка:</label>
        <input type="text" id="price" name="price" value="${zakaz?.price?:''}"/>
        <label for="ztime_id">Заявка действует:</label>
        <g:select class="auto" name="ztime_id" optionKey="id" optionValue="name" from="${ztime}" value="${zakaz?.ztime_id}"/>
        <label for="manager_id" class="auto">Менеджер:</label>
        <g:select class="auto" name="manager_id" optionKey="id" optionValue="name" from="${Admin.findAllByIs_manager(1)}" value="${zakaz?.manager_id}" noSelection="${['0':'Не задан']}"/><br/>
        <label for="profit">Доход:</label>
        <input type="text" id="profit" disabled value="${zakaz?.price?zakaz.price-zakaz.benefit:''}"/>
        <label for="benefit">Вознаграждение:</label>
        <input type="text" id="benefit" name="benefit" style="width:100px!important" value="${zakaz?.benefit?:-1}"/>
        <label for="route_id" class="auto">Станд. маршрут:</label>
        <g:select style="width:180px!important" name="route_id" optionKey="id" from="${Standartroute.findAllByModstatus(1)}" value="${zakaz?.route_id}" noSelection="${['0':'Не задан']}"/>
      </fieldset>
      <fieldset class="bord">
        <legend>Дополнительно</legend>
        <label for="doc">Документы:</label>
        <input type="text" id="doc" name="doc" value="${zakaz?.doc?:''}" />
        <label for="comment">Примечание:</label>
        <input type="text" id="comment" name="comment" value="${zakaz?.comment?:''}" /><br/>
        <label for="dangerclass">Класс опасности:</label>
        <g:select name="dangerclass" optionKey="id" optionValue="name" from="${dangerclass}" noSelection="${['0':'0']}" value="${zakaz?.dangerclass?:0}"/>
        <label for="is_roof">
          <input type="checkbox" id="is_roof" name="is_roof" value="1" <g:if test="${zakaz?.is_roof?:0}">checked</g:if>/>
          Навес GenSet
        </label>
        <label for="idle" class="auto">Простой, р/день:</label>
        <input type="text" id="idle" name="idle" value="${zakaz?.idle?:'3000'}" style="width:119px!important"/>
        <fieldset class="nobord" id="trailertype_div">
          <legend>Допустимые полуприцепы:</legend>
          <g:each in="${trailertype}" var="item" status="i">
            <input type="checkbox" id="trailertype${i}" name="trailertype_id" value="${item.id}" <g:if test="${(trailertype_id?:[]).contains(item.id.toString())}">checked</g:if> />
            <label class="nopadd mini" for="trailertype${i}">${item?.name}</label>
          </g:each>
        </fieldset>
      </fieldset>
      <h3 class="fleft">Информация о пунктах забора и выгрузки</h3>
      <a class="link fright button-right2" id="map_show" href="javascript:void(0)" onclick="showMap()">Показать карту</a>
      <a class="link fright button-right2" id="map_hide" href="javascript:void(0)" onclick="hideMap()" style="display:none">Скрыть карту</a>      
      <div class="clear"></div>
      <div class="box-iframe button-top" style="display:none">
        <div id="map_canvas"></div>
      </div>
      <div id="form_div"></div>
      <div class="btns">
        <input type="submit" class="button" ${zakaz&&!copiedId&&zakaz.modstatus>2?'disabled':''} value="Сохранить" />
      <g:if test="${zakaz&&!copiedId&&zakaz.modstatus in 0..1}">
        <g:remoteLink url="[action:'zakazstatus',id:zakaz.id,params:[status:-2]]" class="button" onSuccess="location.reload(true)">Отклонить</g:remoteLink>
      </g:if>
      <g:if test="${zakaz&&!copiedId&&zakaz.modstatus==-2}">
        <g:remoteLink url="[action:'zakazstatus',id:zakaz.id]" class="button" onSuccess="location.reload(true)">Восстановить</g:remoteLink>
      </g:if>
      <g:if test="${zakaz&&!copiedId&&zakaz.modstatus==1&&Zakaztocarrier.findAllByZakaz_idAndModstatus(zakaz.id,2)}">
        <g:remoteLink url="[action:'partition',id:zakaz.id]" class="button" onSuccess="processPartitonResponse(e)">Разделить</g:remoteLink>
      </g:if>
      </div>
      <g:if test="${zakaz&&!copiedId}">
        <input type="hidden" name="ztype_id" value="${zakaz?.ztype_id?:0}"/>
      </g:if>
    </g:formRemote>
  <g:if test="${zakaz&&!copiedId}">
    <div class="tabs">
      <ul class="nav">
        <li ${!(zakaz.modstatus in [1,2,3])?'class=selected':''}><a href="javascript:void(0)" onclick="viewCell(0)">Варианты</a></li>
        <li ${zakaz.modstatus in [1,2]?'class=selected':''}><a href="javascript:void(0)" onclick="viewCell(1)">Предложения</a></li>
        <li ${zakaz.modstatus==3?'class=selected':''}><a href="javascript:void(0)" onclick="viewCell(2)">Поездки</a></li>
      </ul>
      <div class="tab-content">
        <div class="inner">
          <div id="details"></div>
        </div>
      </div>
    </div>
    <g:formRemote name="zakazVariantsForm" url="[action:'zakazvariants',id:zakaz.id]" update="[success:'details']">
      <input type="hidden" id="is_simplesearch" name="is_simplesearch" value="0" />
      <input type="submit" class="button" id="zakazvariants_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
    <g:formRemote name="zakazOffersForm" url="[action:'zakazoffers',id:zakaz.id]" update="[success:'details']">
      <input type="submit" class="button" id="zakazoffers_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
    <g:formRemote name="zakazTripForm" url="[action:'zakaztrips',id:zakaz.id]" update="[success:'details']">
      <input type="submit" class="button" id="zakaztrip_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
  </g:if>
    <g:form id="returnToListForm" name="returnToListForm" url="${[action:'zakaz',params:[fromDetails:1]]}">
    </g:form>
  </body>
</html>
