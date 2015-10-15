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
          <th>Код</th>
          <th>Счет</th>
          <th>Клиент</th>
          <th>Плательщик</th>
          <th>Назначение</th>
          <th>№ платежки</th>
          <th>Дата платежа</th>
          <th>Сумма</th>
          <th>Корректировка</th>
          <th>Статус</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="line-height:16px;color:${!record.modstatus?'red':record.modstatus==1?'#3e3e3e':'#0E66C8'}">
          <td>${record.id}</td>
          <td>${record.norder}</td>
          <td>${clientnames[record.client_id]}</td>
          <td>${record.platname}</td>
          <td>${record.platcomment}</td>
          <td>${record.platnumber}</td>
          <td>${String.format('%td.%<tm.%<tY', record.paydate)}</td>
          <td>${record.summa}</td>
          <td>${record.is_fix?'да':'нет'}</td>
          <td><abbr title="${!record.modstatus?'нераспознанный':record.modstatus==1?'квитанция':'подтвержденный'}"><i class="icon-${!record.modstatus?'question-sign':record.modstatus==1?'exclamation':'ok'} icon-large"></i></abbr></td>
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
