<div id="ajax_wrap">
<g:if test="${report?.records}">
  <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0" style="font-size:8pt">
    <thead>
      <tr>
        <th>Дата отпр.</th>
        <th>Отправитель</th>
        <th>Маршрут</th>
        <th>Ставка<br/>отпр.</th>
        <th>Ставка<br/>пер.<br/>/ возн.</th>
        <th>Доход</th>
        <th>Номер контейнера</th>
        <th>Дата сдачи<br/>документов</th>
        <th>ФИО водителя</th>
        <th>Госномер</th>
        <th>Перевозчик</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>ИТОГО</td>
        <td colspan="2"></td>
        <td>${priceshsum}</td>
        <td>${pricesum}</td>
        <td>${priceshsum-pricesum-benefitsum}</td>
        <td>${contcol}</td>
        <td colspan="4"></td>
      </tr>
  <g:each in="${report.records}" var="record">
  <g:if test="${!manager_id||manager_id==orders[record.id]?.manager_id?:0}">
      <tr>
        <td>${String.format('%td/%<tm/%<tY',record.dateA)}</td>
        <td>${record.shippername}</td>
        <td>${record.addressA}<g:if test="${record.addressB}"><br/>${record.addressB}</g:if><g:if test="${record.addressC}"><br/>${record.addressC}</g:if><g:if test="${record.addressD}"><br/>${record.addressD}</g:if></td>
        <td>${record.price_sh}</td>
        <td>${record.price} / ${orders[record.id]?.benefit}</td>
        <td>${record.price_sh-record.price-orders[record.id]?.benefit}</td>
        <td>${record.containernumber1}</td>
        <td>${record.taskstatus>5?String.format('%td/%<tm/%<tY',record.docdate):'не сданы'}</td>
        <td>${record.driver_fullname}</td>
        <td>${record.cargosnomer}</td>
        <td>${record.carriername}</td>
      </tr>
    <g:if test="${record.containernumber2}">
      <tr>
        <td>${String.format('%td/%<tm/%<tY',record.dateA)}</td>
        <td>${record.shippername}</td>
        <td>${record.addressA}<g:if test="${record.addressB}"><br/>${record.addressB}</g:if><g:if test="${record.addressC}"><br/>${record.addressC}</g:if><g:if test="${record.addressD}"><br/>${record.addressD}</g:if></td>
        <td>${record.price_sh}</td>
        <td>${record.price} / ${orders[record.id]?.benefit}</td>
        <td>${record.price_sh-record.price-orders[record.id]?.benefit}</td>
        <td>${record.containernumber2}</td>
        <td>${record.taskstatus>5?String.format('%td/%<tm/%<tY',record.docdate):'не сданы'}</td>
        <td>${record.driver_fullname}</td>
        <td>${record.cargosnomer}</td>
        <td>${record.carriername}</td>
      </tr>
    </g:if>
  </g:if>
  </g:each>
    </tbody>
  </table>
</g:if><g:else>
  <h1>Нет данных за указанный период</h1>
</g:else>
</div>