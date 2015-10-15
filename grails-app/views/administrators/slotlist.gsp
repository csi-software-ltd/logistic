<div id="ajax_wrap">  
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <th>Имя</th>
        <th>Начало</th>
        <th>Окончание</th>
        <th>Статус</th>
        <th>Действия</th>
      </thead>
      <tbody>
      <g:each in="${slots}" status="i" var="record">
        <tr align="center">
          <td>${record.name}</td>
          <td>${record.start}</td>
          <td>${record.end}</td>
          <td><span class="icon-${record.modstatus?'ok':'remove'}" title="${record.modstatus?'активно':'неактивно'}"></span></td>
          <td class="btns" style="text-align:center">
            <a class="button" href="javascript:void(0)" title="Редактировать" onclick="editSlot(${record.id},'${record.name}','${record.start}','${record.end}',${record.modstatus});"><i class="icon-pencil"></i></a>
            <a class="button" href="javascript:void(0)" title="Удалить" onclick="deleteSlot(${record.id});"><i class="icon-trash"></i></a>
          </td>
        </tr>
      </g:each>
        <tr>
          <td colspan="5" class="btns" style="text-align:center">
            <a class="button" href="javascript:void(0)" onClick="editSlot(0,'','','',0);">Добавить слот</a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
