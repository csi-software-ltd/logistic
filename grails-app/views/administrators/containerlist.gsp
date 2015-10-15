<div id="ajax_wrap">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${containers.count}</div>
    <div class="fright">
      <g:paginate controller="administrators" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${containers.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </div>
    <div class="clear"></div>
  </div>  
<g:if test="${containers.records}">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr>
          <th>Код</th>
          <th>Название</th>
          <th>Сокр. название</th>
          <th>Изображение</th>
          <th>Тип</th>
          <th>Длина</th>
          <th>Ширина</th>
          <th>Высота</th>
          <th>Грузоподъемность</th>
          <th>Главный</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${containers.records}" status="i" var="record">
        <tr align="center">
          <td>${record.id}</td>
          <td align="left">${record.name}</td>
          <td>${record.shortname}</td>
          <td>${record.picture}</td>
          <td>${ctype.find{it.id==record.ctype_id}?.sname}</td>
          <td>${record.length}</td>
          <td>${record.width}</td>
          <td>${record.hight}</td>
          <td>${record.capacity}</td>
          <td><g:if test="${record.is_main}"><i class="icon-ok" title="Да"></i></g:if></td>
          <td><a class="button" href="${g.createLink(action:'containerdetail',id:record.id)}" title="Редактировать"><i class="icon-pencil"></i></a></td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
  <div style="padding:10px">
    <span class="fleft">Найдено: ${containers.count}</span>
    <span class="fright">
      <g:paginate controller="administrators" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${containers.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </span>
  </div>
</g:if>
</div>
