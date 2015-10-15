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
          <th>Дата создания</th>
          <th>Дата счета</th>
          <th>Дата передачи<br/>документов</th>
          <th>Компания отпр.</th>
          <th>Компания сист.</th>
          <th>Сумма</th>
          <th>Пункт назначения</th>
          <th>Статус</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="line-height:16px;color:${record.is_fix==1?'red':'#0E66C8'}">
          <td>${record.id}</td>
          <td>${record.norder}</td>
          <td>${String.format('%td.%<tm.%<ty', record.inputdate)}</td>
          <td>${String.format('%td.%<tm.%<ty', record.orderdate)}</td>
          <td>${record.docdate?String.format('%td.%<tm.%<ty', record.docdate):'-'}</td>
          <td>${Clientrequisites.get(record.clientcompany_id)?.payee}</td>
          <td>${syscompanies[record.syscompany_id]}</td>
          <td>${record.fullcost+record.idlesum+record.forwardsum}</td>
          <td>${record.destination}</td>
          <td><abbr title="${!record.modstatus?'новый':record.modstatus==1?'подтвержденный':'синхронизирован'}"><i class="icon-${!record.modstatus?'eye-open':record.modstatus==1?'refresh':'ok'} icon-large"></i></abbr></td>
          <td nowrap>
            <g:link action="payorderdetail" id="${record.id}" class="button" title="Редактировать"><i class="icon-pencil"></i></g:link>
          <g:if test="${!record.docdate}">
            <a class="button" title="Передать документы" href="javascript:void(0)" onclick="confirmDocument(${record.id},this)"><i class="icon-suitcase"></i></a>
          </g:if><g:else>
            <a class="button" title="Отменить передачу" href="javascript:void(0)" onclick="cancellConfirmDocument(${record.id},this)">
              <span class="icon-stack">
                <i class="icon-suitcase icon-stack-base icon-light"></i>
                <i class="icon-ban-circle" style="left:-2px;color:red;opacity:.7"></i>
              </span>
            </a>
          </g:else>
          <g:if test="${!record.is_act}">
            <a class="button" title="Акт" href="javascript:void(0)" onclick="confirmAct(${record.id},this)"><i class="icon-bookmark"></i></a>
          </g:if><g:else>
            <a class="button" title="Отменить акт" href="javascript:void(0)" onclick="cancellConfirmAct(${record.id},this)">
              <span class="icon-stack">
                <i class="icon-bookmark icon-stack-base icon-light"></i>
                <i class="icon-ban-circle" style="left:-2px;color:red;opacity:.7"></i>
              </span>
            </a>
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
      <g:paginate controller="administrators" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </span>
  </div>
</g:if>
</div>
