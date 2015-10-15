<html>
  <head>
    <title>${infotext?.title?:''}</title>    
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />
    <meta name="layout" content="main" />
    <g:javascript>
      function setSlotSelected(iDriver,iId){
        jQuery('#slots_'+iDriver).find('.button').removeClass('button');
        $('timestart_'+iDriver).value=iId;
        $('slot_'+iDriver+'_'+iId).addClassName('button');
      }
      function processResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          jQuery('.red').removeClass('red');
          e.responseJSON.errorcode.forEach(function(err){
            sErrorMsg='<li>${message(code:"error.incorrect.message",args:["Время"])}</li>';
            $("timestart_"+err).addClassName('red');
            $("timeend_"+err).addClassName('red');
          });
          e.responseJSON.errorslotcode.forEach(function(err){
            sErrorMsg='<li>${message(code:"error.blank.message",args:["Время"])}</li>';
            jQuery(".slots"+err+" > label").addClass('red');
          });
          if(e.responseJSON.errorcontcode.size()) sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["№ контейнера"])}</li>';
          e.responseJSON.errorcontcode.forEach(function(err){
            $(err).addClassName('red');
            $(err).addClassName('red');
          });
          if (e.responseJSON.notEnoughContainersError) sErrorMsg+='<li>${message(code:"error.not.enough.message",args:["контейнеров"])}</li>';
          else if (e.responseJSON.moreEnoughContainersError) sErrorMsg+='<li>${message(code:"error.more.enough.message",args:["контейнеров"])}</li>';
          if (e.responseJSON.bdError) sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>';
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        } else {
          location.assign('${createLink(action:'monitoring')}');
        }
      }
    </g:javascript>
    <style type="text/css">
      .contact-form fieldset.bord{width:98%!important}
      .contact-form input.mini{width:30px!important}
      .contact-form select.auto{width:auto!important}
    </style>
  </head>
  <body>
    <h1>${infotext?.header?:''}</h1>
    <div class="info-box" style="${!infotext?.itext?'display:none':''}">
      <span class="icon icon-info-sign icon-3x"></span>
      <ul id="infolist">
        <li><g:rawHtml>${infotext?.itext?:''}</g:rawHtml></li>
      </ul>
    </div>
    <div class="error-box" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>
    </div>
    <g:formRemote class="contact-form" name="offerDetailForm" url="[action:'confirmoffer',id:zakaz.id]" method="post" onSuccess="processResponse(e)" before="\$('submit_button').disabled=true" after="\$('submit_button').disabled=false">
    <g:each in="${zakazDrivers}">
      <fieldset class="bord">
        <legend>Тягач: <b>${it.gosnomer}</b>, Прицеп: <b>${it.trailnumber}</b>, Водитель: <b>${it.fullname}</b></legend>
        <label for="weight" class="auto">№ контейнера</label>
        <input type="text" id="cont1_${it.id}" name="cont1_${it.id}" style="width:190px;text-transform:uppercase" value=""/>
      <g:if test="${it.zcol==2}">
        <label for="weight" class="auto">№ контейнера2:</label>
        <input type="text" id="cont2_${it.id}" name="cont2_${it.id}" style="width:190px;text-transform:uppercase" value=""/>
      </g:if>
      <g:if test="${zakaz.slotlist}">
        <div id="slots_${it.id}" style="width:250px;float:right">
        <g:each in="${slot}" var="item">
          <input type="button" class="time" id="slot_${it.id}_${item.id}" value="${item.name}" onclick="setSlotSelected(${it.id},${item.id})" />
        </g:each>
          <input type="hidden" id="timestart_${it.id}" name="timestart_${it.id}" value=""/>
        </div>
      </g:if><g:else>
        <label class="auto" for="timestart_${it.id}">Время с:</label>
        <input type="text" id="timestart_${it.id}" name="timestart_${it.id}" class="mini" value="${zakaz.timestart}"/>
        <label class="auto" for="timeend_${it.id}">до:</label>
        <input type="text" id="timeend_${it.id}" name="timeend_${it.id}" class="mini" value="${zakaz.timeend}"/>
      </g:else>
      </fieldset>
    </g:each>
      <div class="clear"></div>
    <g:if test="${zakaz.modstatus==2}">
      <div class="btns">
        <input type="submit" id="submit_button" class="button" value="Подтвердить" />
        <g:link action="offers" class="button">Отмена</g:link>
      </div>
    </g:if>
    </g:formRemote>
  </body>
</html>