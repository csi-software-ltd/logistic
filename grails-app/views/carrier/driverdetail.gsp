<g:formRemote class="contact-form" name="driverEdit_Form" url="[action:'saveDriverDetail']" method="post" onSuccess="processDriverEditResponse(e)">
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
      <label for="fullname">ФИО:</label>
      <input type="text" id="fullname" name="fullname" value="${driver?.fullname}" />
      <label for="tel">Телефон:</label>
      <input type="text" id="tel" name="tel" value="${driver?.tel}" />
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
      <input type="reset" class="button" value="Отмена" onclick="jQuery('#driverEditForm').slideUp();"/>
    </div>
    <input type="hidden" name="driver_id" value="${driver?.id?:0}" />
  </fieldset>
</g:formRemote>
<g:if test="${driver&&(driver.is_passport1||driver.is_passport2||driver.is_prava)}">
<div class="contact-form grid_12 alpha">
  <fieldset class="bord" style="width:924px;">
    <legend>Документы</legend>
    <a class="button" style="${!(driver?.is_passport1)?'display:none':''}" href="${createLink(controller:'index',action:'showpicture',id:driver?.is_passport1,params:[code:Tools.generateModeParam(driver?.is_passport1)])}" target="_blank">Посмотреть паспорт1</a>
    <a class="button" style="${!(driver?.is_passport2)?'display:none':''}" href="${createLink(controller:'index',action:'showpicture',id:driver?.is_passport2,params:[code:Tools.generateModeParam(driver?.is_passport2)])}" target="_blank">Посмотреть паспорт2</a>
    <a class="button" style="${!(driver?.is_prava)?'display:none':''}" href="${createLink(controller:'index',action:'showpicture',id:driver?.is_prava,params:[code:Tools.generateModeParam(driver?.is_prava)])}" target="_blank">Посмотреть права</a>
  </fieldset>
</div>
</g:if>