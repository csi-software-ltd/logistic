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
      var ADDRESS_SEARCH_ZOOM=13,MAX_MAP_ZOOM=10, MAX_MAP_ZOOM_DEF=23,
          iX=${trackingdata?.x?:303157900},
          iY=${trackingdata?.y?:599390400},              
          map=null, placemark=null, gBounds=null, myPolyline=null, aPlacemarkRoute=[], aPlacemarkRouteEnds=[], aTracker_route=[],
          fullScreen=false, bTrackerPlace=true, sRouteDate='';
      function returnToList(){
        $("returnToListForm").submit();
      }
      function processResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['imei','tel','trackaccount','car_gosnomer'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["IMEI"])}</li>'; $("imei").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Телефон"])}</li>'; $("tel").addClassName('red'); break;
              case 3: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Учетный номер"])}</li>'; $("trackaccount").addClassName('red'); break;
              case 4: sErrorMsg+='<li>${message(code:"error.not.exist.message",args:["Машины","номером"])}</li>'; $("car_gosnomer").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        } else {
          location.assign('${createLink(action:'trackerdetail')}'+'/'+e.responseJSON.uId);
        }
      }
      //map>>
      function Yandex(){
        new Autocomplete('car_gosnomer', { serviceUrl:'${resource(dir:'administrators',file:'car_autocomplete')}' });
        ymaps.ready(function()  {
          map = new ymaps.Map("map_canvas",{center:[iY/10000000,iX/10000000],zoom:ADDRESS_SEARCH_ZOOM,behaviors:["default","scrollZoom"]});
          map.controls.add("smallZoomControl").add("scaleLine");
          placemark = new ymaps.Placemark([iY/10000000,iX/10000000],{},{
            draggable: false,
            hasBalloon: false,
            iconImageHref:"${resource(dir:'images',file:'marker.png')}",
            iconImageSize: [19,37],
            iconImageOffset:[-14,-35],
            iconContentOffset:[-1,10]
          });
          map.geoObjects.add(placemark);
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
          
          map.events.add("boundschange", function(map_e) {           
            if((map_e.get('newZoom')!=map_e.get('oldZoom'))|| bTrackerPlace){
              if(map_e.get('newZoom')>MAX_MAP_ZOOM){             
                if(map_e.get('oldZoom')<=MAX_MAP_ZOOM || bTrackerPlace){//add markers                                 
                  var i=0;
                  aTracker_route.forEach(function(t_route){
                    if(i!=0 && i!=aTracker_route.length-1){                                    
                      var sKurs='';                  
                      if(t_route.kurs<=23 || t_route.kurs>=338)            
                        sKurs='север';
                      else if(t_route.kurs>23 && t_route.kurs<68)            
                        sKurs='северо-восток';
                      else if(t_route.kurs>=68 && t_route.kurs<=113)            
                        sKurs='восток';
                      else if(t_route.kurs>113 && t_route.kurs<158)            
                        sKurs='юго-восток'; 
                      else if(t_route.kurs>=158 && t_route.kurs<=225)            
                        sKurs='юг';
                      else if(t_route.kurs>225 && t_route.kurs<248)            
                        sKurs='юго-запад';
                      else if(t_route.kurs>=248 && t_route.kurs<=293)            
                        sKurs='запад';
                      else if(t_route.kurs>293 && t_route.kurs<338)            
                        sKurs='северо-запад';       
                      if(t_route.speed==0)
                        sKurs='0';            
                      var placemarkRoute = new ymaps.Placemark([t_route.y/10000000,t_route.x/10000000],{                        
                        hintContent:'время: '+t_route.tracktime.replace('T',' ').replace('Z',' ')+'<br/>курс на '+sKurs+'<br/>скорость: '+t_route.speed+' км/ч'},{
                        draggable: false,
                        hasBalloon: false,
                        iconLayout: (t_route.speed<=5)?'my#passiveIcon':'my#activeIcon'
                      });
                      map.geoObjects.add(placemarkRoute);
                      aPlacemarkRoute.push(placemarkRoute);                
                    }
                    i++;                  
                  });                                
                }  
              }else{
                aPlacemarkRoute.each(function (el, i) {
                  map.geoObjects.remove(el);       
                });
                aPlacemarkRoute=[];                
              }         
            }
          });          
        });           	        
      }
      function showTrackerRoute(){ 
        $("tracker_route").hide();
        bTrackerPlace=true;           
        var id=${tracker?.id?:0};
        var date=$("date").value;
        sRouteDate=$("date").value;
        <g:remoteFunction action='tracker_route' params="'id='+id+'&date='+date"  update="tracker_tmp"/>
      }
      function proccessTrackerRoute(){
        $("tracker_route").hide();
        $("tracker_tmp").update('');        
        $("label").update('Маршрут');
        clearMap();
        var aPolylinePoints=[],i=0;              
        aTracker_route.forEach(function(t_route){
          if(i==0){
            var placemarkRoute = new ymaps.Placemark([t_route.y/10000000,t_route.x/10000000],{              
              hintContent:'время: '+t_route.tracktime.replace('T',' ').replace('Z',' ')},{
              draggable: false,
              hasBalloon: false,
              iconLayout: 'my#startIcon'
             });
             map.geoObjects.add(placemarkRoute);
             aPlacemarkRouteEnds.push(placemarkRoute);
          }else if(i==aTracker_route.length-1){
            var placemarkRoute = new ymaps.Placemark([t_route.y/10000000,t_route.x/10000000],{              
              hintContent:'время: '+t_route.tracktime.replace('T',' ').replace('Z',' ')},{
              draggable: false,
              hasBalloon: false,
              iconLayout: 'my#endIcon'              
            });
            map.geoObjects.add(placemarkRoute);
            aPlacemarkRouteEnds.push(placemarkRoute);
          }          
          aPolylinePoints.push([t_route.y/10000000,t_route.x/10000000]);          
          i++;
        });        
        myPolyline = new ymaps.Polyline(aPolylinePoints,{},{strokeColor:'#0000FF',strokeWidth:6,opacity:0.5});  
        map.geoObjects.add(myPolyline);      
        gBounds = new ymaps.GeoObjectCollection();       
        gBounds.add(myPolyline);       
        map.geoObjects.add(gBounds);
        if(gBounds.getBounds()!=null)
          map.setBounds(gBounds.getBounds());           
        map.setCenter(map.getCenter(), (map.getZoom()!=MAX_MAP_ZOOM_DEF)?map.getZoom():MAX_MAP_ZOOM, { checkZoomRange: true });
        bTrackerPlace=false;
      }
      function clearMap(){         
        if(placemark){    
          map.geoObjects.remove(placemark);
          placemark=null;
        }                
        if(gBounds!=null){
          gBounds.each(function (el, i) {
            map.geoObjects.remove(el);       
          });
          gBounds.removeAll();
        }
        if(myPolyline!=null){
          map.geoObjects.remove(myPolyline);
          myPolyline=null;    
        }        
        aPlacemarkRoute.each(function (el, i) {
          map.geoObjects.remove(el);       
        });
        aPlacemarkRoute=[];
      
        aPlacemarkRouteEnds.each(function (el, i) {
          map.geoObjects.remove(el);       
        });
        aPlacemarkRouteEnds=[];                
      }
      function showTracker(bNoData){
        if(bNoData==undefined)
          $("tracker_route").show();      
        bTrackerPlace=true;
        $("label").update('Текущее местоположение');
        clearMap();
        aTracker_route=[];
        placemark = new ymaps.Placemark([iY/10000000,iX/10000000],{},{
          draggable: false,
          hasBalloon: false,
          iconImageHref:"${resource(dir:'images',file:'marker.png')}",
          iconImageSize: [19,37],
          iconImageOffset:[-14,-35],
          iconContentOffset:[-1,10]         
        });
        map.geoObjects.add(placemark);
        map.setCenter([iY/10000000,iX/10000000],ADDRESS_SEARCH_ZOOM, { checkZoomRange: true });
      }
      function mapResize(){
        fullScreen = !fullScreen;        
        if(fullScreen){        
          jQuery('.box-iframe').animate({
            width: '890px',        
            height: '500px',
            marginLeft: '-554px',           
            marginBottom: '-180px'          
          }, 500, function(){            
            map.container.fitToViewport();            
          }); 
          jQuery('#map_canvas').addClass('bigMap');          
          jQuery('#mapResize').html('Свернуть');
          map.controls.remove("smallZoomControl");          
          map.controls.add("zoomControl");
        } else {
          jQuery('.box-iframe,#map_canvas').animate({
            width: '336px',
            height: '330px',
            marginLeft: '0',          
            marginBottom: '22px',          
          }, 500, function(){                      
            map.container.fitToViewport();                        
          });          
          jQuery('#map_canvas').removeClass('bigMap');
          jQuery('#mapResize').html('Развернуть');
          map.controls.remove("zoomControl");
          map.controls.add("smallZoomControl");
        }        
        map.container.fitToViewport();
      }
    </g:javascript>
    <style type="text/css">
      .contact-form label{min-width:135px}      
      .bigMap{width:890px!important;height:500px!important}      
      .icon-red {color:red;text-shadow:0 2px 2px rgba(0, 0, 0, 0.8);}
      .icon-black{color:#000;text-shadow:0 2px 2px rgba(255, 255, 255, 1);}      
    </style>
  </head>
  <body onload="Yandex();">
    <script type="text/javascript">
      function onChange_date(){      
        if($("date").value!=sRouteDate){
          showTrackerRoute();          
        }else 
          $("tracker_route").hide();
      }
    </script>
    <h1 class="fleft">${tracker?'Тракер №'+tracker.id:'Добавление нового тракера'}</h1>
    <a class="link fright" href="javascript:void(0)" onClick="returnToList();">К списку тракеров</a>
    <div class="clear"></div>
    <div class="error-box" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>
    </div>    
    <g:formRemote class="contact-form" name="trackerDetailForm" url="[action:'saveTrackerDetail', id:tracker?.id?:0]" method="post" onSuccess="processResponse(e)">
      <fieldset>
        <div class="grid_6 suffix_1">
          <label for="inputdate">Дата добавления:</label>
          <input type="text" id="inputdate" disabled value="${String.format('%tF %<tT', tracker?.inputdate?:new Date())}" />
          <label for="moddate">Дата модификации:</label>
          <input type="text" id="moddate" disabled value="${String.format('%tF %<tT', tracker?.moddate?:new Date())}" />
          <label for="client_fullname">Принадлежит клиенту:</label>
          <input type="text" id="client_fullname" disabled value="${client?.fullname?:'не принадлежит'}" />
          <label for="car_gosnomer">Установлен на машине:</label>
          <input type="text" id="car_gosnomer" name="car_gosnomer" value="${car?.gosnomer?:''}" placeholder="не установлен"/>          
          <div id="car_autocomplete" class="autocomplete" style="display:none"></div>
          <hr class="admin" />
          <label for="imei">IMEI:</label>
          <input type="text" ${tracker?'readonly':''} id="imei" name="imei" value="${tracker?.imei}" />
          <label for="sim">Номер SIM:</label>
          <input type="text" id="sim" name="sim" value="${tracker?.sim}" />
          <label for="tel">Телефон:</label>
          <input type="text" id="tel" name="tel" value="${tracker?.tel}" />
          <label for="trackaccount">Учетный номер:</label>
          <input type="text" id="trackaccount" name="trackaccount" value="${tracker?.trackaccount}" />
          <label for="modstatus">Статус:</label>
          <g:select name="modstatus" value="${tracker?.modstatus?:0}" keys="${-1..2}" from="${['списан','неактивный','активный','в ремонте']}"/>
          <div class="btns pad-top2">
            <input type="submit" id="submit_button" class="button" value="Сохранить" />
            <input type="reset" class="button" value="Сброс" />
          </div>          
        </div>
        <div class="grid_5">          
          <label for="date" class="auto">Дата тракера:</label>
          <g:datepicker class="normal nopad" name="date" value="${String.format('%td.%<tm.%<tY',trackingdata?.tracktime)}" change="1"/>
          <a class="button" href="javascript:void(0)" title="Маршрут" id="tracker_route" onclick="showTrackerRoute()"><i class="icon-road"></i></a>
          <a class="button" href="javascript:void(0)" title="Текущее местоположение" onclick="showTracker()"><i class="icon-location-arrow">&nbsp;</i></a>
          <br><br>
          <h3 class="fleft" id="label">Текущее местоположение</h3>          
          <a class="link fright" id="mapResize" href="javascript:void(0)">Развернуть</a>          
          <div class="clear"></div>
          <div class="box-iframe">          
            <div id="map_canvas"></div>         
          </div>  
          Дата трека: <b>${String.format('%tF %<tT', trackingdata?.tracktime)}</b><br/>
          Скорость движения: <b>${trackingdata?.speed?:0} км/час</b>
        </div>
      </fieldset>
    </g:formRemote>
    <g:form id="returnToListForm" name="returnToListForm" url="${[action:'trackers']}">
    </g:form>
    <div id="tracker_tmp" style="display:none"></div>
  </body>
</html>
