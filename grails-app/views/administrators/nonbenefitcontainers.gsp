<div id="ajax_wrap">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr>        
          <th>Клиент</th>
          <th>Контейнер</th>
          <th>Сумма к оплате</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult}" status="i" var="record">
      <g:each in="${record.contnumbers.split(',')}" var="cont">
      <g:if test="${!record.contbenefit.split(',').find{it==cont}}">
        <tr align="center" style="vertical-align:middle">
          <td>${record.clientname}</td>
          <td>${cont}</td>
          <td>${Math.ceil(record.benefit/record.contnumbers.split(',').size()).toInteger()}</td>
          <td nowrap>
            <a class="button" title="Оплатить" href="javascript:void(0)" onclick="contpay('${record.id}','${cont}')"><i class="icon-money"></i></a>
          </td>
        </tr>
      </g:if>
      </g:each>
      </g:each>
      </tbody>
    </table>
  </div>
</div>