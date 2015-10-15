<div id="ajax_wrap">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${mapresult.size()}</div>
    <div class="fright">
      <g:paginate controller="administrators" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="50" total="${searchresult.count}" offset="${inrequest.offset}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </div>
    <div class="clear"></div>
  </div>
</div>
<script type="text/javascript">
  if (!map) {
    renderMap();
  };
  clearMap()
<g:each in="${mapresult}">
  addplacemark(${it.x},${it.y},'${String.format('%tF %<tT', it?.tracktime)}',${it.kurs},${it.speed},${it.trip_id},"${Trip.get(it.trip_id?:0)?.cargosnomer?:''}","${Driver.get(Trip.get(it.trip_id?:0)?.driver_id?:0)?.name?:''}")
</g:each>
  renderplacemark()
</script>