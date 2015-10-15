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
          <th>Поезд<br>ка</th>
          <th>Перевозчик</th>
          <th>Заказ,<br/>дата</th>
          <th>Отправитель,<br/>cумма</th>
          <th>Опл.</th>
          <th>Марш<br>рут</th>
          <th>Контейнеры</th>
          <th>Водитель,<br/>тягач</th>
          <th>К оплате</th>
          <th>Опл-но,<br/>дата</th>
          <th>Срок оплаты</th>
          <th>Долг</th>
          <th>Менеджер</th>
          <th>Дейст вия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="line-height:16px;font-size:11px">
          <td><g:link action="tripdetail" id="${record.id}">${record.id}</g:link></td>
          <td><g:link action="clientdetail" id="${record.carrier}">${record.carrier_name}</g:link></td>
          <td><g:link action="orderdetail" id="${record.zakaz_id}">${record.zakaz_id}</g:link><br/>${String.format('%td.%<tm.%<ty',record.zakazdate)}</td>
          <td><g:link action="clientdetail" id="${record.shipper}">${record.shipper_name}</g:link><br/>${record.fullcost+record.idlesum+record.forwardsum}</td>
          <td><abbr title="${!record.paystatus?'неоплачено':record.paystatus==1?'частично оплачено':'оплачено'}"><i class="icon-${!record.paystatus?'minus':record.paystatus==1?'refresh':'ok'} icon-large"></i></abbr></td>
          <td>${record.is_longtrip?'дальн':'ближ'}</td>
          <td>${record.cont1}<g:if test="${record.cont2}"><br/>${record.cont2}</g:if></td>
          <td>${record.drivername}<br/>${record.cargosnomer}</td>
          <td>${record.ca_price+(record.cont2?record.ca_price:0)+record.ca_idlesum+record.ca_forwardsum-record.ca_trackertax}</td>
          <td>${record.ca_paid?:''}<br/>${record.ca_lastpaydate?String.format('%td.%<tm.%<ty',record.ca_lastpaydate):'-'}</td>
          <td>${record.ca_maxpaydate?String.format('%td.%<tm.%<ty',record.ca_maxpaydate):'документы не сданы'}</td>
          <td>${record.debt>0&&record.ca_maxpaydate?.before(new Date().clearTime())?record.debt:'-'}</td>
          <td>${record.manager}</td>
          <td nowrap>
            <g:link action="findetail" id="${record.order_id}" class="button" title="Редактировать"><i class="icon-pencil"></i></g:link>
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
