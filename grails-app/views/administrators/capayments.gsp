<g:formRemote class="contact-form padding-bottom3" id="capaymentEditForm" name="capaymentEditForm" url="[action:'saveCarrierPayment']" method="post" onSuccess="processResponse(e)" style="display:none">
  <div class="error-box p2" style="margin-top:-20px;display:none">
    <span class="icon icon-warning-sign icon-3x"></span>
    <ul id="errorcapayment">
      <li></li>
    </ul>
  </div>
  <fieldset id="paymentdetail"></fieldset>
  <input type="hidden" name="payorder_id" value="${payorder.id}" />
</g:formRemote>
<div id="ajax_wrap">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr>
          <th>Поездка</th>
          <th>Дата оплаты</th>
          <th>Сумма оплаты</th>
          <th>Тип</th>
          <th>№ платежа</th>
          <th>Контейнер</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${payments}" status="i" var="record">
        <tr align="center">
          <td>${record.trip_id}</td>
          <td>${String.format('%td.%<tm.%<tY',record.paydate)}</td>
          <td>${record.summa}</td>
          <td>${record.pclass?'нал':'безнал'}</td>
          <td>${record.norder}</td>
          <td>${record.platcomment}</td>
          <td class="btns" style="text-align:center">
            <a class="button" href="javascript:void(0)" title="Редактировать" onclick="editCaPayment(${record.id});"><i class="icon-pencil"></i></a>
            <a class="button" href="javascript:void(0)" title="Удалить" onclick="deletecapayment(${record.id});"><i class="icon-remove"></i></a>
          </td>
        </tr>
      </g:each>
        <tr>
          <td colspan="8" class="btns" style="text-align:center">
            <a class="button" href="javascript:void(0)" onClick="editCaPayment(0);">Добавить платеж</a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
<g:formRemote name="paymentdetailForm" url="[action:'capaymentdetail']" update="[success:'paymentdetail']" onComplete="jQuery('#capaymentEditForm').slideDown();" style="display:none">
  <input type="text" id="payment_id" name="payment_id" value=""/>
  <input type="hidden" name="order_id" value="${payorder.id}" />
  <input type="submit" class="button" id="paymentdetail_submit_button" value="Показать"/>
</g:formRemote>
