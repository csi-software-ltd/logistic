<g:formRemote class="contact-form nopad" id="selectAcceptContForm" name="selectAcceptContForm" url="[action:'saveacceptedcont']" method="post" onSuccess="processAcceptContResponse(e)" style="display:none">
  <div class="error-box padding-bottom2" style="display:none">
    <span class="icon icon-warning-sign icon-3x"></span>
    <ul id="erroracceptcontlist">
      <li></li>
    </ul>
  </div>
  <fieldset id="contforaccept"></fieldset>
</g:formRemote>
<div id="ajax_wrap">
  <div id="resultList">
    <div class="contact-form nopad">
      <fieldset class="bord" style="width:925px">
        <legend>Допустимые типы контейнеров:</legend>
      <g:if test="${containers}">
        <g:each in="${containers}" status="i" var="record">
        <span id="spancont${record.id}" class="button">${record.name}</span>
        </g:each>
      </g:if><g:else>Допустимых типов контейнеров нет</g:else>
      </fieldset>
    </div>
  </div>
</div>
<g:formRemote name="contforacceptForm" url="[action:'contforaccept']" update="[success:'contforaccept']" onComplete="jQuery('#selectAcceptContForm').slideDown();" style="display:none">
  <input type="submit" class="button" id="contforaccept_submit_button" value="Показать"/>
</g:formRemote>
