<g:if test="${syscompany&&requisites&&syscompany?.nds!=requisites?.nds}">
<script type="text/javascript">
  jQuery('.info-box').show();
</script>
</g:if>
<div class="grid_6 alpha">
  <label for="payee">Получатель платежа:</label>
  <input type="text" id="payee" name="payee" value="${requisites?.payee}" />
  <label for="inn">ИНН:</label>
  <input type="text" id="inn" name="inn" value="${requisites?.inn}" />
  <label for="kpp">КПП:</label>
  <input type="text" id="kpp" name="kpp" value="${requisites?.kpp}" />
  <label for="bik">БИК:</label>
  <input type="text" id="bik" name="bik" value="${requisites?.bik}" />
  <div id="bik_autocomplete" class="autocomplete" style="display:none"></div>
  <label for="bankname">Название банка:</label>
  <input type="text" id="bankname" name="bankname" value="${requisites?.bankname}" />
  <label for="address">Адрес:</label>
  <input type="text" id="address" name="address" value="${requisites?.address}" />

  <label for="nagr">Номер договора:</label>
  <input type="text" id="nagr" name="nagr" value="${requisites?.nagr?:''}" /><br/>
  <label for="nagr">Дата договора:</label>
  <g:datepicker class="normal nopad" name="agrdate" value="${requisites?.agrdate?String.format('%td.%<tm.%<tY',requisites?.agrdate):''}" /><br/>
  <label for="syscompany_id">Компания системы:</label>
  <g:select name="syscompany_id" value="${requisites?.syscompany_id}" from="${syscompanies}" noSelection="${['0':'Не задано']}" optionKey="id" optionValue="name"/>   
</div>
<div class="grid_6 omega">
  <label for="ctype_id">Тип компании:</label>
  <g:select name="ctype_id" value="${requisites?.ctype_id}" keys="${1..3}" from="${['ООО', 'ИП', 'ЗАО']}" noSelection="${['0':'Не задано']}"/>
  <label for="nds">НДС, %:</label>
  <g:select name="nds" value="${requisites?.nds}" from="${[0,18]}"/>
  <label for="settlaccount">Расчетный счет:</label>
  <input type="text" id="settlaccount" name="settlaccount" value="${requisites?.settlaccount}" />
  <label for="corraccount">Корр. счет:</label>
  <input type="text" id="corraccount" name="corraccount" value="${requisites?.corraccount}" />
  <label for="ogrn">ОГРН:</label>
  <input type="text" id="ogrn" name="ogrn" value="${requisites?.ogrn}" />
  <label for="license">Лицензия:</label>
  <input type="text" id="license" name="license" value="${requisites?.license}" />
  
  <label for="shortbenefit">Возн. кор. маршрутов:</label>
  <input type="text" id="shortbenefit" name="shortbenefit" value="${requisites?.shortbenefit?:''}" />
  <label for="longbenefit">Возн. длин. маршрутов:</label>
  <input type="text" id="longbenefit" name="longbenefit" value="${requisites?.longbenefit?:''}" />
  <label for="payterm">Срок оплаты в днях:</label>
  <input type="text" id="payterm" name="payterm" value="${requisites?.payterm?:defaultpayterm}" />
</div>
<div class="btns">
  <input type="submit" id="submit_button" class="button" value="Сохранить" />
  <input type="reset" class="button" value="Отмена" onclick="jQuery('#requisitesEditForm').slideUp();"/>
</div>
<input type="hidden" name="requisites_id" value="${requisites?.id?:0}" />
<script type="text/javascript">
  new Autocomplete('bik', { 
        serviceUrl:'${resource(dir:'administrators',file:'bik_autocomplete')}',
        onSelect: function(value, data){
          $('bankname').value = data.split(';')[0];
          $('corraccount').value = data.split(';')[1];
        }
      });
</script>