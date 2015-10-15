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
        <tr>
          <th>Тип</th>
          <th>Код</th>
          <th>Отправитель</th>
          <th>Число<br/>перевоз-<br/>чиков</th>
          <th>Кол-во</th>
          <th>Тип контей-<br/>нера</th>
          <th>Дата доставки</th>
          <th>Погрузка</th>
          <th>Выгрузка</th>
          <th>Ставка</th>
          <th>Актуально</th>
          <th>Статус</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="color:${record.modstatus==0?'red':record.modstatus<0?'#999':'#0E66C8'}">
          <td><abbr title="${Ztype.get(record?.ztype_id?:0)?.name?:''}">${record.ztype_id==1?'И':(record.ztype_id==2?'Э':'Т')}</abbr></td>
          <td>${record.id}</td>
          <td>${record.shippername?:'нет'}</td>
          <td>${record.carriercount}</td>
          <td>${record.zcol}</td>
          <td><abbr title="${containers[record.container].name}">${containers[record.container].shortname}</abbr></td>
          <td>${record.zdate?String.format('%tF', record.zdate):'не задана'}</td>
          <td>${record.terminal?terminals[record.terminal]:record.city_start}</td>
          <td>${record.terminal_end?terminals[record.terminal_end]:record.city_end?record.city_end+' '+record.address_end:record.region_end+' '+record.address_end}</td>
          <td>${record.price}</td>
          <td><g:if test="${actualtimes[record.id]<=0}"><abbr title="время истекло"><i class="icon-time icon-large"></i></abbr></g:if><g:else>${Tools.getDayString(actualtimes[record.id])}</g:else></td>
          <td><abbr title="${zakazstatus[record.modstatus].descr}"><i class="icon-${zakazstatus[record.modstatus].icon} icon-large"></i></abbr></td>
          <td nowrap>
            <g:link action="orderdetail" params="[copiedzakaz:record.id]" class="button" title="Создать копию"><i class="icon-copy"></i></g:link>
            <g:link action="orderdetail" id="${record.id}" class="button" title="Редактировать"><i class="icon-pencil"></i></g:link>
          <g:if test="${!record.route_id}">
            <g:link action="routedetail" params="[copiedzakaz:record.id]" class="button" title="Сохранить стандартный маршрут"><i class="icon-save"></i></g:link>
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
