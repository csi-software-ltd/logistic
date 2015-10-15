<div id="ajax_wrap">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${searchresult.size()}</div>    
    <div class="clear"></div>
  </div>
<g:if test="${searchresult}">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr>
          <th>Название</th>
          <th>ИНН</th>
          <th>Тип</th>
          <th>НДС</th>
          <th>Действия</th>          
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult}" status="i" var="record">
        <tr align="center">
          <td align="left">${record.name}</td>
          <td>${record.inn}</td>
          <td>${(record.ctype_id==1)?'ООО':((record.ctype_id==2)?'ИП':'ЗАО')}</td>
          <td>${record.nds}</td>
          <td>          
            <a class="button" title="Редактировать" href="${g.createLink(action:'syscompanydetail',id:record.id)}" style="margin-bottom:4px"><i class="icon-pencil"></i></a>      
            <a class="button" title="${record?.modstatus?'Деактивировать':'Активировать'}" href="javascript:void(0)" onclick="setActive(${record?.id},${record?.modstatus?0:1})"><i class="icon-${record?.modstatus?'trash':'ok'}"></i></a>
          </td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div> 
</g:if>
</div>
