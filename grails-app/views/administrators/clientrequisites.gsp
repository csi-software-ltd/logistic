<g:formRemote class="contact-form padding-bottom3" id="requisitesEditForm" name="requisitesEditForm" url="[action:'saveClientRequisites']" method="post" onSuccess="processEditRequisitesResponse(e)" style="display:none">
  <div class="error-box p2" style="margin-top:-20px;display:none">
    <span class="icon icon-warning-sign icon-3x"></span>
    <ul id="errorClientRequisites">
      <li></li>
    </ul>
  </div>
  <div class="info-box" style="margin-top:-15px;margin-bottom:19px;display:none">
    <span class="icon icon-info-sign icon-3x"></span>
    <ul>
      <li>НДС компании клиента и системной компании не совпадают</li>
    </ul>
  </div>
  <fieldset id="requisitesdetail"></fieldset>
  <input type="hidden" name="client_id" value="${client?.id}" />
</g:formRemote>
<div id="ajax_wrap">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr>
          <th>Код</th>
          <th>Получатель платежа</th>
          <th>Тип</th>
          <th>Банк</th>
          <th>Ндс,%</th>
          <th>Статус</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${requisites}" status="i" var="record">
        <tr>
          <td align="center">${record.id}</td>
          <td>${record.payee}</td>
          <td>${record.ctype_id}</td>
          <td>${record.bankname}</td>
          <td align="center">${record.nds}</td>
          <td align="center"><span class="icon-${record.modstatus==0?'ok':(record.modstatus==1?'flag':'remove')}" title="${record.modstatus==0?'активен':(record.modstatus==1?'основной':'не активен')}"></span></td>
          <td class="btns" style="text-align:center">
            <a class="button" href="javascript:void(0)" title="Редактировать" onclick="editRequisites(${record.id});"><i class="icon-pencil"></i></a>
          <g:if test="${record.modstatus==-1}">
            <a class="button" href="javascript:void(0)" title="Активировать" onclick="setRequisitesStatus(${record.id},0);"><i class="icon-ok"></i></a>
          </g:if><g:else>
            <a class="button" href="javascript:void(0)" title="Деактивировать" onclick="setRequisitesStatus(${record.id},-1);"><i class="icon-remove"></i></a>
          </g:else>
          <g:if test="${record.modstatus!=1}">
            <a class="button" href="javascript:void(0)" title="Сделать основным" onclick="setRequisitesStatus(${record.id},1);"><i class="icon-flag"></i></a>
          </g:if>
          </td>
        </tr>
      <g:if test="${record.modstatus==1}">
        <script type="text/javascript">
          editRequisites(${record.id});
        </script>
      </g:if>
      </g:each>
        <tr>
          <td colspan="8" class="btns" style="text-align:center">
            <a class="button" href="javascript:void(0)" onClick="editRequisites(0);">Добавить реквизиты</a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
<g:if test="${!requisites}">
  <script type="text/javascript">
    editRequisites(0);
  </script>
</g:if>
<g:formRemote name="requisitesdetailForm" url="[action:'requisitesdetail']" update="[success:'requisitesdetail']" onComplete="jQuery('#requisitesEditForm').slideDown();" style="display:none">
  <input type="text" id="requisites_id" name="requisites_id" value=""/>
  <input type="submit" class="button" id="requisitesDetail_submit_button" value="Показать"/>
</g:formRemote>
