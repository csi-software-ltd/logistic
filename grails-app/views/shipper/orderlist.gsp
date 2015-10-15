<div id="ajax_wrap">
  <div style="padding:10px">
    <span class="fleft">Найдено: ${data?.count}</span>
    <span class="fright">
      <g:paginate controller="shipper" prev="&lt;&lt;" next="&gt;&gt;"
        action="${actionName}" max="20" params="${inrequest}"
        total="${data?.count}" offset="${inrequest.offset}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </span>
    <div class="clear"></div>
  </div>
<g:if test="${data?.records}">
  <div id="resultList">  
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr style="line-height:15px">
          <th>Код</th>
          <th>Тип</th>
          <th>Кон-<br>тей-<br>нер</th>         
          <th>Кол-<br>во</th>          
          <th>Дата заказа</th>     
          <th nowrap>Место погрузки</th>
          <th nowrap>Место затарки</th>
          <th nowrap>Место выгрузки</th>
          <th>Ставка</th>
          <th>Актуально</th>
          <th>Статус</th>              
          <th>Действия</th> 
        </tr>
      </thead>
      <tbody>
      <g:each in="${data?.records}" var="item" status="i">
        <tr align="center" style="font-size:11px;line-height:15px;color:${item.modstatus==1?'red':item.modstatus<0?'#999':'#0E66C8'}">
          <td>${item?.id?:0}</td>
          <td><abbr title="${Ztype.get(item?.ztype_id?:0)?.name?:''}">${item.ztype_id==1?'И':(item.ztype_id==2?'Э':'Т')}</abbr></td>          
          <td><abbr title="${Container.get(item?.container?:0)?.name?:''}">${Container.get(item?.container?:0)?.shortname?:''}</abbr></td>
          <td>${item?.zcol?:0}</td>         
          <td>${String.format('%td.%<tm.%<tY',item?.inputdate)}</td>
          <td><g:if test="${!item?.terminal}">${item?.city_start+' '+item?.address_start}</g:if><g:else>${Terminal.get(item?.terminal?:0)?.name?:''}</g:else></td>
          <td><g:if test="${(item?.ztype_id?:0)==2}">${item?.city_zat+' '+item?.address_zat}</g:if><g:else>---</g:else></td>
          <td>
            <g:if test="${(item?.ztype_id?:0)==1}">${item?.city_end+' '+item?.address_end}</g:if>
            <g:elseif test="${(item?.ztype_id?:0)==2}">
              <g:if test="${!item?.terminal_end}">${item?.city_end?:''}</g:if>
              <g:else>${Terminal.get(item?.terminal_end?:0)?.name?:''}</g:else>
            </g:elseif><g:elseif test="${(item?.ztype_id?:0)==3}">${item?.city_end?:''}</g:elseif>            
          </td>
          <td>${item?.price?:0}</td>
          <td><g:if test="${actualtimes[item.id]<=0}"><abbr title="время истекло"><i class="icon-time icon-large"></i></abbr></g:if><g:else>${Tools.getDayString(actualtimes[item.id])}</g:else></td>
          <td>
            <abbr title="${Zakazstatus.get(item?.modstatus)?.modstatus?:''}">
              <i class="icon-${Zakazstatus.get(item?.modstatus)?.icon?:''} icon-1x"></i>
            </abbr>
          </td>
          <td nowrap>         
            <g:link controller="shipper" action="order" id="${item.id}" params="[copy: 1]" class="button" title="Создать копию"><i class="icon-copy"></i></g:link>
            <g:if test="${item?.modstatus==0}">
              <g:link controller="shipper" action="order" id="${item.id}" params="[edit: 1]" class="button" title="Редактировать"><i class="icon-pencil"></i></g:link>
            </g:if><g:else>
              <g:link controller="shipper" action="order" id="${item.id}" class="button" title="Просмотр"><i class="icon-file-text-alt"></i></g:link>
            </g:else>
            <g:if test="${((item?.modstatus!=null)?item.modstatus:100) in 0..2}">
              <a href="javascript:void(0)" class="button" title="Снять заказ" onclick="remZakaz(${item?.id?:0})"><i class="icon-trash"></i></a>            
            </g:if><g:else>
              <a class="button disabled" title="Снять заказ"><i class="icon-trash"></i></a>            
            </g:else>
          </td>          
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
  <div style="padding:10px">
    <span class="fleft">Найдено: ${data?.count}</span>
    <span class="fright">
      <g:paginate controller="shipper" prev="&lt;&lt;" next="&gt;&gt;"
        action="${actionName}" max="20" params="${inrequest}"
        total="${data?.count}" offset="${inrequest.offset}"/>
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
    </span>
  </div>  
</g:if>
</div>
