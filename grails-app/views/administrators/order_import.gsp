  <fieldset class="bord">
    <legend><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-A icon-light"></i></span> Забор груза</legend>
    <label for="terminal">Терминал:</label>
    <g:select name="terminal" optionKey="id" optionValue="name" from="${terminal+[id:0,name:'Другой']}" noSelection="${['-1':'не задано']}" onChange="setSlot(this.value);setAnother(this.value)" value="${zakaz?.terminal}"/><br/>
    <label for="date_start">Дата загрузки:</label>
    <g:datepicker class="normal nopad" name="date_start" value="${String.format('%td.%<tm.%<tY',zakaz?.date_start&&!copied?zakaz.date_start:new Date())}" />
    <span id="slot">
    <g:if test="${Terminal.get(zakaz?.terminal?:0)?.is_slot}"><br/>      
      <label for="slot_start">Время:</label>
      <g:each in="${slot}" var="item">
        <input type="button" value="${item.name}" onclick="setSlotList('${item.id}');toggleButton(this)" class="<g:if test="${slotlist.contains(item?.id.toString())}">button </g:if>time" />
      </g:each>
      <input type="hidden" id="slotlist" name="slotlist" value="${zakaz?.slotlist?:''}"/>   
      <input type="hidden" name="is_slotlist" value="1"/>
    </g:if><g:elseif test="${zakaz?.terminal!=null}">
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
      <a class="button fright" href="javascript:void(0)" onclick="geocodeAddress($('region_start').value+' '+$('city_start').value+' '+$('address_start').value,1);"><i class="icon-globe"></i> Геокодировать</a>
    </span>
    <span nowrap>
      <label for="prim_start">Примечание:</label>        
      <input type="text" id="prim_start" name="prim_start" value="${zakaz?.prim_start?:''}" /> 
    </span>
    <input type="hidden" id="xA" name="xA" value="${zakaz?.xA?:0}"/>
    <input type="hidden" id="yA" name="yA" value="${zakaz?.yA?:0}"/>
  </fieldset>
  <fieldset class="bord">
    <legend><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-B icon-light"></i></span> Место выгрузки</legend>
    <label for="region_end">Регион:</label>
    <g:select name="region_end" optionKey="name" optionValue="name" from="${region}" value="${zakaz?.region_end?:0}"/> 
    <label for="city_end">Город:</label>
    <input type="text" id="city_end" name="city_end" value="${zakaz?.city_end?:''}" /><br/>
    <label for="address_end">Адрес:</label>
    <input type="text" id="address_end" name="address_end" value="${zakaz?.address_end?:''}" />
    <label for="prim_end">Примечание:</label>
    <input type="text" id="prim_end" name="prim_end" value="${zakaz?.prim_end?:''}" /><br/>
    <label for="zdate">Дата доставки:</label>
    <g:datepicker class="normal nopad" name="zdate" value="${String.format('%td.%<tm.%<tY',zakaz?.zdate&&!copied?zakaz.zdate:new Date())}"/>
    <label for="noticetel">Оповестить о прибытие а.м. по тел.:</label>
    <input type="text" id="noticetel" name="noticetel" value="${zakaz?.noticetel?:''}" placeholder="например: +79111234567"/>
    <label class="auto" for="noticetime">Время:</label>
    <input type="text" class="mini" id="noticetime" name="noticetime" value="${zakaz?.noticetime>=0?zakaz.noticetime:8}"/>
    <input type="hidden" id="xB" name="xB" value="${zakaz?.xB?:0}"/>
    <input type="hidden" id="yB" name="yB" value="${zakaz?.yB?:0}"/>
  <g:if test="${!(zakaz?.region_dop?:0)}">
    <div class="btns fright">
      <a class="button" href="javascript:void(0)" onclick="geocodeAddress($('region_end').value+' '+$('city_end').value+' '+$('address_end').value,2);"><i class="icon-globe"></i> Геокодировать</a>
      <a class="button" id="add_vigruska_link" href="javascript:void(0)" onclick="showAddVigruzka()" <g:if test="${zakaz?.region_dop?:0}">style="display:none"</g:if>><i class="icon-plus-sign"></i> Дополнительное место выгрузки</a>
      <a class="button" id="hide_vigruska_link" href="javascript:void(0)" onclick="hideAddVigruzka('C')" <g:if test="${!(zakaz?.region_dop?:0)}">style="display:none"</g:if>><i class="icon-minus-sign"></i> Убрать дополнительное место выгрузки</a>
    </div>
  </g:if>
  </fieldset>
  <div id="addVigruzka" <g:if test="${!(zakaz?.region_dop?:0)}">style="display:none"</g:if>>
    <fieldset class="bord">
      <legend><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-C icon-light"></i></span> Место выгрузки</legend>
      <label for="region_dop">Регион:</label>
      <g:select name="region_dop" optionKey="name" optionValue="name" from="${region}" value="${zakaz?.region_dop?:0}"/> 
      <label for="city_dop">Город:</label>
      <input type="text" id="city_dop" name="city_dop" value="${zakaz?.city_dop?:''}" /><br/>
      <label for="address_dop">Адрес:</label>
      <input type="text" id="address_dop" name="address_dop" value="${zakaz?.address_dop?:''}" />
      <label for="prim_dop">Примечание:</label>
      <input type="text" id="prim_dop" name="prim_dop" value="${zakaz?.prim_dop?:''}" />
      <a class="button fright" href="javascript:void(0)" onclick="geocodeAddress($('region_dop').value+' '+$('city_dop').value+' '+$('address_dop').value,3);"><i class="icon-globe"></i> Геокодировать</a>
      <input type="hidden" id="xC" name="xC" value="${zakaz?.xC?:0}"/>
      <input type="hidden" id="yC" name="yC" value="${zakaz?.yC?:0}"/>
    </fieldset>
  </div>
  <fieldset class="bord">
    <legend id="vozvrat"><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-C icon-light"></i></span> Возврат порожнего контейнера</legend>
  </fieldset>
  <script type="text/javascript">
    <g:if test="${zakaz?.terminal!=0}">
      $("region_start").disable();
      if (!placemarkA) {
        iXA=${Terminal.get(zakaz?.terminal)?.x?:0}, iYA=${Terminal.get(zakaz?.terminal)?.y?:0};
        setplacemark(1);
      };
    </g:if>
    <g:if test="${!(zakaz?.region_dop?:0)}">
      $("region_dop").disable();
      $("xC").disable();
      $("yC").disable();
    </g:if>
  </script>
