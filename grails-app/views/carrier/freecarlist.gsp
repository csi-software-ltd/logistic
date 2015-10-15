<g:formRemote class="contact-form nopad p2" id="freecarAddForm" name="freecarAddForm" url="[action:'addFreecar']" method="post" onSuccess="processFreecarAddResponse(e)" style="display:none">
  <div class="error-box p2" style="width:730px;margin-top:0;display:none">
    <span class="icon icon-warning-sign icon-3x"></span>
    <ul id="errorfreecarlist">
      <li></li>
    </ul>
  </div>
  <fieldset id="freecar"></fieldset>
</g:formRemote>
<div id="ajax_wrap">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <th width="60">Номер п/п</th>
        <th>Водитель</th>
        <th>Тягач</th>
        <th>Прицеп</th>
        <th>Актуально</th>
        <th>Действия</th>
      </thead>
      <tbody>
      <g:each in="${freecars}" status="i" var="record">
        <tr>
          <td align="center" width="60">${i+1}</td>
          <td>${drivers[record.driver_id]}</td>
          <td>${cars[record.car_id]}</td>
          <td>${trailers[record.trailer_id]}</td>
          <td><g:if test="${actualtimes[record.id]<=0}"><abbr title="время истекло"><i class="icon-time icon-large"></i></abbr></g:if><g:else>${Tools.getDayString(actualtimes[record.id])}</g:else></td>
          <td class="btns" style="text-align:center" nowrap>
            <g:remoteLink class="button" url="[action:'removefreecar',id:record.id]" onSuccess="\$('freecarslist_submit_button').click();" title="Удалить"><i class="icon-trash"></i></g:remoteLink>
          </td>
        </tr>
      </g:each>
        <tr style="height:42px">
          <td colspan="6" class="btns" style="text-align:center">
          <g:if test="${!client.isblocked}">
            <a class="button" id="adddriverbutton" href="javascript:void(0)" onclick="$('freecar_submit_button').click();">Добавить транспорт</a>
          </g:if>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
<g:formRemote name="zakaztodriverForm" url="[action:'freecar']" update="[success:'freecar']" onComplete="\$('errorfreecarlist').up('div').hide();jQuery('#freecarAddForm').slideDown();" style="display:none">
  <input type="hidden" id="selectedDriver_id" name="driver_id" value="0"/>
  <input type="hidden" id="selectedCar_id" name="car_id" value="0"/>
  <input type="hidden" id="selectedTrailer_id" name="trailer_id" value="0"/>
  <input type="submit" class="button" id="freecar_submit_button" value="Показать"/>
</g:formRemote>