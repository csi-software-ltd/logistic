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
      function setTerminalSelected(lId){
        jQuery("input[id^='terminal_']").removeClass('button');
        if(lId!=-1){
          $("terminal_"+lId).addClassName('button');
          $("terminal").selectedIndex = 0;
          $("terminal").hide();
          $("terminal_other").show();
        }
        if(lId=='other') lId=-1;
        $("terminalh").value=lId;
      }
      function setSlot(iId){
        <g:remoteFunction action='getslottask' update="[success:'slot']" params="\'id=\'+iId" />
      }
      function setAnother(iId){
        $("taskaddress").value='';
        if(iId==0){
          $("full_taskaddress").show();
        } else {
          $("full_taskaddress").hide();
        }
      }
      function setSlotSelected(iId,el){
        jQuery('#slot').find('.button').removeClass('button');
        $('taskslot').value = iId;
        $(el).addClassName('button');
      }
      function processForwardResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['taskstart','taskend','taskprim','terminal','taskaddress'].forEach(function(ids){
            if($(ids))
              $(ids).removeClassName('red');
          });
          ['dateE'].forEach(function(ids){
            if($(ids))
              $(ids).up('span').removeClassName('red');
          });
          jQuery("#slot input[type='button']").removeClass('red');
          jQuery("#terminal_div input[type='button']").removeClass('red');
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Терминал"])}</li>'; $("terminal").addClassName('red'); jQuery("#terminal_div input[type='button']").addClass('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Адрес"])}</li>'; $("taskaddress").addClassName('red'); break;
              case 3: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Дата сдачи"])}</li>'; $("dateE").up('span').addClassName('red'); break;
              case 4: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Время сдачи"])}</li>'; jQuery("#slot input[type='button']").addClass('red'); break;
              case 5: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Время с"])}</li>'; $("taskstart").addClassName('red'); break;
              case 6: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время с/до"])}</li>'; $("taskstart").addClassName('red'); $("taskend").addClassName('red'); break;
              case 7: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время с"])}</li>'; $("taskstart").addClassName('red'); break;
              case 8: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Время до"])}</li>'; $("taskend").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        } else {
          location.reload(true);
        }
      }
    </g:javascript>
    <style type="text/css">
      .contact-form fieldset.bord{width:98%!important}
      .contact-form label{min-width:84px!important}      
      .k-datepicker,.data{margin-bottom:10px!important}
      .ymaps-image-with-content-content .icon-stack{top:-5px;left:-5px}
      .ymaps-image-with-content-content .icon-stack .icon-circle{color:#086ac5}      
    </style>
  </head>
  <body>
    <h1 class="fleft">${infotext?.header?:''} № ${trip.id}(${trip.zakaz_id}) / ${Taskstatus.get(trip.taskstatus)?.status}</h1>
    <a class="link fright" style="margin-right:10px" href="javascript:void(0)" onclick="$('returnToListForm').submit();">К списку инструкций</a>
    <div class="clear"></div>    
    <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
    <div class="error-box" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>
    </div>
    <g:formRemote class="contact-form" name="forwardDetailForm" url="[action:'saveTripDeliveryDetail', id:trip.id]" method="post" onSuccess="processForwardResponse(e)">
      <fieldset class="bord">
        <legend>Cведения по сдаче контейнер${zakaztodriver.containernumber2?'ов':'а'} ${zakaztodriver.containernumber1}${zakaztodriver.containernumber2?', '+zakaztodriver.containernumber2:''}</legend>
        <label>Номер тягача:</label>
        <input type="text" disabled value="${trip.returncargosnomer}"/>
        <label>Фио водителя:</label>
        <input type="text" style="width:440px" disabled value="${trip.returndriver_fullname}"/>
        <label>Документы водителя:</label>
        <input type="text" disabled value="${driver.docseria+' '+driver.docnumber}"/><br/>
        <hr class="admin">
        <label><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-anchor icon-light"></i></span> Сдача:</label>
        <input type="text" disabled value="<g:if test="${!trip.taskstatus}">Сдача не назначена</g:if><g:else>${trip.taskstatus in [1,3]?'Запрос на сдачу ':trip.taskstatus==4?'Переадресация ':'Сдача '}${String.format('%tF',trip.taskdate)} ${trip.taskstart?' с '+trip.taskstart:''}${trip.taskend?' до '+trip.taskend:''} <g:if test="${trip.taskterminal}">на терминале ${Terminal.get(trip.taskterminal)?.name}</g:if><g:elseif test="${trip.taskaddress}">по адресу ${trip.taskaddress}</g:elseif></g:else>" style="width:70%" /><br/>
        <div id="terminal_div">
          <label for="terminal">Терминал:</label>
          <g:each in="${terminal_main}">
            <input type="button" id="terminal_${it.id}" value="${it.name}" onclick="setTerminalSelected('${it.id}');setSlot('${it.id}');setAnother('${it.id}')" <g:if test="${it.id==trip.taskterminal}">class="button"</g:if>/>
          </g:each>
          <input id="terminal_0" type="button" value="По адресу" onclick="setTerminalSelected('0');setSlot('0');setAnother('0')" <g:if test="${trip.taskaddress}">class="button"</g:if>/>
          <input id="terminal_other" type="button" value="Другой" onclick="setTerminalSelected('other');$('terminal_other').hide();$('terminal').show();$('slot').update('');setAnother(1);" style="${terminal?.is_main||trip?.taskterminal==0?'':'display:none'}"/>
          <input id="terminalh" name="terminalh" type="hidden" value="${trip.taskterminal?:trip.taskaddress?'0':'-1'}"/>
          <g:select class="auto p0" name="terminal" optionKey="id" optionValue="name" from="${terminal_dop}" noSelection="${['-1':'не задано']}" onChange="\$('terminalh').value=this.value;setSlot(this.value);setAnother(this.value)" value="${trip.taskterminal}" style="${(!terminal||terminal?.is_main)?'display:none':''}"/>
        </div>
        <label for="dateE">Дата сдачи:</label>
        <g:datepicker class="normal nopad" name="dateE" value="${String.format('%td.%<tm.%<tY',trip?.taskdate?:new Date())}" />
        <span id="slot">
          <g:if test="${terminal?.is_slot}"><br/>
            <label for="taskslot">Время:</label>
            <g:each in="${slot}" var="item">
              <input type="button" value="${item.name}" onclick="setSlotSelected('${item.id}',this)" class="<g:if test="${trip.taskslot==item?.id.toString()}">button </g:if>time" />
            </g:each>
            <input type="hidden" id="taskslot" name="taskslot" value="${trip?.taskslot?:''}"/>
          </g:if><g:elseif test="${trip?.terminal!=null}">
            <label class="auto" for="taskstart">Время с:</label>
            <input type="text" class="mini" id="taskstart" name="taskstart" value="${trip?.taskstart?:''}"/>
            <label class="auto" for="taskend">до:</label>
            <input type="text" class="mini" id="taskend" name="taskend" value="${trip?.taskend?:''}"/>
          </g:elseif>
        </span><br/>
        <span id="full_taskaddress" <g:if test="${!trip.taskaddress}">style="display:none"</g:if>>
          <label for="taskaddress">Адрес:</label>
          <input type="text" id="taskaddress" name="taskaddress" value="${trip.taskaddress}" />
        </span>
        <label for="stockbooking">Сток-букинг:</label>
        <input type="text" id="stockbooking" name="stockbooking" value="${trip.stockbooking}" />
        <label for="is_mark">Отметка в документах:</label>
        <input type="checkbox" id="is_mark" disabled ${trip.is_mark?'checked':''} value="1" /><br/>
        <span nowrap>
          <label for="taskprim">Подробности:</label>
          <input type="text" id="taskprim" name="taskprim" value="${trip.taskprim}" style="width:812px" />
        </span>
        <div class="btns spacing2">
          <input type="submit" class="button" ${!(trip.taskstatus in 0..4)||!(trip.modstatus in 0..1)?'disabled':''} value="Сохранить"/>
        </div>
        <input type="hidden" name="is_mark" value="${trip.is_mark}"/>
      </fieldset>
    </g:formRemote>
    <g:form id="returnToListForm" name="returnToListForm" url="${[controller:'shipper',action:'requests',params:[fromDetails:1]]}"></g:form>
  </body>
</html>
