<div id="ajax_wrap">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${searchresult.count}</div>
    <div class="fright">
      <g:paginate controller="carrier" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" offset="${inrequest.offset}" total="${searchresult.count}"/>
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
          <th>Кон-<br>тей-<br>нер</th>
          <th width="60">Дата<br>погрузки</th>
          <th width="100">Место<br>погрузки</th>
          <th width="60">Дата</th>
          <th width="100">Место</th>
          <th>Транспорт</th>
          <th>Статус<br>поездки</th>
          <th>Статус<br>монито-<br>ринга</th>
          <th>Статус<br>сдачи</th>
          <th>Дейст-<br>вия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="font-size:11px;line-height:15px">
          <td>${record.id}<br/>(${record.zakaz_id})</td>
          <td><abbr title="${Ztype.get(record?.ztype_id?:0)?.name?:''}">${record.ztype_id==1?'И':(record.ztype_id==2?'Э':'Т')}</abbr></td>
          <td><abbr title="${containers[record.container].name}">${containers[record.container].shortname}</abbr></td>
          <td>${String.format('%td.%<tm.%<tY', record.dateA)}</td>
          <td><g:if test="${record.terminal}">${terminals[record.terminal]}</g:if><g:else>${record.addressA}</g:else></td>
          <td>${String.format('%td.%<tm.%<tY', record.dateB)}</td>
          <td>${record.addressB}</td>
          <td align="left" style="padding-left:8px">
            Тягач: &nbsp;<font color="#0E66C8">${record.cargosnomer}</font><br/>
            Прицеп: &nbsp;<font color="#0E66C8">${record.trailnumber}</font><br/>
            Водитель: &nbsp;<font color="#0E66C8">${record.driver_fullname}</font>
            <g:if test="${record.containernumber1}"><br/>Контейнер1: &nbsp;<font color="#0E66C8" style="white-space:nowrap">${record.containernumber1}</font></g:if>
            <g:if test="${record.containernumber2}"><br/>Контейнер2: &nbsp;<font color="#0E66C8" style="white-space:nowrap">${record.containernumber2}</font></g:if>
          </td>
          <td><abbr title="${tripstatus[record.modstatus].descr}"><i class="icon-${tripstatus[record.modstatus].icon} icon-large"></i></abbr></td>
          <td><abbr title="${!record.imei?'тракер не привязан':record.trackstatus?'тракер доступен':'тракер недоступен'}"><i class="icon-${!record.imei?'off':record.trackstatus?'ok':'pause'} icon-large"></i></abbr></td>
          <td><abbr title="${taskstatus[record.taskstatus].descr}"><i class="icon-${taskstatus[record.taskstatus].icon} icon-large"></i></abbr></td>
          <td align="center" nowrap>
            <g:link action="tripdetails" id="${record.id}" class="button" title="Детали"><i class="icon-pencil"></i></g:link>
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
        prev="&lt;" next="&gt;" max="20" offset="${inrequest.offset}" total="${searchresult.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </span>
  </div>
</g:if>
</div>
