<html>
  <head>
    <title>${infotext?.title?:''}</title>
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />
    <meta name="layout" content="main" />
    <g:javascript>
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
        switch(iParam){
          case 1:
            sectionSelected('ordersaccept');
            document.getElementsByTagName('h1')[0].innerText = "${infotext?.header?:''}";
            $('ordermodstatus').value = 1;
            $('orders_submit_button').click();
            break;
          case 2:
            sectionSelected('ordersassigned');
            document.getElementsByTagName('h1')[0].innerText = "${infotext?.header?:''}";
            $('ordermodstatus').value = 2;
            $('orders_submit_button').click();
            break;
          case -1:
            sectionSelected('orderscancell');
            document.getElementsByTagName('h1')[0].innerText = "${infotext?.header?:''}";
            $('ordermodstatus').value = -1;
            $('orders_submit_button').click();
            break;
          case -2:
            sectionSelected('ordersarchive');
            document.getElementsByTagName('h1')[0].innerText = "${infotext?.header?:''}";
            $('ordermodstatus').value = -2;
            $('orders_submit_button').click();
            break;
          case 0:
            sectionSelected('ordersnew');
            document.getElementsByTagName('h1')[0].innerText = "${infotext?.header?:''}";
            $('ordermodstatus').value = 0;
            $('orders_submit_button').click();
            break;
          case -101:
            sectionSelected('freecars');
            document.getElementsByTagName('h1')[0].innerText = "Свободные машины";
            $('freecarslist_submit_button').click();
            break;
          default:
            sectionSelected('ordersall');
            document.getElementsByTagName('h1')[0].innerText = "${infotext?.header?:''}";
            $('ordermodstatus').value = -100;
            $('orders_submit_button').click();
            break;
        }
      }
      function sectionSelected(sSection){
        ['ordersaccept','ordersassigned','orderscancell','ordersarchive','ordersall','ordersnew','freecars'].forEach(function(ids){
          $(ids).up('li').removeClassName('selected');
        });
        $(sSection).up('li').addClassName('selected');
      }
      function changeDriver(lId){
        $('selectedDriver_id').value=lId;
        $('selectedCar_id').value='0';
        $('selectedTrailer_id').value='0';
        $('freecar_submit_button').click();
      }
      function changeCar(lId){
        $('selectedCar_id').value=lId;
        $('selectedTrailer_id').value='0';
        $('freecar_submit_button').click();
      }
      function changeTrailer(lId){
        $('selectedTrailer_id').value=lId;
        $('freecar_submit_button').click();
      }
      function processFreecarAddResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['driver_id','car_id','trailer_id','timeend','timestart'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Водитель"])}</li>'; $("driver_id").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Тягач"])}</li>'; $("car_id").addClassName('red'); break;
              case 3: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Прицеп"])}</li>'; $("trailer_id").addClassName('red'); break;
              case 4: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Стандартные маршруты"])}</li>'; break;
              case 5: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время с"])}</li>'; $("timestart").addClassName('red'); break;
              case 6: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время до"])}</li>'; $("timeend").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorfreecarlist").innerHTML=sErrorMsg;
          $("errorfreecarlist").up('div').show();
        } else {
          jQuery('#freecarAddForm').slideUp(300, function() {$('freecarslist_submit_button').click();});
        }
      }
    </g:javascript>
  </head>
  <body onload="initialize(${inrequest?.modstatus})">
    <h1>${infotext?.header?:''}</h1>
    <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
    <g:formRemote class="contact-form" name="ordersForm" url="[action:'orderlist']" update="[success:'orderlist']">
      <fieldset>
        <input type="hidden" id="ordermodstatus" name="modstatus" value="0">
        <input type="submit" class="button" id="orders_submit_button" value="Найти" style="margin-left:10px;display:none"/>
      </fieldset>
    </g:formRemote>
    <g:formRemote class="contact-form" style="display:none" name="freecarsForm" url="[action:'freecarlist']" update="[success:'orderlist']">
      <fieldset>
        <input type="submit" class="button" id="freecarslist_submit_button" value="Найти" style="margin-left:10px;display:none"/>
      </fieldset>
    </g:formRemote>
    <div id="orderlist">
    </div>
  </body>
</html>
