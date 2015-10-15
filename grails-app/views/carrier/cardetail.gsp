<g:formRemote class="contact-form" name="carEdit_Form" url="[action:'saveCarDetail']" method="post" onSuccess="processCarEditResponse(e)">
  <div class="error-box p2" style="width:730px;margin-top:-20px;display:none">
    <span class="icon icon-warning-sign icon-3x"></span>
    <ul id="errorcarlist">
      <li></li>
    </ul>
  </div>
  <fieldset>
    <div class="grid_6 alpha">
      <label for="car_gosnomer">Госномер:</label>
      <input type="text" id="car_gosnomer" name="car_gosnomer" value="${car?.gosnomer}" />
    </div>
    <div class="grid_6 omega">
      <label for="car_model_id">Модель:</label>
      <g:select name="car_model_id" value="${car?.model_id}" optionKey="id" optionValue="name" from="${carmodel}"/>
      <label for="car_is_platform">Платформа:</label>
      <g:select name="car_is_platform" value="${car?.is_platform}" keys="${0..1}" from="${['отсутствует','есть']}"/>
    </div>
    <div class="clear"></div>
    <g:if test="${drivers}">
    <div class="grid_11 alpha">
      <fieldset class="bord" style="width:856px">
        <legend>Водители</legend>
      <g:each in="${drivers}" var="driver" status="i">
        <input type="checkbox" id="${driver.name}" name="drivers" value="${driver.id}" <g:if test="${carDrivers_id.contains(driver.id)}">checked</g:if> />
        <label class="nopadd" for="${driver.name}">${driver.name}</label>   
      </g:each>
      </fieldset>
    </div>
    </g:if>
    <div class="clear"></div>
    <div class="btns">
      <input type="reset" class="button" value="Отмена" onclick="jQuery('#carEditForm').slideUp();"/>
    </div>
    <input type="hidden" name="car_id" value="${car?.id?:0}" />
  </fieldset>
</g:formRemote>
<g:if test="${car&&(car.is_passport1||car.is_passport2)}">
<div class="contact-form grid_12 alpha">
  <fieldset class="bord" style="width:924px;">
    <legend>Документы</legend>
    <a class="button" style="${!(car?.is_passport1)?'display:none':''}" href="${createLink(controller:'index',action:'showpicture',id:car?.is_passport1,params:[code:Tools.generateModeParam(car?.is_passport1)])}" target="_blank">Посмотреть тех. паспорт1</a>
    <a class="button" style="${!(car?.is_passport2)?'display:none':''}" href="${createLink(controller:'index',action:'showpicture',id:car?.is_passport2,params:[code:Tools.generateModeParam(car?.is_passport2)])}" target="_blank">Посмотреть тех. паспорт2</a>
  </fieldset>
</div>
</g:if>