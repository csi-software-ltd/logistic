<div id="ajax_wrap">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${searchresult.count}</div>
    <div class="fright">
      <g:paginate controller="administrators" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}" offset="${inrequest.offset}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </div>
    <div class="clear"></div>
  </div>  
<g:if test="${searchresult.records}">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr style="line-height:15px">
          <th>Иконка</th>
          <th>Код<br/>(заказ)</th>
          <th>Отправитель</th>
          <th>Перевозчик</th>
          <th>Водитель</th>
          <th>Тягач</th>
          <th>Событие</th>
          <th>Время</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="line-height:15px;color:${tripeventtype[record.type_id].significance?'red':'#0E66C8'}">
          <td><i class="icon-${tripeventtype[record.type_id].icon} icon-large" title="${tripeventtype[record.type_id].descr}"></i></td>
          <td>${record.trip_id}<br/>(${record.zakaz_id})</td>
          <td>${record.shippername?:'нет'}</td>
          <td>${record.carriername?:'нет'}</td>
          <td>${record.driver_fullname}</td>
          <td>${record.cargosnomer}</td>
          <td>${tripeventtype[record.type_id].descr}</td>
          <td>${String.format('%td.%<tm.%<tY %<tT', record.eventdate)}</td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
  <div style="padding:10px">
    <span class="fleft">Найдено: ${searchresult.count}</span>
    <span class="fright">
      <g:paginate controller="administrators" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}" offset="${inrequest.offset}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </span>
  </div>
</g:if>
</div>
