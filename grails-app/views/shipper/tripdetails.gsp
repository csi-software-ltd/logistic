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
      var ADDRESS_SEARCH_ZOOM=10,
          iXA=${trip?.xA?:0}, iYA=${trip?.yA?:0},
          iXB=${trip?.xB?:0}, iYB=${trip?.yB?:0},
          iXC=${trip?.xC?:0}, iYC=${trip?.yC?:0},
          iXD=${trip?.xD?:0}, iYD=${trip?.yD?:0},
          iXT=${trip?.xT?:0}, iYT=${trip?.yT?:0},
          map=null, gBounds=null, placemarkA=null, placemarkB=null, placemarkC=null, placemarkD=null, placemarkT=null, aPolylinePoints=[], myPolyline=null;
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
        if (${trip.distance?1:0}){
          ymaps.ready(function()  {
            var mY = iYA || 5993904
            var mX = iXA || 3031579
            map = new ymaps.Map("map_canvas",{center:[mY/100000,mX/100000],zoom:ADDRESS_SEARCH_ZOOM,behaviors:["default","scrollZoom"]});
            map.controls.add("zoomControl").add("scaleLine");
            gBounds = new ymaps.GeoObjectCollection();
            for (var i = 5; i > 0 ; i--) {
              setplacemark(i);
            };

            iconLayoutClass = ymaps.templateLayoutFactory.createClass(
              '<i class="icon-flag icon-2x icon-red" style="position:absolute;top:-22px;left:-3px"></i>'
            );
            ymaps.layout.storage.add('my#startIcon',iconLayoutClass); 
            iconLayoutClass = ymaps.templateLayoutFactory.createClass(
              '<i class="icon-flag-checkered icon-2x icon-black" style="position:absolute;top:-22px;left:-3px"></i>'
            );
            ymaps.layout.storage.add('my#endIcon',iconLayoutClass);
          <g:each in="${route}" var="it" status="i">
          <g:if test="${!i||i==route.size()-1}">
            var placemarkRoute = new ymaps.Placemark([${it.y/10000000},${it.x/10000000}],{},{
              draggable: false,
              hasBalloon: false,
              iconLayout: 'my#${!i?'end':'start'}Icon'
            });
            gBounds.add(placemarkRoute);
          </g:if>
            aPolylinePoints.push([${it.y/10000000},${it.x/10000000}]);
          </g:each>
            myPolyline = new ymaps.Polyline(aPolylinePoints,{},{strokeColor:'#0000FF',strokeWidth:6});
            gBounds.add(myPolyline);

            map.geoObjects.add(gBounds);
            if(gBounds.getBounds()!=null)
              map.setBounds(gBounds.getBounds());
          });
        };
      }
      function setplacemark(iId){
        switch (iId) {
          case 1:
            if(iXA!=0){
              placemarkA = new ymaps.Placemark([iYA/100000,iXA/100000],{iconContent: '<span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-A icon-light"></i></span>'},{
                draggable: false,
                hasBalloon: false
              });
              gBounds.add(placemarkA);
            } break;
          case 2:
            if(iXB!=0){
              placemarkB = new ymaps.Placemark([iYB/100000,iXB/100000],{iconContent: '<span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-B icon-light"></i></span>'},{
                draggable: false,
                hasBalloon: false
              });
              gBounds.add(placemarkB);
            } break;
          case 3:
            if(iXC!=0){
              placemarkC = new ymaps.Placemark([iYC/100000,iXC/100000],{iconContent: '<span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-C icon-light"></i></span>'},{
                draggable: false,
                hasBalloon: false
              });
              gBounds.add(placemarkC);
            } break;
          case 4:
            if(iXD!=0){
              placemarkD = new ymaps.Placemark([iYD/100000,iXD/100000],{iconContent: '<span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-D icon-light"></i></span>'},{
                draggable: false,
                hasBalloon: false
              });
              gBounds.add(placemarkD);
            } break;
          case 5:
            if(iXT!=0){
              placemarkT = new ymaps.Placemark([iYT/100000,iXT/100000],{iconContent: '<span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-anchor icon-light"></i></span>'},{
                draggable: false,
                hasBalloon: false
              });
              gBounds.add(placemarkT);
            } break;
        }
      }
      //<<map
      function getEvents(){
        $('tripevent_submit_button').click();
      }
      function processResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['containernumber1','containernumber2','timestartA','timeendA','timestartB','timeendB','timestartC','timeendC','timestartD','timeendD'].forEach(function(ids){
            if($(ids))
              $(ids).removeClassName('red');
          });
          ['dateA','dateB','dateC','dateD'].forEach(function(ids){
            if($(ids))
              $(ids).up('span').removeClassName('red');
          });
          jQuery("#datetimeA input[type='button']").removeClass('red');
          jQuery("#datetimeD input[type='button']").removeClass('red');
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.not.enough.message",args:["контейнеров"])}</li>'; $("containernumber1").addClassName('red'); if($("containernumber2")) $("containernumber2").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Дата А"])}</li>'; $("dateA").up('span').addClassName('red'); break;
              case 3: sErrorMsg+='<li>${message(code:"error.not.enough.message",args:["слотов"])}</li>'; jQuery("#datetimeA input[type='button']").addClass('red');; break;
              case 4: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время с/до"])}</li>'; $("timestartA").addClassName('red'); $("timeendA").addClassName('red'); break;
              case 5: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время с"])}</li>'; $("timestartA").addClassName('red'); break;
              case 6: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время до"])}</li>'; $("timeendA").addClassName('red'); break;
              case 7: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Дата B"])}</li>'; $("dateB").up('span').addClassName('red'); break;
              case 8: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время с/до"])}</li>'; $("timestartB").addClassName('red'); $("timeendB").addClassName('red'); break;
              case 9: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время с"])}</li>'; $("timestartB").addClassName('red'); break;
              case 10: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время до"])}</li>'; $("timeendB").addClassName('red'); break;
              case 11: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Дата C"])}</li>'; $("dateC").up('span').addClassName('red'); break;
              case 12: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время с/до"])}</li>'; $("timestartC").addClassName('red'); $("timeendC").addClassName('red'); break;
              case 13: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время с"])}</li>'; $("timestartC").addClassName('red'); break;
              case 14: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время до"])}</li>'; $("timeendC").addClassName('red'); break;
              case 15: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Дата D"])}</li>'; $("dateD").up('span').addClassName('red'); break;
              case 16: sErrorMsg+='<li>${message(code:"error.not.enough.message",args:["слотов"])}</li>'; jQuery("#datetimeD input[type='button']").addClass('red');; break;
              case 17: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время с/до"])}</li>'; $("timestartD").addClassName('red'); $("timeendD").addClassName('red'); break;
              case 18: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время с"])}</li>'; $("timestartD").addClassName('red'); break;
              case 19: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время до"])}</li>'; $("timeendD").addClassName('red'); break;
              case 20: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Контейнер1"])}</li>'; $("containernumber1").addClassName('red'); break;
              case 21: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Контейнер2"])}</li>'; $("containernumber2").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        } else {
          location.reload(true);
        }
      }
      function setSlotSelected(sPoint,iId){
        jQuery('#datetime'+sPoint).find('.button').removeClass('button');
        var el = $('timeslot'+sPoint)
        if(el)
          el.value=iId;
        el = $('slot'+sPoint+'_'+iId)
        if(el)
          el.addClassName('button');
      }
      function toggleDatetime(sPoint){
        jQuery('#datetime'+sPoint).slideToggle(300, function(sPoint) {
          setSlotSelected(sPoint,'-1');
          $('timeedit'+sPoint).value=(parseInt($('timeedit'+sPoint).value)+1)%2;
        }(sPoint));
      }
      function cancelTrip(){
        if(confirm('Вы подтверждаете отмену погрузки?'))
          <g:remoteFunction action='canceltrip' id="${trip.id}" onSuccess="location.reload(true)"/>
      }
    </g:javascript>
    <style type="text/css">
      .contact-form fieldset.bord{width:98%!important}
      .contact-form input.mini{width:180px!important}
      .k-datepicker,.data{margin-bottom:10px!important}
      .ymaps-image-with-content-content .icon-stack{top:-5px;left:-5px}
      .ymaps-image-with-content-content .icon-stack .icon-circle{color:#086ac5}
      .icon-red {color:red;text-shadow:0 2px 2px rgba(0, 0, 0, 0.8);}
      .icon-black{color:#000;text-shadow:0 2px 2px rgba(255, 255, 255, 1);}         
    </style>
  </head>
  <body onload="getEvents();Yandex();">
    <h1 class="fleft">${infotext?.header?:''} № ${trip.id}(${trip.zakaz_id}) / ${tripstatus.status} / ${!trip.imei?'тракер не привязан':trip.trackstatus?'тракер доступен':'тракер недоступен'}</h1>
  <g:if test="${trip.distance}">
    <a class="link fright button-right2" id="map_hide" href="javascript:void(0)" onclick="hideMap()">Скрыть карту</a>      
    <a class="link fright button-right2" id="map_show" href="javascript:void(0)" onclick="showMap()" style="display:none">Показать карту</a>
  </g:if>
    <a class="link fright" style="margin-right:10px" href="javascript:void(0)" onclick="$('returnToListForm').submit();">К списку поездок</a>
    <div class="clear"></div>    
    <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
    <div class="error-box" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>
    </div>
    <g:formRemote class="contact-form" name="tripDetailForm" url="[action:'saveTripDetail', id:trip.id]" method="post" onSuccess="processResponse(e)">
      <fieldset class="bord">
        <legend>Общие сведения</legend>
        <label for="ztype_id">Тип заказа:</label>
        <g:select class="auto" name="ztype_id" optionKey="id" optionValue="name" from="${ztype}" value="${trip.ztype_id?:0}" disabled="true"/>
        <label for="container">Тип контейнера:</label>
        <g:select class="auto" name="container" optionKey="id" optionValue="name" from="${container}" value="${trip.container}" disabled="true"/>
        <label class="auto">Дата создания:</label>
        <input type="text" class="data" disabled value="${String.format('%tF',trip.inputdate)}"/><br/>
        <label>Водитель:</label>
        <input type="text" class="auto" disabled value="${trip.driver_fullname}"/>
        <g:if test="${driver.is_passport1}"><a class="icon-file-text icon-dark icon-1x icon-fixed-width" href="${createLink(controller:'index',action:'showpicture',id:driver.is_passport1,params:[code:Tools.generateModeParam(driver.is_passport1)])}" target="_blank" title="паспорт"></a></g:if>
        <g:if test="${driver.is_passport2}"><a class="icon-file-text icon-dark icon-1x icon-fixed-width" href="${createLink(controller:'index',action:'showpicture',id:driver.is_passport2,params:[code:Tools.generateModeParam(driver.is_passport2)])}" target="_blank" title="паспорт"></a></g:if>
        <g:if test="${driver.is_prava}"><a class="icon-file-text icon-dark icon-1x icon-fixed-width" href="${createLink(controller:'index',action:'showpicture',id:driver.is_prava,params:[code:Tools.generateModeParam(driver.is_prava)])}" target="_blank" title="права"></a></g:if>
        <label class="auto">Тягач:</label>
        <input type="text" class="data" disabled value="${trip.cargosnomer}"/>
        <g:if test="${car.is_passport1}"><a class="icon-file-text icon-dark icon-1x icon-fixed-width" href="${createLink(controller:'index',action:'showpicture',id:car.is_passport1,params:[code:Tools.generateModeParam(car.is_passport1)])}" target="_blank" title="паспорт"></a></g:if>
        <g:if test="${car.is_passport2}"><a class="icon-file-text icon-dark icon-1x icon-fixed-width" href="${createLink(controller:'index',action:'showpicture',id:car.is_passport2,params:[code:Tools.generateModeParam(car.is_passport2)])}" target="_blank" title="паспорт"></a></g:if>
        <label class="auto">Прицеп:</label>
        <input type="text" class="data" disabled value="${trip.trailnumber?:'без прицепа'}"/>
        <g:if test="${trailer?.is_passport1}"><a class="icon-file-text icon-dark icon-1x icon-fixed-width" href="${createLink(controller:'index',action:'showpicture',id:trailer?.is_passport1,params:[code:Tools.generateModeParam(trailer?.is_passport1)])}" target="_blank" title="паспорт"></a></g:if>
        <g:if test="${trailer?.is_passport2}"><a class="icon-file-text icon-dark icon-1x icon-fixed-width" href="${createLink(controller:'index',action:'showpicture',id:trailer?.is_passport2,params:[code:Tools.generateModeParam(trailer?.is_passport2)])}" target="_blank" title="паспорт"></a></g:if>
        <br/><label>Контейнер1:</label>
        <input type="text" id="containernumber1" name="containernumber1" value="${zakaztodriver.containernumber1}" style="text-transform:uppercase"/>
      <g:if test="${trip.zcol>1}">
        <label class="auto">Контейнер2:</label>
        <input type="text" id="containernumber2" name="containernumber2" value="${zakaztodriver.containernumber2}" style="text-transform:uppercase;"/>
      </g:if>
      </fieldset>
      <fieldset class="bord">
        <legend>Внешняя ссылка</legend>
        <label>Внешняя ссылка:</label>
        <input type="text" value="${createLink(controller:'index',action:'monitoringext',params:[id:trip.id,code:Tools.generateModeParam(trip.id,trip.shipper)],absolute:true)}" style="width:70%" onfocus="this.select()"/>
      </fieldset>
      <fieldset class="bord">
        <legend>Информация по маршруту</legend>
        <label><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-A icon-light"></i></span> Загрузка:</label>
        <input type="text" disabled value="${String.format('%tF',trip.dateA)} c ${trip.timestartA} до ${trip.timeendA} <g:if test="${trip.terminal}">на терминале ${Terminal.get(trip.terminal)?.name}</g:if><g:elseif test="${trip.addressA}">по адресу ${trip.addressA}</g:elseif>" style="width:70%"/><a class="link" style="margin-left:10px" href="javascript:void(0)" onclick="toggleDatetime('A')">Изменить дату</a><br/>
        <div id="datetimeA" style="display:none">
          <label for="dateA">Дата А:</label>
          <g:datepicker class="normal nopad" name="dateA" value="${String.format('%td.%<tm.%<tY',trip?.dateA?:new Date())}" />
        <g:if test="${terminal?.is_slot}"><br/>          
          <label for="timeslotA">Слоты:</label>
          <span class="data">            
          <g:each in="${Slot.findAllByTerminal_idAndModstatus(terminal.id,1)}" var="item">
            <input type="button" class="time" id="slotA_${item.id}" value="${item.name}" onclick="setSlotSelected('A',${item.id})" />
          </g:each>
            <input type="hidden" id="timeslotA" name="timeslotA" value="-1"/>
          </span>
        </g:if><g:else>
          <label class="auto" for="timestartA">Время с:</label>
          <input type="text" id="timestartA" name="timestartA" class="data" value="${trip.timestartA}"/>
          <label class="auto" for="timeendA">до:</label>
          <input type="text" id="timeendA" name="timeendA" class="data" value="${trip.timeendA}"/>
        </g:else>
          <input type="hidden" id="timeeditA" name="timeeditA" value="0"/><br/>
        </div>
        <label><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-B icon-light"></i></span> ${trip.ztype_id==1?'Выгрузка':trip.ztype_id==2?'Затарка':'Таможня'}:</label>
        <input type="text" disabled value="<g:if test="${trip.dateB}">${String.format('%tF',trip.dateB)} ${trip.timestartB?' с '+trip.timestartB:''}${trip.timeendB?' до '+trip.timeendB:''}</g:if><g:else>Дата пока не задана</g:else> по адресу ${trip.addressB}" style="width:70%" /><a class="link" style="margin-left:10px" href="javascript:void(0)" onclick="toggleDatetime('B')">Изменить дату</a><br>
        <div id="datetimeB" style="display:none">
          <label for="dateB">Дата B:</label>
          <g:datepicker class="normal nopad" name="dateB" value="${String.format('%td.%<tm.%<tY',trip?.dateB?:new Date())}" />
          <label class="auto" for="timestartB">Время с:</label>
          <input type="text" id="timestartB" name="timestartB" class="data" value="${trip.timestartB}"/>
          <label class="auto" for="timeendB">до:</label>
          <input type="text" id="timeendB" name="timeendB" class="data" value="${trip.timeendB}"/>
          <input type="hidden" id="timeeditB" name="timeeditB" value="0"/><br/>
        </div>
      <g:if test="${trip.addressC}">
        <label><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-C icon-light"></i></span> ${trip.ztype_id==1?'Доп. выгрузка':trip.ztype_id==2?'Таможня':'Выгрузка'}:</label>
        <input type="text" disabled value="<g:if test="${trip.dateC}">${String.format('%tF',trip.dateC)} ${trip.timestartC?' с '+trip.timestartC:''}${trip.timeendC?' до '+trip.timeendC:''}</g:if><g:else>Дата пока не задана</g:else> по адресу ${trip.addressC}" style="width:70%" /> <a class="link" style="margin-left:10px" href="javascript:void(0)" onclick="toggleDatetime('C')">Изменить дату</a><br/>
        <div id="datetimeC" style="display:none">
          <label for="dateC">Дата C:</label>
          <g:datepicker class="normal nopad" name="dateC" value="${String.format('%td.%<tm.%<tY',trip?.dateC?:new Date())}" />
          <label class="auto" for="timestartC">Время с:</label>
          <input type="text" id="timestartC" name="timestartC" class="data" value="${trip.timestartC}"/>
          <label class="auto" for="timeendC">до:</label>
          <input type="text" id="timeendC" name="timeendC" class="data" value="${trip.timeendC}"/>
          <input type="hidden" id="timeeditC" name="timeeditC" value="0"/><br/>
        </div>
      </g:if><g:if test="${trip.addressD}">
        <label><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-D icon-light"></i></span> ${trip.ztype_id==2?'Сдача':'Доп. выгрузка'}:</label>
        <input type="text" disabled value="<g:if test="${trip.dateD}">${String.format('%tF',trip.dateD)} ${trip.timestartD?' с '+trip.timestartD:''}${trip.timeendD?' до '+trip.timeendD:''}</g:if><g:else>Дата пока не задана</g:else> по адресу ${trip.addressD}" style="width:70%" /> <a class="link" style="margin-left:10px" href="javascript:void(0)" onclick="toggleDatetime('D')">Изменить дату</a><br/>
        <div id="datetimeD" style="display:none">
          <label for="dateD">Дата D:</label>
          <g:datepicker class="normal nopad" name="dateD" value="${String.format('%td.%<tm.%<tY',trip?.dateD?:new Date())}" />
        <g:if test="${terminal_end?.is_slot}">
          <label class="auto">Слоты:</label>
          <span class="data">
          <g:each in="${Slot.findAllByTerminal_idAndModstatus(terminal_end.id,1)}" var="item">
            <input type="button" class="time" id="slotD_${item.id}" value="${item.name}" onclick="setSlotSelected('D',${item.id})" />
          </g:each>
            <input type="hidden" id="timeslotD" name="timeslotD" value="-1"/>
          </span>
        </g:if><g:else>
          <label class="auto" for="timestartD">Время с:</label>
          <input type="text" id="timestartD" name="timestartD" class="data" value="${trip.timestartD}"/>
          <label class="auto" for="timeendD">до:</label>
          <input type="text" id="timeendD" name="timeendD" class="data" value="${trip.timeendD}"/>
        </g:else>
          <input type="hidden" id="timeeditD" name="timeeditD" value="0"/><br/>
        </div>
      </g:if>
        <label><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-anchor icon-light"></i></span> Сдача:</label>
        <input type="text" disabled value="<g:if test="${!trip.taskstatus}">Сдача не назначена</g:if><g:elseif test="${trip.taskstatus==5}">Контейнер сдан</g:elseif><g:else>${trip.taskstatus in [1,3]?'Запрос на сдачу ':trip.taskstatus==4?'Переадресация ':'Сдача '}${String.format('%tF',trip.taskdate)} ${trip.taskstart?' с '+trip.taskstart:''}${trip.taskend?' до '+trip.taskend:''} <g:if test="${trip.taskterminal}">на терминале ${Terminal.get(trip.taskterminal)?.name}</g:if><g:elseif test="${trip.taskaddress}">по адресу ${trip.taskaddress}</g:elseif></g:else>" style="width:70%" />
        <div class="clear"></div>
        <div class="btns">
          <input type="button" class="button" ${!(trip.modstatus in 0..1)?'disabled':''} value="Отменить погрузку" onclick="cancelTrip()"/>
          <input type="submit" class="button" value="Сохранить"/>
        </div>
      <g:if test="${trip.distance}">
        <div class="box-iframe" style="width:930px;height:500px;margin-top:10px">
          <div id="map_canvas" style="width:930px;height:500px"></div>
        </div>
      </g:if>
      </fieldset>
    </g:formRemote>
    <div class="tabs">
      <ul class="nav">
        <li class="selected"><a href="javascript:void(0)">События</a></li>
      </ul>
      <div class="tab-content">
        <div class="inner">
          <div id="details"></div>
        </div>
      </div>
    </div>
    <g:formRemote name="tripeventForm" url="[action:'tripeventlist',id:trip.id]" update="[success:'details']">
      <input type="submit" class="button" id="tripevent_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
    <g:form id="returnToListForm" name="returnToListForm" url="${[controller:'shipper',action:'monitoring',params:[fromDetails:1]]}">
    </g:form>
  </body>
</html>
