<g:if test="${inrequest?.part}">
  <h3>${user?.login?:'' }</h3>
  <div class="error-box" style="display:none">
    <span class="icon icon-warning-sign icon-3x"></span>
    <ul id="errorlist">
      <li></li>
    </ul>        
  </div>
  <g:formRemote class="contact-form" url="[controller:'administrators',action:'usersave']" name="userForm" onSuccess="processUserSaveResponse(e)">
    <input type="hidden" name="id" value="${user?.id?:0}" />
    <fieldset>
      <label for="login">Логин:</label>
      <input type="text" name="login" value="${user?.login?:''}" />
      <label for="name">Полное имя:</label>
      <input type="text" name="name" value="${user?.name?:''}" />
      <label for="email">Email:</label>
      <input type="text" id="email" name="email" value="${user?.email?:''}" />
      <label for="email">Телефон:</label>
      <input type="text" id="tel" name="tel" value="${user?.tel?:''}" />
      <label for="group">Группа:</label>
      <select name="group">
        <g:if test="${!user?.admingroup_id?:0}"><option value="0"></option></g:if>
      <g:each in="${groups}" var="group">
        <option value="${group.id}" <g:if test="${group.id==user?.admingroup_id?:0 }">selected</g:if>>${group.name}</option>
      </g:each>
      </select>
      <label for="email">Менеджер:</label>
      <input type="checkbox" id="is_manager" name="is_manager" value="1" <g:if test="${user?.is_manager}">checked</g:if> />
      <div class="btns">        			
        <input type="button" class="button" value="Удалить" onclick="deleteUser(${user?.id?:0})" />            
        <input type="submit" class="button" value="Сохранить" />            
        <input type="reset" class="button" value="Отмена" onclick="$('details').update('');" />
      </div>
    </fieldset>
  </g:formRemote>
  <hr class="admin" />  
  <div class="error-box" id="pass_error" style="margin-top:0;display:none">
    <span class="icon icon-warning-sign icon-3x"></span>
    <p id="passmess"></p>  
  </div>
  <g:formRemote class="contact-form" url="[controller:'administrators',action:'changepass']" onSuccess="processPassResponse(e)" method="POST" name="changePassForm">
    <input type="hidden" name="ajax" value="1" />				  
    <input type="hidden" name="id" id="change_pass_id" value="${user?.id?:0}" />
    <fieldset>
      <label for="pass">Новый пароль:</label>
      <input type="password" name="pass" id="pass" />
      <label for="confirm_pass">Повторите пароль:</label>
      <input type="password" name="confirm_pass" id="confirm_pass" />
      <div class="btns">
        <input type="submit" class="button" value="Изменить пароль" />
      </div>
    </fieldset>
  </g:formRemote>
  
</g:if><g:elseif test="${group}">
  <h3>${group.name}</h3>
  <g:formRemote class="contact-form" url="[controller:'administrators',action:'groupsave']" name="groupForm" update="[success:'details']">
    <input type="hidden" name="id" value="${group.id}" />
    <label class="nopad" for="is_profile">Профиль пользователя</label>
    <input type="checkbox" name="is_profile" value="1" <g:if test="${group.is_profile}">checked</g:if>/><br/>
    <label class="nopad" for="is_users">Пользователи</label>
    <input type="checkbox" name="is_users" value="1" <g:if test="${group.is_users}">checked</g:if>/><br/>
    <label class="nopad" for="is_infotext">Инфотекст</label>
    <input type="checkbox" name="is_infotext" value="1" <g:if test="${group.is_infotext}">checked</g:if>/><br/>
    <label class="nopad" for="is_container">Типы контейнеров</label>
    <input type="checkbox" name="is_container" value="1" <g:if test="${group.is_container}">checked</g:if>/><br/>
    <label class="nopad" for="is_terminal">Терминалы и слоты</label>
    <input type="checkbox" name="is_terminal" value="1" <g:if test="${group.is_terminal}">checked</g:if>/><br/>
    <label class="nopad" for="is_clients">Клиенты</label>
    <input type="checkbox" name="is_clients" value="1" <g:if test="${group.is_clients}">checked</g:if>/><br/>
    <label class="nopad" for="is_tracker">Тракеры</label>
    <input type="checkbox" name="is_tracker" value="1" <g:if test="${group.is_tracker}">checked</g:if>/><br/>
    <label class="nopad" for="is_zakaz">Заказы</label>
    <input type="checkbox" name="is_zakaz" value="1" <g:if test="${group.is_zakaz}">checked</g:if>/><br/>
    <label class="nopad" for="is_monitoring">Мониторинг</label>
    <input type="checkbox" name="is_monitoring" value="1" <g:if test="${group.is_monitoring}">checked</g:if>/><br/>
    <label class="nopad" for="is_requests">Сдача контейнеров</label>
    <input type="checkbox" name="is_requests" value="1" <g:if test="${group.is_requests}">checked</g:if>/><br/>
    <label class="nopad" for="is_contsearch">Поиск контейнеров</label>
    <input type="checkbox" name="is_contsearch" value="1" <g:if test="${group.is_contsearch}">checked</g:if>/><br/>
    <label class="nopad" for="is_reports">Отчеты</label>
    <input type="checkbox" name="is_reports" value="1" <g:if test="${group.is_reports}">checked</g:if>/><br/>
    <label class="nopad" for="is_guestbook">Обратная связь</label>
    <input type="checkbox" name="is_guestbook" value="1" <g:if test="${group.is_guestbook}">checked</g:if>/><br/>
    <label class="nopad" for="is_autopilot">Режим автопилота</label>
    <input type="checkbox" name="is_autopilot" value="1" <g:if test="${group.is_autopilot}">checked</g:if>/><br/>
    <label class="nopad" for="is_syscompany">Компании системы</label>
    <input type="checkbox" name="is_syscompany" value="1" <g:if test="${group.is_syscompany}">checked</g:if>/><br/>
    <label class="nopad" for="is_payorders">Счета и оплаты</label>
    <input type="checkbox" name="is_payorders" value="1" <g:if test="${group.is_payorders}">checked</g:if>/><br/>
    <label class="nopad" for="is_financial">Финансовый учет</label>
    <input type="checkbox" name="is_financial" value="1" <g:if test="${group.is_financial}">checked</g:if>/><br/>
    <label class="nopad" for="is_route">Стандартные маршруты</label>
    <input type="checkbox" name="is_route" value="1" <g:if test="${group.is_route}">checked</g:if>/><br/>
    <label class="nopad" for="is_chief">Меню руководителя</label>
    <input type="checkbox" name="is_chief" value="1" <g:if test="${group.is_chief}">checked</g:if>/>
    <div class="btns">
      <input type="reset" class="button" value="Отмена" onclick="$('details').update('')" />
      <input type="submit" class="button" value="Сохранить"/>
    </div>
  </g:formRemote>
</g:elseif>