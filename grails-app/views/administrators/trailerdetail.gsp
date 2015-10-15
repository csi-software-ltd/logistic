<g:formRemote class="contact-form" name="trailerEdit_Form" url="[action:'saveTrailerDetail']" method="post" onSuccess="processTrailerEditResponse(e)">
  <div class="error-box p2" style="width:730px;margin-top:-20px;display:none">
    <span class="icon icon-warning-sign icon-3x"></span>
    <ul id="errortrailerlist">
      <li></li>
    </ul>
  </div>
  <fieldset>
    <div class="grid_6 alpha">
      <label for="trailnumber">Госномер:</label>
      <input type="text" id="trailnumber" name="trailnumber" value="${trailer?.trailnumber}" />
    </div>
    <div class="grid_6 omega">
      <label for="trailer_trailertype_id">Прицеп:</label>
      <g:select name="trailer_trailertype_id" value="${trailer?.trailertype_id}" keys="${0..2}" from="${['не задано','короткий','длинный']}"/>
    </div>
    <div class="clear"></div>
    <g:if test="${cars}">
    <div class="grid_11 alpha">
      <fieldset class="bord" style="width:856px">
        <legend>Тягачи:</legend>
      <g:each in="${cars}" var="car" status="i">
        <input type="checkbox" id="${car.gosnomer}" name="cars" value="${car.id}" <g:if test="${carTrailers_id.contains(car.id)}">checked</g:if> />
        <label class="nopadd" for="${car.gosnomer}">${car.gosnomer}</label>
      </g:each>
      </fieldset>
    </div>
    </g:if>
    <div class="clear"></div>
    <div class="btns">
      <input type="submit" id="submit_button" class="button" value="Сохранить" />
      <input type="reset" class="button" value="Отмена" onclick="jQuery('#trailerEditForm').slideUp();"/>
    </div>
    <input type="hidden" name="trailer_id" value="${trailer?.id?:0}" />
    <input type="hidden" name="client_id" value="${client?.id}" />
  </fieldset>
</g:formRemote>
<g:if test="${trailer}">
<div class="contact-form grid_6 alpha">
  <fieldset class="bord">
    <legend>Тех.паспорт1</legend>
    <div id="upload_passport1" style="${trailer?.is_passport1?'display:none':''}">
      <g:form name="tp1" method="post" url="${[action:'savescantrailer',id:trailer.id?:0]}" enctype="multipart/form-data" target="upload_target">
        <div class="error" id="error_passport1" style="display:none"></div>
        <label for="passport1" class="nopad">Загрузить скан:</label>
        <input type="file" name="passport1" size="23" accept="image/jpeg,image/png" onchange="startSubmit('tp1')"/>
      </g:form>
      <iframe id="upload_target" name="upload_target" src="#" style="width:0;height:0;border:0"></iframe>
    </div>
    <div id="result_passport1" style="${!(trailer?.is_passport1)?'display:none':''}">
      <a class="button" href="${createLink(controller:'index',action:'showpicture',id:trailer?.is_passport1,params:[code:Tools.generateModeParam(trailer?.is_passport1)])}" target="_blank" id="viewscan_passport1">Посмотреть тех.паспорт1</a>
      <g:remoteLink class="button" url="[action:'deletetrailerscan',id:trailer.id,params:[file:'passport1']]" onSuccess="reloadImage('passport1')">Удалить</g:remoteLink>
    </div>
  </fieldset>
</div>
<div class="contact-form grid_6 omega">
  <fieldset class="bord">
    <legend>Тех.паспорт2</legend>
    <div id="upload_passport2" style="${trailer?.is_passport2?'display:none':''}">
      <g:form name="tp2" method="post" url="${[action:'savescantrailer',id:trailer.id?:0]}" enctype="multipart/form-data" target="upload_target2">
        <div class="error" id="error_passport2" style="display:none"></div>
        <label for="passport2" class="nopad">Загрузить скан:</label>
        <input type="file" name="passport2" size="23" accept="image/jpeg,image/png" onchange="startSubmit('tp2')"/>
      </g:form>
      <iframe id="upload_target2" name="upload_target2" src="#" style="width:0;height:0;border:0"></iframe>
    </div>
    <div id="result_passport2" style="${!(trailer?.is_passport2)?'display:none':''}">
      <a class="button" href="${createLink(controller:'index',action:'showpicture',id:trailer?.is_passport2,params:[code:Tools.generateModeParam(trailer?.is_passport2)])}" target="_blank" id="viewscan_passport2">Посмотреть тех.паспорт2</a>
      <g:remoteLink class="button" url="[action:'deletetrailerscan',id:trailer.id,params:[file:'passport2']]" onSuccess="reloadImage('passport2')">Удалить</g:remoteLink>
    </div>
  </fieldset>
</div>
</g:if>