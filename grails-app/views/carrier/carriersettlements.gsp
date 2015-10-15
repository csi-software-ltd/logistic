<div id="ajax_wrap">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${searchresult.count}</div>
    <div class="fright">
      <g:paginate controller="carrier" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </div>
    <div class="clear"></div>
  </div>  
<g:if test="${searchresult.records}">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr style="line-height:14px">
          <th>Заказ,<br/>дата</th>
          <th>Поездка</th>
          <th>Водитель, тягач</th>
          <th>Маршрут</th>
          <th>Контейнеры</th>
          <th width="70">Дата сдачи документов</th>
          <th>К оплате<br/>(простой)<br/>(переадр.)</th>
          <th>Дата оплаты</th>
          <th width="70">Срок оплаты</th>
          <th>Долг</th>
          <th>Дата оплаты,<br/>сумма (№ пп)</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="line-height:16px;font-size:11px">
          <td>${record.zakaz_id}<br/>${String.format('%td.%<tm.%<ty',record.zakazdate)}</td>
          <td><g:link action="tripdetails" id="${record.id}">${record.id}</g:link></td>
          <td>${record.drivername}<br/>${record.cargosnomer}</td>
          <td>${record.is_longtrip?'дальний':'ближний'}</td>
          <td>${record.cont1}<g:if test="${record.cont2}"><br/>${record.cont2}</g:if></td>
          <td>${record.docdate?String.format('%td.%<tm.%<ty',record.docdate):'документы не сданы'}</td>
          <td>${record.ca_price+(record.cont2?record.ca_price:0)+record.ca_idlesum+record.ca_forwardsum}<br/>(${record.ca_idlesum})<br/>(${record.ca_forwardsum})</td>
          <td>${record.ca_paid?:''}<br/>${record.ca_lastpaydate?String.format('%td-%<tm-%<tY',record.ca_lastpaydate):'-'}</td>
          <td>${record.ca_maxpaydate?String.format('%td-%<tm-%<tY',record.ca_maxpaydate):'документы не сданы'}</td>
          <td>${record.debt>0&&record.ca_maxpaydate?.before(new Date().clearTime())?record.debt:'-'}</td>
          <td><g:each in="${payments[record.id]}" var="payment">${String.format('%td.%<tm.%<ty',payment.paydate)}<br>${payment.summa} (${payment.norder})<br/></g:each></td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
  <div style="padding:10px">
    <span class="fleft">Найдено: ${searchresult.count}</span>
    <span class="fright">
      <g:paginate controller="carrier" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </span>
  </div>
</g:if>
</div>
