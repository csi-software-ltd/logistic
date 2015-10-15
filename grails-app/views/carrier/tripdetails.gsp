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
            map.controls.add("smallZoomControl").add("scaleLine");
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
              iconLayout: 'my#${!i?'start':'end'}Icon'
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
      function toggleDatetime(sPoint){
        jQuery('#datetime'+sPoint).slideToggle(300, function(sPoint) {
          $('timeedit'+sPoint).value=(parseInt($('timeedit'+sPoint).value)+1)%2;
        }(sPoint));
      }
      function processResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['timestartE','timeendE'].forEach(function(ids){
            if($(ids))
              $(ids).removeClassName('red');
          });
          ['dateE'].forEach(function(ids){
            if($(ids))
              $(ids).up('span').removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 22: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Дата сдачи"])}</li>'; $("dateE").up('span').addClassName('red'); break;
              case 23: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время с/до"])}</li>'; $("timestartE").addClassName('red'); $("timeendE").addClassName('red'); break;
              case 24: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время с"])}</li>'; $("timestartE").addClassName('red'); break;
              case 25: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время до"])}</li>'; $("timeendE").addClassName('red'); break;
              case 28: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время с"])}</li>'; $("timestartE").addClassName('red'); break;
              case 29: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время по"])}</li>'; $("timeendE").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        } else {
          location.reload(true);
        }
      }
      function confirmDelivery(){
        if(confirm('Вы подтверждаете сдачу?'))
          <g:remoteFunction action='deliveryconfirm' onSuccess="location.reload(true)" id="${trip.id}" />
      }
    </g:javascript>
    <style type="text/css">
      .contact-form fieldset.bord{width:98%!important}
      .contact-form label{min-width:90px!important}
      .contact-form input.mini{width:180px!important}
      .k-datepicker,.data{margin-bottom:10px!important}
      .ymaps-image-with-content-content .icon-stack{top:-5px;left:-5px}
      .ymaps-image-with-content-content .icon-stack .icon-circle{color:#086ac5}      
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
        <input type="text" class="data" disabled value="${String.format('%tF',trip.inputdate)}"/>
        <label class="auto">Цена:</label>
        <input type="text" class="data" disabled value="${trip.price?:'это баг'}"/><br/>
        <label>Водитель:</label>
        <input type="text" class="auto" disabled value="${trip.driver_fullname}"/>
        <label class="auto">Тягач:</label>
        <input type="text" class="data" disabled value="${trip.cargosnomer}"/>
        <label class="auto">Прицеп:</label>
        <input type="text" class="data" disabled value="${trip.trailnumber}"/><br/>
        <label>Контейнер1:</label>
        <input type="text" name="containernumber1" readonly value="${zakaztodriver.containernumber1}"/>
        <label class="auto">Контейнер2:</label>
        <input type="text" name="containernumber2" readonly value="${zakaztodriver.containernumber2}"/>
      </fieldset>
      <fieldset class="bord">
        <legend>Информация по маршруту</legend>
        <label style="width:115px"><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-A icon-light"></i></span> Загрузка:</label>
        <input type="text" disabled value="${String.format('%tF',trip.dateA)} c ${trip.timestartA} до ${trip.timeendA} <g:if test="${trip.terminal}">на терминале ${Terminal.get(trip.terminal)?.name}</g:if><g:elseif test="${trip.addressA}">по адресу ${trip.addressA}</g:elseif>" style="width:70%"/><br/>
        <label style="width:115px"><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-B icon-light"></i></span> ${trip.ztype_id==1?'Выгрузка':trip.ztype_id==2?'Затарка':'Таможня'}:</label>
        <input type="text" disabled value="<g:if test="${trip.dateB}">${String.format('%tF',trip.dateB)} ${trip.timestartB?' с '+trip.timestartB:''}${trip.timeendB?' до '+trip.timeendB:''}</g:if><g:else>Дата пока не задана</g:else> по адресу ${trip.addressB}" style="width:70%"/><br/>
      <g:if test="${trip.addressC}">
        <label style="width:115px"><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-C icon-light"></i></span> ${trip.ztype_id==1?'Доп. выгрузка':trip.ztype_id==2?'Таможня':'Выгрузка'}:</label>
        <input type="text" disabled value="<g:if test="${trip.dateC}">${String.format('%tF',trip.dateC)} ${trip.timestartC?' с '+trip.timestartC:''}${trip.timeendC?' до '+trip.timeendC:''}</g:if><g:else>Дата пока не задана</g:else> по адресу ${trip.addressC}" style="width:70%" /><br/>
      </g:if><g:if test="${trip.addressD}">
        <label style="width:115px"><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-D icon-light"></i></span> ${trip.ztype_id==2?'Сдача':'Доп. выгрузка'}:</label>
        <input type="text" disabled value="<g:if test="${trip.dateD}">${String.format('%tF',trip.dateD)} ${trip.timestartD?' с '+trip.timestartD:''}${trip.timeendD?' до '+trip.timeendD:''}</g:if><g:else>Дата пока не задана</g:else> по адресу ${trip.addressD}" style="width:70%" /><br/>
      </g:if>
        <label style="width:115px"><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-anchor icon-light"></i></span> Сдача:</label>
        <input type="text" disabled value="<g:if test="${!trip.taskstatus}">Сдача не назначена</g:if><g:else>${trip.taskstatus in [1,3]?'Запрос на сдачу ':trip.taskstatus==4?'Переадресация ':'Сдача '}${String.format('%tF',trip.taskdate)} ${trip.taskstart?' с '+trip.taskstart:''}${trip.taskend?' до '+trip.taskend:''} <g:if test="${trip.taskterminal}">на терминале ${Terminal.get(trip.taskterminal)?.name}</g:if><g:elseif test="${trip.taskaddress}">по адресу ${trip.taskaddress}</g:elseif></g:else>" style="width:70%" /> 
        <g:if test="${trip.taskstatus<4&&trip.modstatus in 0..1}"><a class="button" title="Запрос на сдачу" href="javascript:void(0)" onclick="toggleDatetime('E')"><i class="icon-anchor"></i></a></g:if><g:else><a class="button disabled" title="Запрос на сдачу"><i class="icon-anchor"></i></a></g:else> 
        <g:if test="${trip.taskstatus in [2,4]}"><g:link class="button" url="[controller:'carrier', action:'forward', id:trip.id]" title="Переадресация"><i class="icon-exchange"></i></g:link></g:if><g:else><a class="button disabled" title="Переадресация"><i class="icon-exchange"></i></a></g:else> 
        <g:if test="${trip.taskstatus==2}"><a class="button" title="Сдать контейнер" href="javascript:void(0)" onclick="confirmDelivery()"><i class="icon-bookmark"></i></a></g:if><g:else><a class="button disabled" title="Сдать контейнер"><i class="icon-bookmark"></i></a></g:else> 
        <br/><div id="datetimeE" style="display:none">
          <label style="width:115px" for="dateE">Дата сдачи:</label>
          <g:datepicker class="normal nopad" name="dateE" value="${String.format('%td.%<tm.%<tY',trip?.taskdate?:new Date())}" />
          <label class="auto" for="timestartE">Время с:</label>
          <input type="text" id="timestartE" name="timestartE" class="data" value="${trip.taskstart}"/>
          <label class="auto" for="timeendE">до:</label>
          <input type="text" id="timeendE" name="timeendE" class="data" value="${trip.taskend}"/>
          <input type="hidden" id="timeeditE" name="timeeditE" value="0"/><br/>
        </div>
        <div class="clear"></div>
        <div class="btns">
          <input type="submit" class="button" value="Сохранить"/>
        </div>        
      <g:if test="${trip.distance}">
        <div class="box-iframe" style="margin:10px 0 0;width:930px;height:500px">
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
    <g:form id="returnToListForm" name="returnToListForm" url="${[controller:'carrier',action:'monitoring',params:[fromDetails:1]]}">
    </g:form>
  </body>
</html>
