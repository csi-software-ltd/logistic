<g:formRemote class="contact-form nopad" id="selectExcRegionForm" name="selectExcRegionForm" url="[action:'saveexcludedregion']" method="post" onSuccess="processExcludeRegionResponse(e)" style="display:none">
  <div class="error-box padding-bottom2" style="display:none">
    <span class="icon icon-warning-sign icon-3x"></span>
    <ul id="errorexcregionlist">
      <li></li>
    </ul>
  </div>
  <fieldset id="regionsforexc"></fieldset>
</g:formRemote>
<div id="ajax_wrap">
  <div id="resultList">
    <g:formRemote class="contact-form nopad" name="limitingparamsForm" url="[action:'savelimitingparams']" onSuccess="processLimitingParamsResponse(e);">
      <fieldset>
        <label for="shipdistance">Максимальное расстояние, км (0 - без ограничений):</label>
        <input type="text" class="mini" id="shipdistance" name="shipdistance" value="${client.shipdistance}" />
        <label for="shipprice" class="auto">Цена, руб. от:</label>
        <input type="text" class="mini" id="shipprice" name="shipprice" value="${client.shipprice}" />
        <label for="shipweight" class="auto">Вес, т до:</label>
        <input type="text" class="mini" id="shipweight" name="shipweight" value="${client.shipweight}" />
      </fieldset>
    </g:formRemote>
    <div class="contact-form nopad">
      <fieldset class="bord" style="width:925px">
        <legend>Кроме регионов:</legend>
      <g:if test="${regions}">
        <g:each in="${regions}" status="i" var="record">
        <span id="spanreg${record.id}" class="button">${record.name}</span>
        </g:each>
      </g:if><g:else>Ограничений по регионам нет</g:else>
      </fieldset>
    </div>
  </div>
</div>
<g:formRemote name="regionsforexcForm" url="[action:'regionsforexc']" update="[success:'regionsforexc']" onComplete="jQuery('#selectExcRegionForm').slideDown();" style="display:none">
  <input type="submit" class="button" id="regionsforexc_submit_button" value="Показать"/>
</g:formRemote>
