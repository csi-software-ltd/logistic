<div class="grid_6 alpha">
  <label for="trip_id">Поездка:</label>
  <select id="trip_id" name="trip_id">
    <option value="0">Не задано</option>
  <g:each in="${trips}">
    <option value="${it.id}" <g:if test="${it.id==payment?.trip_id}">selected</g:if>>${it.id} - ${it.driver_fullname}</option>
  </g:each>
  </select>
  <label for="summa">Сумма:</label>
  <input type="text" id="summa" name="summa" value="${payment?.summa}" />
  <label for="paydate">Дата платежа:</label>
  <g:datepicker class="data normal nopad" name="paydate" value="${String.format('%td.%<tm.%<tY',payment?.paydate?payment.paydate:new Date())}" />
</div>
<div class="grid_6 omega">
  <label for="pclass">Тип платежа:</label>
  <g:select name="pclass" value="${payment?.pclass}" keys="${[0,1]}" from="${['Безнал','Нал']}"/>
  <label for="norder">Номер платежа:</label>
  <input type="text" id="norder" name="norder" value="${payment?.norder}" />
  <label>Вычет для наличных:</label>
  <input type="text" disabled value="${cashdeduction}%" />
</div>
<div class="btns">
  <input type="submit" id="submit_button" class="button" value="Сохранить" />
  <input type="reset" class="button" value="Отмена" onclick="jQuery('#capaymentEditForm').slideUp();"/>
</div>
<input type="hidden" name="payment_id" value="${payment?.id?:0}" />