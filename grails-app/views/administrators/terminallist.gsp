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
        <tr>
          <th>Код</th>
          <th>Имя</th>
          <th>Адрес</th>
          <th>Сайт</th>
          <th>Главный</th>
          <th>Статус</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr>
          <td align="center">${record.id}</td>
          <td>${record.name}</td>
          <td>${record.address}</td>
          <td><a href="${record.infourl}" target="_blank">${record.infourl}</a></td>
          <td align="center">${record.is_main?'Да':'Нет'}</td>
          <td align="center"><i class="icon-${record.modstatus?'ok':'remove'}" title="${record.modstatus?'активен':'не активен'}"></i></td>
          <td align="center"><a class="button" href="${g.createLink(action:'terminaldetail',id:record.id)}" title="Редактировать"><i class="icon-pencil"></i></a></td>
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
