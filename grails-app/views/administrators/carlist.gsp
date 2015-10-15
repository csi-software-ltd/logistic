<div id="carEditForm" style="display:none"></div>
<div class="clear"></div>
<div id="ajax_wrap">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <th>Код</th>
        <th>Номер</th>
        <th>Модель</th>
        <th>Платформа</th>
        <th>Водители</th>
        <th>Статус</th>
        <th>Действия</th>
      </thead>
      <tbody>
      <g:each in="${cars}" status="i" var="record">
        <tr>
          <td align="center">${record.id}</td>
          <td>${record.gosnomer}</td>
          <td>${carmodel.find{it.id==record.model_id}?.name}</td>
          <td>${record.is_platform?'есть':'нет'}</td>
          <td>${carDrivers_id[record.id].collect{ dr_id -> drivers.find{it.id==dr_id}?.name }.join(', ')}</td>
          <td align="center"><span class="icon-${record.modstatus?'ok':'remove'}" title="${record.modstatus?'активен':'не активен'}"></span></td>
          <td class="btns" style="text-align:center" nowrap>
            <a class="button" href="javascript:void(0)" title="Редактировать" onclick="editCar(${record.id});"><i class="icon-pencil"></i></a>
          <g:if test="${record.modstatus==0}">
            <a class="button" href="javascript:void(0)" title="Активировать" onclick="setCarStatus(${record.id},1);"><i class="icon-ok"></i></a>
          </g:if><g:else>
            <a class="button" href="javascript:void(0)" title="Деактивировать" onclick="setCarStatus(${record.id},0);"><i class="icon-remove"></i></a>
          </g:else>
          </td>
        </tr>
      </g:each>
        <tr>
          <td colspan="8" class="btns" style="text-align:center">
            <a class="button" href="javascript:void(0)" onClick="editCar(0);">Добавить машину</a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
<g:formRemote name="cardetailForm" url="[action:'cardetail']" update="[success:'carEditForm']" onComplete="jQuery('#carEditForm').slideDown();" style="display:none">
  <input type="text" id="car_id" name="car_id" value=""/>
  <input type="submit" class="button" id="carDetail_submit_button" value="Показать"/>
  <input type="text" name="client_id" value="${client?.id}" />
</g:formRemote>