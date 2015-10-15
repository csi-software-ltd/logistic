<div id="ajax_wrap">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${searchresult.count}</div>
    <div class="fright">
      <g:paginate controller="shipper" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}" offset="${inrequest.offset}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </div>
    <div class="clear"></div>
  </div>  
<g:if test="${searchresult.records}">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr>
          <th>Код</th>
          <th>Заказ</th>
          <th>Перевозчик</th>
          <th>Время</th>
          <th>Тип события</th>
          <th>Иконка</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="font-size:11px;${tripeventtype[record.type_id].significance?'color:red':''}">
          <td><g:link action="tripdetails" id="${record.trip_id}" title="Детали">${record.trip_id}</g:link></td>
          <td><g:link action="order" id="${record.zakaz_id}">${record.zakaz_id}</g:link></td>
          <td>${record.driver_fullname}</br>${record.cargosnomer}</td>
          <td>${String.format('%td.%<tm.%<tY %<tT', record.eventdate)}</td>
          <td>${tripeventtype[record.type_id].descr}</td>
          <td><i class="icon-${tripeventtype[record.type_id].icon} icon-large" title="${tripeventtype[record.type_id].descr}"></i></td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
  <div style="padding:10px">
    <span class="fleft">Найдено: ${searchresult.count}</span>
    <span class="fright">
      <g:paginate controller="shipper" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}" offset="${inrequest.offset}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </span>
  </div>
</g:if>
</div>