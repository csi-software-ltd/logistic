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
      var is_vartrailer=0;          
      function init(){
      <g:if test="${(zakaz?.container?:0) && (zakaz?.zcol?:0)}">
        is_vartrailer=${Container.get(zakaz?.container?:0)?.is_vartrailer?:0};        
      </g:if>
      <g:else>
        <g:if test="${(container?:[]).size()>0}">
          is_vartrailer=${container[0]?.is_vartrailer?:0};
        </g:if>                    
      </g:else>
        loadWeightForm($("zcol").value);
        //changeTrailerType($("container").value);                    
        //setTrailerType();      
      <g:if test="${order_id?:0}">
        loadForm(${Zakaz.get(order_id)?.ztype_id});          
      </g:if>
      }      
      function loadForm(iNumber){      
        <g:each in="${ztype}">               
          $("ztype_id_${it.id}").removeClassName('button'); 
          $("ztype_id_${it.id}").removeClassName('red');          
        </g:each>          
        $("ztype_id_"+iNumber).addClassName('button');                     
        
        clearMessages();        
        var lId=${order_id?:0};
        
        $("ztype_id").value=iNumber;
        switch (iNumber) {
          case 1:           
            <g:remoteFunction action='order_import' params="\'id=\'+lId+'&copied=${copy?1:0}'" update="form_div" onLoading="showLoader()" onLoaded="hideLoader()"/>           
            break;
          case 2:         
            <g:remoteFunction action='order_export' params="\'id=\'+lId+'&copied=${copy?1:0}'" update="form_div" onLoading="showLoader()" onLoaded="hideLoader()"/>
            break;
          case 3: 
            <g:remoteFunction action='order_transit' params="\'id=\'+lId+'&copied=${copy?1:0}'" update="form_div" onLoading="showLoader()" onLoaded="hideLoader()"/>          
            break;          
          default: break;
        }           
      }      
      function showLoader(){
        $("loader").show();
      } 
      function hideLoader(){
        $("loader").hide();
      }    
      function loadWeightForm(iNumber){
        ['weight2','weight3','weight4','weight5','addzcol'].forEach(function(ids){
          $(ids).hide();
        });
        ['zcol_1','zcol_2','zcol_3','zcol_4','zcol_5','zcol_6'].forEach(function(ids){
          $(ids).removeClassName('button');
        });        
        $("zcol").value=iNumber;
        switch (iNumber) {          
          case '1': $("zcol_1").addClassName('button');
                    ['weight2','weight3','weight4','weight5'].forEach(function(ids){
                      $(ids).value=''; 
                    });break;
          case '2': $("zcol_2").addClassName('button');
                    $('weight2').show(); 
                    ['weight3','weight4','weight5'].forEach(function(ids){
                      $(ids).value=''; 
                    });break;
          case '3': $("zcol_3").addClassName('button');
                    $('weight2').show();$('weight3').show();
                    ['weight4','weight5'].forEach(function(ids){
                      $(ids).value=''; 
                    }); break;
          case '4': $("zcol_4").addClassName('button');
                    $('weight2').show();$('weight3').show();$('weight4').show(); 
                    $('weight5').value=''; break;
          case '5': $("zcol_5").addClassName('button');
                    $('weight2').show();$('weight3').show();$('weight4').show();$('weight5').show(); break;
          default:  $("zcol_6").addClassName('button'); $('addzcol').show(); break;
        }
        setTrailerType();  
      }
      function setSlot(iId){
        <g:remoteFunction action='getslot' update="[success:'slot']" params="\'id=\'+iId" />
      }                   
      function commonResponse(e,sErrorMsg){             
        ['slot_start','slot_end','price','terminal','weight1','weight2','weight3','weight4','weight5','idle','container','noticetel','noticetime','addzcol'].forEach(function(ids){
          if($(ids))
            $(ids).removeClassName('red');
        });        
        jQuery("#slot input[type='button']").removeClass('red');
        jQuery("#terminal_div input[type='button']").removeClass('red');
        jQuery("#container_div input[type='button']").removeClass('red');
        jQuery("#slot .time").removeClass('red');
        e.responseJSON.container_error.forEach(function(err){
          switch (err) {
            case 1: sErrorMsg+='<li>Не выбран контейнер</li>';
                    $("container").addClassName('red');
                    jQuery("#container_div input[type='button']").addClass('red');
                    break;            
          }
        });        
        e.responseJSON.price_error.forEach(function(err){
          switch (err) {
            case 1: sErrorMsg+='<li>${message(code:"error.invalid.range.message",args:["Ставка в рублях","0","1000000"])}</li>';
                    $("price").addClassName('red');
                    break;
            case 2: sErrorMsg+='<li>${message(code:"error.invalid.range.message",args:["Простой в рублях","0","1000000"])}</li>';
                    $("idle").addClassName('red');
                    break;
          }
        });
        var iWeightError=0;
        e.responseJSON.weight_error.forEach(function(err){
          switch (err) {
            case 1: iWeightError++;
                    $("weight1").addClassName('red');                 
                    break;
            case 2: iWeightError++;
                    $("weight2").addClassName('red');
                    break;
            case 3: iWeightError++;
                    $("weight3").addClassName('red');
                    break;
            case 4: iWeightError++;
                    $("weight4").addClassName('red');
                    break;
            case 5: iWeightError++;
                    $("weight5").addClassName('red');
                    break;
            case 6: sErrorMsg+='<li>Некорректное кол-во контейнеров</li>';
                    $("addzcol").addClassName('red');
                    break;
          }
        });
        if(iWeightError)
          sErrorMsg+='<li>Вес в тоннах, ограничения, больше 0 и меньше 50</li>';            
       
       e.responseJSON.error.forEach(function(err){
          switch (err) {
            case 1: sErrorMsg+='<li>Не выбран терминал пункта А</li>';                  
                    $("terminal").addClassName('red');             
                    jQuery("#terminal_div input[type='button']").addClass('red');
                    break; 
            case 100: sErrorMsg+='<li>Ошибка сохранения в БД</li>';                                                 
                    break;          
          }
        });        
        $("date_start").up('span').removeClassName('red');
        e.responseJSON.date_error.forEach(function(err){
          switch (err) {
            case 1: sErrorMsg+='<li>Ошибка преобразования даты</li>';                  
                    break;                         
            case 2: sErrorMsg+='<li>Дата загрузки должна быть актуальна</li>';
                    $("date_start").up('span').addClassName('red');            
                    break;        
          }
        });      
        e.responseJSON.time_error.forEach(function(err){
          switch (err) {
            case 1: sErrorMsg+='<li>Время загрузки должно быть актуально</li>';
                    e.responseJSON.time_error_slot_ids.forEach(function(id){
                      if($("slot_start_"+id))
                        $("slot_start_"+id).addClassName('red');
                    });                    
                    break;                         
            case 2: sErrorMsg+='<li>Время загрузки должно быть актуально</li>';
                    if($("slot_start"))
                      $("slot_start").addClassName('red');            
                    break;        
          }
        });         
        e.responseJSON.slot_error.forEach(function(err){
          switch (err) {
            case 1: sErrorMsg+='<li>Некорректный диапазон времени пункта А</li>';
                    if($("slot_start"))
                      $("slot_start").addClassName('red');
                    if($("slot_end"))   
                      $("slot_end").addClassName('red');
                    break;
            case 2: sErrorMsg+='<li>Начало диапазона времени пункта А - целое число 0-23</li>';
                    if($("slot_start"))
                      $("slot_start").addClassName('red');
                    break;
            case 3: sErrorMsg+='<li>Конец диапазона времени пункта А - целое число 0-23</li>';
                    if($("slot_end"))
                      $("slot_end").addClassName('red');
                    break;
            case 4: sErrorMsg+='<li>Не выбрано время пункта А</li>';
                    jQuery("#slot input[type='button']").addClass('red');
                    break;        
          }
        });
        e.responseJSON.notice_error.forEach(function(err){
          switch (err) {
            case 1: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Телефон для оповещения"])}</li>';
                    $("noticetel").addClassName('red');
                    break;
            case 2: sErrorMsg+='<li>Время оповещения - целое число 0-23</li>';
                    $("noticetime").addClassName('red');
                    break;
          }
        });
        return sErrorMsg;
      }
      function processSaveZakazResponse(e){        
        if(e.responseJSON.error_ztype_id==1){
          clearMessages();           
          var sErrorMsg='<li>Выберите тип заявки</li>';       
          <g:each in="${ztype}">               
            $("ztype_id_${it.id}").addClassName('red');         
          </g:each>
          if(sErrorMsg.length){
            $("errorlist").innerHTML=sErrorMsg;
            $("errorlist").up('div').show();
            jQuery("body:not(:animated)").animate({ scrollTop: 0 }, 1000);
            jQuery("html").animate({ scrollTop: 0 }, 500)            
          }
        }else{                
          switch (e.responseJSON.ztype_id) {
            case 1: processSaveZakazImportResponse(e);
                    break;
            case 2: processSaveZakazExportResponse(e)
                    break;
            case 3: processSaveZakazTransitResponse(e)
                    break;                 
          }     
        }
        $('submitbutton').disabled=false;
      }
      function processSaveZakazImportResponse(e){             
        clearMessages();           
        var sErrorMsg=commonResponse(e,'');
        
        $("zdate").up('span').removeClassName('red');        

        e.responseJSON.date_error.forEach(function(err){
          switch (err) {            
            case 3: sErrorMsg+='<li>Дата выгрузки должна быть актуальна</li>';
                    $("zdate").up('span').addClassName('red');            
                    break;
            case 6: sErrorMsg+='<li>Дата выгрузки не может быть меньше даты загрузки</li>';
                    $("zdate").up('span').addClassName('red');  
                    $("date_start").up('span').addClassName('red');                    
                    break;        
          }
        });        
        
        if(sErrorMsg.length){
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
          jQuery("body:not(:animated)").animate({ scrollTop: 0 }, 1000);
          jQuery("html").animate({ scrollTop: 0 }, 500)            
        }else{          
          $('backToOrderButton').click()
        /*        
          $("infolist").update("<li>Заявка подана</li>");
          $("infolist").up('div').show();  
        */  
        }  
      }
      function processSaveZakazExportResponse(e){
        ['slot_start_end','slot_end_end','terminal_end','timestart_zat'].forEach(function(ids){
          if($(ids))
            $(ids).removeClassName('red');
        });      
        jQuery("#terminal_end_div input[type='button']").removeClass('red');
        clearMessages();        
        var sErrorMsg=commonResponse(e,'');        
         e.responseJSON.error.forEach(function(err){
          switch (err) {
            case 2: sErrorMsg+='<li>Не выбран терминал пункта D</li>';                  
                    $("terminal_end").addClassName('red');             
                    jQuery("#terminal_end_div input[type='button']").addClass('red');
                    break;          
          }
        });
        
        $("date_zat").up('span').removeClassName('red');
        
        e.responseJSON.date_error.forEach(function(err){
          switch (err) {            
            case 4: sErrorMsg+='<li>Дата затарки должна быть актуальна</li>';
                    $("date_zat").up('span').addClassName('red');            
                    break;
            case 6: sErrorMsg+='<li>Дата затарки не может быть меньше даты загрузки</li>';
                    $("date_zat").up('span').addClassName('red');  
                    $("date_start").up('span').addClassName('red');                    
                    break;                     
          }
        });        
        e.responseJSON.timezat_error.forEach(function(err){
          switch (err) {            
            case 1: sErrorMsg+='<li>Время прибытия к затарке - целое число 0-23</li>';
                    if($("timestart_zat"))
                      $("timestart_zat").addClassName('red');
                    break;             
          }
        });
        e.responseJSON.slot_error.forEach(function(err){
          switch (err) {
            case 11: sErrorMsg+='<li>Некорректный диапазон времени сдачи контейнера</li>';
                    if($("slot_start_end"))
                      $("slot_start_end").up('span').addClassName('red');
                    if($("slot_end_end"))   
                      $("slot_end_end").up('span').addClassName('red');
                    break;
            case 12: sErrorMsg+='<li>Начало диапазона времени сдачи контейнера - целое число 0-23</li>';
                    if($("slot_start_end"))
                      $("slot_start_end").addClassName('red');
                    break;
            case 13: sErrorMsg+='<li>Конец диапазона времени сдачи контейнера - целое число 0-23</li>';
                    if($("slot_end_end"))
                      $("slot_end_end").addClassName('red');
                    break;
            case 14: sErrorMsg+='<li>Ошибка справочника времени сдачи контейнера</li>';
                    if($("slot_start_end"))
                      $("slot_start_end").addClassName('red');
                    if($("slot_end_end"))
                      $("slot_end_end").addClassName('red');
                    break;        
          }
        });  
        if(sErrorMsg.length){
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
          jQuery("body:not(:animated)").animate({ scrollTop: 0 }, 1000);
          jQuery("html").animate({ scrollTop: 0 }, 500)            
        }else{                    
          $('backToOrderButton').click()
          /*
            $("infolist").update("<li>Заявка подана</li>");
            $("infolist").up('div').show();            
          */
        }  
      }    
      function processSaveZakazTransitResponse(e){              
        clearMessages();
        var sErrorMsg=commonResponse(e,'');
        
        $("date_cust").up('span').removeClassName('red');        
        
        e.responseJSON.date_error.forEach(function(err){
          switch (err) {            
            case 5: sErrorMsg+='<li>Дата таможни должна быть актуальна</li>';
                    $("date_cust").up('span').addClassName('red');            
                    break;
            case 6: sErrorMsg+='<li>Дата таможни не может быть меньше даты загрузки</li>';
                    $("date_cust").up('span').addClassName('red');  
                    $("date_start").up('span').addClassName('red');                    
                    break;                    
          }
        });                
               
        if(sErrorMsg.length){
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
          jQuery("body:not(:animated)").animate({ scrollTop: 0 }, 1000);
          jQuery("html").animate({ scrollTop: 0 }, 500)            
        }else{        
          $('backToOrderButton').click()
        /*
          $("infolist").update("<li>Заявка подана</li>");
          $("infolist").up('div').show();  
        */  
        } 
      }
      function setAnother(iId){
        $("region_start").disable();
        $("city_start").value='';
        $("address_start").value='';
        
        if(iId==0){
          $("region_start").enable();
          $("full_address_start").show();          
        }else{
          $("full_address_start").hide();                   
        }
      }
      function showAddDop(){       
        jQuery('#addDop').slideDown();        
        $("add_dop_link").hide();
        $("hide_dop_link").show();
      }
      function hideAddDop(){        
        jQuery('#addDop').slideUp();         
        $("add_dop_link").show();
        $("hide_dop_link").hide();          
      }
      function showAddVigruzka(){
        $("region_dop").enable();
        jQuery('#addVigruzka').slideDown();
        if($("vozvrat"))        
          $("vozvrat").update("Пункт D - Возврат порожнего контейнера");      
        $("add_vigruska_link").hide();
        $("hide_vigruska_link").show();
      }
      function hideAddVigruzka(){
        $("region_dop").disable();
        $("region_dop").selectedIndex=0;
        jQuery('#addVigruzka').slideUp();
        if($("vozvrat"))        
          $("vozvrat").update("Пункт C - Возврат порожнего контейнера");      
        $("add_vigruska_link").show();
        $("hide_vigruska_link").hide();
        jQuery('#addVigruzka input[value]').each(function (i){      
          jQuery(this).val('');                 
        });    
      }
      function clearMessages(){
        $("errorlist").innerHTML='';
        $("errorlist").up('div').hide(); 
        $("infolist").update("");
        $("infolist").up('div').hide(); 
      }
      function changeTrailerType(iId,bSelect){       
        <g:each in="${container}">       
          if(iId==${it?.id?:0}){
            is_vartrailer=${it?.is_vartrailer?:0};
          }else{
            $("container_${it.id}").removeClassName('button');          
          }  
        </g:each>        
        <g:each in="${container_dop}">       
          if(iId==${it?.id?:0})
            is_vartrailer=${it?.is_vartrailer?:0};          
        </g:each>
        if(iId==-1)        
          is_vartrailer=0;          
        $("container_other").removeClassName('button');
        if(bSelect==undefined){
          $("container_"+iId).addClassName('button');
          $("container").selectedIndex=0;
          $("container").hide();
          $("container_other").show();          
        }        
        if(iId=='other'){                   
          is_vartrailer=0;          
          iId=-1;
        }        
        if(bSelect){
          iId=-1;
        }        
        $("containerh").value=iId;                        
        setTrailerType();      
      }
      function setTrailerType(){
        if(is_vartrailer){
          $("trailertype_div").show();          
          <g:if test="${!zakaz}">
            <g:each in="${trailertype}" var="item" status="i">
              <g:if test="${item.active}">
                $("trailertype${i}").checked=true; 
              </g:if>
              <g:else>
                $("trailertype${i}").checked=false;
              </g:else>
            </g:each>
          </g:if>
        }else{
          $("trailertype_div").hide();
          <g:each in="${trailertype}" var="item" status="i">            
            $("trailertype${i}").checked=false;
          </g:each>          
        }
      }           
  /* export>>*/
      function copyAddressExport(){  
        $("region_cust").selectedIndex=$("region_zat").selectedIndex;
        $("city_cust").value=$("city_zat").value;
        $("address_cust").value=$("address_zat").value;     
      } 
      function setAnotherEnd(iId){
        $("region_end").disable();
        $("city_end").value='';
        $("address_end").value='';
        
        if(iId==0){
          $("region_end").enable();
          $("full_address_end").show();
        }else{
          $("full_address_end").hide();
        }
      }
      function setSlotEnd(iId){
        <g:remoteFunction action='getslot' update="[success:'slot_end_span']" params="'id='+iId+'&end=1'" />
      }      
  /* export<<*/
      function syncSlotEnd(){
        $("slot_end").selectedIndex=$("slot_start").selectedIndex;
      }
      function syncSlotEnd1(){
        $("slot_end_end").selectedIndex=$("slot_start_end").selectedIndex;
      }   
      function remZakaz(lId){
        if (confirm('Вы уверены в операции удаления заявки?'))
          <g:remoteFunction action='remZakaz'  params="\'id=\'+lId" onLoading="showLoader()" onLoaded="hideLoader()" onSuccess="backToList()"/>
      } 
      function backToList(){
        $('backToOrderButton').click()
      }
      function setTerminalSelected(lId,sName){      
        if(sName=='end'){
          <g:each in="${terminal}">               
            $("terminal_end_${it.id}").removeClassName('button');
            $("terminal_end_${it.id}").removeClassName('red');            
          </g:each>
          $("terminal_end_0").removeClassName('button');
          $("terminal_end_other").removeClassName('button');
          $("terminal_end_0").removeClassName('red');
          $("terminal_end_other").removeClassName('red');
          if(lId!=-1){
            $("terminal_end_"+lId).addClassName('button');
            $("terminal_end").selectedIndex=0;
            $("terminal_end").hide();
            $("terminal_end_other").show();
          } 
          if(lId=='other')          
            lId=-1;
          $("terminalh_end").value=lId;
        }else{
          <g:each in="${terminal}">               
            $("terminal_${it.id}").removeClassName('button'); 
            $("terminal_${it.id}").removeClassName('red');            
          </g:each>
          $("terminal_0").removeClassName('button');
          $("terminal_other").removeClassName('button');
          $("terminal_0").removeClassName('red');
          $("terminal_other").removeClassName('red');
          if(lId!=-1){
            $("terminal_"+lId).addClassName('button');
            $("terminal").selectedIndex=0;
            $("terminal").hide();
            $("terminal_other").show();
          }  
          if(lId=='other')          
            lId=-1;
          $("terminalh").value=lId;        
        }
      }
      function setSlotList(lId){      
        var tmp=[];
        if($("slotlist").value.length)
          tmp=$("slotlist").value.split(',');                 
          
        var bFlag=0;
        var i=0;
        tmp.forEach(function(it){ 
          if(it==lId){
            tmp.splice(i,1);
            bFlag=1;
          }  
          i++;
        });
        if(!bFlag)
          tmp.push(lId);     
          
        $("slotlist").value=tmp.toString();
        $("slot_start_"+lId).removeClassName("red");
      }
      function toggleButton(t){
        if(jQuery(t).hasClass('button'))
          $(t).removeClassName('button');
        else  
          $(t).addClassName('button');
      }
      function updateDate(){
        var date = $('date_start').value.split('.');
        var nextdate = new Date(new Date(date[2],date[1]-1,date[0]).getTime()+(24 * 60 * 60 * 1000));
        var datepicker = null;
        if($("zdate")) datepicker = jQuery("#zdate").data("kendoDatePicker");
        else if ($("date_cust")) datepicker = jQuery("#date_cust").data("kendoDatePicker");
        else if ($("date_zat")) datepicker = jQuery("#date_zat").data("kendoDatePicker");
        if(datepicker) datepicker.value(nextdate);
      }
    </g:javascript>
    <style type="text/css">      
      .contact-form fieldset.bord{width:98%!important}
      .contact-form label{min-width:100px}     
      .contact-form input[type="text"]{width:244px!important}      
      .contact-form input.mini{width:30px!important}      
      .contact-form select{width:262px!important}
      .contact-form select.auto{width:auto!important}
      .k-datepicker,.data{margin-bottom:10px!important} 
      .k-picker-wrap.red {border-color: #FF0000 !important;}  
      input[type="button"].red{background:none red; color #fff !important}      
    </style>
  </head>
  <body onload="init()">    
    <h1 class="fleft">${infotext?.header?:''} <g:if test="${(order_id?:0) && !copy}"> № ${order_id +' ('+Zakazstatus.get(zakaz?.modstatus)?.modstatus+')'}</g:if></h1>    
    <a class="fright" style="margin-right:10px" href="javascript:void(0)" onclick="$('backToOrderButton').click()">вернуться к списку заявок</a>    
    <div class="clear"></div>
    <g:formRemote class="contact-form" name="importForm" url="[action:'saveZakaz']" onSuccess="processSaveZakazResponse(e)" before="\$('submitbutton').disabled=true;">
      <input type="hidden" id="ztype_id" name="ztype_id" value="${zakaz?.ztype_id?:0}"/>
      <div class="fleft">
        <label class="auto" for="ztype_id">Тип заявки:</label>
      <g:each in="${ztype}">
        <input type="button" id="ztype_id_${it?.id?:0}" value="${it?.name?:''}" onclick="loadForm(${it?.id?:0})" <g:if test="${(zakaz?.ztype_id?:0)==(it?.id?:-1)}">class="button"</g:if> /><!--<g:if test="${zakaz && ((zakaz?.ztype_id?:0)!=(it?.id?:-1))}">disabled="true"</g:if>-->
      </g:each>
      <img src="${resource(dir:'images',file:'loader.gif')}" alt="" id="loader" style="display:none" />
      </div>
    <g:if test="${order_id?:0}">    
      <div class="grid_7 fright" align="right">
        <label for="inputdate" class="auto" disabled>Дата подачи:</label>
        <input type="text" readonly value="${String.format('%td.%<tm.%<tY %<tH:%<tM',zakaz?.inputdate?:new Date())}" style="width:105px!important"/>
        <label for="last" class="auto" disabled>Время действия:</label>
        <input type="text" readonly value="${actualTime>0&&!copy?Tools.getDayString(actualTime):'истекло'}" style="width:105px!important"/>
      </div>
    </g:if>      
      <div class="clear"></div>
      <div class="error-box" style="display:none">
        <span class="icon icon-warning-sign icon-3x"></span>
        <ul id="errorlist">
          <li></li>
        </ul>        
      </div>
      <div class="info-box" style="display:none">
        <span class="icon icon-info-sign icon-3x"></span>
        <ul id="infolist">
          <li></li>        
        </ul>
      </div>          
     
      <fieldset class="bord"> 
        <legend>Общие сведения</legend>
        <div id="container_div">
          <label for="container">Тип контейнера:</label>
          <g:each in="${container}" var="item" status="i">        
            <input id="container_${item.id}" type="button" value="${item.name2}" onclick="changeTrailerType('${item.id}')" <g:if test="${(item.id==zakaz?.container)||((zakaz?.container==null)&&(i==0))}">class="button"</g:if>/>      
          </g:each>
          <input id="container_other" type="button" value="Другой" onclick="changeTrailerType('other');$('container_other').hide();$('container').show();" style="${(zakaz && zakaz.container && Container.get(zakaz.container).is_main)?'':((!zakaz||!zakaz.container)?'':'display:none')}"/>
          <input id="containerh" name="containerh" type="hidden" value="${zakaz?.container?:(container.size()?container[0].id:(container_dop.size()?container_dop[0].id:-1))}"/>
          <g:select class="auto p0" name="container" optionKey="id" optionValue="name2" from="${container_dop}" noSelection="${['-1':'не задано']}" onChange="changeTrailerType(this.value,true)" value="${zakaz?.container}" style="${(zakaz && zakaz.container && Container.get(zakaz.container).is_main)?'display:none':((!zakaz||!zakaz.container)?'display:none':'')}"/> 
        </div>
        <label for="zcol_id">Количество:</label>
        <input id="zcol_1" type="button" value="1" onclick="loadWeightForm('1')" />
        <input id="zcol_2" type="button" value="2" onclick="loadWeightForm('2')" />
        <input id="zcol_3" type="button" value="3" onclick="loadWeightForm('3')" />
        <input id="zcol_4" type="button" value="4" onclick="loadWeightForm('4')" />
        <input id="zcol_5" type="button" value="5" onclick="loadWeightForm('5')" />
        <input id="zcol_6" type="button" value="5+" onclick="loadWeightForm('5+')" />
        <input type="hidden" id="zcol" name="zcol" value="${zakaz?.zcol<6?zakaz?.zcol:'5+'}"/>
        <input type="text" class="mini" size="2" id="addzcol" name="addzcol" value="${zakaz?.zcol}" style="display:none"/>
        <label for="weight1_id" class="auto">Вес в тоннах:</label>
        <input type="text" class="mini" size="2" id="weight1" name="weight1" value="${zakaz?.weight1?:''}" maxlength="2"/> 
        <input type="text" class="mini" size="2" id="weight2" name="weight2" value="${zakaz?.weight2?:''}" style="display:none" maxlength="5"/>
        <input type="text" class="mini" size="2" id="weight3" name="weight3" value="${zakaz?.weight3?:''}" style="display:none" maxlength="5"/>
        <input type="text" class="mini" size="2" id="weight4" name="weight4" value="${zakaz?.weight4?:''}" style="display:none" maxlength="5"/>
        <input type="text" class="mini" size="2" id="weight5" name="weight5" value="${zakaz?.weight5?:''}" style="display:none" maxlength="5"/>
        <br/>
        <label for="price">Ставка:</label>
        <input type="text" class="data" id="price" name="price" value="${zakaz?.price?:''}" />        
        <label for="ztime_id" class="auto">Заявка действует:</label>
        <g:select class="auto" name="ztime_id" optionKey="id" optionValue="name" from="${ztime}" value="${zakaz?.ztime_id}"/>
        <label for="doc" class="auto">Документы:</label>
        <input type="text" id="doc" name="doc" value="${zakaz?.doc?:''}" /> 
        <fieldset class="nobord fleft" id="trailertype_div">
        <legend>Допустимые полуприцепы:</legend>   
        <g:each in="${trailertype}" var="item" status="i">        
          <input type="checkbox" id="trailertype${i}" name="trailertype_id" value="${item.id}" <g:if test="${(trailertype_id?:[]).contains(item.id.toString())}">checked</g:if>/> 
          <label class="nopadd mini" for="trailertype${i}">${item?.name}</label>
        </g:each>          
        </fieldset>
        <div class="btns box5-top">
          <a class="button" id="add_dop_link" href="javascript:void(0)" onclick="showAddDop()"><i class="icon-plus-sign"></i> Дополнительная информация</a>
          <a class="button" id="hide_dop_link" href="javascript:void(0)" onclick="hideAddDop()" style="display:none"><i class="icon-minus-sign"></i> Скрыть дополнительную информацию</a>
        </div>
      </fieldset>
      <div id="addDop" style="display:none">
        <fieldset class="bord">
          <legend>Дополнительная информация</legend>       
          <label for="dangerclass">Класс опасности:</label>
          <g:select name="dangerclass" optionKey="id" optionValue="name" from="${dangerclass}" noSelection="${['0':'0']}" value="${zakaz?.dangerclass?:0}"/>        
          <label for="is_roof">
            <input type="checkbox" id="is_roof" name="is_roof" value="1" <g:if test="${zakaz?.is_roof?:0}">checked</g:if>/>
            Навес GenSet
          </label>
          <div class="grid_3 fright" style="margin-right:125px">
            <label for="idle" class="auto">Простой, р/день:</label>
            <input type="text" id="idle" name="idle" value="${(zakaz==null)?'3000':zakaz?.idle}" style="width:60px!important"/>
          </div>
          <label for="comment">Примечание:</label>
          <input type="text" id="comment" name="comment" value="${zakaz?.comment?:''}" />
        </fieldset>  
      </div>
      <div id="form_div"></div>
      <div class="btns">
        <g:if test="${(order_id && edit) || (order_id && copy) || !order_id}">
          <input type="submit" class="button" id="submitbutton" <g:if test="${order_id && edit}">value="Сохранить"</g:if><g:elseif test="${order_id && copy}">value="Копировать"</g:elseif><g:elseif test="${!order_id}">value="Отправить"</g:elseif> />
        </g:if>
        <g:if test="${order_id && edit}">
          <input type="button" class="button" value="Снять" onclick="remZakaz(${zakaz?.id?:0})" />
        </g:if>
        <input type="button" class="button" value="Отмена" onclick="$('backToOrderButton').click()" />            
      </div>  
      <input type="hidden" name="copy" value="${copy?:0}"/>
      <input type="hidden" name="order_id" value="${order_id?:0}"/>                 
    </g:formRemote>
    <g:form url="[action:'orders']" method="post" name="backToOrders">
      <input type="submit" style="display:none" id="backToOrderButton"/>
      <input type="hidden" name="fromEdit" value="1"/>        
    </g:form>    
  </body>
</html> 
