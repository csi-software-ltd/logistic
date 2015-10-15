<div id="ajax_wrap">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${count}</div>
    <div class="fright">
      <g:paginate controller="administrators" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${count}" offset="${inrequest.offset}"/>
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
<g:each in="${searchresult.records}" var="item" status="i">
  addplacemark(${item.x},${item.y},'${String.format('%tF %<tT', item?.tracktime)}',${item.kurs},${item.speed},${Tracker.findWhere(imei:item.imei)?.id?:0},'${cars[i]?.gosnomer?:''}');
</g:each>
  var bBounds=1;  
  <g:if test="${inrequest.param}">  
    bBounds=0;    
  </g:if>  
  <g:else>
    firstMapResize=0;    
  </g:else>
  renderplacemark(bBounds);
</script>
