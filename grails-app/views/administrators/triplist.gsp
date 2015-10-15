<div id="ajax_wrap">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${searchresult.count}</div>
    <div class="fright">
      <g:paginate controller="administrators" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}" offset="${inrequest.offset}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </div>
    <div class="clear"></div>
  </div>  
<g:if test="${searchresult.records}">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr style="line-height:14px">
          <th>Код<br>(заказ)</th>
          <th>Тип</th>
          <th>Отправитель</th>
          <th>Перевозчик</th>
          <th>Транспорт</th>
          <th>Статус<br>поездки</th>
          <th>Статус<br>монито-<br>ринга</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="line-height:16px;color:${record.modstatus==0?'red':record.modstatus<0?'#999':'#0E66C8'}">
          <td>${record.id}(<g:link action="orderdetail" id="${record.zakaz_id}">${record.zakaz_id}</g:link>)</td>
          <td><abbr title="${ztypes[record.ztype_id]}">${record.ztype_id==1?'И':(record.ztype_id==2?'Э':'Т')}</abbr></td>
          <td>${record.shippername?:'нет'}</td>
          <td>${record.carriername?:'нет'}</td>
          <td align="left">
            Тягач: &nbsp;<font color="#0E66C8">${record.cargosnomer}</font><br/>
            Водитель: &nbsp;<font color="#0E66C8" style="white-space:nowrap">${record.driver_fullname}</font><br/>
            Документы: &nbsp;<font color="#0E66C8">${record.docseria+' '+record.docnumber}</font><br/>
            Тел.: &nbsp;<font color="#0E66C8"><g:join in="${(User.findAllByClient_idAndIs_am(record.carrier,1).collect{it.tel}-'').unique()}" delimiter=", "/></font><br/>
            Контейнер1: &nbsp;<font color="#0E66C8" style="white-space:nowrap">${record.containernumber1}</font>
            <g:if test="${record.containernumber2}"><br/>Контейнер2: &nbsp;<font color="#0E66C8" style="white-space:nowrap">${record.containernumber2}</font></g:if>
          </td>
          <td><abbr title="${tripstatus[record.modstatus].descr}"><i class="icon-${tripstatus[record.modstatus].icon} icon-large"></i></abbr></td>
          <td><abbr title="${!record.imei?'тракер не привязан':record.trackstatus?'тракер доступен':'тракер недоступен'}"><i class="icon-${!record.imei?'off':record.trackstatus?'ok':'pause'} icon-large"></i></abbr></td>
          <td nowrap>
            <g:link action="tripdetail" id="${record.id}" class="button" title="Редактировать"><i class="icon-pencil"></i></g:link>
          <g:if test="${record.payorder_id==0&&record.modstatus>-1}">
            <g:remoteLink class="button" url="[action:'generateorder',id:record.id]" title="Сформировать счет" onSuccess="initialize(0)"><i class="icon-copy"></i></g:remoteLink>
          </g:if>
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
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}" offset="${inrequest.offset}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </span>
  </div>
</g:if>
</div>
