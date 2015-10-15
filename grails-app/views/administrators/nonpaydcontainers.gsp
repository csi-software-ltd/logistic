<div id="ajax_wrap">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr>        
          <th>Перевозчик</th>
          <th>Контейнер</th>
          <th>Сумма к оплате<br/>с учетом простоя и абонентки</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult}" status="i" var="record">
      <g:if test="${!record.contpaid1}">
        <tr align="center" style="vertical-align:middle">
          <td>${record.carrier_name}</td>
          <td>${record.cont1}</td>
          <td>${record.ca_price+record.ca_idlesum+record.ca_forwardsum-record.ca_trackertax+record.ca_paid<=(record.ca_price+(record.cont2?record.ca_price:0)+record.ca_idlesum+record.ca_forwardsum-record.ca_trackertax)?record.ca_price+record.ca_idlesum+record.ca_forwardsum-record.ca_trackertax:(record.ca_price+(record.cont2?record.ca_price:0)+record.ca_idlesum+record.ca_forwardsum-record.ca_trackertax-record.ca_paid)}</td>
          <td nowrap>
            <a class="button" title="Оплатить налом" href="javascript:void(0)" onclick="contpay('${record.id}','1','0','${record.order_id}')"><i class="icon-money"></i></a>
            <a class="button" title="Оплатить безналом" href="javascript:void(0)" onclick="contpay('${record.id}','0','0','${record.order_id}')"><i class="icon-shield"></i></a>
          </td>
        </tr>
      </g:if>
      <g:if test="${record.cont2&&!record.contpaid2}">
        <tr align="center" style="vertical-align:middle">
          <td>${record.carrier_name}</td>
          <td>${record.cont2}</td>
          <td>${record.ca_price+record.ca_paid<=(record.ca_price+(record.cont2?record.ca_price:0)+record.ca_idlesum+record.ca_forwardsum-record.ca_trackertax)?record.ca_price:(record.ca_price+(record.cont2?record.ca_price:0)+record.ca_idlesum+record.ca_forwardsum-record.ca_trackertax-record.ca_paid)}</td>
          <td nowrap>
            <a class="button" title="Оплатить налом" href="javascript:void(0)" onclick="contpay('${record.id}','1','1','${record.order_id}')"><i class="icon-money"></i></a>
            <a class="button" title="Оплатить безналом" href="javascript:void(0)" onclick="contpay('${record.id}','0','1','${record.order_id}')"><i class="icon-shield"></i></a>
          </td>
        </tr>
      </g:if>
      </g:each>
      </tbody>
    </table>
  </div>
</div>