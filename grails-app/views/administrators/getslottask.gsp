  <g:if test="${terminal?.is_slot}"><br/>
    <label>Время:</label>
    <g:each in="${slot}" var="item">
      <input type="button" class="time" value="${item.name}" onclick="setSlotSelected('${item.id}',this)" />
    </g:each>
    <input type="hidden" id="taskslot" name="taskslot" value=""/>
  </g:if><g:else>
    <label class="auto" for="taskstart">Время с:</label>
    <input type="text" class="mini" id="taskstart" name="taskstart" value=""/>
    <label class="auto" for="taskend">до:</label>
    <input type="text" class="mini" id="taskend" name="taskend" value=""/>
  </g:else>
