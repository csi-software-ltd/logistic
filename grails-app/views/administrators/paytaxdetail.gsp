<div class="grid_6 alpha smallselect">
  <label for="paydate">Дата:</label>
  <g:datePicker name="paydate" precision="month" value="${paytax?.paydate?:new Date()}" relativeYears="[113-new Date().getYear()..0]"/>
</div>
<div class="grid_6 omega">
  <label for="summa">Сумма:</label>
  <input type="text" id="summa" name="summa" value="${paytax?.summa?:defaultsumma}" />
</div>
<div class="btns">
  <input type="submit" id="submit_button" class="button" value="Сохранить" />
  <input type="reset" class="button" value="Отмена" onclick="jQuery('#paytaxEditForm').slideUp();"/>
</div>
<input type="hidden" name="paytax_id" value="${paytax?.id?:0}" />