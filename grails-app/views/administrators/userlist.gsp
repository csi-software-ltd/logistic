<div id="ajax_wrap">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${users.count}</div>
    <div class="fright">
      <g:paginate controller="administrators" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${users.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </div>
    <div class="clear"></div>
  </div>
<g:if test="${users.records}">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr>
          <th>Код</th>
          <th>Дата создания</th>
          <th>Код клиента</th>
          <th>Ник [пользователь]</th>
          <th>Email</th>
          <th>Компания</th>
          <th>Тип</th>
          <th>Статус</th>
          <th>Телефон</th>
          <th>Дата подтверж-дения условий</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${users.records}" status="i" var="record">
        <tr align="center" style="line-height:17px">
          <td>${record.id}</td>
          <td>${String.format('%tF',record.inputdate)}</td>
          <td>${record.client_id}</td>
          <td align="left">${record.nickname}<br/><font color="#1D95CB">${record.name}</font></td>
          <td align="left">${record.email}</td>
          <td>${record.company}</td>
          <td><abbr title="${record?.type_id==1?'грузоотправитель':(record?.type_id==2?'грузоперевозчик':'менеджер')}"><i class="icon-${record?.type_id==1?'suitcase':(record?.type_id==2?'truck':'male')} icon-large"></i></abbr></td>
          <td><abbr title="${record.modstatus==-1?'забанен':(record.modstatus==0?'неподтвержден':'активен')}"><i class="icon-${record.modstatus==-1?'trash':(record.modstatus==0?'eye-open':'ok')} icon-large"></i></abbr></td>
          <td>${record.tel?:''}</td>
          <td>${record.type_id==1?'не нужно':record.confirmtermdate?String.format('%tF %<tT',record.confirmtermdate):'нет'}</td>
          <td nowrap>
          <g:if test="${record.modstatus!=-1}">
            <a class="button" href="javascript:void(0)" onclick="setBan(${record.id},-1)" title="Забанить аккаунт"><i class="icon-trash"></i></a>
          </g:if><g:else>
            <a class="button" href="javascript:void(0)" onclick="setBan(${record.id},0)" title="Активировать"><i class="icon-ok"></i></a>
          </g:else>
            <a class="button" href="javascript:void(0)" onclick="loginAsUser(${record.id})" title="Войти под именем"><i class="icon-lock"></i></a>
            <a class="button" href="${g.createLink(action:'userdetail',id:record.id)}" title="Редактировать"><i class="icon-pencil"></i></a>
          </td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
  <div style="padding:10px">
    <div class="fleft">Найдено: ${users.count}</div>
    <div class="fright">
      <g:paginate controller="administrators" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${users.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </div>
  </div>
</g:if>
</div>
