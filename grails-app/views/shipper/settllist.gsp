<div id="ajax_wrap">
  <div style="padding:10px">
    <span class="fright">
      <g:paginate controller="shipper" prev="&lt;&lt;" next="&gt;&gt;"
        action="${actionName}" max="20" total="${searchresult?.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </span>
    <div class="clear"></div>
  </div>
  <g:if test="${searchresult.records}">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr>
          <th>№ счета</th>
          <th>Дата счета</th>
          <th>Срок оплаты</th>
          <th>Контрагент</th>
          <th>Сумма счета, руб.</th>
          <th>Неоплаченная сумма, руб.</th>
          <th>Просрочено, дней</th>
          <th>Печать</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" var="record">
        <tr align="center">
          <td>${record.norder}</td>
          <td>${String.format('%td.%<tm.%<tY',record.orderdate)}</td>
          <td>${!record.debt?'оплачено':record.maxpaydate?String.format('%td.%<tm.%<tY',record.maxpaydate):'нет'}</td>
          <td>${Syscompany.get(record.syscompany_id)?.name}</td>
          <td>${record.fullcost+record.idlesum+record.forwardsum}</td>
          <td>${record.debt}</td>
          <td>${record.debt&&(new Date()>record.maxpaydate)?new Date()-(record.maxpaydate?:new Date()):0}</td>
          <td><g:link controller="shipper" action="printorder" id="${record.id}" class="button" title="Печать" target="_blank"><i class="icon-print icon-large"></i></g:link></td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </g:if><g:else>Долгов на данный момент нет</g:else>
</div>