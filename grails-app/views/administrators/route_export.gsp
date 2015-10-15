  <fieldset class="bord">
    <legend><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-A icon-light"></i></span> Забор контейнера</legend>
    <label for="terminal">Терминал:</label>
    <g:select name="terminal" optionKey="id" optionValue="name" from="${terminal+[id:0,name:'Другой']}" noSelection="${['-1':'не задано']}" onChange="setAnother(this.value)" value="${route?.terminal}"/><br/>
    <span id="full_address_start" <g:if test="${route?.terminal!=0}">style="display:none"</g:if>>           
      <label for="region_start">Регион:</label>
      <g:select name="region_start" optionKey="name" optionValue="name" from="${region}" value="${route?.region_start?:0}"/> 
      <label for="city_start">Город:</label>
      <input type="text" id="city_start" name="city_start" value="${route?.city_start?:''}" /><br/>
      <label for="address_start">Адрес:</label>
      <input type="text" id="address_start" name="address_start" value="${route?.address_start?:''}" />
    </span>
  </fieldset>
  <fieldset class="bord">
    <legend><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-B icon-light"></i></span> Адрес затарки</legend>
    <label for="region_zat">Регион:</label>
    <g:select name="region_zat" optionKey="name" optionValue="name" from="${region}" value="${route?.region_zat?:0}"/> 
    <label for="city_zat">Город:</label>
    <input type="text" id="city_zat" name="city_zat" value="${route?.city_zat?:''}" /><br/>
    <label for="address_zat">Адрес:</label>
    <input type="text" id="address_zat" name="address_zat" value="${route?.address_zat?:''}" />
  </fieldset>
  <fieldset class="bord">
    <legend><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-C icon-light"></i></span> Адрес таможни</legend>
    <label for="region_cust">Регион:</label>
    <g:select name="region_cust" optionKey="name" optionValue="name" from="${region}" value="${route?.region_cust?:0}"/> 
    <label for="city_cust">Город:</label>
    <input type="text" id="city_cust" name="city_cust" value="${route?.city_cust?:''}" /><br/>
    <label for="address_cust">Адрес:</label>
    <input type="text" id="address_cust" name="address_cust" value="${route?.address_cust?:''}" />
    <div class="btns">
      <a class="button" id="copy_address_link" href="javascript:void(0)" onclick="copyAddressExport()"><i class="icon-paste"></i> Совпадает с адресом затарки</a>
    </div>
  </fieldset>
  <fieldset class="bord">
    <legend><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-D icon-light"></i></span> Адрес сдачи</legend>
    <label for="terminal_end">Терминал:</label>
    <g:select name="terminal_end" optionKey="id" optionValue="name" from="${terminal+[id:0,name:'Другой']}" noSelection="${['-1':'не задано']}" onChange="setAnotherEnd(this.value)" value="${route?.terminal_end}"/><br/>
    <span id="full_address_end" <g:if test="${route?.terminal_end!=0}">style="display:none"</g:if>>           
      <label for="region_end">Регион:</label>
      <g:select name="region_end" optionKey="name" optionValue="name" from="${region}" value="${route?.region_end?:0}"/> 
      <label for="city_end">Город:</label>
      <input type="text" id="city_end" name="city_end" value="${route?.city_end?:''}" /><br/>
      <label for="address_end">Адрес:</label>
      <input type="text" id="address_end" name="address_end" value="${route?.address_end?:''}" />
    </span>
  </fieldset>
  <script type="text/javascript">
  <g:if test="${route?.terminal!=0}">
    $("region_start").disable();
  </g:if>
  <g:if test="${route?.terminal_end!=0}">
    $("region_end").disable();
  </g:if>
</script>