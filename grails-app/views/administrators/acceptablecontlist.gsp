<g:formRemote class="contact-form nopad" id="selectAcceptContForm" name="selectAcceptContForm" url="[action:'saveacceptedcont',id:client.id]" method="post" onSuccess="processAcceptContResponse(e)" style="display:none">
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
        <span id="spancont${record.id}" class="button">${record.name} <g:remoteLink class="icon-remove" url="[action:'removacceptablecont',id:record.id,params:[client_id:client.id]]" onSuccess="hidecont('${record.id}',${fullaccept})"></g:remoteLink></span>
        </g:each>
      </g:if><g:else>Допустимых типов контейнеров нет</g:else>
      </fieldset>
    </div>
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <tr>
        <td colspan="8" class="btns" style="text-align:center">
        <g:if test="${!fullaccept}">
          <a class="button" href="javascript:void(0)" onClick="$('contforaccept_submit_button').click();">Добавить тип контейнера</a>
        </g:if><g:if test="${containers}">
          <g:remoteLink class="button" action="removeallacceptablecont" id="${client.id}" onSuccess="getAcceptableContList();">Удалить все</g:remoteLink>
        </g:if>
        </td>
      </tr>
    </table>
  </div>
</div>
<g:formRemote name="contforacceptForm" url="[action:'contforaccept',id:client.id]" update="[success:'contforaccept']" onComplete="jQuery('#selectAcceptContForm').slideDown();" style="display:none">
  <input type="submit" class="button" id="contforaccept_submit_button" value="Показать"/>
</g:formRemote>
