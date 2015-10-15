<html>
  <head>
    <title>Административное приложение</title>
    <meta name="layout" content="admin" />
    <g:javascript>
      var ADDRESS_SEARCH_ZOOM=13, MAX_MAP_ZOOM=10, MAX_MAP_ZOOM_DEF=23,     
          iX=${terminal?.x?:303157900}, iY=${terminal?.y?:599390400},
          map=null,gBounds=null,HMap=[],firstMapResize=0;
      function initialize(iParam){
        HMap=[];
        switch(iParam){
          case 0:
            sectionColor('track');
            $('trackfilter').show();            
            $('trackmapfilter').hide();
            $('track_submit_button').click();            
            break;
          case 1:
            sectionColor('trackmap');
            $('trackfilter').hide();
            $('trackmapfilter').show();
            $("param").value='';
            $('trackmap_submit_button').click();            
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
        $('track').style.color = 'black';        
        $('trackmap').style.color = 'black';
        $(sSection).style.color = '#0080F0';
      }      
      function renderMap(){
        ymaps.ready(function()  {
          map = new ymaps.Map("map_canvas",{center:[iY/10000000,iX/10000000],zoom:ADDRESS_SEARCH_ZOOM,behaviors:["default","scrollZoom"]});
          map.controls.add("smallZoomControl").add("scaleLine")
        
          //map.events.add("boundschange", function(map_e) {
          map.events.add("actionend", function(map_e) {          
            if(firstMapResize)          
              updateMap();
            else
              firstMapResize=1;            
          });                
        });
        gBounds = new ymaps.GeoObjectCollection();
      }
      function clearMap(){
        map.geoObjects.remove(gBounds);
        gBounds.removeAll()
      }
      function addplacemark(lX,lY,sTime,iKurs,iSpeed,iTrackId,SGosNum){
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
          placemark.events.add("click", function(result) {
            location.assign('${context.serverURL}'+'/administrators/trackerdetail/'+iTrackId)
          },placemark);
          gBounds.add(placemark);
        }
      }
      function renderplacemark(bBounds){        
        map.geoObjects.add(gBounds);
        if(bBounds){
          if(gBounds.getLength())
            map.setBounds(gBounds.getBounds(),{checkZoomRange:true});
          else
            map.setCenter([iY/10000000,iX/10000000],ADDRESS_SEARCH_ZOOM, { checkZoomRange: true });
        }  
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
//используется для нормирования Y коодинаты
    var consar=new Array(-85051128,-83979259,-82676284,-81093213,-79171334,-76840816,-74019543,-70612614,-66513260,-61606396,-55776579,-48922499,-40979898,-31952162,-21943045,-11178401,0,11178401,21943045,31952162,40979898,48922499,55776579,61606396,66513260,70612614,74019543,76840816,79171334,81093213,82676284,83979259,85051128);
    //первая часть — само преобразовании координат в деление, название функций и их содержимое взято с викимапии

    function getdatakvname(x, y, curzoomkv){
      var xdel=0;
      var ydel=0;
      var xline=0;
      var yline=0;
      var x1=-180000000;
      var x2=180000000;
      var y1=-85051128;
      var y2=85051128;
      var y1cons=0;
      var y2cons=32;
      var yconsdel=0;
      var n=0;
      var z=curzoomkv-1;
      while(z>=0){
        xdel=Math.round((x1+x2)/2);
        if(n<4){yconsdel=(y1cons+y2cons)/2; ydel=consar[yconsdel];}
        else  {ydel=Math.round((y1+y2)/2);}
        if(x<=xdel){x2=xdel; xline=xline*2;}
        else    {x1=xdel+1; xline=xline*2+1;}
        if(y<=ydel){y2=ydel; y2cons=yconsdel; yline=yline*2;}
        else   {y1=ydel+1; y1cons=yconsdel; yline=yline*2+1;}
        z--;
        n++
      }
      var out=new Array();
      out.xline=xline;
      out.yline=yline;
      return out;
    }

  function cheakpoint(x, y, xline, yline, curzoomkv){
    var xdel=0;
    var ydel=0;
    var x1=-180000000;
    var x2=180000000;
    var y1=-85051128;
    var y2=85051128;
    var y1cons=0;
    var y2cons=32;
    var yconsdel=0;
    var n=0;
    var xlinetest=0;
    var ylinetest=0;
    var test=0;
    var z=curzoomkv-1;
    while(z>=0){
      xdel=Math.round((x1+x2)/2);
      if(n<4){yconsdel=(y1cons+y2cons)/2; ydel=consar[yconsdel]}
      else  {ydel=Math.round((y1+y2)/2)}
      test=Math.pow(2, z);
      xlinetest=xline&test;
      ylinetest=yline&test;
      if(xlinetest>0){x1=xdel+1}
      else      {x2=xdel}
      if(ylinetest>0){y1=ydel+1; y1cons=yconsdel}
      else      {y2=ydel; y2cons=yconsdel}
      z--;
      n++
    }
    var out=new Array();
    if((x>=x1)&&(x<=x2)&&(y>=y1)&&(y<=y2)){out.res=1}
    else{out.res=0}
    return out;
  }
  function retcode(xline, yline, curzoomkv){
    var xparam=0;
    var yparam=0;
    var test=0;
    var xlinetest=0;
    var ylinetest=0;
    var line='';
    var z=curzoomkv-1;
    while(z>=0){
      test=Math.pow(2, z);
      xlinetest=xline&test;
      ylinetest=yline&test;
      if(xlinetest>0){xparam=1}
      else{xparam=0}
      if(ylinetest>0){yparam=2}
      else{yparam=0}
      linepart=xparam+yparam;
      line=line+linepart;
      z--;
    }
   return line;
  }
  
  function request_geo_objectsin(iVar){   
    require_block={}; 
    
    curzoomkv=map.getZoom()-1;
    var bounds=map.getBounds();
    var bounds_sw=bounds[0];
    var bounds_ne=bounds[1];
    var x1point=Math.round(bounds_sw[1]*1000000);
    var y1point=Math.round(bounds_sw[0]*1000000);
    var x2point=Math.round(bounds_ne[1]*1000000);
    var y2point=Math.round(bounds_ne[0]*1000000);     

    if(x1point<-180000000){x1point=-180000000}if(x2point<-180000000){x2point=-180000000}if(x1point>180000000) {x1point=180000000}if(x2point>180000000) {x2point=180000000}if(y1point<-85051128) {y1point=-85051128}if(y2point<-85051128) {y2point=-85051128}if(y1point>85051128) {y1point=85051128}if(y2point>85051128) {y2point=85051128}
  
    outar=[];
    outar=getdatakvname(x1point, y1point, curzoomkv);
    var xline=outar.xline;
    var yline=outar.yline;
    var maks=Math.pow(2, curzoomkv)-1;
    var vlez=0;
    var xsdvig=0;
    var xlinet=xline;
    var ylinet=yline;
    while(vlez!=1){
      outar=cheakpoint(x2point, y1point, xlinet, ylinet, curzoomkv);
      vlez=outar.res;
      xsdvig++;
      xlinet=xlinet+1;
      if(xlinet>maks){xlinet=0}
    }
    vlez=0;
    var ysdvig=0;
    var xlinet=xline;
    var ylinet=yline;
    while(vlez!=1){
      outar=cheakpoint(x1point, y2point, xlinet, ylinet, curzoomkv);
      vlez=outar.res;
      ysdvig++;
      ylinet=ylinet+1;
      if(ylinet>maks){ylinet=0}
    }
    var temp='';
    var newtemp='';
    var ylinesave=yline;
    var ysdvigsave=ysdvig;
    while(xsdvig>0){
      while(ysdvig>0){
        temp=retcode(xline, yline, curzoomkv);
        var lineleng=0;
        
        xml_url=temp;    
        require_block[temp]=xml_url;

        ysdvig--; yline++;
        if(yline>maks){yline=0}
      }
      yline=ylinesave;
      ysdvig=ysdvigsave;
      xsdvig--;
      xline++;
      if(xline>maks){xline=0}      
	}
    var i=0;  
    var flag=0;
    var params='';
    var HMapTmp=new Array();

    for(gotarrn in require_block){  
      HMapTmp.push(gotarrn);
      for(elem in HMap)      
        if(HMap[elem]==gotarrn)
          flag=1;
    }
    if(!flag){
       HMap=HMapTmp;
        $("param").value=HMapTmp;
        $("trackmap_submit_button").click();
       /* 
        var params='offset='+iVar+'&'+'param='+HMapTmp+'&'+getParams(1);
        params=params.replace(/\&amp;/g,'&');        								 								                                 		
        */
      }  
    }
    function updateMap(iVar){      
      if(iVar>0)
        HMap=[]; 
      request_geo_objectsin(iVar);          		  		       
    }    
    </g:javascript>
    <style type="text/css">
      .grid_4 .link{color:#fff;font-size:18px;margin-left:15px;text-decoration:underline}    
      .box-iframe,#map_canvas{width:950px;height:400px}      
    </style>
  </head>
  <body onload="initialize(0)">
    <div class="menu admin">
      <div class="grid_4 p3 fright" align="right">
        <a class="link" href="javascript:void(0)" onclick="initialize(0)" id="track">Список</a>        
        <a class="link" href="javascript:void(0)" onclick="initialize(1)" id="trackmap">Карта</a>
      </div>
      <div class="clear"></div>
      <div id="trackfilter">
        <g:formRemote class="contact-form nopad" name="allForm" url="[action:'trackerlist']" onSuccess="\$('mapcontainer').hide();" update="[success:'trackerlist']">
          <fieldset>
            <label for="imei" class="auto">IMEI:</label>
            <input type="text" name="imei" />
            <label for="trackaccount" class="auto">Учетный номер:</label>
            <input type="text" name="trackaccount" class="mini"/>
            <label for="gosnomer" class="auto">Госномер:</label>
            <input type="text" name="gosnomer" class="mini"/><br/>
            <label for="client_id" class="auto">Код клиента:</label>
            <input type="text" name="client_id" class="mini"/>
            <label for="modstatus" class="auto">Статус:</label>
            <select name="modstatus" class="auto">
              <option value="1">активный</option>
              <option value="0">неактивный</option>
              <option value="2">ремонт</option>
              <option value="-1">списан</option>
              <option value="-2">все</option>
            </select>
            <div class="btns fright">          
              <input type="submit" class="button" id="track_submit_button" value="Показать" />
              <input type="reset" class="button" value="Сброс" />          
              <g:link action="trackerdetail" class="button">Добавить новый</g:link>
            </div>
          </fieldset>          
        </g:formRemote>
      </div>
      <div id="trackmapfilter" style="display:none">
        <g:formRemote class="contact-form nopad" name="allForm" url="[action:'trackermap']" onSuccess="\$('mapcontainer').show();" update="[success:'trackerlist']">      
          <fieldset>
            <label for="imei" class="auto">IMEI:</label>
            <input type="text" name="imei" />
            <label for="trackaccount" class="auto">Учетный номер:</label>
            <input type="text" name="trackaccount" class="mini"/>
            <label for="gosnomer" class="auto">Госномер:</label>
            <input type="text" name="gosnomer" class="mini"/><br/>
            <label for="client_id" class="auto">Код клиента:</label>
            <input type="text" name="client_id" class="mini"/>
            <label for="modstatus" class="auto">Статус:</label>
            <select name="modstatus" class="auto">
              <option value="1">активный</option>
              <option value="0">неактивный</option>
              <option value="2">ремонт</option>
              <option value="-1">списан</option>
              <option value="-2">все</option>
            </select>
            <div class="btns fright">          
              <input type="submit" class="button" id="trackmap_submit_button" value="Показать" />
              <input type="reset" class="button" value="Сброс" />          
              <g:link action="trackerdetail" class="button">Добавить новый</g:link>
            </div>
          </fieldset>
          <input type="hidden" id="param" name="param" value=""/>          
        </g:formRemote>
      </div>
    </div>                
    <div class="clear"></div>
    <div id="trackerlist"></div>
    <div id="mapcontainer" class="box-iframe" style="display:none">
      <div id="map_canvas"></div>
    </div>    
  </body>
</html>
