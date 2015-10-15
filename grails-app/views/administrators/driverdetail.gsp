<g:formRemote class="contact-form" name="driverEdit_Form" url="[action:'saveDriverDetail']" method="post" onSuccess="processDriverEditResponse(e)" before="\$('driveredit_submit_button').disabled=true" after="\$('driveredit_submit_button').disabled=false">
  <div class="error-box p2" style="width:730px;margin-top:-20px;display:none">
    <span class="icon icon-warning-sign icon-3x"></span>
    <ul id="errordriverlist">
      <li></li>
    </ul>
  </div>
  <fieldset>
    <div class="grid_6 alpha">
      <label for="name">Имя:</label>
      <input type="text" id="driver_name" name="name" value="${driver?.name}" />
      <label for="driverfullname">ФИО:</label>
      <input type="text" id="driverfullname" name="fullname" value="${driver?.fullname}" />
      <label for="tel">Телефон:</label>
      <input type="text" id="tel" name="tel" value="${driver?.tel}" placeholder="например: +79111234567" />
      <label for="document_id">Тип документа:</label>
      <g:select name="document_id" value="${driver?.document_id}" keys="${[1]}" from="${['паспорт']}"/>
    </div>
    <div class="grid_6 omega">
      <label for="docseria">Серия:</label>
      <input type="text" id="docseria" name="docseria" value="${driver?.docseria}" />
      <label for="docnumber">Номер:</label>
      <input type="text" id="docnumber" name="docnumber" value="${driver?.docnumber}" />
      <label for="docuch">Кем выдан:</label>
      <input type="text" id="docuch" name="docuch" value="${driver?.docuch}" />
      <label for="docdata">Дата выдачи:</label>
      <g:datepicker class="data" name="docdata" value="${String.format('%td.%<tm.%<tY',driver?.docdata?:new Date())}" />
    </div>
    <div class="btns">
      <input type="submit" id="driveredit_submit_button" class="button" value="Сохранить" />
      <input type="reset" class="button" value="Отмена" onclick="jQuery('#driverEditForm').slideUp();"/>
    </div>
    <input type="hidden" name="driver_id" value="${driver?.id?:0}" />
    <input type="hidden" name="client_id" value="${client?.id}" />
  </fieldset>
</g:formRemote>
<g:if test="${driver}">
<div class="contact-form grid_6 alpha">
  <fieldset class="bord">
    <legend>Паспорт1</legend>
    <div id="upload_passport1" style="${driver?.is_passport1?'display:none':''}">
      <g:form name="dp1" method="post" url="${[action:'savescandriver',id:driver.id?:0]}" enctype="multipart/form-data" target="upload_target">
        <div class="error" id="error_passport1" style="display:none"></div>
        <label for="passport1" class="nopad">Загрузить скан:</label>
        <input type="file" name="passport1" size="23" accept="image/jpeg,image/png" onchange="startSubmit('dp1')"/>
      </g:form>
      <iframe id="upload_target" name="upload_target" src="#" style="width:0;height:0;border:0"></iframe>
    </div>
    <div id="result_passport1" style="${!(driver?.is_passport1)?'display:none':''}">
      <a class="button" href="${createLink(controller:'index',action:'showpicture',id:driver?.is_passport1,params:[code:Tools.generateModeParam(driver?.is_passport1)])}" target="_blank" id="viewscan_passport1">Посмотреть паспорт1</a>
      <g:remoteLink class="button" url="[action:'deletedriverscan',id:driver.id,params:[file:'passport1']]" onSuccess="reloadImage('passport1')">Удалить</g:remoteLink>
    </div>
  </fieldset>
</div>
<div class="contact-form grid_6 omega">
  <fieldset class="bord">
    <legend>Паспорт2</legend>
    <div id="upload_passport2" style="${driver?.is_passport2?'display:none':''}">
      <g:form name="dp2" method="post" url="${[action:'savescandriver',id:driver.id?:0]}" enctype="multipart/form-data" target="upload_target2">
        <div class="error" id="error_passport2" style="display:none"></div>
        <label for="passport2" class="nopad">Загрузить скан:</label>
        <input type="file" name="passport2" size="23" accept="image/jpeg,image/png" onchange="startSubmit('dp2')"/>
      </g:form>
      <iframe id="upload_target2" name="upload_target2" src="#" style="width:0;height:0;border:0"></iframe>
    </div>
    <div id="result_passport2" style="${!(driver?.is_passport2)?'display:none':''}">
      <a class="button" href="${createLink(controller:'index',action:'showpicture',id:driver?.is_passport2,params:[code:Tools.generateModeParam(driver?.is_passport2)])}" target="_blank" id="viewscan_passport2">Посмотреть паспорт2</a>
      <g:remoteLink class="button" url="[action:'deletedriverscan',id:driver.id,params:[file:'passport2']]" onSuccess="reloadImage('passport2')">Удалить</g:remoteLink>
    </div>
  </fieldset>
</div>
<div class="contact-form nopad grid_12 alpha">
  <fieldset class="bord">
    <legend>Права</legend>
    <div id="upload_prava" style="${driver?.is_prava?'display:none':''}">
      <g:form name="dpr" method="post" url="${[action:'savescandriver',id:driver.id?:0]}" enctype="multipart/form-data" target="upload_target3">
        <div class="error" id="error_prava" style="display:none"></div>
        <label for="prava" class="nopad">Загрузить скан:</label>
        <input type="file" name="prava" size="23" accept="image/jpeg,image/png" onchange="startSubmit('dpr')"/>
      </g:form>
      <iframe id="upload_target3" name="upload_target3" src="#" style="width:0;height:0;border:0"></iframe>
    </div>
    <div id="result_prava" style="${!(driver?.is_prava)?'display:none':''}">
      <a class="button" href="${createLink(controller:'index',action:'showpicture',id:driver?.is_prava,params:[code:Tools.generateModeParam(driver?.is_prava)])}" target="_blank" id="viewscan_prava">Посмотреть права</a>
      <g:remoteLink class="button" url="[action:'deletedriverscan',id:driver.id,params:[file:'prava']]" onSuccess="reloadImage('prava')">Удалить</g:remoteLink>
    </div>
  </fieldset>
</div>
</g:if>