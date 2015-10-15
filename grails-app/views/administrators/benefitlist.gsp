<g:formRemote class="contact-form nopad" id="editbenefitpaymentForm" name="editbenefitpaymentForm" url="[action:'savebenefitpayment']" method="post" onSuccess="processEditBenefitPaymentResponse(e)" style="display:none">
  <div class="error-box p2" style="margin-top:0;display:none">
    <span class="icon icon-warning-sign icon-3x"></span>  
    <ul id="errorbenefitpayment">
      <li></li>
    </ul>
  </div>
  <fieldset id="editbenefitpayment"></fieldset>
  <input type="hidden" name="payorder_id" value="${payorder.id}" />
</g:formRemote>
<div id="ajax_wrap">
  <div id="resultList">
    <g:formRemote class="contact-form nopad" name="editbenefitForm" url="[action:'saveorderbenefit',id:payorder.id]" onSuccess="processOrderBenefitResponse(e);">
      <fieldset>
        <label for="benefit">К выплате:</label>
        <input type="text" class="mini" disabled id="benefit" name="benefit" value="${payorder.benefit}" />
        <label class="auto">Оплачено:</label>
        <input type="text" class="mini" disabled value="${paidbenefit}" />
        <label class="auto">Срок:</label>
        <input type="text" class="mini" disabled value="${payorder.maxbenefitdate?String.format('%td.%<tm.%<tY',payorder.maxbenefitdate):'счет не оплачен'}" />
        <label class="auto">Долг:</label>
        <input type="text" class="mini" disabled value="${payorder.benefit-paidbenefit>0&&payorder.maxbenefitdate?.before(new Date().clearTime())?payorder.benefit-paidbenefit:'нет'}" />
      </fieldset>
    </g:formRemote>
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr>
          <th>Дата оплаты</th>
          <th>Сумма оплаты</th>
          <th>Получатель</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${paybenefits}" status="i" var="record">
        <tr>
          <td align="center">${String.format('%td.%<tm.%<tY',record.paydate)}</td>
          <td align="center">${record.summa}</td>
          <td align="center">${record.beneficial}</td>
          <td class="btns" style="text-align:center">
            <a class="button" href="javascript:void(0)" title="Редактировать" onclick="editBenefitPayment(${record.id});"><i class="icon-pencil"></i></a>
            <a class="button" href="javascript:void(0)" title="Удалить" onclick="deletebenefitpayment(${record.id});"><i class="icon-remove"></i></a>
          </td>
        </tr>
      </g:each>
        <tr>
          <td colspan="8" class="btns" style="text-align:center">
            <a class="button" href="javascript:void(0)" onClick="editBenefitPayment(0);">Добавить платеж</a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
<g:formRemote name="benefitpaymentForm" url="[action:'editbenefitpayment',id:payorder.id]" update="[success:'editbenefitpayment']" onComplete="jQuery('#editbenefitpaymentForm').slideDown();" style="display:none">
  <input type="text" id="paybenefit_id" name="paybenefit_id" value=""/>
  <input type="submit" class="button" id="editbenefitpayment_submit_button" value="Показать"/>
</g:formRemote>
