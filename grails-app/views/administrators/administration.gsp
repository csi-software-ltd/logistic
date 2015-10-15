<html>
  <head>
    <title>Административное приложение</title>
    <meta name="layout" content="admin"/>
    <g:javascript>
      function clickPaginate(event){
        event.stop();
        var link = event.element();
        if(link.href == null){
          return;
        }  
        new Ajax.Updater(
          { success: $('ajax_wrap') },
          link.href,
          { evalScripts: true });
      }      
      function deleteUser(lId){
        if (confirm('Вы уверены?')){
          <g:remoteFunction controller='administrators' action='deleteuser' onSuccess='processDeleteUserResponse(e)' params="\'id=\'+lId" />
        }
      }      
      function processDeleteUserResponse(e){
        if (e.responseJSON.done){
          $('details').update('');
          selectGroupUser(1);
        }else{
          if (e.responseJSON.message)
            $('mess').update(e.responseJSON.message);
          $('message').show();
        }
      }      
      function updateDetails(lId,iPart){
        hideAll();		
        $('details').show();
        <g:remoteFunction controller='administrators' action='groupuserdetails' update='details' params="'id='+lId+'&part='+iPart" />
      }      
      function selectGroupUser(lId){
        hideAll();
        <g:remoteFunction controller='administrators' action='groupuserlist' update='groupuser' params="\'id=\'+lId" />
        if (lId)
          user();
        else
          group();        
      }      
      function showGroupWindow(){
        hideAll();
        $('details').hide();
        $('creategroup').show();
      }      
      function showUserWindow(){
        hideAll();
        $('details').hide();
        $('createuser').show();		
      }      
      function hideGroupWindow(){
        $('creategroup').hide();
        $('name').value = '';
        $('groupmess').update('');
        $('group_error').hide();
      }      
      function hideUserWindow(){
        $('createuser').hide();
        $('login').value = '';
        $('usermess').update('');
        $('user_error').hide();
      }      
      function hideAll(){
        $('details').update('');
        hideGroupWindow();
        hideUserWindow();
        closeMessage();
        hidePassWindow();		
      }      
      function processGroupResponse(e){
        if (e.responseJSON.done){
          if (e.responseJSON.message){
            $('mess').update(e.responseJSON.message);
            hideGroupWindow();
            $('message').show();
          }else{
            selectGroupUser(0);
            hideGroupWindow();
            if(e.responseJSON.id)
              updateDetails(e.responseJSON.id,0);
          }
        }else{          
          $('groupmess').update(e.responseJSON.message);
          $('group_error').show();
        }
      }      
      function processUserResponse(e){
        if (e.responseJSON.done){
          if (e.responseJSON.message){
            $('mess').update(e.responseJSON.message);
            hideUserWindow();
            $('message').show();
          }else{
            selectGroupUser(1);
            hideUserWindow();
            if(e.responseJSON.id)
              updateDetails(e.responseJSON.id,1);
          }
        }else{
          $('usermess').update(e.responseJSON.message);
          $('user_error').show();
        }
      }      
      function selectGuestbook(iCheked){
        if (iCheked){
          $('gbmain').enable();
          $('gberrors').enable();
          $('gbcall').enable();
          $('gbpcrequest').enable();
        }else{
          $('gbmain').disable();
          $('gberrors').disable();
          $('gbcall').disable();
          $('gbpcrequest').disable();
        }
      }     
      function closeMessage(){
        $('message').hide();
      }      
      function showPassWindow(lId){
        hideAll();              
      }      
      function hidePassWindow(){ /*    
        $('pass').value='';
        $('confirm_pass').value='';
        $('passmess').update('');*/
      }      
      function processPassResponse(e){
        if (e.responseJSON.done){
          $('mess').update(e.responseJSON.message);
          hidePassWindow();
          $('message').show();
        }else{
          $('passmess').update(e.responseJSON.message);
          $('pass_error').show();
        }
      }      
      function group(){
        $('userlink').style.color = 'black';
        $('grouplink').style.color = '#0080F0';
      }      
      function user(){
        $('userlink').style.color = '#0080F0';
        $('grouplink').style.color = 'black';
      }     
      function processUserSaveResponse(e){      
        var sErrorMsg='';
        ['email','tel'].forEach(function(ids){
          if($(ids))
            $(ids).removeClassName('red');
        });
        if(e.responseJSON.errorcode.length){        
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>Некорректные данные в поле "Телефон"</li>';
                      $("tel").addClassName('red');
                      break;
              case 2: sErrorMsg+='<li>Некорректные данные в поле "Email"</li>';
                      $("email").addClassName('red');
                      break;
            }
          });
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show(); 
        }else{
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').hide();         
        }
      }      
    </g:javascript>
    <style type="text/css">
      .grid_4 .link{color:#fff;font-size:18px;margin-left:15px;text-decoration:underline}
      .contact-form label{min-width:150px}      
    </style>
  </head>  
  <body onload="selectGroupUser(0);">
    <div class="grid_4 p3 fright" align="right">
      <g:remoteLink class="link" id="grouplink" url="${[controller:'administrators', action:'groupuserlist',id:0]}" update="[success:'groupuser']" onSuccess="hideAll();group();">Группы</g:remoteLink>
      <g:remoteLink class="link" id="userlink" url="${[controller:'administrators', action:'groupuserlist',id:1]}" update="[success:'groupuser']" onSuccess="hideAll();user();">Пользователи</g:remoteLink>
    </div>      
    <div class="clear"></div>
    <div class="grid_4 pad-top alpha">
      <div id="groupuser">              
      </div>
    </div>
    <div class="grid_7 pad-top pad-left1">
      <div id="details">              
      </div>           
      <div id="creategroup" style="display:none">              
        <h3>Добавить группу</h3>
        <div class="error-box" id="group_error" style="display:none">
          <span class="icon icon-warning-sign icon-3x"></span>
          <p id="groupmess"></p>
        </div>
        <g:formRemote class="contact-form" url="[controller:'administrators',action:'creategroup']" onSuccess="processGroupResponse(e)" method="post" name="createGroupForm">
          <fieldset>
            <label for="name">Имя группы:</label>
            <input type="text" name="name" id="name" placeholder="Введите имя группы" />
            <div class="btns">
              <input type="submit" class="button" value="Добавить" />
              <input type="button" class="button" value="Отмена" onclick="hideGroupWindow()" />
            </div>
          </fieldset>
        </g:formRemote>        
      </div>
      <div id="createuser" style="display:none;">
        <h3>Добавить пользователя</h3>
        <div class="error-box" id="user_error" style="display:none">
          <span class="icon icon-warning-sign icon-3x"></span>
          <p id="usermess"></p>
        </div>
        <g:formRemote class="contact-form" url="[controller:'administrators',action:'createuser']" onSuccess="processUserResponse(e)" method="post" name="createUserForm">
          <fieldset>
            <label for="login">Логин:</label>
            <input type="text" name="login" id="login" placeholder="Введите логин пользователя" />
            <label for="pass">Пароль:</label>
            <input type="password" name="pass" id="pass" placeholder="Задайте пароль" />
            <label for="confirm_pass">Повторить:</label>
            <input type="password" name="confirm_pass" id="confirm_pass" placeholder="Повторите пароль" />
            <div class="btns">
              <input type="submit" class="button" value="Добавить" />
              <input type="button" class="button" value="Отмена" onclick="hideUserWindow()" />
            </div>
          </fieldset>
        </g:formRemote>        
      </div>
      <div id="message" style="display:none">
        <div id="mess"></div>
        <input type="button" value="ОК" style="width:80px" onclick="closeMessage()"/>        
      </div>
    </div>  
  </body>
</html>
