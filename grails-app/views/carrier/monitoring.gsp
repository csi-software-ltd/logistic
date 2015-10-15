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
    var ADDRESS_SEARCH_ZOOM=13, MAX_MAP_ZOOM=10, MAX_MAP_ZOOM_DEF=23,     
          iX=${terminal?.x?:303157900}, iY=${terminal?.y?:599390400},
          map=null, placemark=null, gBounds=null, myPolyline=null, aPlacemarkRoute=[], aPlacemarkRouteEnds=[], aTracker_route=[],
          bTrackerPlace=true, sRouteDate=''; //HMap=[]                   
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
      function initialize(iParam){
        $('h1').update('Мониторинг');
        switch(iParam){
          case 0:
            sectionSelected('trip');
            $('mapcontainer').hide();
            $('tripForm').show();
            $('tripeventForm').hide();
            $('trip_submit_button').click();
            $("my_cars").hide();
            break;
          case 1:
            sectionSelected('tripevent');
            $('mapcontainer').hide();
            $('tripForm').hide();
            $('tripeventForm').show();
            $("my_cars").hide();
            $('tripevent_submit_button').click();
            break;
          case 2:
            sectionSelected('mycars');
            $('tripForm').hide();
            $('tripeventForm').hide();         
            var lId=${user?.id?:0};            
            $("my_cars").show();
            $("car").selectedIndex = 0;
            $("car_filtr").hide();
            $("tracker_route").show();
            jQuery("#date").data("kendoDatePicker").value(new Date());
            <g:remoteFunction action='trackermap' onSuccess="\$('mapcontainer').show();" update="[success:'resultlist']" params="\'id=\'+lId" />
            break;  
        }
      }
      function sectionSelected(sSection){
        $('trip').up('li').removeClassName('selected');
        $('tripevent').up('li').removeClassName('selected');
        $('mycars').up('li').removeClassName('selected');
        $(sSection).up('li').addClassName('selected');
      }
      
      function renderMap(){
        ymaps.ready(function()  {
          map = new ymaps.Map("map_canvas",{center:[iY/10000000,iX/10000000],zoom:ADDRESS_SEARCH_ZOOM,behaviors:["default","scrollZoom"]});
          map.controls.add("zoomControl").add("scaleLine");

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
                      var sKurs=getKursString(t_route.kurs);                                               
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
        gBounds = new ymaps.GeoObjectCollection();
      }
      function clearMap(){
        map.geoObjects.remove(gBounds);
        gBounds.removeAll()
      }
      function addplacemark(lX,lY,sTime,iKurs,iSpeed,SGosNum){
        if (map){
          var placemark = new ymaps.Placemark([lY/10000000,lX/10000000],{
            hintContent:'номер: '+SGosNum+'<br/>время: '+sTime+'<br/>курс на '+getKursString(iKurs)+'<br/>скорость: '+iSpeed+' км/ч'
          },{
            draggable: false,
            hasBalloon: false,
            iconImageHref:"${resource(dir:'images',file:'marker.png')}",
            iconImageSize: [19,37],
            iconImageOffset:[-14,-35],
            iconContentOffset:[-1,10]
          });         
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
//>>    
      function showTrackerRoute(){ 
        $("tracker_route").hide();
        bTrackerPlace=true;           
        var id=$("car").value;
        var date=$("date").value;
        sRouteDate=$("date").value;
        $('h1').update('Мониторинг (маршрут)');
        <g:remoteFunction action='car_route' params="'id='+id+'&date='+date"  update="resultlist"/>
      }
      function proccessTrackerRoute(){
        $("tracker_route").hide();
        $("resultlist").update('');        
        //$("label").update('Маршрут');
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
        clearMap();
        aTracker_route=[];        
        var id=$("car").value;
        $('h1').update('Мониторинг (текущее местоположение)');
        <g:remoteFunction action='car_route' params="'id='+id+'&current=1'"  update="resultlist"/>                
      }
      function setCar(iCarId){
        if(iCarId!="0"){
          $("car_filtr").show();
        }else{
          $("car_filtr").hide();
          initialize(2);
        }
        $("tracker_route").show();
      }            
    </g:javascript>
    <style type="text/css">        
      .box-iframe,#map_canvas{width:950px!important;height:500px!important}
      .icon-red {color:red;text-shadow:0 2px 2px rgba(0, 0, 0, 0.8);}
      .icon-black{color:#000;text-shadow:0 2px 2px rgba(255, 255, 255, 1);}         
    </style>
  </head>
  <body onload="initialize(${type})">
    <script type="text/javascript">
      function onChange_date(){      
        if($("date").value!=sRouteDate){
          showTrackerRoute();          
        }else 
          $("tracker_route").hide();
      }
    </script>
    <h1 id="h1">${infotext?.header?:''}</h1>
    <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
    <g:formRemote class="contact-form" name="tripForm" url="[action:'triplist']" update="[success:'resultlist']" onLoading="\$('loader').show()" onLoaded="\$('loader').hide()">
      <fieldset>
        <label for="trip_modstatus" class="auto">Статус:</label>
        <g:select name="trip_modstatus" class="auto nopad" value="${inrequest?.trip_modstatus}" from="${tripstatus}" optionKey="id" optionValue="status" noSelection="${['-100':'Все']}"/>
        <label for="container" class="auto">Контейнер:</label>
        <input type="text" id="container" name="container" class="mini nopad" value="${inrequest?.container}"/>
        <label for="trip_id" class="auto">Код:</label>
        <input type="text" id="trip_id" name="trip_id" class="mini nopad" value="${inrequest?.trip_id}"/>
        <label for="zakaz_id" class="auto">Заказ:</label>
        <input type="text" id="zakaz_id" name="zakaz_id" class="mini nopad" value="${inrequest?.zakaz_id}"/>        
        <input type="submit" class="button" id="trip_submit_button" value="Найти" style="margin-left:10px"/>
        <img src="${resource(dir:'images',file:'loader.gif')}" alt="" id="loader" style="display:none" />
      </fieldset>
    </g:formRemote>
    <g:formRemote class="contact-form" name="tripeventForm" url="[action:'eventlist']" update="[success:'resultlist']" onLoading="\$('loader2').show()" onLoaded="\$('loader2').hide()" style="display:none">
      <fieldset>
        <label for="trip_id" class="auto">Код:</label>
        <input type="text" id="trip_id" name="trip_id" class="mini nopad" value="${inrequest?.trip_id}"/>
        <label for="trip_modstatus" class="auto">Статус поездки:</label>
        <g:select name="trip_modstatus" class="auto nopad" value="${inrequest?.trip_modstatus}" from="${tripstatus}" optionKey="id" optionValue="status" noSelection="${['-100':'Все']}"/>
        <label for="eventtype" class="auto">Тип события:</label>
        <g:select name="eventtype" class="auto nopad" optionKey="id" optionValue="name" from="${tripeventtype}" noSelection="${['-100':'все']}" value="${inrequest?.eventtype}"/>
        <input type="submit" class="button" id="tripevent_submit_button" value="Найти" style="margin-left:10px"/>
        <img src="${resource(dir:'images',file:'loader.gif')}" alt="" id="loader2" style="display:none" />
      </fieldset>
    </g:formRemote>
    <div class="clear"></div>
    <div id="my_cars" class="contact-form" style="display:none">
      <fieldset class="fleft">
        <label for="car" class="auto">Машины:</label>
        <g:select name="car" class="auto nopad" optionKey="id" optionValue="gosnomer" from="${cars}" noSelection="${['0':'все']}" onChange="setCar(this.value)"/>
        <span id="car_filtr" style="display:none">
          <label for="date" class="auto">Дата тракера:</label>
          <g:datepicker class="normal nopad" name="date" value="${String.format('%td.%<tm.%<tY',new Date())}" change="1"/>
          <a class="button" href="javascript:void(0)" title="Маршрут" id="tracker_route" onclick="showTrackerRoute()"><i class="icon-road"></i></a>
          <a class="button" href="javascript:void(0)" title="Текущее местоположение" onclick="showTracker()"><i class="icon-location-arrow">&nbsp;</i></a>
        </span>
      </fieldset>
    </div>    
    <div id="resultlist"></div>    
    <div class="clear"></div>
    <div id="mapcontainer" class="box-iframe" style="display:none">
      <div id="map_canvas"></div>
    </div>
  </body>
</html>
