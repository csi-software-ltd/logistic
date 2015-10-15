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
          <th>Дата создания</th>
          <th>Email</th>
          <th>Имя</th>
          <th>Телефон</th>
          <th>Тип</th>
          <th>Статус</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center">
          <td>${record.id}</td>
          <td>${String.format('%tF',record.inputdate)}</td>
          <td align="left">${record.name}</td>
          <td align="left">${record.fullname}</td>
          <td align="left">${record.tels}</td>
          <td><abbr title="${record?.type_id==1?'грузоотправитель':(record?.type_id==2?'грузоперевозчик':'менеджер')}"><i class="icon-${record?.type_id==1?'suitcase':(record?.type_id==2?'truck':'male')} icon-large"></i></abbr></td>
          <td><abbr title="${record.modstatus==1?'активный':record.modstatus==0?'новый':'неактивный'}"><i class="icon-${record.modstatus==0?'eye-open':(record.modstatus==1?'ok':'remove')} icon-large"></i></abbr></td>
          <td>
            <a class="button" href="${g.createLink(action:'clientdetail',id:record.id)}" title="Редактировать"><i class="icon-pencil"></i></a>
            <g:if test="${record.isblocked}"><a class="button" href="javascript:void(0)" onclick="unblock(${record.id})" title="Разблокировать"><i class="icon-ok"></i></a></g:if>
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
