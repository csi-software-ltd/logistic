<div id="driverEditForm" style="display:none"></div>
<div class="clear"></div>
<div id="ajax_wrap">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr>
          <th>Код</th>
          <th>Имя</th>
          <th>Телефон</th>
          <th>Документ</th>
          <th>Статус</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${drivers}" status="i" var="record">
        <tr>
          <td align="center">${record.id}</td>
          <td>${record.name}</td>
          <td>${record.tel}</td>
          <td>${record.docseria+' '+record.docnumber}</td>
          <td align="center"><span class="icon-${record.modstatus?'ok':'remove'}" title="${record.modstatus?'активен':'не активен'}"></span></td>
          <td class="btns" style="text-align:center" nowrap>
            <a class="button" href="javascript:void(0)" title="Редактировать" onclick="editDriver(${record.id});"><i class="icon-pencil"></i></a>
          <g:if test="${record.modstatus==0}">
            <a class="button" href="javascript:void(0)" title="Активировать" onclick="setDriverStatus(${record.id},1);"><i class="icon-ok"></i></a>
          </g:if><g:else>
            <a class="button" href="javascript:void(0)" title="Деактивировать" onclick="setDriverStatus(${record.id},0);"><i class="icon-remove"></i></a>
          </g:else>
          </td>
        </tr>
      </g:each>
        <tr>
          <td colspan="6" class="btns" style="text-align:center">
            <a class="button" href="javascript:void(0)" onclick="editDriver(0);">Добавить водителя</a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
<g:formRemote name="driverdetailForm" url="[action:'driverdetail']" update="[success:'driverEditForm']" onComplete="jQuery('#driverEditForm').slideDown();" style="display:none">
  <input type="text" id="driver_id" name="driver_id" value=""/>
  <input type="text" name="client_id" value="${client?.id}" />
  <input type="submit" class="button" id="driverDetail_submit_button" value="Показать"/>
</g:formRemote>