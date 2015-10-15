<label for="driver_id" class="auto">Водитель:</label>
<g:select name="driver_id" optionKey="id" optionValue="name" class="auto" from="${drivers}" value="${driverId}" onchange="changeDriver(this.value)"/>
<label for="car_id" class="auto">Тягач:</label>
<g:select name="car_id" optionKey="id" optionValue="gosnomer" class="auto" from="${cars}" value="${carId}" onchange="changeCar(this.value)"/>
<label for="trailer_id" class="auto">Прицеп:</label>
<g:select name="trailer_id" optionKey="id" optionValue="trailnumber" class="auto" from="${trailers}" value="${trailerId}" onchange="changeTrailer(this.value)"/>
<label class="auto" for="timestart">Время погрузки с:</label>
<input type="text" class="mini" id="timestart" name="timestart" />
<label class="auto" for="timeend">до:</label>
<input type="text" class="mini" id="timeend" name="timeend"><br/>
<div class="clear"></div>
<g:if test="${routes}">
<div class="grid_11 alpha">
  <fieldset class="bord" style="width:856px">
    <legend>Автоматически подтверждать на эти стандартные маршруты:</legend>
  <g:each in="${routes}" var="route" status="i">
    <input type="checkbox" id="${route.shortname}" name="routes" value="${route.id}" checked="checked" />
    <label class="nopadd" for="${route.shortname}">${route.shortname} - ${Container.get(route.container)?.shortname} - ${route.weight1} т. - ${route.price_basic} руб.</label>
    <g:if test="${i%2&&i}"><br/></g:if>
  </g:each>
  </fieldset>
</div>
</g:if>
<div class="clear"></div>
<div class="btns">
  <input type="submit" id="submit_button" class="button" value="Сохранить" />
  <input type="reset" class="button" value="Отмена" onclick="jQuery('#freecarAddForm').slideUp();"/>
</div>