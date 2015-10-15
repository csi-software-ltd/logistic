<form class="contact-form padding-bottom3">
  <fieldset>
    <div class="grid_6 alpha">
      <label for="norder">№ счета:</label>
      <input type="text" id="norder" name="norder" value="${payorder.norder?:'не задан'}" />
      <label for="orderdate">Дата счета:</label>
      <input type="text" id="orderdate" name="orderdate" value="${String.format('%td.%<tm.%<tY',payorder.orderdate)}" />
      <label for="summa">Сумма счета:</label>
      <input type="text" id="summa" name="summa" value="${payorder.fullcost+payorder.idlesum+payorder.forwardsum}" />
    </div>
    <div class="grid_6 omega">
      <label for="paid">Сумма оплаты:</label>
      <input type="text" id="paid" name="paid" value="${payorder.paid}" />
      <label for="maxpaydate">Срок оплаты:</label>
      <input type="text" id="maxpaydate" name="maxpaydate" value="${payorder.maxpaydate?String.format('%td.%<tm.%<tY',payorder.maxpaydate):'документы не переданы'}" />
      <label for="debt">Долг:</label>
      <input type="text" id="debt" name="debt" value="${debt>0&&payorder.maxpaydate?.before(new Date().clearTime())?debt:'нет'}" />
    </div>
  </fieldset>
</form>
<div id="ajax_wrap">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr>
          <th>Дата</th>
          <th>№ счета</th>
          <th>Сумма</th>
          <th>Сумма НДС</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${payments}" var="record">
        <tr>
          <td align="center">${String.format('%td.%<tm.%<tY',record.paydate)}</td>
          <td align="center">${record.platnumber}</td>
          <td align="center">${record.summa}</td>
          <td align="center">${record.summands}</td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
</div>
