<div id="ajax_wrap">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${searchresult.count}</div>
    <div class="fright">
      <g:paginate controller="administrators" action="${actionName}" params="${params}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </div>
    <div class="clear"></div>
  </div>
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr style="line-height:16px">
          <th>Клиент</th>
          <th>Сумма заказа,<br/>простой,<br/>переадресация</th>
          <th>Контейнеры</th>
          <th>Счет,<br>дата</th>
          <th>Сумма оплаты,<br>дата</th>
          <th>Срок оплаты</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="line-height:16px;font-size:11px;">
          <td><g:link action="clientdetail" id="${record.client_id}">${record.clientname}</g:link></td>
          <td>${record.fullcost+record.idlesum+record.forwardsum}<br/>(${record.idlesum})<br/>(${record.forwardsum})</td>
          <td><g:rawHtml>${record.contnumbers.split(',').join('<br/>')}</g:rawHtml></td>
          <td>${record.norder}<br/>${String.format('%td.%<tm.%<ty',record.orderdate)}</td>
          <td>${record.paid?:'-'}<br/>${record.lastpayment?String.format('%td.%<tm.%<ty',record.lastpayment):''}</td>
          <td>${record.maxpaydate?String.format('%td.%<tm.%<ty',record.maxpaydate):'документы не переданы'}</td>
          <td nowrap>
            <a class="button" title="Оплатить" href="javascript:void(0)" onclick="orderpay('${record.id}')"><i class="icon-money"></i></a>
          </td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
</div>