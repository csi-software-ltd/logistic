﻿  <h3>Информация о пунктах забора и выгрузки</h3>
  <fieldset class="bord">
    <legend>Пункт А - Забор груза</legend>
    <div id="terminal_div">
      <label for="terminal">Терминал:</label>    
      <g:each in="${terminal}">        
        <input type="button" id="terminal_${it.id}" value="${it.name}" onclick="setTerminalSelected('${it.id}');setSlot('${it.id}');setAnother('${it.id}')" <g:if test="${it.id==zakaz?.terminal}">class="button"</g:if>/>      
      </g:each>
      <input id="terminal_0" type="button" value="По адресу" onclick="setTerminalSelected('0');setSlot('0');setAnother('0')" <g:if test="${zakaz?.terminal==0}">class="button"</g:if>/>
      <input id="terminal_other" type="button" value="Другой" onclick="setTerminalSelected('other');$('terminal_other').hide();$('terminal').show();$('slot').update('');setAnother(1);" style="${(zakaz && zakaz.terminal && Terminal.get(zakaz.terminal).is_main)?'':((!zakaz||!zakaz.terminal)?'':'display:none')}"/>
      <input id="terminalh" name="terminalh" type="hidden" value="${(zakaz?.terminal!=null)?zakaz?.terminal:-1}"/>
      <g:select class="auto p0" name="terminal" optionKey="id" optionValue="name" from="${terminal_dop}" noSelection="${['-1':'не задано']}" onChange="setTerminalSelected('-1');setSlot(this.value);setAnother(this.value)" value="${zakaz?.terminal}" style="${(zakaz && zakaz.terminal && Terminal.get(zakaz.terminal).is_main)?'display:none':((!zakaz||!zakaz.terminal)?'display:none':'')}"/>
    </div>    
    <label for="date_start">Дата загрузки:</label>
    <g:datepicker class="normal nopad" name="date_start" value="${String.format('%td.%<tm.%<tY',zakaz?.date_start&&!copied?zakaz.date_start:new Date())}" />
    <span id="slot">
      <g:if test="${Terminal.get(zakaz?.terminal?:0)?.is_slot}"><br/>
        <label for="slot_start">Время:</label>
        <g:each in="${slot}" var="item">
          <input id="slot_start_${item.id}" type="button" value="${item.name}" onclick="setSlotList('${item.id}');toggleButton(this)" class="<g:if test="${slotlist.contains(item?.id.toString())}">button </g:if>time" />
        </g:each>
        <input type="hidden" id="slotlist" name="slotlist" value="${zakaz?.slotlist?:''}"/>   
        <input type="hidden" name="is_slotlist" value="1"/>
      </g:if>
      <g:elseif test="${zakaz?.terminal!=null}">
        <label class="auto" for="slot_start">Время с:</label>
        <input type="text" class="mini" id="slot_start" name="slot_start" value="${zakaz?.timestart?:''}"/>
        <label class="auto" for="slot_end">до:</label>
        <input type="text" class="mini" id="slot_end" name="slot_end" value="${zakaz?.timeend?:''}"/>
      </g:elseif>    
    </span><br/>
    <span id="full_address_start" <g:if test="${zakaz?.terminal!=0}">style="display:none"</g:if>>           
      <label for="region_start">Регион:</label>
      <g:select name="region_start" optionKey="name" optionValue="name" from="${region}" value="${zakaz?.region_start?:0}"/>
      <label for="city_start">Город:</label>
      <input type="text" id="city_start" name="city_start" value="${zakaz?.city_start?:''}" /><br/>
      <label for="address_start">Адрес:</label>
      <input type="text" id="address_start" name="address_start" value="${zakaz?.address_start?:''}" />
    </span>
    <span nowrap>
      <label for="prim_start">Примечание:</label>        
      <input type="text" id="prim_start" name="prim_start" value="${zakaz?.prim_start?:''}" /> 
    </span>
  </fieldset>
  <fieldset class="bord">
    <legend>Пункт B – Место выгрузки</legend>
    <label for="region_end">Регион:</label>
    <g:select name="region_end" optionKey="name" optionValue="name" from="${region}" value="${zakaz?.region_end?:0}"/> 
    <label for="city_end">Город:</label>
    <input type="text" id="city_end" name="city_end" value="${zakaz?.city_end?:''}" /><br/>
    <label for="address_end">Адрес:</label>
    <input type="text" id="address_end" name="address_end" value="${zakaz?.address_end?:''}" />
    <label for="prim_end">Примечание:</label>
    <input type="text" id="prim_end" name="prim_end" value="${zakaz?.prim_end?:''}" /><br/>
    <label for="zdate">Дата выгрузки:</label>
    <g:datepicker class="normal nopad" name="zdate" value="${String.format('%td.%<tm.%<tY',zakaz?.zdate&&!copied?zakaz.zdate:new Date())}"/>
    <label for="noticetel">Оповестить о прибытие а.м. по тел.:</label>
    <input type="text" id="noticetel" name="noticetel" value="${zakaz?.noticetel?:''}" placeholder="например: +79111234567"/>
    <label class="auto" for="noticetime">Время:</label>
    <input type="text" class="mini" id="noticetime" name="noticetime" value="${zakaz?.noticetime>=0?zakaz.noticetime:8}"/>
    <div class="btns">
      <a class="button" id="add_vigruska_link" href="javascript:void(0)" onclick="showAddVigruzka()" <g:if test="${(zakaz?.region_dop?:0)}">style="display:none"</g:if>><i class="icon-plus-sign"></i> Дополнительное место выгрузки</a>
      <a class="button" id="hide_vigruska_link" href="javascript:void(0)" onclick="hideAddVigruzka()" <g:if test="${!(zakaz?.region_dop?:0)}">style="display:none"</g:if>><i class="icon-minus-sign"></i> Убрать дополнительное место выгрузки</a>
    </div>  
  </fieldset>
  <div id="addVigruzka" <g:if test="${!(zakaz?.region_dop?:0)}">style="display:none"</g:if>>
    <fieldset class="bord">
      <legend>Пункт C – Место выгрузки</legend>
      <label for="region_dop">Регион:</label>
      <g:select name="region_dop" optionKey="name" optionValue="name" from="${region}" value="${zakaz?.region_dop?:0}"/> 
      <label for="city_dop">Город:</label>
      <input type="text" id="city_dop" name="city_dop" value="${zakaz?.city_dop?:''}" /><br/>
      <label for="address_dop">Адрес:</label>
      <input type="text" id="address_dop" name="address_dop" value="${zakaz?.address_dop?:''}" />
      <label for="prim_dop">Примечание:</label>
      <input type="text" id="prim_dop" name="prim_dop" value="${zakaz?.prim_dop?:''}" /><br/>   
    </fieldset>
  </div>
  <fieldset class="bord">
    <legend id="vozvrat">Пункт С - Возврат порожнего контейнера</legend>
  </fieldset>
  <script type="text/javascript">
    <g:if test="${zakaz?.terminal!=0}">
      $("region_start").disable();
    </g:if>
    <g:if test="${!(zakaz?.region_dop?:0)}">
      $("region_dop").disable();
    </g:if>
  </script>
