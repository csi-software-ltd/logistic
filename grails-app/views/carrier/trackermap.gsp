<div id="ajax_wrap">
  <div class="fright" style="padding:5px 10px">
    Найдено машин: ${cars.size()}, отображено тракеров: ${trackers_count}
  </div>
</div>
<script type="text/javascript">
  if (!map) {
    renderMap();
  };
  clearMap()
  <g:each in="${tracking}" var="item" status="i">
    <g:if test="${item}"> 
      addplacemark(${item.x},${item.y},'${String.format('%tF %<tT', item?.tracktime)}',${item.kurs},${item.speed},'${cars[i]?.gosnomer?:''}');
    </g:if>
  </g:each>    
  renderplacemark();
</script>
