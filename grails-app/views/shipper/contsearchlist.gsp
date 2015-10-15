<div id="ajax_wrap">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${searchresult.count}</div>
    <div class="fright">
      <g:paginate controller="shipper" action="${actionName}" params="${[cont:cont]}" 
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
          <th>Заказ</th>
          <th>Поездка</th>
          <th>Дата</th>
          <th>Контейнер</th>
          <th>Транспорт</th>
          <th>Статус<br>заказа</th>
          <th>Статус<br>поездки</th>
          <th>Статус<br>сдачи</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="font-size:11px;line-height:15px">
          <td><g:link action="order" id="${record.zakaz_id}">${record.zakaz_id}</g:link></td>
          <td><g:link action="tripdetails" id="${record.id}">${record.id}</g:link></td>
          <td>${String.format('%tF',record.inputdate)}</td>
          <td><abbr title="${containers[record.container].name}">${containers[record.container].shortname}</abbr></td>
          <td align="left" nowrap>
            Тягач: &nbsp;<font color="#0E66C8">${record.returncargosnomer}</font><br/>
            Водитель: &nbsp;<font color="#0E66C8">${record.returndriver_fullname}</font><br/>
            Документы вод.: &nbsp;<font color="#0E66C8">${record.docseria+' '+record.docnumber}</font><br/>
            Контейнер1: &nbsp;<font color="#0E66C8" style="white-space:nowrap">${record.containernumber1}</font>
            <g:if test="${record.containernumber2}"><br/>Контейнер2: &nbsp;<font color="#0E66C8" style="white-space:nowrap">${record.containernumber2}</font></g:if>
          </td>
          <td><abbr title="${zakazstatus[record.zakazstatus].descr}"><i class="icon-${zakazstatus[record.zakazstatus].icon} icon-large"></i></abbr></td>
          <td><abbr title="${tripstatus[record.modstatus].descr}"><i class="icon-${tripstatus[record.modstatus].icon} icon-large"></i></abbr></td>
          <td><abbr title="${taskstatus[record.taskstatus].descr}"><i class="icon-${taskstatus[record.taskstatus].icon} icon-large"></i></abbr></td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
  <div style="padding:10px">
    <span class="fleft">Найдено: ${searchresult.count}</span>
    <span class="fright">
      <g:paginate controller="shipper" action="${actionName}" params="${[cont:cont]}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </span>
  </div>
</g:if>
</div>
