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
      <input type="reset" class="button" value="Отмена" onclick="jQuery('#trailerEditForm').slideUp();"/>
    </div>
    <input type="hidden" name="trailer_id" value="${trailer?.id?:0}" />
  </fieldset>
</g:formRemote>
<g:if test="${trailer&&(trailer.is_passport1||trailer.is_passport2)}">
<div class="contact-form grid_12 alpha">
  <fieldset class="bord" style="width:924px;">
    <legend>Документы</legend>
    <a class="button" style="${!(trailer?.is_passport1)?'display:none':''}" href="${createLink(controller:'index',action:'showpicture',id:trailer?.is_passport1,params:[code:Tools.generateModeParam(trailer?.is_passport1)])}" target="_blank">Посмотреть тех. паспорт1</a>
    <a class="button" style="${!(trailer?.is_passport2)?'display:none':''}" href="${createLink(controller:'index',action:'showpicture',id:trailer?.is_passport2,params:[code:Tools.generateModeParam(trailer?.is_passport2)])}" target="_blank">Посмотреть тех. паспорт2</a>
  </fieldset>
</div>
</g:if>