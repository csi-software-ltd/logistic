<div id="ajax_wrap">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${searchresult.count}</div>
    <div class="fright">
      <g:paginate controller="administrators" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </div>
    <div class="clear"></div>
  </div>  
<g:if test="${searchresult.records}">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr style="line-height:16px">
          <th rowspan="2">Клиент</th>
          <th rowspan="2">Сумма заказа,<br/>простой,<br/>переадресация</th>
          <th rowspan="2">Счет,<br>дата</th>
          <th rowspan="2">Оплачено,<br>дата</th>
          <th rowspan="2">Срок оплаты</th>
          <th rowspan="2">Долг</th>
          <th rowspan="2">Возн.</th>
          <th colspan="3">За перевозку</th>
          <th rowspan="2">Менеджер</th>
          <th rowspan="2">Прибыль</th>
          <th rowspan="2">Дейст вия</th>
        </tr>
        <tr>
          <th>к&nbsp;оплате</th>
          <th>оплачено</th>
          <th>долг</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="line-height:16px;font-size:11px">
          <td><g:link action="clientdetail" id="${record.client_id}">${record.clientname}</g:link></td>
          <td>${record.fullcost+record.idlesum+record.forwardsum}<br/>(${record.idlesum})<br/>(${record.forwardsum})</td>
          <td>${record.norder}<br/>${String.format('%td.%<tm.%<ty',record.orderdate)}</td>
          <td>${record.paid?:''}<br/>${record.lastpayment?String.format('%td.%<tm.%<ty',record.lastpayment):'-'}</td>
          <td>${!record.debt?'оплачено':record.maxpaydate?String.format('%td.%<tm.%<ty',record.maxpaydate):'документы не переданы'}</td>
          <td>${record.debt>0&&record.maxpaydate?.before(new Date().clearTime())?record.debt:'-'}</td>
          <td><g:if test="${record.benefit}">${record.benefit}<br/>${record.is_paidbenefit?'опл.':'неопл.'}</g:if><g:else>-</g:else></td>
          <td>${trips[record.id].sum{it.price+it.idlesum+it.forwardsum+(it.containernumber2?it.price:0)-it.trackertax}}</td>
          <td>${trips[record.id].sum{it.paid}}</td>
          <td>${trips[record.id].sum{it.price+it.idlesum+it.forwardsum+(it.containernumber2?it.price:0)-it.trackertax}-trips[record.id].sum{it.paid}?:'-'}</td>
          <td>${record.manager}</td>
          <td>${Math.round((record.fullcost+record.idlesum+record.forwardsum-trips[record.id].sum{it.price+it.idlesum+it.forwardsum+(it.containernumber2?it.price:0)})*kprofit-record.benefit)}<br/>(${record.fullcost+record.idlesum+record.forwardsum-trips[record.id].sum{it.price+it.idlesum+it.forwardsum+(it.containernumber2?it.price:0)}-record.benefit})</td>
          <td nowrap>
            <g:link action="findetail" id="${record.id}" class="button" title="Редактировать"><i class="icon-pencil"></i></g:link>
          </td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
  <div style="padding:10px">
    <span class="fleft">Найдено: ${searchresult.count}</span>
    <span class="fright">
      <g:paginate controller="administrators" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </span>
  </div>
</g:if>
</div>
