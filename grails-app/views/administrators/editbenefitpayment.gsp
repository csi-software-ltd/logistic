<label for="summa">Сумма:</label>
<input type="text" id="summa" name="summa" value="${paybenefit?.summa}" />
<label for="beneficial">Получатель:</label>
<input type="text" id="beneficial" name="beneficial" value="${paybenefit?.beneficial}" /><br/>
<label for="platcomment">Комментарий:</label>
<input type="text" id="platcomment" name="platcomment" value="${paybenefit?.platcomment}" style="width:656px"/>
<div class="btns padding-bottom3">
  <input type="submit" id="submit_button" class="button" value="Сохранить" />
  <input type="reset" class="button" value="Отмена" onclick="jQuery('#editbenefitpaymentForm').slideUp();"/>
</div>
<input type="hidden" name="paybenefit_id" value="${paybenefit?.id?:0}" />