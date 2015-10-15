<label for="driver_id">Водитель:</label>
<g:select name="driver_id" optionKey="id" optionValue="name" class="auto" from="${drivers}" value="${driverId}" onchange="changeDriver(this.value)"/>
<label for="car_id" class="auto">Тягач:</label>
<g:select name="car_id" optionKey="id" optionValue="gosnomer" class="auto" from="${cars}" value=""/>
