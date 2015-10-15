<div id="ajax_wrap">
  <div id="resultList">
    <g:formRemote name="sendZakazOfferForm" url="[action:'sendzakazoffer',id:zakazId]" onSuccess="getVariants();">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <tr>        
          <th>Код</th>
          <th>Название</th>
          <th>Свободный транспорт</th>
          <th>Дата заказа</th>
          <th>Кол-во заказов</th>
          <th>Дата запроса</th>
          <th>Статус рассылки<input type="checkbox" id="groupcheckbox" checked ${session.admin.is_allvariants?'disabled':''} onclick="togglecheck()"></th>
        </tr>
      </thead>
      <tbody>
    <g:if test="${zakaz.price_basic}">
      <g:each in="${variants}" status="i" var="record">
      <g:if test="${record.ishavetrackers}">
        <tr align="center" style="vertical-align:middle">
          <td>${record.id}</td>
          <td align="left">${record.fullname}</td>
          <td>${record.carcount}</td>
          <td>${record.lastorder?String.format('%tF %<tT', record.lastorder):'нет'}</td>
          <td>${record.ordercount}</td>
          <td>${offers[record.id]?String.format('%tF %<tT', offers[record.id]):'нет'}</td>
          <td>
            <g:if test="${offers[record.id]}"><abbr title="Разослано"><i class="icon-ok"></abbr></i></g:if>
            <g:else><input type="checkbox" checked ${session.admin.is_allvariants?'disabled':''} name="clientids" value="${record.id}"></g:else>
          </td>
        </tr>
      </g:if>
      </g:each>
        <tr>
          <td colspan="8" class="btns" style="text-align:center">
            Безтрекерные
          </td>
        </tr>
      <g:each in="${variants}" status="i" var="record">
      <g:if test="${!record.ishavetrackers}">
        <tr align="center" style="vertical-align:middle">
          <td>${record.id}</td>
          <td align="left">${record.fullname}</td>
          <td>${record.carcount}</td>
          <td>${record.lastorder?String.format('%tF %<tT', record.lastorder):'нет'}</td>
          <td>${record.ordercount}</td>
          <td>${offers[record.id]?String.format('%tF %<tT', offers[record.id]):'нет'}</td>
          <td>
            <g:if test="${offers[record.id]||zakaz.delayedclients.split(',').contains(record.id.toString())}"><abbr title="Разослано"><i class="icon-ok"></abbr></i></g:if>
            <g:else><input type="checkbox" checked ${session.admin.is_allvariants?'disabled':''} name="delayedclientids" value="${record.id}"></g:else>
          </td>
        </tr>
      </g:if>
      </g:each>
        <tr>
          <td colspan="8" class="btns" style="text-align:center">
            <g:if test="${zakaz.modstatus in [0,1]}">
              <input type="submit" class="button" value="Разослать предложения"/>
            </g:if>
            <g:if test="${iSsearch}">
              <a class="button" href="javascript:void(0)" onClick="$('is_simplesearch').value=0;getVariants();">Строгий поиск</a>
            </g:if><g:else>
              <a class="button" href="javascript:void(0)" onClick="$('is_simplesearch').value=1;getVariants();">Ослабленный поиск</a>
            </g:else>
          </td>
        </tr>
    </g:if><g:else>
        <tr>
          <td colspan="8" class="btns" style="text-align:center">
            Не задана ставка для перевозчика
          </td>
        </tr>
    </g:else>
      </tbody>
    </table>
      <input type="hidden" name="is_simplesearch" value="${iSsearch?:0}"/>
    </g:formRemote>
  </div>
</div>
