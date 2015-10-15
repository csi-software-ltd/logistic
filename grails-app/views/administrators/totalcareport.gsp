<div id="ajax_wrap">
<g:if test="${report}">
  <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0" style="font-size:8pt">
    <thead>
      <tr>
        <th>Перевозчик</th>
        <th>Общая задолженность</th>
        <th>Общий долг</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td colspan="2">Итого перевозчиков</td>
        <td>${report.size()}</td>
      </tr>
      <tr>
        <td colspan="2">Итого задолженность</td>
        <td>${arrearssum}</td>
      </tr>
      <tr>
        <td colspan="2">Итого долг</td>
        <td>${debtsum}</td>
      </tr>
    <g:each in="${report}" status="i" var="record">
      <tr>
        <td>${record.clientname}</td>
        <td>${record.arrears}</td>
        <td>${record.totaldebt}</td>
      </tr>
    </g:each>
    </tbody>
  </table>
</g:if><g:else>
  <h1>Нет данных за указанный период</h1>
</g:else>
</div>