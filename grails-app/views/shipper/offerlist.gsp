<div id="ajax_wrap">
<g:if test="${searchresult.records}">
  <div style="padding:10px">
    <div class="fleft">Найдено: ${searchresult.count}</div>
    <div class="fright">
      <g:paginate controller="shipper" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </div>
    <div class="clear"></div>
  </div>
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr style="line-height:15px">
          <th>Код</th>
          <th>Тип</th>
          <th>Кон-<br>тей-<br>нер</th>
          <th>Кол-<br>во</th>
          <th>Дата<br>погрузки</th>
          <th width="90">Погрузка</th>
          <th width="90">Выгрузка</th>
          <th>Транспорт</th>
          <th>Действия</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${searchresult.records}" status="i" var="record">
        <tr align="center" style="font-size:11px;line-height:15px">
          <td>${record.id}</td>
          <td><abbr title="${Ztype.get(record?.ztype_id?:0)?.name?:''}">${record.ztype_id==1?'И':(record.ztype_id==2?'Э':'Т')}</abbr></td>
          <td><abbr title="${containers[record.container].name}">${containers[record.container].shortname}</abbr></td>
          <td>${record.zcol}</td>
          <td>${String.format('%tF', record.date_start)}</td>
          <td>${record.terminal?terminals[record.terminal]:record.city_start?:record.region_start}</td>
          <td>${record.terminal_end?terminals[record.terminal_end]:record.city_end?:record.region_end} ${record.address_end}</td>
          <td align="left">
          <g:each in="${zakazDrivers[record.id]}" var="it" status="j">
            Тягач: &nbsp;<font color="#0E66C8">${it.gosnomer}</font> -
            <g:if test="${it.carpassport1}"><a class="icon-file-text icon-dark icon-2x icon-fixed-width" href="${createLink(controller:'index',action:'showpicture',id:it.carpassport1,params:[code:Tools.generateModeParam(it.carpassport1)])}" target="_blank" title="тех.паспорт"></a></g:if>
            <g:if test="${it.carpassport2}"><a class="icon-file-text icon-dark icon-2x icon-fixed-width" href="${createLink(controller:'index',action:'showpicture',id:it.carpassport2,params:[code:Tools.generateModeParam(it.carpassport2)])}" target="_blank" title="тех.паспорт"></a></g:if>,&nbsp;
            Прицеп: &nbsp;<font color="#0E66C8">${it.trailnumber?:'нет'}</font> -
            <g:if test="${it.trailerpassport1}"><a class="icon-file-text icon-dark icon-2x icon-fixed-width" href="${createLink(controller:'index',action:'showpicture',id:it.trailerpassport1,params:[code:Tools.generateModeParam(it.trailerpassport1)])}" target="_blank" title="тех.паспорт"></a></g:if>
            <g:if test="${it.trailerpassport2}"><a class="icon-file-text icon-dark icon-2x icon-fixed-width" href="${createLink(controller:'index',action:'showpicture',id:it.trailerpassport2,params:[code:Tools.generateModeParam(it.trailerpassport2)])}" target="_blank" title="тех.паспорт"></a></g:if>,<br/>
            Водитель: &nbsp;<font color="#0E66C8">${it.fullname}</font> -
            <g:if test="${it.driverpassport1}"><a class="icon-file-text icon-dark icon-2x icon-fixed-width" href="${createLink(controller:'index',action:'showpicture',id:it.driverpassport1,params:[code:Tools.generateModeParam(it.driverpassport1)])}" target="_blank" title="паспорт"></a></g:if>
            <g:if test="${it.driverpassport2}"><a class="icon-file-text icon-dark icon-2x icon-fixed-width" href="${createLink(controller:'index',action:'showpicture',id:it.driverpassport2,params:[code:Tools.generateModeParam(it.driverpassport2)])}" target="_blank" title="паспорт"></a></g:if>
            <g:if test="${it.driverprava}"><a class="icon-file-text icon-dark icon-2x icon-fixed-width" href="${createLink(controller:'index',action:'showpicture',id:it.driverprava,params:[code:Tools.generateModeParam(it.driverprava)])}" target="_blank" title="права"></a></g:if>,&nbsp;
            Документы: &nbsp;<font color="#0E66C8">${it.docseria+' '+it.docnumber}</font>
            <g:if test="${(j+1)!=zakazDrivers[record.id].size()}"><hr style="background:none;border-top:1px dotted #E9E9E4;margin:5px 0"/></g:if>
          </g:each>
          </td>
          <td align="center" nowrap>
            <g:link action="offerdetails" id="${record.id}" class="button" title="Подтвердить"><i class="icon-ok"></i></g:link>
            <a href="javascript:void(0)" class="button" title="Отказать" onclick="declineOffer(${record.id})"><i class="icon-remove"></i></a>
          </td>          
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
  <div style="padding:10px">
    <span class="fleft">Найдено: ${searchresult.count}</span>
    <span class="fright">
      <g:paginate controller="shipper" action="${actionName}" params="${inrequest}" 
        prev="&lt;" next="&gt;" max="20" total="${searchresult.count}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </span>
  </div>
</g:if><g:else>
  <div style="padding:10px">
    <p><b>Новых предложений по погрузке нет. Для контроля доставки контейнеров используйте раздел мониторинга.</b></p>
  </div>
</g:else>
</div>