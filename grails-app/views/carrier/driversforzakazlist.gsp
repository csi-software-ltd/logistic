<g:formRemote class="contact-form nopad p2" id="driverAddForm" name="driverAddForm" url="[action:'addDriverToZakaz']" method="post" onSuccess="processDriverAddResponse(e)" style="display:none">
  <div class="error-box p2" style="width:730px;margin-top:0;display:none">
    <span class="icon icon-warning-sign icon-3x"></span>
    <ul id="errordriverlist">
      <li></li>
    </ul>
  </div>
  <fieldset id="zakaztodriver"></fieldset>
  <input type="hidden" name="zakaz_id" value="${zakaz.id}"/>
</g:formRemote>
<div id="ajax_wrap">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <th width="60">Номер п/п</th>
        <th>Водитель</th>
        <th>Тягач</th>
        <th>Прицеп</th>
        <th width="60">Кол-во контейнеров</th>
        <th>Действия</th>
      </thead>
      <tbody>
      <g:each in="${zakaztodriver}" status="i" var="record">
        <tr>
          <td align="center" width="60">${i+1}</td>
          <td>${drivers[record.driver_id]}</td>
          <td>${cars[record.car_id]}</td>
          <td>${trailers[record.trailer_id]}</td>
          <td align="center" width="60">${record.zcol}</td>
          <td class="btns" style="text-align:center" nowrap>
            <g:if test="${zakaztocarrier.modstatus==0&&zakaz.modstatus==1}">
              <g:remoteLink class="button" url="[action:'removedriverfromzakaz',id:record.id,params:[zakaztocarrier_id:zakaztocarrier.id]]" onSuccess="getDriverList();" title="Удалить"><i class="icon-trash"></i></g:remoteLink>
            </g:if>
          </td>
        </tr>
      </g:each>
        <tr>
          <td colspan="6" class="btns" style="text-align:center">
            <g:if test="${zakaztocarrier.modstatus==0&&zakaz.modstatus==1&&drivercol<zakaz.zcol&&!(zakaztocarrier.deadline.getTime()-new Date().getTime()<=0)}">
              <a class="button" id="adddriverbutton" href="javascript:void(0)" onclick="$('zakaztodriver_submit_button').click();">Добавить транспорт</a>
            </g:if>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
<g:formRemote name="zakaztodriverForm" url="[action:'zakaztodriver']" update="[success:'zakaztodriver']" onComplete="jQuery('#driverAddForm').slideDown();" style="display:none">
  <input type="hidden" name="zakaz_id" value="${zakaz.id}"/>
  <input type="hidden" id="selectedDriver_id" name="driver_id" value="0"/>
  <input type="hidden" id="selectedCar_id" name="car_id" value="0"/>
  <input type="hidden" id="selectedTrailer_id" name="trailer_id" value="0"/>
  <input type="submit" class="button" id="zakaztodriver_submit_button" value="Показать"/>
</g:formRemote>
