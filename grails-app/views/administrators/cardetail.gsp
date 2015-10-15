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
      <input type="submit" id="submit_button" class="button" value="Сохранить" />
      <input type="reset" class="button" value="Отмена" onclick="jQuery('#carEditForm').slideUp();"/>
    </div>
    <input type="hidden" name="car_id" value="${car?.id?:0}" />
    <input type="hidden" name="client_id" value="${client?.id}" />
  </fieldset>
</g:formRemote>
<g:if test="${car}">
<div class="contact-form grid_6 alpha">
  <fieldset class="bord">
    <legend>Тех.паспорт1</legend>
    <div id="upload_passport1" style="${car?.is_passport1?'display:none':''}">
      <g:form name="cp1" method="post" url="${[action:'savescancar',id:car.id?:0]}" enctype="multipart/form-data" target="upload_target">
        <div class="error" id="error_passport1" style="display:none"></div>
        <label for="passport1" class="nopad">Загрузить скан:</label>
        <input type="file" name="passport1" size="23" accept="image/jpeg,image/png" onchange="startSubmit('cp1')"/>
      </g:form>
      <iframe id="upload_target" name="upload_target" src="#" style="width:0;height:0;border:0"></iframe>
    </div>
    <div id="result_passport1" style="${!(car?.is_passport1)?'display:none':''}">
      <a class="button" href="${createLink(controller:'index',action:'showpicture',id:car?.is_passport1,params:[code:Tools.generateModeParam(car?.is_passport1)])}" target="_blank" id="viewscan_passport1">Посмотреть тех.паспорт1</a>
      <g:remoteLink class="button" url="[action:'deletecarscan',id:car.id,params:[file:'passport1']]" onSuccess="reloadImage('passport1')">Удалить</g:remoteLink>
    </div>
  </fieldset>
</div>
<div class="contact-form grid_6 omega">
  <fieldset class="bord">
    <legend>Тех.паспорт2</legend>
    <div id="upload_passport2" style="${car?.is_passport2?'display:none':''}">
      <g:form name="cp2" method="post" url="${[action:'savescancar',id:car.id?:0]}" enctype="multipart/form-data" target="upload_target2">
        <div class="error" id="error_passport2" style="display:none"></div>
        <label for="passport2" class="nopad">Загрузить скан:</label>
        <input type="file" name="passport2" size="23" accept="image/jpeg,image/png" onchange="startSubmit('cp2')"/>
      </g:form>
      <iframe id="upload_target2" name="upload_target2" src="#" style="width:0;height:0;border:0"></iframe>
    </div>
    <div id="result_passport2" style="${!(car?.is_passport2)?'display:none':''}">
      <a class="button" href="${createLink(controller:'index',action:'showpicture',id:car?.is_passport2,params:[code:Tools.generateModeParam(car?.is_passport2)])}" target="_blank" id="viewscan_passport2">Посмотреть тех.паспорт2</a>
      <g:remoteLink class="button" url="[action:'deletecarscan',id:car.id,params:[file:'passport2']]" onSuccess="reloadImage('passport2')">Удалить</g:remoteLink>
    </div>
  </fieldset>
</div>
</g:if>