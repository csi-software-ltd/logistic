  <g:if test="${terminal?.is_slot}"><br/>
    <label for="slotlist">Время:</label>  
    <g:each in="${slot}" var="item" status="i">
      <input id="slot_start_${item.id}" type="button" class="time" value="${item.name}" onclick="setSlotList('${item.id}');toggleButton(this);${slot.size()==i+1?'updateDate()':''}" />
    </g:each>
    <input type="hidden" id="slotlist" name="slotlist" value=""/>   
    <input type="hidden" name="is_slotlist" value="1"/>
  </g:if><g:else>
    <label class="auto" for="slot_start">Время с:</label>
    <input type="text" class="mini" id="slot_start" name="slot_start" value=""/>
    <label class="auto" for="slot_end">до:</label>
    <input type="text" class="mini" id="slot_end" name="slot_end" value=""/>
  </g:else>


