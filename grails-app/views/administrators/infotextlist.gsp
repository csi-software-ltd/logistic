<div id="ajax_wrap">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${count}</div>
    <div class="fright">
      <g:paginate controller="administrators" prev="&lt;" next="&gt;"
        action="${actionName}" max="20" params="${params}"
        total="${count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </div>
    <div class="clear"></div>
  </div>
<g:if test="${records}">
  <div id="resultList">  
    <table class="list" width="100%" cellpadding="0" cellspacing="0">
      <thead>
        <tr>
        <g:if test="${inrequest.id!=1}">
          <th>Код</th>
          <th>Заголовок</th> 
          <th>Контроллер</th>		
          <th>Экшен</th>
          <th>Дата модификац.</th>                  
        </g:if><g:else>
          <th>Код</th>
          <th>Экшен</th>
          <th>Название</th>
          <th>Тема письма</th>
        </g:else>
          <th>Действия</th>
        </tr>        
      </thead>
      <tbody>
      <g:each in="${records}" status="i" var="record">
        <tr align="center" style="vertical-align:middle">
          <td>${record.id}</td>
        <g:if test="${inrequest.id!=1}">
          <td align="left">${record.name}</td>
          <td>${record.controller}</td>
          <td>${record.action}</td>
          <td>${String.format('%td.%<tm.%<tY',record.moddate)}</td>
          <td><a class="button" href="${g.createLink(action:'infotextedit',id:record.id)}" title="Редактировать"><i class="icon-pencil"></i></a></td>
        </g:if><g:else>
          <td>${record.action}</td>
          <td>${record.name}</td>          
          <td>${record.title}</td>
          <td><a class="button" href="${g.createLink(action:'infotextedit',id:record.id,params:[type:'1'])}" title="Редактировать"><i class="icon-pencil"></i></a></td>
        </g:else>
        </tr>
      </g:each>
      </tbody>
    </table>    
  </div>
  <div style="padding:10px">
    <div class="fleft">Найдено: ${count}</div>
    <div class="fright">
      <g:paginate controller="administrators" prev="&lt;" next="&gt;"
        action="${actionName}" max="20" params="${params}"
        total="${count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </div>
  </div>  
</g:if>
</div>
