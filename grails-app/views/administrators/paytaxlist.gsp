<g:formRemote class="contact-form padding-bottom3" id="paytaxEditForm" name="paytaxEditForm" url="[action:'savepaytax']" method="post" onSuccess="processPaytaxResponse(e)" style="display:none">
  <div class="error-box p2" style="margin-top:-20px;display:none">
    <span class="icon icon-warning-sign icon-3x"></span>
    <ul id="errorpaytax">
      <li></li>
    </ul>
  </div>
  <fieldset id="paytaxdetail"></fieldset>
  <input type="hidden" name="client_id" value="${client?.id}" />
</g:formRemote>
<div id="ajax_wrap">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr>
          <th>Дата</th>
          <th>Сумма</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${paytaxlist}" status="i" var="record">
        <tr>
          <td align="center">${String.format('%tm.%<tY',record.paydate)}</td>
          <td align="center">${record.summa}</td>
        </tr>
      </g:each>
        <tr>
          <td colspan="8" class="btns" style="text-align:center">
            <a class="button" href="javascript:void(0)" onClick="editPaytax(0);">Добавить платеж</a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
<g:formRemote name="paytaxdetailForm" url="[action:'paytaxdetail']" update="[success:'paytaxdetail']" onComplete="jQuery('#paytaxEditForm').slideDown();" style="display:none">
  <input type="text" id="paytax_id" name="paytax_id" value=""/>
  <input type="submit" class="button" id="paytaxdetail_submit_button" value="Показать"/>
</g:formRemote>