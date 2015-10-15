<script type="text/javascript">
  <g:if test="${current}">   
      iY=${tracker_route[0]?.y?:599390400};
      iX=${tracker_route[0]?.x?:303157900}
    
      placemark = new ymaps.Placemark([iY/10000000,iX/10000000],{
        <g:if test="${tracker_route[0]}">
          hintContent:'время: '+"${String.format('%tF %<tT', tracker_route[0]?.tracktime)}"+'<br/>курс на '+getKursString(${tracker_route[0].kurs})+'<br/>скорость: '+${tracker_route[0].speed}+' км/ч'
        </g:if>  
       },{
          draggable: false,
          hasBalloon: false,
          iconImageHref:"${resource(dir:'images',file:'marker.png')}",
          iconImageSize: [19,37],
          iconImageOffset:[-14,-35],
          iconContentOffset:[-1,10]         
        });
        map.geoObjects.add(placemark);
        map.setCenter([iY/10000000,iX/10000000],ADDRESS_SEARCH_ZOOM, { checkZoomRange: true });
  </g:if>      
  <g:else>
    aTracker_route=[];
    <g:each in="${tracker_route}">
      var tmp={y:${it.y},x:${it.x},kurs:${it.kurs},tracktime:"${String.format('%tF %<tT', it?.tracktime)}",speed:${it.speed}};
      aTracker_route.push(tmp);
    </g:each>
    if(aTracker_route.length)
      proccessTrackerRoute();
    else{    
      bTrackerPlace=true;
      showTracker(1);
      $("resultlist").update('');
    }      
  </g:else>
</script>
