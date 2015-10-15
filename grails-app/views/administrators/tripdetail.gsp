<html>
  <head>
    <title>Административное приложение</title>
    <meta name="layout" content="admin" />
    <g:javascript>
      var ADDRESS_SEARCH_ZOOM=13, ROUTE_MARK_ZOOM=14, 
          iX=${route[0]?.x?:303157900},
          iY=${route[0]?.y?:599390400},
          iXA=${trip?.xA?:0}, iYA=${trip?.yA?:0},
          iXB=${trip?.xB?:0}, iYB=${trip?.yB?:0},
          iXC=${trip?.xC?:0}, iYC=${trip?.yC?:0},
          iXD=${trip?.xD?:0}, iYD=${trip?.yD?:0},
          iXT=${trip?.xT?:0}, iYT=${trip?.yT?:0},
          map=null, placemark=null, gBounds=null, gBoundsEnds=null, gBoundsTracePoints=null, myPolyline=null, fullScreen=false, aPolylinePoints=[], routeMode=false, placemarkA=null, placemarkB=null, placemarkC=null, placemarkD=null, placemarkT=null;
      function returnToList(){
        $("returnToListForm").submit();
      }
      function processResponse(e){
        ['containernumber1','containernumber2','driver_name','cargosnomer'].forEach(function(ids){
          if($(ids))
            $(ids).removeClassName('red');
        });
        if(e.responseJSON.error){
          var sErrorMsg = '';
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.denial.message",args:["завершить поездку - не сдан контейнер"])}</li>'; break;
              case 2: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Номер тягача"])}</li>'; $("cargosnomer").addClassName('red'); break;
              case 3: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Водитель"])}</li>'; $("driver_name").addClassName('red'); break;
              case 4: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Контейнер1"])}</li>'; $("containernumber1").addClassName('red'); break;
              case 5: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Контейнер2"])}</li>'; $("containernumber2").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        } else {
          location.reload(true);
        }
      }
      function Yandex(){
        ymaps.ready(function()  {
          map = new ymaps.Map("map_canvas",{center:[iY/10000000,iX/10000000],zoom:ADDRESS_SEARCH_ZOOM,behaviors:["default","scrollZoom"]});
          map.controls.add("smallZoomControl").add("scaleLine")
          placemark = new ymaps.Placemark([iY/10000000,iX/10000000],{},{
            draggable: false,
            hasBalloon: false,
            iconImageHref:"${resource(dir:'images',file:'marker.png')}",
            iconImageSize: [19,37],
            iconImageOffset:[-14,-35],
            iconContentOffset:[-1,10]
          });
          //map.geoObjects.add(placemark);
          gBoundsTracePoints = new ymaps.GeoObjectCollection();
          for (var i = 5; i > 0 ; i--) {
            setplacemark(i);
          };
          gBoundsTracePoints.add(placemark);
          map.geoObjects.add(gBoundsTracePoints);
          map.setBounds(gBoundsTracePoints.getBounds());
          map.setCenter(map.getCenter(), map.getZoom(), { checkZoomRange: true });
          jQuery('#mapResize').click(mapResize);
          var iconLayoutClass = ymaps.templateLayoutFactory.createClass(
            '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="22" height="22" preserveAspectRatio="none" viewBox="-11 -11 22 22" style="position:absolute;left:-11px;top:-11px">'+
            '  <defs/>'+
            '  <g>'+
            '   <ellipse cx="0" cy="0" rx="5" ry="5" fill="#FFF" stroke="red" fill-opacity="1" style="stroke-width:2px" stroke-width="2" stroke-opacity="1"/>'+
            '  </g>'+
            '</svg>'
          );
          ymaps.layout.storage.add('my#activeIcon',iconLayoutClass);
          iconLayoutClass = ymaps.templateLayoutFactory.createClass(
            '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="22" height="22" preserveAspectRatio="none" viewBox="-11 -11 22 22" style="position:absolute;left:-11px;top:-11px">'+
            '  <defs/>'+
            '  <g>'+
            '   <ellipse cx="0" cy="0" rx="5" ry="5" fill="#FFF" stroke="#666" fill-opacity="1" style="stroke-width:2px" stroke-width="2" stroke-opacity="1"/>'+
            '  </g>'+
            '</svg>'
          );
          ymaps.layout.storage.add('my#passiveIcon',iconLayoutClass);
          iconLayoutClass = ymaps.templateLayoutFactory.createClass(
            '<i class="icon-flag icon-2x icon-red" style="position:absolute;top:-22px;left:-3px"></i>'
          );          
          ymaps.layout.storage.add('my#startIcon',iconLayoutClass); 
          iconLayoutClass = ymaps.templateLayoutFactory.createClass(
            '<i class="icon-flag-checkered icon-2x icon-black" style="position:absolute;top:-22px;left:-3px"></i>'
          );
          ymaps.layout.storage.add('my#endIcon',iconLayoutClass);

          gBounds = new ymaps.GeoObjectCollection();
          gBoundsEnds = new ymaps.GeoObjectCollection();
        <g:each in="${route}" var="it" status="i">
        <g:if test="${!i||i==route.size()-1}">
          var placemarkRoute = new ymaps.Placemark([${it.y/10000000},${it.x/10000000}],{
            hintContent:'время: '+'${String.format('%tF %<tT', it?.tracktime)}'+'<br/>курс на '+getKursString(${it.kurs})+'<br/>скорость: '+${it.speed}+' км/ч'},{
            draggable: false,
            hasBalloon: false,
            iconLayout: 'my#${!i?'end':'start'}Icon'            
          });
          gBoundsEnds.add(placemarkRoute);
        </g:if><g:else>
          var placemarkRoute = new ymaps.Placemark([${it.y/10000000},${it.x/10000000}],{
            hintContent:'время: '+'${String.format('%tF %<tT', it?.tracktime)}'+'<br/>курс на '+getKursString(${it.kurs})+'<br/>скорость: '+${it.speed}+' км/ч'},{
            draggable: false,
            hasBalloon: false,                
            iconLayout: (${it.speed}<=5)?'my#passiveIcon':'my#activeIcon'
          });
          gBounds.add(placemarkRoute);
        </g:else>
          aPolylinePoints.push([${it.y/10000000},${it.x/10000000}]);
        </g:each>
          myPolyline = new ymaps.Polyline(aPolylinePoints,{},{strokeColor:'#0000FF',strokeWidth:6});
          map.controls.events.add("zoomchange", function(e) {
            if(e.get('newZoom')>=ROUTE_MARK_ZOOM&&routeMode){
              if(e.get('oldZoom')<ROUTE_MARK_ZOOM)
                map.geoObjects.add(gBounds);
            } else if(routeMode){
              map.geoObjects.remove(gBounds);
            }
          });
        });
      }
      function showTrackerRoute(){
        $("label").update('Маршрут');
        routeMode = !routeMode;
        clearMap();
        map.geoObjects.add(myPolyline);
        map.geoObjects.add(gBoundsEnds);
        map.setBounds(myPolyline.geometry.getBounds());
        map.setCenter(map.getCenter(), map.getZoom(), { checkZoomRange: true });
      }
      function clearMap(){
        map.geoObjects.remove(myPolyline);
        gBoundsTracePoints.remove(placemark);
        map.geoObjects.remove(gBounds);
        map.geoObjects.remove(gBoundsEnds);
      }
      function showTracker(){
        $("label").update('Текущее местоположение');
        routeMode = !routeMode;
        clearMap();
        gBoundsTracePoints.add(placemark);
        map.setBounds(gBoundsTracePoints.getBounds());
        map.setCenter(map.getCenter(), map.getZoom(), { checkZoomRange: true });
      }
      function mapResize(){
        fullScreen = !fullScreen;
        if(fullScreen){
          jQuery('.box-iframe').animate({
            width: '890px',
            height: '500px',
            marginLeft: '-554px',
            marginBottom: '-180px'
          },500, function() {
            map.container.fitToViewport();
          });
          jQuery('#mapResize').html('Свернуть');
          jQuery('#map_canvas').addClass('bigMap');
        } else {
          jQuery('.box-iframe,#map_canvas').animate({
            width: '336px',
            height: '330px',
            marginLeft: '0',
            marginBottom: '22px',
          },500, function() {
            map.container.fitToViewport();
          });
          jQuery('#mapResize').html('Развернуть');
          jQuery('#map_canvas').removeClass('bigMap');
        }
        map.container.fitToViewport();
      }
      function getKursString(iKurs){
        switch (parseInt((iKurs+23)/45)){
          case 1: return 'северо-восток';
          case 2: return 'восток';
          case 3: return 'юго-восток';
          case 4: return 'юг';
          case 5: return 'юго-запад';
          case 6: return 'запад';
          case 7: return 'северо-запад';
          default: return 'север';
        }
      }
      function setplacemark(iId){
        switch (iId) {
          case 1:
            if(iXA!=0){
              placemarkA = new ymaps.Placemark([iYA/100000,iXA/100000],{iconContent: '<span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-A icon-light"></i></span>'},{
                draggable: false,
                hasBalloon: false
              });
              gBoundsTracePoints.add(placemarkA);
            } break;
          case 2:
            if(iXB!=0){
              placemarkB = new ymaps.Placemark([iYB/100000,iXB/100000],{iconContent: '<span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-B icon-light"></i></span>'},{
                draggable: false,
                hasBalloon: false
              });
              gBoundsTracePoints.add(placemarkB);
            } break;
          case 3:
            if(iXC!=0){
              placemarkC = new ymaps.Placemark([iYC/100000,iXC/100000],{iconContent: '<span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-C icon-light"></i></span>'},{
                draggable: false,
                hasBalloon: false
              });
              gBoundsTracePoints.add(placemarkC);
            } break;
          case 4:
            if(iXD!=0){
              placemarkD = new ymaps.Placemark([iYD/100000,iXD/100000],{iconContent: '<span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-D icon-light"></i></span>'},{
                draggable: false,
                hasBalloon: false
              });
              gBoundsTracePoints.add(placemarkD);
            } break;
          case 5:
            if(iXT!=0){
              placemarkT = new ymaps.Placemark([iYT/100000,iXT/100000],{iconContent: '<span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-anchor icon-light"></i></span>'},{
                draggable: false,
                hasBalloon: false
              });
              gBoundsTracePoints.add(placemarkT);
            } break;
        }
      }
      function submitform(iStatus){
        $("status").value = iStatus;
        $("proxy_submit_button").click();
      }
      function cancelTrip(iId){
        if(confirm('Вы подтверждаете отмену погрузки?'))
          submitform(iId)
      }
      function getEvents(){
        $('tripevent_submit_button').click();
      }
    </g:javascript>
    <style type="text/css">
      .contact-form label{min-width:149px}
      .contact-form fieldset.bord{width:98%!important}
      .bigMap{width:890px!important;height:500px!important}
      .ymaps-image-with-content-content .icon-stack{top:-5px;left:-5px}
      .ymaps-image-with-content-content .icon-stack .icon-circle{color:#086ac5}
      .icon-red {color:red;text-shadow:0 2px 2px rgba(0, 0, 0, 0.8);}
      .icon-black{color:#000;text-shadow:0 2px 2px rgba(255, 255, 255, 1);}
    </style>
  </head>
  <body onload="getEvents();Yandex()">
    <h1 class="fleft">${'Поездка №'+trip.id}</h1>
    <a class="link fright" href="javascript:void(0)" onClick="returnToList();">К списку поездок</a>
    <div class="clear"></div>
    <div class="error-box" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>
    </div>
    <g:formRemote class="contact-form" name="trackerDetailForm" url="[action:'saveTripDetail', id:trip.id]" method="post" onSuccess="processResponse(e)">
      <fieldset>
        <div class="grid_6 suffix_1">
          <label for="zakaz_id">Код заказа:</label>
          <input type="text" id="zakaz_id" disabled value="${trip.zakaz_id}" />
          <label for="shipper">Грузоотправитель:</label>
          <input type="text" id="shipper" disabled value="${shipper.fullname}" />
          <label for="carrier">Грузоперевозчик:</label>
          <input type="text" id="carrier" disabled value="${carrier.fullname}" />
          <label for="driver_name">Водитель:</label>
          <g:select id="driver_name" name="driver_id" class="nopad" value="${trip.driver_id}" from="${drivers}" optionKey="id" optionValue="fullname"/>
          <label for="driver_doc">Паспорт водителя:</label>
          <input type="text" id="driver_doc" disabled value="${driver.docseria+' '+driver.docnumber}" />
          <label for="cargosnomer">Номер тягача:</label>
          <g:select id="cargosnomer" name="car_id" class="nopad" value="${trip.car_id}" from="${cars}" optionKey="id" optionValue="gosnomer"/>
          <label for="trailnumber">Номер прицепа:</label>
          <input type="text" id="trailnumber" disabled value="${trip.trailnumber}" />
          <label for="container">Тип контейнера:</label>
          <input type="text" id="container" disabled value="${container.name}" />
          <label for="containernumber1">Контейнер1:</label>
          <input type="text" id="containernumber1" name="containernumber1" value="${zakaztodriver.containernumber1}" style="text-transform:uppercase;"/>
          <label for="containernumber2">Контейнер2:</label>
          <input type="text" id="containernumber2" name="containernumber2" ${zakaztodriver.containernumber2?'':'disabled'} value="${zakaztodriver.containernumber2}" style="text-transform:uppercase;"/>
          <label for="tel">Главные телефоны:</label>
          <input type="text" id="tel" disabled value="${(User.findAllByClient_idAndIs_am(trip.carrier,1).collect{it.tel}-'')?.unique().join(', ')}" />
          <label for="dateA">Дата начала поездки:</label>
          <input type="text" id="dateA" disabled value="${String.format('%td.%<tm.%<tY', trip.dateA?:trip.inputdate)}" />
          <label for="modstatus">Статус поездки:</label>
          <input type="text" id="modstatus" disabled value="${tripstatus.status}" />
          <label for="trackstatus">Статус мониторинга:</label>
          <input type="text" id="trackstatus" disabled value="${!trip.imei?'тракер не привязан':trip.trackstatus?'тракер доступен':'тракер недоступен'}"/>
          <label for="taskstatus">Статус сдачи контейнера:</label>
          <input type="text" id="taskstatus" disabled value="${Taskstatus.get(trip.taskstatus)?.status}"/>
          <label for="docstatus">Статус сдачи документов:</label>
          <input type="text" id="docstatus" disabled value="${trip.taskstatus==6?'документы сданы':'документы не сданы'}"/>
          <label for="comment">Комментарий:</label>
          <input type="text" id="comment" name="comment" value="${trip.comment}"/>
          <label for="idlesum">Сумма простоя:</label>
          <input type="text" id="idlesum" name="idlesum" value="${trip.idlesum}"/>
          <label for="forwardsum">Сумма переадресации:</label>
          <input type="text" id="forwardsum" name="forwardsum" value="${trip.forwardsum}"/>
          <label for="benefit">Сумма вознаграждения:</label>
          <input type="text" id="benefit" name="benefit" value="${trip.benefit}"/>
        <g:if test="${admin?.menu?.find{it.id==18}}">
          <label for="price">Ставка перевозчика:</label>
          <input type="text" id="price" name="price" value="${trip.price}"/>
        </g:if>
        </div>
        <div class="grid_5">
          <a class="button" href="javascript:void(0)" title="Маршрут" onclick="showTrackerRoute()"><i class="icon-road"></i></a>
          <a class="button" href="javascript:void(0)" title="Текущее местоположение" onclick="showTracker()"><i class="icon-location-arrow">&nbsp;</i></a>
          <br><br>
          <h3 class="fleft" id="label">Текущее местоположение</h3>
          <a class="link fright" id="mapResize" href="javascript:void(0)">Развернуть</a>
          <div class="clear"></div>
          <div class="box-iframe">
            <div id="map_canvas"></div>
          </div>
        <g:if test="${trip.imei}">
          Дата трека: <b>${route[0]?String.format('%td.%<tm.%<tY %<tT', route[0].tracktime):'нет данных'}</b><br/>
          Скорость движения: <b>${route[0]?route[0].speed:'нет данных'} км/час</b>
        </g:if><g:else>
          <b>Мониторинг недоступен для данной поездки</b>
        </g:else>
        </div>
        <div class="clear"></div>
        <div class="btns">
          <input type="button" class="button" ${!(trip.modstatus in 0..1)?'disabled':''} value="Отменить погрузку пер." onclick="cancelTrip(-3)"/>
          <input type="button" class="button" ${!(trip.modstatus in 0..1)?'disabled':''} value="Отменить погрузку отпр." onclick="cancelTrip(-2)"/>
          <input type="button" class="button" value="Сохранить" onclick="submitform(0)"/>
        <g:if test="${trip.modstatus in [0,1]}">
          <input type="button" class="button" value="Завершить" onclick="submitform(2)"/>
          <input type="button" class="button red" value="Аварийное завершение" onclick="if(confirm('Вы, действительно, хотите аварийно завершить поездку?')){submitform(-4)}else{}"/>
        </g:if><g:elseif test="${trip.modstatus==-1}">
          <input type="button" class="button" value="Восстановить" onclick="submitform(1)"/>
        </g:elseif>
          <input type="submit" id="proxy_submit_button" class="button" value="Сохранить" style="display:none"/>
        </div>
        <input type="hidden" id="status" name="status" value="0"/>
      </fieldset>
      <fieldset class="bord">
        <legend>Информация по маршруту</legend>
        <label><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-A icon-light"></i></span> Загрузка:</label>
        <input type="text" disabled value="${String.format('%td.%<tm.%<tY',trip.dateA)} c ${trip.timestartA} до ${trip.timeendA} <g:if test="${trip.terminal}">на терминале ${Terminal.get(trip.terminal)?.name}</g:if><g:elseif test="${trip.addressA}">по адресу ${trip.addressA}</g:elseif>" style="width:79%"/><br/>
        <label><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-B icon-light"></i></span> ${trip.ztype_id==1?'Выгрузка':trip.ztype_id==2?'Затарка':'Таможня'}:</label>
        <input type="text" disabled value="<g:if test="${trip.dateB}">${String.format('%td.%<tm.%<tY',trip.dateB)} ${trip.timestartB?' с '+trip.timestartB:''}${trip.timeendB?' до '+trip.timeendB:''}</g:if><g:else>Дата пока не задана</g:else> по адресу ${trip.addressB}" style="width:79%"/><br/>
      <g:if test="${trip.addressC}">
        <label><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-C icon-light"></i></span> ${trip.ztype_id==1?'Доп. выгрузка':trip.ztype_id==2?'Таможня':'Выгрузка'}:</label>
        <input type="text" disabled value="<g:if test="${trip.dateC}">${String.format('%td.%<tm.%<tY',trip.dateC)} ${trip.timestartC?' с '+trip.timestartC:''}${trip.timeendC?' до '+trip.timeendC:''}</g:if><g:else>Дата пока не задана</g:else> по адресу ${trip.addressC}" style="width:79%" /><br/>
      </g:if><g:if test="${trip.addressD}">
        <label><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-D icon-light"></i></span> ${trip.ztype_id==2?'Сдача':'Доп. выгрузка'}:</label>
        <input type="text" disabled value="<g:if test="${trip.dateD}">${String.format('%td.%<tm.%<tY',trip.dateD)} ${trip.timestartD?' с '+trip.timestartD:''}${trip.timeendD?' до '+trip.timeendD:''}</g:if><g:else>Дата пока не задана</g:else> по адресу ${trip.addressD}" style="width:79%" />
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
    <g:form id="returnToListForm" name="returnToListForm" url="${[action:'monitoring']}">
    </g:form>
  </body>
</html>
