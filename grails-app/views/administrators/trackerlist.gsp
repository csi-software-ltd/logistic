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
          <th>IMEI</th>
          <th>Учетный номер</th>
          <th>Госномер</th>
          <th>Код клиента</th>
          <th>Телефон</th>
          <th>Статус</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="vertical-align:middle">
          <td>${record.id}</td>
          <td>${record.imei}</td>
          <td>${record.trackaccount}</td>
          <td>${record.gosnomer?:''}</td>
          <td>
            <g:if test="${record.client_id?:0}">
              <g:link action="clientdetail" id="${record.client_id}">${record.client_id}</g:link>
            </g:if><g:else>нет</g:else>
          </td>
          <td>${record.tel}</td>
          <td><i class="icon-${record.modstatus==1?'ok':record.modstatus==0?'remove':record.modstatus==2?'refresh':'trash'} icon-large" title="${record.modstatus==1?'активный':record.modstatus==0?'неактивный':record.modstatus==2?'в ремонте':'списан'}"></i></td>
          <td><a class="button" href="${g.createLink(action:'trackerdetail',id:record.id)}" title="Редактировать"><i class="icon-pencil"></i></a></td>
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
