  <h3>${inrequest?.part?'Пользователи':'Группы'}</h3>
<g:each in="${groupusers}" var="item" status="i">
  <a <g:if test="${i==0}">id="first"</g:if> href="javascript:void(0)" onclick="updateDetails(${item.id},${inrequest?.part})">${inrequest?.part?item.login:item.name}</a><br>
</g:each>
  <div class="btns pad-top fleft">
  <g:if test="${inrequest?.part}">
    <input type="button" class="button" value="Добавить" onclick="showUserWindow()"/>
  </g:if><g:else>
    <input type="button" class="button" value="Добавить" onclick="showGroupWindow()"/>
  </g:else>
  </div>
