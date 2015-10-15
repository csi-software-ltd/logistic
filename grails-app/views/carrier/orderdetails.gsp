<html>
  <head>
    <title>${infotext?.title?:''}</title>
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />
    <meta name="layout" content="main" />
    <g:javascript>
      var ADDRESS_SEARCH_ZOOM=10,
          iXA=${zakaz?.xA?:0}, iYA=${zakaz?.yA?:0},
          iXB=${zakaz?.xB?:0}, iYB=${zakaz?.yB?:0},
          iXC=${zakaz?.xC?:0}, iYC=${zakaz?.yC?:0},
          iXD=${zakaz?.xD?:0}, iYD=${zakaz?.yD?:0},
          map=null, gBounds=null, placemarkA=null, placemarkB=null, placemarkC=null, placemarkD=null;
      function confirmzakaz(){
        $('is_confirm').value='1';
        $('proxy_submit_button').click();
      }
      function declinezakaz(){
        $('is_confirm').value='-1';
        $('proxy_submit_button').click();
      }
      function getDriverList(){
        $('zakazDrivers_submit_button').click();
      }
      function processResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['zcol','cprice'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Количество"])}</li>'; $("zcol").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Ставка"])}</li>'; $("cprice").addClassName('red'); break;
              case 3: sErrorMsg+='<li>${message(code:"error.not.actual.message",args:["Заказ"])}</li>'; break;
              case 4: sErrorMsg+='<li>${message(code:"error.denial.message",args:["отказать"])}</li>'; break;
              case 5: sErrorMsg+='<li>${message(code:"error.accept.denial.message")}</li>'; break;
              case 6: sErrorMsg+='<li>${message(code:"error.accept.not.enough.message")}</li>'; break;
              case 7: sErrorMsg+='<li>${message(code:"error.accept.more.enough.message")}</li>'; break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
          jQuery("body:not(:animated)").animate({ scrollTop: 0 }, 1000);
          jQuery("html").animate({ scrollTop: 0 }, 500)        
        } else {
          location.reload(true);
        }
      }
      function changeDriver(lId){
        $('selectedDriver_id').value=lId;
        $('selectedCar_id').value='0';
        $('selectedTrailer_id').value='0';
        $('zakaztodriver_submit_button').click();
      }
      function changeCar(lId){
        $('selectedCar_id').value=lId;
        $('selectedTrailer_id').value='0';
        $('zakaztodriver_submit_button').click();
      }
      function changeTrailer(lId){
        $('selectedTrailer_id').value=lId;
        $('zakaztodriver_submit_button').click();
      }
      function processDriverAddResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['driver_id','car_id','trailer_id'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Водитель"])}</li>'; $("driver_id").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Тягач"])}</li>'; $("car_id").addClassName('red'); break;
              case 3: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Прицеп"])}</li>'; $("trailer_id").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errordriverlist").innerHTML=sErrorMsg;
          $("errordriverlist").up('div').show();
        } else {
          jQuery('#driverAddForm').slideUp(300, function() {getDriverList();});
        }
      }
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
        if (${zakaz.distance?1:0}){
          ymaps.ready(function()  {
            var mY = iYA || 5993904
            var mX = iXA || 3031579
            map = new ymaps.Map("map_canvas",{center:[mY/100000,mX/100000],zoom:ADDRESS_SEARCH_ZOOM,behaviors:["default","scrollZoom"]});
            map.controls.add("smallZoomControl").add("scaleLine");
            gBounds = new ymaps.GeoObjectCollection();
            for (var i = 4; i > 0 ; i--) {
              setplacemark(i);
            };
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
        }
      }
    </g:javascript>
    <style type="text/css">
      .contact-form fieldset.bord{width:98%!important}
      .contact-form input.mini{width:30px!important}
      .data{margin-bottom:10px!important}
      .ymaps-image-with-content-content .icon-stack{top:-5px;left:-5px}
      .ymaps-image-with-content-content .icon-stack .icon-circle{color:#086ac5}
      .contact-form label.leftpad{margin-left:37px;width:123px}
    </style>
  </head>
  <body onload="getDriverList();Yandex();">
    <h1 class="fleft">${infotext?.header?:''} № ${zakaz.id}</h1>
  <g:if test="${zakaz.distance}">
    <a class="link fright button-right2" id="map_hide" href="javascript:void(0)" onclick="hideMap()">Скрыть карту</a>      
    <a class="link fright button-right2" id="map_show" href="javascript:void(0)" onclick="showMap()" style="display:none">Показать карту</a>
  </g:if>
    <a class="link fright" style="margin-right:10px" href="javascript:void(0)" onclick="$('returnToListForm').submit();">К списку заявок</a>
    <div class="clear"></div>    
    <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
    <div class="error-box" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>
    </div>
    <g:formRemote class="contact-form" name="offerForm" url="[action:'saveoffer', id:zakaztocarrier.id?:0]" onSuccess="processResponse(e)">
      <fieldset class="bord">
        <legend>Общие сведения</legend>
        <label for="ztype_id">Тип заявки:</label>
        <g:select class="auto" name="ztype_id" optionKey="id" optionValue="name" from="${ztype}" value="${zakaz.ztype_id?:0}" disabled="true"/>
        <label for="ztype_id" class="auto">Дата заявки:</label>
        <input type="text" class="data" disabled value="${String.format('%tF',zakaz.inputdate)}"/>
        <label for="deadline" class="auto">Актуально:</label>
        <input type="text" style="width:119px" disabled value="${zakaztocarrier.deadline.getTime()-new Date().getTime()>0?String.format('%tT',new Date(zakaztocarrier.deadline.getTime()-new Date().getTime()-60*180*1000)):'время истекло'}"/>
        <label for="modstatus" class="auto">Статус:</label>
        <input type="text" class="data" disabled value="${zakaztocarrier.modstatus==0?'новый':zakaztocarrier.modstatus==1?'акцепт':zakaztocarrier.modstatus==-1?'отказ':'назначен'}"/><br/>
        <label for="container">Тип контейнера:</label>
        <g:select class="auto" name="container" optionKey="id" optionValue="name2" from="${container}" value="${zakaz.container}" disabled="true"/>
        <label for="weight" class="auto">Макс. вес, т:</label>
        <input type="text" class="mini" disabled value="${maxweight}"/>
        <label for="idle" class="auto">Простой, р/день:</label>
        <input type="text" id="idle" name="idle" disabled value="${zakaz.idle}" style="width:45px" />
      <g:if test="${confirmedTrailertypes}">
        <br/><label>Допустимые полуприцепы: &nbsp;<g:join in="${confirmedTrailertypes.collect{it?.name}}"/></label>
      </g:if>
      </fieldset>
      <fieldset class="bord">
        <legend>Изменяемые сведения</legend>
        <label for="zcol" class="auto">Кол-во контейнеров:<br><small>Укажите кол-во контейнеров, которое будете вывозить</small></label>
        <g:select name="zcol" from="${1..zakaz?.zcol}" class="auto ${(zakaztocarrier.modstatus==0 && zakaz.modstatus==1 && (zakaztocarrier.deadline.getTime()-new Date().getTime()>0))?'red':''}" value="${zakaztocarrier.zcol}"/>
        <label for="cprice" class="auto">Ставка:<g:if test="${zakaztocarrier.is_debate}"><br><small>Укажите сумму, по которой будете вывозить</small></g:if></label>
        <input type="text" id="cprice" name="cprice" class="data ${(zakaztocarrier.modstatus==0 && zakaztocarrier.is_debate)?'red':''}" ${!zakaztocarrier.is_debate?'disabled':''} value="${zakaztocarrier.cprice}"/>
      </fieldset>
      <fieldset class="bord">
        <legend>Информация по маршруту</legend>
      <g:if test="${zakaz.distance}">
        <div class="box-iframe" style="width:930px;height:250px">
          <div id="map_canvas" style="width:930px;height:250px"></div>
        </div>
      </g:if>          
      <g:if test="${zakaz.terminal}">
        <label for="terminal" style="width:150px"><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-A icon-light"></i></span> Терминал загрузки:</label>
        <g:select name="terminal" optionKey="id" optionValue="name" from="${terminal}" value="${zakaz.terminal}" disabled="true"/>
      </g:if><g:else>
        <label for="city" style="width:150px"><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-A icon-light"></i></span> Город загрузки:</label>
        <input type="text" disabled value="${zakaz.city_start?:zakaz.region_start}"/>
      </g:else>
        <label for="date_start" style="width:90px">Дата загрузки:</label>
        <input type="text" class="data" disabled value="${String.format('%tF',zakaz.date_start)}"/>
        <span id="slot">
        <g:if test="${timeend<0}">
          <label class="auto" for="timestart">Слоты:</label>
          <g:each in="${timestart.split(',')}">
          <input type="button" class="button time" value="${it}" />
          </g:each><br/>
        </g:if><g:else>
          <label class="auto" for="timestart">Время с:</label>
          <input type="text" class="mini" disabled value="${timestart}"/>
          <label class="auto" for="timeend">до:</label>
          <input type="text" class="mini" disabled value="${timeend}"/><br/>
        </g:else>
        </span>
      <g:if test="${zakaz.prim_start}">
        <label class="leftpad">Примечание:</label>
        <textarea style="width:78%" disabled>${zakaz.prim_start}</textarea><br/>
      </g:if><g:if test="${zakaz.ztype_id==2}">
        <label style="width:150px"><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-B icon-light"></i></span> Город затарки:</label>
        <input type="text" disabled value="${zakaz.city_zat?:zakaz.region_zat}"/>
        <label style="min-width:90px">Дата затарки:</label>
        <input type="text" class="data" disabled value="${String.format('%tF',zakaz.date_zat)}"/>
        <label class="auto">Прибыть к:</label>
        <input type="text" class="mini" disabled value="${zakaz.timestart_zat}"/><br/>
        <g:if test="${zakaz.prim_zat}">
        <label class="leftpad">Примечание:</label>
        <textarea style="width:78%" disabled>${zakaz.prim_zat}</textarea><br/>
        </g:if>
      </g:if><g:if test="${zakaz.ztype_id in [2,3]}">
        <label style="width:150px"><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-${zakaz.ztype_id==2?'C':'B'} icon-light"></i></span> ${zakaz.city_cust?'Город':'Регион'} таможни:</label>
        <input type="text" disabled value="${zakaz.city_cust?:zakaz.region_cust}"/><br/>
        <g:if test="${zakaz.address_cust}">
        <label class="leftpad">Адрес таможни:</label>
        <input type="text" style="width:78%" disabled value="${zakaz.address_cust}"/>
        </g:if><br/><g:if test="${zakaz.prim_cust}">
        <label class="leftpad">Примечание:</label>
        <textarea style="width:78%" disabled>${zakaz.prim_cust}</textarea><br/>
        </g:if>
      </g:if><g:if test="${zakaz.terminal_end}">
        <label for="terminal" style="width:150px"><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-${zakaz.ztype_id==2?'D':zakaz.ztype_id==3?'C':'B'} icon-light"></i></span> Терминал выгрузки:</label>
        <g:select name="terminal" optionKey="id" optionValue="name" from="${terminal}" value="${zakaz.terminal_end}" disabled="true"/><br/>
      </g:if><g:else>
        <label style="width:150px"><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-${zakaz.ztype_id==2?'D':zakaz.ztype_id==3?'C':'B'} icon-light"></i></span> Город выгрузки:</label>
        <input type="text" disabled value="${zakaz.city_end?:zakaz.region_end}"/><br/>
        <g:if test="${zakaz.address_end}">
        <label class="leftpad">Адрес выгрузки:</label>
        <input type="text" style="width:78%" disabled value="${zakaz.address_end}"/>
        </g:if><br/>
      </g:else><g:if test="${zakaz.prim_end}">
        <label class="leftpad">Примечание:</label>
        <textarea style="width:78%" disabled>${zakaz.prim_end}</textarea><br/>
      </g:if><g:if test="${zakaz.ztype_id==3&&zakaz.region_dop}">
        <label style="width:150px"><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-D icon-light"></i></span> Город доп. выгрузки:</label>
        <input type="text" disabled value="${zakaz.city_dop?:zakaz.region_dop}"/><br/>
        <g:if test="${zakaz.address_dop}">
        <label class="leftpad">Адрес доп. выгрузки:</label>
        <input type="text" style="width:78%" disabled value="${zakaz.address_dop}"/>
        </g:if><g:if test="${zakaz.prim_dop}">
        <label class="leftpad">Примечание:</label>
        <textarea style="width:78%" disabled>${zakaz.prim_dop}</textarea><br/>
        </g:if>
      </g:if>
      </fieldset>
    <g:if test="${manager}">
      <fieldset class="bord">
        <legend>Контактные данные менеджера</legend>
        <label for="adm_name" class="auto">Имя:</label>
        <input type="text" id="adm_name" disabled value="${manager.name}"/>
        <label for="adm_tel" class="auto">Телефон:</label>
        <input type="text" id="adm_tel" disabled value="${manager.tel}"/>
      </fieldset>
    </g:if>
      <div class="btns">
        <input type="submit" id="proxy_submit_button" class="button" value="Отправить" style="display:none"/>
        <input type="button" class="button" ${!(zakaztocarrier.modstatus==0&&zakaz.modstatus==1)||(zakaztocarrier.deadline.getTime()-new Date().getTime()<=0)||(client.isblocked)?'disabled':''} value="Принять" onclick="confirmzakaz()"/>
        <input type="button" class="button" ${zakaztocarrier.modstatus==2||zakaztocarrier.modstatus==-1?'disabled':''} value="Отказать" onclick="declinezakaz()"/>
      </div>
      <input type="hidden" id="is_confirm" name="is_confirm" value="1"/>
    </g:formRemote>  
    <div class="tabs">
      <ul class="nav">
        <li class="selected"><a href="javascript:void(0)">Транспорт по заказу</a></li>
      </ul>
      <div class="tab-content">
        <div class="inner">
          <div id="details"></div>
        </div>
      </div>
    </div>  
    <g:formRemote name="zakazDriversForm" url="[action:'driversforzakazlist',id:zakaz.id]" update="[success:'details']" onComplete="\$('adddriverbutton').click();">
      <input type="hidden" name="zakaztocarrier_id" value="${zakaztocarrier.id}" />
      <input type="submit" class="button" id="zakazDrivers_submit_button" value="Показать" style="display:none" />
    </g:formRemote>
    <g:form id="returnToListForm" name="returnToListForm" url="${[action:'orders',params:[fromDetails:1]]}">
    </g:form>
  </body>
</html>
