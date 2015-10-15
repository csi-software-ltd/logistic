<g:formRemote class="contact-form nopad" id="selectExcRegionForm" name="selectExcRegionForm" url="[action:'saveexcludedregion',id:client.id]" method="post" onSuccess="processExcludeRegionResponse(e)" style="display:none">
  <div class="error-box padding-bottom2" style="display:none">
    <span class="icon"><img src="${resource(dir:'images',file:'icon-error.png')}" alt="" /></span>  
    <ul id="errorexcregionlist">
      <li></li>
    </ul>
  </div>
  <fieldset id="regionsforexc"></fieldset>
</g:formRemote>
<div id="ajax_wrap">
  <div id="resultList">
    <g:formRemote class="contact-form nopad" name="limitingparamsForm" url="[action:'savelimitingparams',id:client.id]" onSuccess="processLimitingParamsResponse(e);">
      <fieldset>
        <label for="shipdistance">Максимальное расстояние, км (0 - без ограничений):</label>
        <input type="text" class="mini" id="shipdistance" name="shipdistance" value="${client.shipdistance}" />
        <label for="shipprice" class="auto">Цена, руб. от:</label>
        <input type="text" class="mini" id="shipprice" name="shipprice" value="${client.shipprice}" />
        <label for="shipweight" class="auto">Вес, т до:</label>
        <input type="text" class="mini" id="shipweight" name="shipweight" value="${client.shipweight}" />
        <a class="button" href="javascript:void(0)" onclick="$('limitingparams_submit_button').click();" title="Сохранить"><i class="icon-ok"></i></a>
        <input type="submit" class="button"  id="limitingparams_submit_button" value="Отправить" style="display:none"/>
      </fieldset>
    </g:formRemote>
    <div class="contact-form nopad">
      <fieldset class="bord" style="width:925px">
        <legend>Кроме регионов:</legend>
      <g:if test="${regions}">
        <g:each in="${regions}" status="i" var="record">
        <span id="spanreg${record.id}" class="button">${record.name} <g:remoteLink class="icon-remove" url="[action:'removeexcludedregion',id:record.id,params:[client_id:client.id]]" onSuccess="hideregion('${record.id}',${fullexclude})"></g:remoteLink></span>
        </g:each>
      </g:if><g:else>Ограничений по регионам нет</g:else>
      </fieldset>
    </div>
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <tr>
        <td colspan="8" class="btns" style="text-align:center">
        <g:if test="${!fullexclude}">
          <a class="button" href="javascript:void(0)" onClick="$('regionsforexc_submit_button').click();">Добавить регион</a>
        </g:if><g:if test="${regions}">
          <g:remoteLink class="button" action="removeallexcludedregion" id="${client.id}" onSuccess="getGeographicExc();">Удалить все</g:remoteLink>
        </g:if>
        </td>
      </tr>
    </table>
  </div>
</div>
<g:formRemote name="regionsforexcForm" url="[action:'regionsforexc',id:client.id]" update="[success:'regionsforexc']" onComplete="jQuery('#selectExcRegionForm').slideDown();" style="display:none">
  <input type="submit" class="button" id="regionsforexc_submit_button" value="Показать"/>
</g:formRemote>