<html>
  <head>
    <title>${infotext?.title?:''}</title>
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />
    <meta name="layout" content="main" />
    <g:javascript>
      var ADDRESS_SEARCH_ZOOM=10,
          iXA=${trip?.xA?:0}, iYA=${trip?.yA?:0},
          iXB=${trip?.xB?:0}, iYB=${trip?.yB?:0},
          iXC=${trip?.xC?:0}, iYC=${trip?.yC?:0},
          iXD=${trip?.xD?:0}, iYD=${trip?.yD?:0},
          map=null, gBounds=null, placemarkA=null, placemarkB=null, placemarkC=null, placemarkD=null, aPolylinePoints=[], myPolyline=null;
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
          map.controls.add("zoomControl").add("scaleLine");
          if (${trip.distance?1:0}){
            gBounds = new ymaps.GeoObjectCollection();
            for (var i = 4; i > 0 ; i--) {
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
          };
        });
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
        }
      }
      //<<map
    </g:javascript>
    <style type="text/css">
      .ymaps-image-with-content-content .icon-stack{top:-5px;left:-5px}
      .ymaps-image-with-content-content .icon-stack .icon-circle{color:#086ac5}
      .icon-red {color:red;text-shadow:0 2px 2px rgba(0, 0, 0, 0.8);}
      .icon-black{color:#000;text-shadow:0 2px 2px rgba(255, 255, 255, 1);}         
    </style>
  </head>
  <body onload="Yandex()">
              <div class="wrapper">                
                <div class="grid_12">
                  <h2>${infotext?.promotext1?:''}</h2>
                    <div class="box-iframe" style="width:930px;height:650px;margin-top:10px">
                    <div id="map_canvas" style="width:930px;height:650px"></div>
                  </div>
                </div>
              </div>
  </body>
</html>