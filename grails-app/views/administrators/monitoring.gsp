<html>
  <head>
    <title>Административное приложение containerovoz.ru</title>
    <meta name="layout" content="admin" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'kendo.default.min.css')}" type="text/css" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'kendo.common.min.css')}" type="text/css" />
    <g:javascript library="kendo.culture.ru-RU.min" />
    <g:javascript library="kendo.web.min" />
    <g:javascript>
      var ADDRESS_SEARCH_ZOOM=13,
          iX=303157900, iY=599390400,
          map=null, gBounds=null
      function initialize(iParam){
        switch(iParam){
          case 0:
            sectionColor('trip');
            $('tripfilter').show();
            $('tripeventfilter').hide();
            $('tripmapfilter').hide();
            $('trip_submit_button').click();
            break;
          case 1:
            sectionColor('tripevent');
            $('tripfilter').hide();
            $('tripeventfilter').show();
            $('tripmapfilter').hide();
            $('tripevent_submit_button').click();
            break;
          case 2:
            sectionColor('tripmap');
            $('tripfilter').hide();
            $('tripeventfilter').hide();
            $('tripmapfilter').show();
            $('tripmap_submit_button').click();
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
        $('trip').style.color = 'black';
        $('tripevent').style.color = 'black';
        $('tripmap').style.color = 'black';
        $(sSection).style.color = '#0080F0';
      }
      //map>>
      function renderMap(){
        ymaps.ready(function()  {
          map = new ymaps.Map("map_canvas",{center:[iY/10000000,iX/10000000],zoom:ADDRESS_SEARCH_ZOOM,behaviors:["default","scrollZoom"]});
          map.controls.add("smallZoomControl").add("scaleLine")
        });
        gBounds = new ymaps.GeoObjectCollection();
      }
      function clearMap(){
        map.geoObjects.remove(gBounds);
        gBounds.removeAll()
      }
      function addplacemark(lX,lY,sTime,iKurs,iSpeed,iTripId,sGosnomer,sDriver){
        if (map){
          var placemark = new ymaps.Placemark([lY/10000000,lX/10000000],{
            hintContent:'машина: '+sGosnomer+'<br/>водитель: '+sDriver+'<br/>время: '+sTime+'<br/>курс на '+getKursString(iKurs)+'<br/>скорость: '+iSpeed+' км/ч'
          },{
            draggable: false,
            hasBalloon: false,
            iconImageHref:"${resource(dir:'images',file:'marker.png')}",
            iconImageSize: [19,37],
            iconImageOffset:[-14,-35],
            iconContentOffset:[-1,10]
          });
          placemark.events.add("click", function(result) {
            location.assign('${context.serverURL}'+'/administrators/tripdetail/'+iTripId)
          },placemark);
          gBounds.add(placemark);
        }
      }
      function renderplacemark(){
        map.geoObjects.add(gBounds);
        if(gBounds.getLength())
          map.setBounds(gBounds.getBounds(),{checkZoomRange:true});
        else
          map.setCenter([iY/10000000,iX/10000000],ADDRESS_SEARCH_ZOOM, { checkZoomRange: true });
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
    </g:javascript>
    <style type="text/css">
      .grid_4 .link{color:#fff;font-size:18px;margin-left:15px;text-decoration:underline}
      .contact-form input.mini{width:40px}
      .box-iframe,#map_canvas{width:950px;height:400px}
    </style>
  </head>
	<body onload="initialize(${type})">
    <div class="menu admin">
      <div class="grid_4 p3 fright" align="right">
        <a class="link" href="javascript:void(0)" onclick="initialize(0)" id="trip">Поездки</a>
        <a class="link" href="javascript:void(0)" onclick="initialize(1)" id="tripevent">События</a>
        <a class="link" href="javascript:void(0)" onclick="initialize(2)" id="tripmap">Карта</a>
      </div>
      <div class="clear"></div>
      <div id="tripfilter">
        <g:formRemote class="contact-form nopad" name="allForm" url="[action:'triplist']" onSuccess="\$('mapcontainer').hide();" update="[success:'resultlist']">
          <fieldset>
            <label class="auto" for="trip_id">Код:</label>
            <input type="text" id="trip_id" name="trip_id" value="${inrequest?.trip_id}" class="mini"/>
            <label class="auto" for="zakaz_id">Заказ:</label>
            <input type="text" id="zakaz_id" name="zakaz_id" value="${inrequest?.zakaz_id}" class="mini"/>
            <label class="auto" for="shipper">Отправитель:</label>
            <g:select name="shipper" style="width:138px" value="${inrequest?.shipper}" from="${shippernames}" optionKey="id" optionValue="fullname" noSelection="${['0':'Любой']}"/>
            <label class="auto" for="carrier">Перевозчик:</label>
            <g:select name="carrier" style="width:135px" value="${inrequest?.carrier}" from="${carriernames}" optionKey="id" optionValue="fullname" noSelection="${['0':'Любой']}"/>
            <label class="auto" for="cargosnomer">Тягач:</label>
            <input type="text" id="cargosnomer" name="cargosnomer" value="${inrequest?.cargosnomer}" style="width:110px" /><br/>
            <label class="auto" for="driver_id">Водитель:</label>
            <g:select name="driver_id" style="width:246px" value="${inrequest?.driver_id}" from="${drivernames}" optionKey="id" optionValue="fullname" noSelection="${['0':'Любой']}"/>
            <label for="container" class="auto">Контейнер:</label>
            <input type="text" id="container" style="width:130px" name="container" value="${inrequest?.container}"/>
            <label class="auto" for="modstatus">Статус:</label>
            <select id="modstatus" name="modstatus">
              <option value="-101" <g:if test="${inrequest?.modstatus==-101}">selected="selected"</g:if>>активные</option>
            <g:each in="${tripstatus}">
              <option value="${it.id}" <g:if test="${inrequest?.modstatus==it.id}">selected="selected"</g:if>>${it.status}</option>
            </g:each>
              <option value="-100" <g:if test="${inrequest?.modstatus==-100}">selected="selected"</g:if>>все</option>
            </select>
            <div class="btns">
              <input type="submit" class="button" id="trip_submit_button" value="Показать" />
              <input type="reset" class="button" value="Сброс" />
            </div>
          </fieldset>
        </g:formRemote>
      </div>
      <div id="tripeventfilter" style="display:none">
        <g:formRemote class="contact-form nopad" name="allForm" url="[action:'eventlist']" onSuccess="\$('mapcontainer').hide();" update="[success:'resultlist']">
          <fieldset>
            <label class="auto" for="trip_id">Код:</label>
            <input type="text" id="trip_id" name="trip_id" value="${inrequest?.trip_id}" class="mini"/>
            <label class="auto" for="shipper">Отправитель:</label>
            <g:select name="shipper" style="width:148px" value="${inrequest?.shipper}" from="${shippernames}" optionKey="id" optionValue="fullname" noSelection="${['0':'Любой']}"/>
            <label class="auto" for="carrier">Перевозчик:</label>
            <g:select name="carrier" style="width:135px" value="${inrequest?.carrier}" from="${carriernames}" optionKey="id" optionValue="fullname" noSelection="${['0':'Любой']}"/>
            <label class="auto" for="cargosnomer">Тягач:</label>
            <input type="text" id="cargosnomer" name="cargosnomer" value="${inrequest?.cargosnomer}" style="width:110px" /><br/>
            <label class="auto" for="driver_id">Водитель:</label>
            <g:select name="driver_id" style="width:234px" value="${inrequest?.driver_id}" from="${drivernames}" optionKey="id" optionValue="fullname" noSelection="${['0':'Любой']}"/>
            <label class="auto" for="modstatus">Статус:</label>
            <select id="modstatus" name="modstatus" style="width:170px">
              <option value="-101" <g:if test="${inrequest?.modstatus==-101}">selected="selected"</g:if>>активные</option>
            <g:each in="${tripstatus}">
              <option value="${it.id}" <g:if test="${inrequest?.modstatus==it.id}">selected="selected"</g:if>>${it.status}</option>
            </g:each>
              <option value="-100" <g:if test="${inrequest?.modstatus==-100}">selected="selected"</g:if>>все</option>
            </select>
            <label class="auto" for="type_id">Тип события:</label>
            <g:select class="auto" name="type_id" optionKey="id" optionValue="name" from="${tripeventtype}" noSelection="${['-100':'все']}" value="${inrequest?.type_id}"/><br/>
            <label class="auto" for="date_start">Дата начала:</label>
            <g:datepicker class="normal nopad" name="date_start" value="${String.format('%td.%<tm.%<tY',inrequest?.date_start?:new Date())}"/>
            <label class="auto" for="date_end">Дата окончания:</label>
            <g:datepicker class="normal nopad" name="date_end" value="${String.format('%td.%<tm.%<tY',inrequest?.date_end?:new Date())}"/>
            <div class="btns fright">
              <input type="submit" class="button" id="tripevent_submit_button" value="Показать" />
              <input type="reset" class="button" value="Сброс" />
            </div>
          </fieldset>
        </g:formRemote>
      </div>
      <div id="tripmapfilter" style="display:none">
        <g:formRemote class="contact-form nopad" name="allForm" url="[action:'tripmap']" onSuccess="\$('mapcontainer').show();" update="[success:'resultlist']">
          <fieldset>
            <label class="auto" for="trip_id">Код:</label>
            <input type="text" id="trip_id" name="trip_id" value="${inrequest?.trip_id}" class="mini"/>
            <label class="auto" for="zakaz_id">Заказ:</label>
            <input type="text" id="zakaz_id" name="zakaz_id" value="${inrequest?.zakaz_id}" class="mini"/>
            <label class="auto" for="shipper">Отправитель:</label>
            <g:select name="shipper" style="width:148px" value="${inrequest?.shipper}" from="${shippernames}" optionKey="id" optionValue="fullname" noSelection="${['0':'Любой']}"/>
            <label class="auto" for="carrier">Перевозчик:</label>
            <g:select name="carrier" style="width:135px" value="${inrequest?.carrier}" from="${carriernames}" optionKey="id" optionValue="fullname" noSelection="${['0':'Любой']}"/>
            <label class="auto" for="cargosnomer">Тягач:</label>
            <input type="text" id="cargosnomer" name="cargosnomer" value="${inrequest?.cargosnomer}" style="width:110px" /><br/>
            <label class="auto" for="driver_id">Водитель:</label>
            <g:select name="driver_id" style="width:236px" value="${inrequest?.driver_id}" from="${drivernames}" optionKey="id" optionValue="fullname" noSelection="${['0':'Любой']}"/>
            <label for="container" class="auto">Контейнер:</label>
            <input type="text" id="container" style="width:150px" name="container" value="${inrequest?.container}"/>
            <label class="auto" for="modstatus">Статус:</label>
            <select id="modstatus" name="modstatus">
              <option value="-101" <g:if test="${inrequest?.modstatus==-101}">selected="selected"</g:if>>активные</option>
            <g:each in="${tripstatus}">
              <option value="${it.id}" <g:if test="${inrequest?.modstatus==it.id}">selected="selected"</g:if>>${it.status}</option>
            </g:each>
              <option value="-100" <g:if test="${inrequest?.modstatus==-100}">selected="selected"</g:if>>все</option>
            </select>
            <div class="btns">
              <input type="submit" class="button" id="tripmap_submit_button" value="Показать" />
              <input type="reset" class="button" value="Сброс" />
            </div>
          </fieldset>
        </g:formRemote>
      </div>
    </div>
    <div id="resultlist"></div>
    <div id="mapcontainer" class="box-iframe" style="display:none">
      <div id="map_canvas"></div>
    </div>
  </body>
</html>
