<label for="driver_id" class="auto">Водитель:</label>
<g:select name="driver_id" optionKey="id" optionValue="name" class="auto" from="${drivers}" value="${driverId}" onchange="changeDriver(this.value)"/>
<label for="car_id" class="auto">Тягач:</label>
<g:select name="car_id" optionKey="id" optionValue="gosnomer" class="auto" from="${cars}" value="${carId}" onchange="changeCar(this.value)"/>
<label for="trailer_id" class="auto">Прицеп:</label>
<g:select name="trailer_id" optionKey="id" optionValue="trailnumber" class="auto" from="${trailers}" value="${trailerId}" onchange="changeTrailer(this.value)"/>
<label for="zcol" class="auto">Кол-во контейнеров:</label>
<g:select name="zcol" class="auto" from="${1..(zcol<3?zcol:2)}"/>
<div class="btns">
  <input type="submit" id="submit_button" class="button" value="Сохранить" />
  <input type="reset" class="button" value="Отмена" onclick="jQuery('#driverAddForm').slideUp();"/>
</div>
