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
        <tr style="line-height:15px">
          <th>Код<br>(заказ)</th>
          <th>Кон-<br>тей-<br>нер</th>
          <th width="100">Место погрузки</th>
          <th>Транспорт</th>
          <th width="100">Место сдачи</th>
          <th width="100">Сток-букинг</th>
          <th width="60" nowrap>Дата, время<br>сдачи</th>
          <th>Статус<br>поездки</th>
          <th>Статус<br>сдачи</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="font-size:11px;line-height:15px;color:${record.is_readcurrier==0?'red':'#3e3e3e'}">
          <td>${record.id}<br>(${record.zakaz_id})</td>
          <td><abbr title="${containers[record.container].name}">${containers[record.container].shortname}</abbr></td>
          <td><g:if test="${record.terminal}">${terminals[record.terminal]}</g:if><g:else>${record.addressA}</g:else></td>
          <td align="left">
            Тягач: &nbsp;<font color="#0E66C8">${record.returncargosnomer}</font><br/>
            Водитель: &nbsp;<font color="#0E66C8" style="white-space:nowrap">${record.returndriver_fullname}</font>
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
          <td align="center" nowrap>
          <g:if test="${record.taskstatus!=4}">
            <g:link action="instructiondetails" id="${record.id}" class="button" title="${record.taskstatus in [0,1,3]&&record.modstatus in 0..1?'Запрос на сдачу':'Инструкция на сдачу'}"><i class="icon-${record.taskstatus in [0,1,3]&&record.modstatus in 0..1?'anchor':'info-sign'}"></i></g:link>
          </g:if><g:else>
            <a class="button disabled" title="Запрос на сдачу"><i class="icon-anchor"></i></a>            
          </g:else>
          <g:if test="${record.taskstatus in [2,4]&&record.modstatus in 0..1}">
            <g:link class="button" url="[controller:'carrier',action:'forward',id:record.id]" title="Переадресация"><i class="icon-exchange"></i></g:link>
          </g:if><g:else>
            <a class="button disabled" title="Переадресация"><i class="icon-exchange"></i></a>            
          </g:else>
          <g:if test="${record.taskstatus==2&&record.modstatus in 0..1}">
            <a class="button" title="Сдать контейнер" href="javascript:void(0)" onclick="confirmDelivery(${record.id})"><i class="icon-bookmark"></i></a>
          </g:if><g:else>
            <a class="button disabled" title="Сдать контейнер"><i class="icon-bookmark"></i></a>
          </g:else>
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
