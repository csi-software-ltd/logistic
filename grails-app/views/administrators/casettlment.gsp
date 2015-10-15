<div id="ajax_wrap">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr style="line-height:16px">
          <th>Поездка</th>
          <th>Перевозчик</th>
          <th>Водитель, тягач</th>
          <th>Контейнеры</th>
          <th>К оплате,<br/>ставка<br/>(простой)<br/>(переадресация)<br/>(абон. плата)</th>
          <th>Срок оплаты</th>
          <th>Сумма оплаты,<br/>дата</th>
          <th>Долг</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${caSettlements.records}" var="record">
        <tr>
          <td align="center"><g:link action="tripdetail" id="${record.id}">${record.id}</g:link></td>
          <td align="center"><g:link action="clientdetail" id="${record.carrier}">${record.carrier_name}</g:link></td>
          <td align="center">${record.drivername}<br/>${record.cargosnomer}</td>
          <td align="center">${record.cont1}<g:if test="${record.cont2}"><br/>${record.cont2}</g:if></td>
          <td align="center">${record.ca_price+(record.cont2?record.ca_price:0)+record.ca_idlesum+record.ca_forwardsum-record.ca_trackertax}<br/>${record.ca_price}<br/>(${record.ca_idlesum})<br/>(${record.ca_forwardsum})<br/>(${record.ca_trackertax})</td>
          <td align="center">${record.ca_maxpaydate?String.format('%td.%<tm.%<tY',record.ca_maxpaydate):'документы не сданы'}</td>
          <td align="center">${record.ca_paid?:''}<br/>${record.ca_lastpaydate?String.format('%td.%<tm.%<tY',record.ca_lastpaydate):'-'}</td>
          <td align="center">${record.debt>0&&record.ca_maxpaydate?.before(new Date().clearTime())?record.debt:'нет'}</td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
</div>
