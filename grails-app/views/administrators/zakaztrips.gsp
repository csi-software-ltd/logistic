<div id="ajax_wrap">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr>
          <th>Номер</th>
          <th>Перевозчик</th>
          <th>Водитель/Тягач</th>
          <th>Контейнеры</th>
          <th>Статус</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${trips.records}" status="i" var="record">
        <tr align="center" style="vertical-align:middle">
          <td><g:link action="tripdetail" id="${record.id}" target="_blank">${record.id}</g:link></td>
          <td><g:link action="clientdetail" id="${record.carrier}" target="_blank">${record.carriername}</g:link></td>
          <td>${record.driver_fullname}<br/>${record.cargosnomer}</td>
          <td>${record.containernumber1}<g:if test="${record.containernumber2}"><br/>${record.containernumber2}</g:if></td>
          <td><abbr title="${tripstatus[record.modstatus].descr}"><i class="icon-${tripstatus[record.modstatus].icon} icon-large"></i></abbr></td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
</div>