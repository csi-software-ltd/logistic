<div id="ajax_wrap">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${searchresult.count}</div>
    <div class="fright">
      <g:paginate controller="carrier" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}" offset="${inrequest.offset}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </div>
    <div class="clear"></div>
  </div>  
<g:if test="${searchresult.records}">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr style="line-height:15px">
          <th>Код</th>
          <th>Тип</th>
          <th>Контейнер</th>
          <th>Кол-во</th>
          <th>Дата погрузки</th>
          <th>Место погрузки</th>
          <th>Место выгрузки</th>
          <th>Ставка</th>
          <th>Актуально</th>
          <th>Статус</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="font-size:11px;line-height:15px;color:${record.modstatus==0?'red':record.modstatus<0?'#999':'#0E66C8'}">
          <td>${record.zakaz_id}</td>
          <td><abbr title="${Ztype.get(record?.ztype_id?:0)?.name?:''}">${record.ztype_id==1?'И':(record.ztype_id==2?'Э':'Т')}</abbr></td>
          <td><abbr title="${Container.get(record.container?:0)?.name?:''}">${containers[record.container].shortname}</abbr></td>
          <td>${record.zcol}</td>
          <td>${String.format('%tF', record.date_start)}</td>
          <td>${record.terminal?terminals[record.terminal]:record.city_start?:record.region_start}</td>
          <td>${record.terminal_end?terminals[record.terminal_end]:record.city_end?:record.region_end}</td>
          <td>${record.cprice}</td>
          <td><g:if test="${!record.remindtime}"><abbr title="время истекло"><i class="icon-time icon-large"></i></abbr></g:if><g:else>${String.format('%tT',new Date((record.remindtime-60*180)*1000))}</g:else></td>
          <td>
            <abbr title="${record.modstatus==0?'новый':record.modstatus==1?'акцепт':record.modstatus==-1?'отказ':record.modstatus==-2?'архив':'назначен'}">
              <i class="icon-${record.modstatus==0?'eye-open':record.modstatus==1?'flag':record.modstatus==-1?'trash':record.modstatus==-2?'archive':'suitcase'} icon-large"></i>
            </abbr>
          </td>
          <td nowrap>
            <g:link action="orderdetails" id="${record.id}" class="button" title="Детали"><i class="icon-pencil"></i></g:link>
          </td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
  <div style="padding:10px">
    <span class="fleft">Найдено: ${searchresult.count}</span>
    <span class="fright">
      <g:paginate controller="carrier" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </span>
  </div>
</g:if>
</div>
