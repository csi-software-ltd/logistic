<div id="ajax_wrap">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr>
          <th>Клиент</th>
          <th>Название</th>
          <th>Цена</th>
          <th>Кол-во конт.</th>
          <th>Кол-во авто</th>
          <th>Назн. конт.</th>
          <th>Статус</th>
          <th>Дата запроса</th>
          <th>Дата ответа</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${offers}" status="i" var="record">
        <tr align="center" style="vertical-align:middle">
          <td>${record.client_id}</td>
          <td align="left">${Client.get(record.client_id?:0)?.fullname}</td>
          <td style="background-color:${record.cprice<=(zakaz.price_basic?:zakaz.price)?'green':'red'}">${record.cprice}</td>
          <td style="color:${record.zcol<zakaz.zcol?'red':'green'}">${record.zcol}</td>
          <td>${record.ncar}</td>
          <td>${driverzcols[record.id]}</td>
          <td>${record.modstatus==0?'новый':record.modstatus==1?'акцепт':record.modstatus==2?'назначен':'отказ'}</td>
          <td>${String.format('%tF %<tT', record.inputdate)}</td>
          <td>${record.moddate!=record.inputdate&&record.modstatus!=0?String.format('%tF %<tT', record.moddate):'нет'}</td>
          <td>
          <g:if test="${record.modstatus==1&&zakaz.modstatus==1&&record.is_carinfo}">
            <g:remoteLink action="orderassign" id="${record.id}" class="button" title="Назначить" onSuccess="processResponseAssign(e);"><i class="icon-ok"></i></g:remoteLink>
          </g:if>
          <g:if test="${record.modstatus==1&&zakaz.modstatus==1&&!record.is_carinfo}">
            <g:remoteLink action="orderremind" id="${record.id}" class="button" title="Напомнить о водителях" onSuccess="alert('Напоминание отправлено');"><i class="icon-envelope"></i></g:remoteLink>
          </g:if>
          <g:if test="${record.modstatus==0&&zakaz.modstatus==1}">
            <a class="button" href="javascript:void(0)" onclick="loginAsCarrier(${User.findByClient_id(record.client_id)?.id},${record.id})" title="Назначить а.м."><i class="icon-lock"></i></a>
          </g:if>
          <g:if test="${record.modstatus==2&&zakaz.modstatus==2}">
            <a class="button" href="javascript:void(0)" onclick="loginAsShipper(${User.findByClient_id(zakaz.shipper)?.id})" title="Назначить контейнеры"><i class="icon-lock"></i></a>
          </g:if>
          </td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
</div>
