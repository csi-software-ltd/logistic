<div id="ajax_wrap">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr>
          <th>№пп</th>
          <th>Дата</th>
          <th>Время</th>
          <th>Описание</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${events}" status="i" var="record">
        <tr>
          <td align="center">${i+1}</td>
          <td>${String.format('%tF',record.eventdate)}</td>
          <td>${String.format('%tT',record.eventdate)}</td>
          <td>${eventtypes[record.type_id].descr}</td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
</div>