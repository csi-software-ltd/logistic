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
        <tr style="line-height:15px">
          <th>Код<br>(заказ)<br/>счет</th>
          <th>Кон-<br>тей-<br>нер</th>
          <th width="100">Место погрузки</th>
          <th>Транспорт</th>
          <th width="100">Место сдачи</th>
          <th width="100">Сток-букинг</th>
          <th nowrap>Дата, время<br>сдачи</th>
          <th>Статус<br>поездки</th>
          <th>Статус<br>сдачи</th>
          <th>Дейст-<br>вия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="font-size:11px;line-height:15px;color:${record.taskstatus in [1,3,4]?'red':(record.taskstatus==0?'#999':'#3e3e3e')}">
          <td>${record.id}<br>(<g:link action="order" id="${record.zakaz_id}">${record.zakaz_id}</g:link>)<br/>${norders[record.id]?:'нет'}</td>
          <td><abbr title="${containers[record.container].name}">${containers[record.container].shortname}</abbr></td>
          <td><g:if test="${record.terminal}">${terminals[record.terminal]}</g:if><g:else>${record.addressA}</g:else></td>
          <td align="left">
            Тягач: &nbsp;<font color="#0E66C8">${record.returncargosnomer}</font><br/>
            Водитель: &nbsp;<font color="#0E66C8">${record.returndriver_fullname}</font><br/>
            Документы: &nbsp;<font color="#0E66C8">${record.docseria+' '+record.docnumber}</font>
            <g:if test="${record.containernumber1}"><br/>Контейнер1: &nbsp;<font color="#0E66C8" style="white-space:nowrap">${record.containernumber1}</font></g:if>
            <g:if test="${record.containernumber2}"><br/>Контейнер2: &nbsp;<font color="#0E66C8" style="white-space:nowrap">${record.containernumber2}</font></g:if>
          </td>
          <td><g:if test="${record.taskterminal}">${terminals[record.taskterminal]}</g:if><g:else>${record.taskaddress?:'не задано'}</g:else></td>
          <td>${record.stockbooking?:'не задано'}</td>
          <td>
            <g:if test="${!record.taskstatus}">не задано</g:if><g:else>${String.format('%td.%<tm.%<tY',record.taskdate)}<br/>${record.taskstart?' с '+record.taskstart:''}${record.taskend?' до '+record.taskend:''}</g:else>
          </td>
          <td><abbr title="${tripstatus[record.modstatus].descr}"><i class="icon-${tripstatus[record.modstatus].icon} icon-large"></i></abbr></td>
          <td><abbr title="${taskstatus[record.taskstatus].descr}"><i class="icon-${taskstatus[record.taskstatus].icon} icon-large"></i></abbr></td>
          <td>
            <g:link action="instructiondetails" id="${record.id}" class="button" title="Инструкция"><i class="icon-info-sign"></i></g:link>
          </td>
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
