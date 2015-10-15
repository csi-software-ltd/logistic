  <fieldset class="bord">
    <legend><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-A icon-light"></i></span> Забор груза</legend>
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
    <legend><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-B icon-light"></i></span> Место выгрузки</legend>
    <label for="region_end">Регион:</label>
    <g:select name="region_end" optionKey="name" optionValue="name" from="${region}" value="${route?.region_end?:0}"/> 
    <label for="city_end">Город:</label>
    <input type="text" id="city_end" name="city_end" value="${route?.city_end?:''}" /><br/>
    <label for="address_end">Адрес:</label>
    <input type="text" id="address_end" name="address_end" value="${route?.address_end?:''}" />
  </fieldset>
  <fieldset class="bord">
    <legend id="vozvrat"><span class="icon-stack"><i class="icon-circle icon-stack-base"></i><i class="icon-C icon-light"></i></span> Возврат порожнего контейнера</legend>
  </fieldset>
  <script type="text/javascript">
    <g:if test="${route?.terminal!=0}">
      $("region_start").disable();
    </g:if>
  </script>
