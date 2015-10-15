<div id="ajax_wrap">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${searchcount}</div>
    <div class="fright">
      <g:paginate controller="administrators" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchcount}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </div>
    <div class="clear"></div>
  </div>
<g:if test="${searchresult}">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr style="line-height:14px">
          <th width="60">Дата</th>
          <th>Автор<br>Email, Телефон</th>
          <th>Сообщение</th>
          <th>IP-адрес</th>
          <th>Статус</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult}" status="i" var="record">
        <tr align="center" style="font-size:11px;line-height:16px">
          <td nowrap>${String.format('%td.%<tm.%<ty %<tH:%<tM',record.inputdate)}</td>
          <td align="left"><b>${record.name}</b><br/>${record.email?record.email+', ':''}${record.tel}</td>
          <td align="left">${record.message}</td>
          <td>${record.ip}</td>
          <td><abbr title="${record.modstatus?'Прочитана':'Непрочитана'}"><i class="icon-${record.modstatus?'ok':'eye-open'} icon-large"></i></abbr></td>
          <td>
            <g:if test="${!record.modstatus}"><a class="button" title="Прочитать" href="javascript:void(0)" onclick="readmessage(${record.id})" style="margin-bottom:4px"><i class="icon-ok"></i></a><br/></g:if>
            <a class="button" title="Удалить" href="javascript:void(0)" onclick="deletemessage(${record.id})"><i class="icon-trash"></i></a>
          </td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
  <div style="padding:10px">
    <span class="fleft">Найдено: ${searchcount}</span>
    <span class="fright">
      <g:paginate controller="administrators" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchcount}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </span>
  </div>
</g:if>
</div>
