<html>
  <head>
    <title>Административное приложение</title>
    <meta name="layout" content="admin" />
    <g:javascript>
      var ADDRESS_SEARCH_ZOOM=13,
          iX=${terminal?.x?:3031579},
          iY=${terminal?.y?:5993904},
      map=null, placemark=null;
      function returnToList(){
        $("returnToListForm").submit();
      }
      function getSlotlist(){
        if(${terminal?1:0}) $('slotlist_submit_button').click();
      }
      function processResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['name'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Название"])}</li>'; $("name").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        } else {
          location.assign('${createLink(action:'terminaldetail')}'+'/'+e.responseJSON.uId);
        }
      }
      function processSlotEditResponse(e){
        if(e.responseJSON.error){
          ['slot_name','slot_start','slot_end'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          var sErrorMsg = '';
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Название"])}</li>'; $("slot_name").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Номер терминала"])}</li>'; break;
              case 3: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Начало"])}</li>'; $("slot_start").addClassName('red'); break;
              case 4: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Окончание"])}</li>'; $("slot_end").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorslotlist").innerHTML=sErrorMsg;
          $("errorslotlist").up('div').show();
        } else {
          cancelEdit();
          getSlotlist();
        }
      }
      //map>>
      function Yandex(){
        ymaps.ready(function()  {
          map = new ymaps.Map("map_canvas",{center:[iY/100000,iX/100000],zoom:ADDRESS_SEARCH_ZOOM,behaviors:["default","scrollZoom"]});
          map.controls.add("smallZoomControl").add("scaleLine")
          placemark = new ymaps.Placemark([iY/100000,iX/100000],{},{
            draggable: true,
            hasBalloon: false,
            iconImageHref:"${resource(dir:'images',file:'marker.png')}",
            iconImageSize: [19,37],
            iconImageOffset:[-14,-35],
            iconContentOffset:[-1,10]
          });
          map.geoObjects.add(placemark);
          placemark.events.add("dragend", function(result){
            var coordinates=this.geometry.getCoordinates();
            var x=Math.round(coordinates[1]*100000);
            var y=Math.round(coordinates[0]*100000);
            $('y').value = y; // и добавляем в поля широту
            $('x').value = x; // и долготу
          },placemark);
          map.events.add("click", function(e){
            var clickPoint=e.get("coordPosition");
            map.geoObjects.remove(placemark);
            map.setCenter(clickPoint, map.getZoom()); // центром карты делаем эту точку
            placemark = new ymaps.Placemark(clickPoint,{},{
              draggable: true,
              hasBalloon: false,
              iconImageHref:"${resource(dir:'images',file:'marker.png')}",
              iconImageSize: [19,37],
              iconImageOffset:[-14,-35],
              iconContentOffset:[-1,10]        
            });
            map.geoObjects.add(placemark);
            var x=Math.round(clickPoint[1]*100000);
            var y=Math.round(clickPoint[0]*100000);
            $('y').value  = y; // и добавляем в поля широту
            $('x').value = x; // и долготу
            placemark.events.add("dragend", function (result) {
              var coordinates =  this.geometry.getCoordinates();
              var x=Math.round(coordinates[1]*100000);
              var y=Math.round(coordinates[0]*100000);
              $('y').value  = y; // и добавляем в поля широту
              $('x').value = x; // и долготу
            },placemark);
          });
        });
      }
      function geocodeAddress(address) {
        var geocoder2 = ymaps.geocode(address, {results: 1, boundedBy: map.getBounds()});
        // Результат поиска передается в callback-функцию
        geocoder2.then(function (res) {
          map.geoObjects.remove(placemark);
          if (res.geoObjects.getLength()) {
            placemark = res.geoObjects.get(0);
            placemark.options.set({
              draggable: true,
              iconImageHref:"${resource(dir:'images',file:'marker.png')}",
              iconImageSize: [19,37],
              iconImageOffset:[-14,-35],
              iconContentOffset:[-1,10]
            });
            map.setZoom(ADDRESS_SEARCH_ZOOM);
            map.panTo(placemark.geometry.getCoordinates(),{flying:false});
            map.geoObjects.add(placemark);
            var x = Math.round(placemark.geometry.getCoordinates()[1]*100000);
            var y = Math.round(placemark.geometry.getCoordinates()[0]*100000);
            $('y').value  = y;
            $('x').value = x;
            placemark.events.add("dragend", function (result) { 
              var coordinates =  this.geometry.getCoordinates();
              var x=Math.round(coordinates[1]*100000);
              var y=Math.round(coordinates[0]*100000);
              $('y').value  = y; // и добавляем в поля широту
              $('x').value = x; // и долготу
            },placemark);
            $('geocodererror').hide();
          }else
            $('geocodererror').show();
        },
        function (error) {
          $('geocodererror').show();
        });
      }
      //map<<
      function hidesloterrors(){
        ['slot_name','slot_start','slot_end'].forEach(function(ids){
          $(ids).removeClassName('red');
        });
        $("errorslotlist").up('div').hide();
      }
      function cancelEdit(){
        hidesloterrors();
        jQuery('#slotEditForm').slideUp();        
      }
      function editSlot(iId,sName,sStart,sEnd,iStatus){
        hidesloterrors();
        iId = iId || 0;
        $('slot_name').value = sName;
        $('slot_modstatus').selectedIndex = iStatus;
        $('slot_start').value = sStart;
        $('slot_end').value = sEnd;
        $('slot_id').value = iId;
        jQuery('#slotEditForm').slideDown();        
      }
      function deleteSlot(iId){
        <g:remoteFunction controller='administrators' action='deleteSlot' onSuccess="cancelEdit();getSlotlist();" params="'id='+iId+'&terminal_id=${terminal?.id}'" />
      }
    </g:javascript>
  </head>
  <body onload="getSlotlist();Yandex();">
    <h1 class="padding-bottom">${terminal?'Терминал '+terminal.name:'Добавление нового терминала'}</h1>
    <a class="link fright" href="javascript:void(0)" onClick="returnToList();">К списку терминалов</a>
    <div class="clear"></div>
    <div class="error-box" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>
    </div>    
    <g:formRemote class="contact-form" name="terminalDetailForm" url="[action:'saveTerminalDetail', id:terminal?.id?:0]" method="post" onSuccess="processResponse(e)">
      <fieldset>
        <div class="grid_6">
          <label for="name">Название:</label>
          <input type="text" id="name" name="name" value="${terminal?.name}" />
          <label for="modstatus">Статус:</label>
          <g:select name="modstatus" value="${terminal?.modstatus}" keys="${0..1}" from="${['неактивный','активный']}"/>
          <label for="is_main">Приоритет:</label>
          <g:select name="is_main" value="${terminal?.is_main}" keys="${0..1}" from="${['не главный','главный']}" />
          <label for="infourl">Сайт:</label>
          <input type="text" id="infourl" name="infourl" value="${terminal?.infourl}" />
          <label for="address">Адрес:</label>
          <input type="text" id="address" name="address" value="${terminal?.address}" />
          <a class="link fright" href="javascript:void(0)" onclick="geocodeAddress($('address').value);">Геокодировать адрес</a>
          <div class="pad-top1 error" id="geocodererror" style="display:none">
            <p>Заданный адрес не найден.<br/>
            Укажите вручную местонахождение вашего объекта, щелкнув на карте в нужном месте мышью.<br/>
            Вы можете откорректировать местоположение, перетащив маркер мышью.</p>
          </div>
        </div>
        <div class="grid_5">
          <div class="box-iframe">
            <div id="map_canvas"></div>
          </div>
        </div>
        <div class="clear"></div>
        <div class="btns">
          <input type="submit" id="submit_button" class="button" value="Сохранить" />
          <input type="reset" class="button" value="Сброс" />
        </div>      
      </fieldset>
      <input type="hidden" id="x" name="x" value="${terminal?.x?:0}" />
      <input type="hidden" id="y" name="y" value="${terminal?.y?:0}" />
    </g:formRemote>
  <g:if test="${terminal}">
    <h1 class="img-bottom">Слоты терминала ${terminal.name}</h1>
    <g:formRemote class="contact-form padding-bottom3" id="slotEditForm" name="slotEditForm" url="[action:'saveSlotDetail']" method="post" onSuccess="processSlotEditResponse(e)" style="display:none">
      <div class="error padding-bottom2" style="display:none">
        <ul id="errorslotlist">
          <li></li>
        </ul>
      </div>      
      <fieldset>
        <div class="grid_6">
          <label for="slot_name">Название:</label>
          <input type="text" id="slot_name" name="slot_name" value="" />
          <label for="slot_modstatus">Статус:</label>
          <g:select name="slot_modstatus" value="" keys="${0..1}" from="${['неактивный','активный']}"/>
        </div>
        <div class="grid_6">
          <label for="slot_start">Начало:</label>
          <input type="text" id="slot_start" name="slot_start" value="" />
          <label for="slot_end">Окончание:</label>
          <input type="text" id="slot_end" name="slot_end" value="" />
        </div>
        <div class="btns">
          <input type="submit" id="submit_button" class="button" value="Сохранить" />
          <input type="reset" class="button" value="Отмена" onclick="cancelEdit()" />
        </div>
      </fieldset>      
      <input type="hidden" id="slot_id" name="slot_id" value="" />
      <input type="hidden" id="terminal_id" name="terminal_id" value="${terminal?.id}" />
    </g:formRemote>    
    <g:formRemote name="slotlistForm" url="[action:'slotlist',id:terminal.id]" update="[success:'slotlist']">
      <input type="submit" class="button" id="slotlist_submit_button" value="Показать" style="display:none" />
    </g:formRemote>    
    <div id="slotlist"></div>
  </g:if>
    <g:form id="returnToListForm" name="returnToListForm" url="${[action:'terminal']}">
    </g:form>
  </body>
</html>