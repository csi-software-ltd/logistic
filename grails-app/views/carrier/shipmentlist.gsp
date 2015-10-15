<div id="ajax_wrap">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${searchresult.count}</div>
    <div class="fright">
      <g:paginate controller="carrier" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </div>
    <div class="clear"></div>
  </div>
<g:if test="${searchresult.records}">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr style="line-height:14px">
          <th>Код<br>(заказ)</th>
          <th>Тип</th>
          <th>Контейнер</th>
          <th>Транспорт</th>
          <th width="60">Дата<br>погрузки</th>
          <th>Место погрузки</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="font-size:11px;line-height:15px">
          <td>${record.id}<br/>(${record.zakaz_id})</td>
          <td><abbr title="${Ztype.get(record?.ztype_id?:0)?.name?:''}">${record.ztype_id==1?'И':(record.ztype_id==2?'Э':'Т')}</abbr></td>
          <td><abbr title="${containers[record.container].name}">${containers[record.container].shortname}</abbr></td>
          <td align="left" style="padding-left:8px">
            Тягач: &nbsp;<font color="#0E66C8">${record.cargosnomer}</font><br/>
            Прицеп: &nbsp;<font color="#0E66C8">${record.trailnumber}</font><br/>
            Водитель: &nbsp;<font color="#0E66C8">${record.driver_fullname}</font>
            <g:if test="${record.containernumber1}"><br/>Контейнер1: &nbsp;<font color="#0E66C8" style="white-space:nowrap">${record.containernumber1}</font></g:if>
            <g:if test="${record.containernumber2}"><br/>Контейнер2: &nbsp;<font color="#0E66C8" style="white-space:nowrap">${record.containernumber2}</font></g:if>
          </td>
          <td>${String.format('%td.%<tm.%<tY', record.dateA)}<br/>${record.timestartA?' с '+record.timestartA:''}${record.timeendA?' до '+record.timeendA:''}</td>
          <td><g:if test="${record.terminal}">${terminals[record.terminal]}</g:if><g:else>${record.addressA}</g:else><g:if test="${record.doc}"><br/>Документы: &nbsp;<font color="#0E66C8">${record.doc}</font></g:if></td>
          <td>
            <g:if test="${record.modstatus in 0..1}"><a class="button" title="Отменить погрузку" href="javascript:void(0)" onclick="cancelTrip(${record.id})"><i class="icon-trash"></i></a></g:if><g:else><a class="button disabled" title="Отменить погрузку"><i class="icon-trash"></i></a></g:else>
          </td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
  <div style="padding:10px">
    <span class="fleft">Найдено: ${searchresult.count}</span>
    <span class="fright">
      <g:paginate controller="carrier" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </span>
  </div>
</g:if>
</div>
