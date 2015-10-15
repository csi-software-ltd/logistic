  <fieldset class="bord">
    <legend><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-A icon-light"></i></span> Забор контейнера</legend>
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
    <legend><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-B icon-light"></i></span> Адрес затарки</legend>
    <label for="region_zat">Регион:</label>
    <g:select name="region_zat" optionKey="name" optionValue="name" from="${region}" value="${zakaz?.region_zat?:0}"/> 
    <label for="city_zat">Город:</label>
    <input type="text" id="city_zat" name="city_zat" value="${zakaz?.city_zat?:''}" /><br/>
    <label for="address_zat">Адрес:</label>
    <input type="text" id="address_zat" name="address_zat" value="${zakaz?.address_zat?:''}" />
    <label for="date_zat">Дата затарки:</label>
    <g:datepicker class="normal nopad" name="date_zat" value="${String.format('%td.%<tm.%<tY',zakaz?.date_zat&&!copied?zakaz.date_zat:new Date())}" />
    <label class="auto" for="timestart_zat">Прибыть к:</label>
    <input type="text" class="mini" id="timestart_zat" name="timestart_zat" value="${zakaz?.timestart_zat?:''}"/><br/>
    <label for="prim_zat">Примечание:</label>
    <input type="text" id="prim_zat" name="prim_zat" value="${zakaz?.prim_zat?:''}" />
    <a class="button fright" href="javascript:void(0)" onclick="geocodeAddress($('region_zat').value+' '+$('city_zat').value+' '+$('address_zat').value,2);"><i class="icon-globe"></i> Геокодировать</a>
    <input type="hidden" id="xB" name="xB" value="${zakaz?.xB?:0}"/>
    <input type="hidden" id="yB" name="yB" value="${zakaz?.yB?:0}"/>
  </fieldset>
  <fieldset class="bord">
    <legend><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-C icon-light"></i></span> Адрес таможни</legend>
    <label for="region_cust">Регион:</label>
    <g:select name="region_cust" optionKey="name" optionValue="name" from="${region}" value="${zakaz?.region_cust?:0}"/> 
    <label for="city_cust">Город:</label>
    <input type="text" id="city_cust" name="city_cust" value="${zakaz?.city_cust?:''}" /><br/>
    <label for="address_cust">Адрес:</label>
    <input type="text" id="address_cust" name="address_cust" value="${zakaz?.address_cust?:''}" />
    <label for="prim_cust">Примечание:</label>
    <input type="text" id="prim_cust" name="prim_cust" value="${zakaz?.prim_cust?:''}" />
    <a class="button fright" href="javascript:void(0)" onclick="geocodeAddress($('region_cust').value+' '+$('city_cust').value+' '+$('address_cust').value,3);"><i class="icon-globe"></i> Геокодировать</a>
    <input type="hidden" id="xC" name="xC" value="${zakaz?.xC?:0}"/>
    <input type="hidden" id="yC" name="yC" value="${zakaz?.yC?:0}"/>
    <div class="btns">
      <a class="button" id="copy_address_link" href="javascript:void(0)" onclick="copyAddressExport()"><i class="icon-paste"></i> Совпадает с адресом затарки</a>
    </div>
  </fieldset>
  <fieldset class="bord">
    <legend><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-D icon-light"></i></span> Адрес сдачи</legend>
    <label for="terminal_end">Терминал:</label>
    <g:select name="terminal_end" optionKey="id" optionValue="name" from="${terminal+[id:0,name:'Другой']}" noSelection="${['-1':'не задано']}" onChange="setAnotherEnd(this.value)" value="${zakaz?.terminal_end}"/><br/>
    <span id="full_address_end" <g:if test="${zakaz?.terminal_end!=0}">style="display:none"</g:if>>           
      <label for="region_end">Регион:</label>
      <g:select name="region_end" optionKey="name" optionValue="name" from="${region}" value="${zakaz?.region_end?:0}"/> 
      <label for="city_end">Город:</label>
      <input type="text" id="city_end" name="city_end" value="${zakaz?.city_end?:''}" /><br/>
      <label for="address_end">Адрес:</label>
      <input type="text" id="address_end" name="address_end" value="${zakaz?.address_end?:''}" />
      <a class="button fright" href="javascript:void(0)" onclick="geocodeAddress($('region_end').value+' '+$('city_end').value+' '+$('address_end').value,4);"><i class="icon-globe"></i> Геокодировать</a>
    </span>
    <span nowrap>
      <label for="prim_end">Примечание:</label>        
      <input type="text" id="prim_end" name="prim_end" value="${zakaz?.prim_end?:''}" /> 
    </span>
    <input type="hidden" id="xD" name="xD" value="${zakaz?.xD?:0}"/>
    <input type="hidden" id="yD" name="yD" value="${zakaz?.yD?:0}"/>
  </fieldset>
  <script type="text/javascript">
  <g:if test="${zakaz?.terminal!=0}">
    $("region_start").disable();
    if (!placemarkA) {
      iXA=${Terminal.get(zakaz?.terminal)?.x?:0}, iYA=${Terminal.get(zakaz?.terminal)?.y?:0};
      setplacemark(1);
    };
  </g:if>
  <g:if test="${zakaz?.terminal_end!=0}">
    $("region_end").disable();
  </g:if>
</script>
