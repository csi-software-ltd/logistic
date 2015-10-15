<div id="ajax_wrap">
<g:if test="${report}">
  <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0" style="font-size:8pt">
    <thead>
      <tr>
        <th>Перевозчик</th>
        <th>Начисленная абонентская плата</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Итого перевозчиков</td>
        <td>${report.size()}</td>
      </tr>
      <tr>
        <td>Итого абон. плата</td>
        <td>${report.sum{it.tax}}</td>
      </tr>
    <g:each in="${report}" status="i" var="record">
      <tr>
        <td>${record.client_name}</td>
        <td>${record.tax}</td>
      </tr>
    </g:each>
    </tbody>
  </table>
</g:if><g:else>
  <h1>Нет данных за указанный период</h1>
</g:else>
</div>