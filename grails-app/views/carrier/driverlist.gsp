<div id="driverEditForm" style="display:none"></div>
<div class="clear"></div>
<div id="ajax_wrap">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <th>Код</th>
        <th>Имя</th>
        <th>Телефон</th>
        <th>Документ</th>
        <th>Действия</th>
      </thead>
      <tbody>
      <g:each in="${drivers}" status="i" var="record">
        <tr>
          <td align="center">${record.id}</td>
          <td>${record.name}</td>
          <td>${record.tel}</td>
          <td>${record.docseria+' '+record.docnumber}</td>
          <td class="btns" style="text-align:center" nowrap>
            <a class="button" href="javascript:void(0)" title="Редактировать" onclick="editDriver(${record.id});"><i class="icon-pencil"></i></a>
          </td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
</div>
<g:formRemote name="driverdetailForm" url="[action:'driverdetail']" update="[success:'driverEditForm']" onComplete="jQuery('#driverEditForm').slideDown();" style="display:none">
  <input type="text" id="driver_id" name="driver_id" value=""/>
  <input type="submit" class="button" id="driverDetail_submit_button" value="Показать"/>
</g:formRemote>
