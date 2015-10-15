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
          <th>Клиент</th>
          <th>Сумма заказа,<br/>простой,<br/>переадресация</th>
          <th nowrap>Поездка, перевозчик<br/>cумма (простой,<br/>переадресация)</th>
          <th>Контейнеры</th>
          <th>Счет,<br>дата</th>
          <th>Сумма оплаты,<br>дата</th>
          <th>Срок оплаты</th>
          <th>Долг</th>
          <th>Возн.</th>
          <th>Менеджер</th>
          <th>Дейст вия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="line-height:16px;font-size:11px;background:${record.paid<=(record.fullcost+record.idlesum+record.forwardsum)?'#FFFFFF':'gold'}">
          <td><g:link action="clientdetail" id="${record.client_id}">${record.clientname}</g:link></td>
          <td>${record.fullcost+record.idlesum+record.forwardsum}<br/>(${record.idlesum})<br/>(${record.forwardsum})</td>
          <td align="left"><g:each in="${trips[record.id]}" var="trip"><g:link action="tripdetail" id="${trip.id}">${trip.id}</g:link>, <g:link action="clientdetail" id="${trip.carrier}">${Client.get(trip.carrier).fullname}</g:link><br/>${trip.price+(trip.containernumber2?trip.price:0)+trip.idlesum+trip.forwardsum} (${trip.idlesum},${trip.forwardsum})<br/></g:each></td>
          <td><g:rawHtml>${record.contnumbers.split(',').join('<br/>')}</g:rawHtml></td>
          <td>${record.norder}<br/>${String.format('%td.%<tm.%<ty',record.orderdate)}</td>
          <td>${record.paid?:'-'}<br/>${record.lastpayment?String.format('%td.%<tm.%<ty',record.lastpayment):''}</td>
          <td>${!record.debt?'оплачено':record.maxpaydate?String.format('%td.%<tm.%<ty',record.maxpaydate):'документы не переданы'}</td>
          <td>${record.debt>0&&record.maxpaydate?.before(new Date().clearTime())?record.debt:'-'}</td>
          <td><g:if test="${record.benefit}">${record.benefit}<br/>${record.is_paidbenefit?'опл.':'неопл.'}</g:if><g:else>-</g:else></td>
          <td>${record.manager}</td>
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
