<div id="trailerEditForm" style="display:none"></div>
<div class="clear"></div>
<div id="ajax_wrap">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr>
          <th>Код</th>
          <th>Номер</th>
          <th>Тип прицепа</th>
          <th>Тягачи</th>
          <th>Статус</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${trailers}" status="i" var="record">
        <tr>
          <td align="center">${record.id}</td>
          <td>${record.trailnumber}</td>
          <td>${record.trailertype_id==1?'короткий':record.trailertype_id==2?'длинный':'не задано'}</td>
          <td>${carTrailers_id[record.id].collect{ car_id -> cars.find{it.id==car_id}?.gosnomer }.join(', ')}</td>
          <td align="center"><span class="icon-${record.modstatus?'ok':'remove'}" title="${record.modstatus?'активен':'не активен'}"></span></td>
          <td class="btns" style="text-align:center" nowrap>
            <a class="button" href="javascript:void(0)" title="Редактировать" onclick="editTrailer(${record.id});"><i class="icon-pencil"></i></a>
          <g:if test="${record.modstatus==0}">
            <a class="button" href="javascript:void(0)" title="Активировать" onclick="setTrailerStatus(${record.id},1);"><i class="icon-ok"></i></a>
          </g:if><g:else>
            <a class="button" href="javascript:void(0)" title="Деактивировать" onclick="setTrailerStatus(${record.id},0);"><i class="icon-remove"></i></a>
          </g:else>
          </td>
        </tr>
      </g:each>
        <tr>
          <td colspan="8" class="btns" style="text-align:center">
            <a class="button" href="javascript:void(0)" onClick="editTrailer(0);">Добавить прицеп</a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
<g:formRemote name="trailerdetailForm" url="[action:'trailerdetail']" update="[success:'trailerEditForm']" onComplete="jQuery('#trailerEditForm').slideDown();" style="display:none">
  <input type="text" id="trailer_id" name="trailer_id" value=""/>
  <input type="submit" class="button" id="trailerDetail_submit_button" value="Показать"/>
  <input type="text" name="client_id" value="${client?.id}" />
</g:formRemote>