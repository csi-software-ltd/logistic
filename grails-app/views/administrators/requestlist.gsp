<div id="ajax_wrap">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${searchresult.count}</div>
    <div class="fright">
      <g:paginate controller="administrators" action="${actionName}" params="${inrequest}" 
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
          <th rowspan="2">Код<br>(заказ)<br>конт<br>счет</th>
          <th rowspan="2">Грузо-<br>отправитель</th>          
          <th rowspan="2">Ставка<br>перев<br>(отпр)</th>
          <th rowspan="2">Дата<br>погруз</th>
          <th rowspan="2" width="80">Место<br>погрузки</th>
          <th rowspan="2" width="185">Транспорт</th>
          <th rowspan="2" width="90">Место сдачи,<br>cтокбукинг</th>
          <th rowspan="2">Дата,<br>время<br>сдачи</th>
          <th rowspan="2">Дата<br>сдачи<br>док-ов</th>
          <th colspan="2">Статус</th>
          <th rowspan="2">Дейст<br>-вия</th>
        </tr>
        <tr>
          <th>поезд</th>
          <th>сдачи</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="font-size:11px;line-height:16px">
          <td>
            <g:link action="tripdetail" id="${record.id}">${record.id}</g:link><br>
            (<g:link action="orderdetail" id="${record.zakaz_id}">${record.zakaz_id}</g:link>)<br>
            <abbr title="${containers[record.container].name}">${containers[record.container].shortname}</abbr><br>
            <g:if test="${payorders[record.id]?.norder}"><g:link action="findetail" id="${payorders[record.id].id}">${payorders[record.id].norder}</g:link></g:if><g:else>нет</g:else>
          </td>
          <td>${record.shippername}</td>          
          <td>${record.price}<br>(${record.price_sh})</td>
          <td>${String.format('%td.%<tm.%<ty',record.dateA)}</td>
          <td><g:if test="${record.terminal}">${terminals[record.terminal]}</g:if><g:else>${record.addressA}</g:else></td>
          <td align="left">
            Тягач: &nbsp;<font color="#0E66C8">${record.cargosnomer}</font><br/>
            Водитель: &nbsp;<font color="#0E66C8">${record.driver_fullname}</font><br/>
            Документы: &nbsp;<font color="#0E66C8">${record.docseria+' '+record.docnumber}</font><br/>
            Тел.: &nbsp;<font color="#0E66C8" style="white-space:nowrap"><g:join in="${(User.findAllByClient_idAndIs_am(record.carrier,1).collect{it.tel}-'').unique()}" delimiter=", "/></font><br/>
            Контейнер1: &nbsp;<font color="#0E66C8" nowrap>${record.containernumber1}</font>
            <g:if test="${record.containernumber2}"><br/>Контейнер2: &nbsp;<font color="#0E66C8" nowrap>${record.containernumber2}</font></g:if>
          </td>
          <td><g:if test="${record.taskterminal}">${terminals[record.taskterminal]}</g:if><g:else>${record.taskaddress?:'не задано'}</g:else><br><br>${record.stockbooking?:'место не задано'}</td>
          <td nowrap>
            <g:if test="${!record.taskstatus}">не задано</g:if>
            <g:else>${String.format('%td.%<tm.%<ty',record.taskdate)}<br/>${record.taskstart?' с '+record.taskstart:''}${record.taskend?' до '+record.taskend:''}</g:else>
          </td>
          <td nowrap>
            <g:if test="${!record.docdate}">не сданы</g:if><g:else>${String.format('%td.%<tm.%<ty',record.docdate)}</g:else>
          </td>
          <td><abbr title="${tripstatus[record.modstatus].descr}"><i class="icon-${tripstatus[record.modstatus].icon} icon-large"></i></abbr></td>
          <td><abbr title="${taskstatus[record.taskstatus].descr}"><i class="icon-${taskstatus[record.taskstatus].icon} icon-large"></i></abbr></td>
          <td>
            <g:link action="instructiondetails" id="${record.id}" class="button" title="Инструкция" style="margin-bottom:4px"><i class="icon-info-sign"></i></g:link><br/>
          <g:if test="${record.taskstatus==5}">
            <a class="button" title="Документы сданы" href="javascript:void(0)" onclick="confirmDocument(${record.id})"><i class="icon-suitcase"></i></a>
          </g:if><g:elseif test="${record.taskstatus==6}">
            <a class="button" title="Документы не сданы" onclick="cancellConfirmDocument(${record.id})"><i class="icon-undo"></i></a>
          </g:elseif>
          </td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
  <div style="padding:10px">
    <span class="fleft">Найдено: ${searchresult.count}</span>
    <span class="fright">
      <g:paginate controller="administrators" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </span>
  </div>
</g:if>
</div>
