<html>
  <head>
    <title>Административное приложение</title>
    <meta name="layout" content="admin" />
    <g:javascript>
      function returnToList(){
        $("returnToListForm").submit();
      }
      function processResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['name','inn','fulladdress','bik','bank','corschet','account','nds','accountant','chief'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Название"])}</li>'; $("name").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.blank.message",args:["ИНН"])}</li>'; $("inn").addClassName('red'); break;
              case 3: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Адрес"])}</li>'; $("fulladdress").addClassName('red'); break;
              case 4: sErrorMsg+='<li>${message(code:"error.blank.message",args:["БИК"])}</li>'; $("bik").addClassName('red'); break;
              case 5: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Кор счет"])}</li>'; $("corschet").addClassName('red'); break;
              case 6: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Расчетный счет"])}</li>'; $("account").addClassName('red'); break;
              case 7: sErrorMsg+='<li>${message(code:"error.blank.message",args:["НДС"])}</li>'; $("nds").addClassName('red'); break;
              case 8: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Название банка"])}</li>'; $("bank").addClassName('red'); break;
              case 9: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Руководитель"])}</li>'; $("chief").addClassName('red'); break;
              case 10: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Бухгалтер"])}</li>'; $("accountant").addClassName('red'); break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
        } else {
          location.assign('${createLink(action:'syscompanydetail')}'+'/'+e.responseJSON.uId);
        }
      }
    </g:javascript>
    <style type="text/css">
      .contact-form label{min-width:130px}
    </style>
  </head>
  <body>
    <h1 class="fleft">${syscompany?'Компания: '+syscompany.name:'Добавление новой компании системы'}</h1>
    <a class="link fright" href="javascript:void(0)" onclick="returnToList();">К списку компаний</a>
    <div class="clear"></div>
    <div class="error-box" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>
    </div>
    <g:formRemote class="contact-form" name="syscompanyDetailForm" url="[action:'saveSyscompanyDetail', id:syscompany?.id?:0]" method="post" onSuccess="processResponse(e)">
      <fieldset>
        <div class="grid_6 alpha">
          <label for="name">Название:</label>
          <input type="text" id="name" name="name" value="${syscompany?.name?:''}" />
          <label for="fulladdress">Адрес:</label>
          <input type="text" id="fulladdress" name="fulladdress" value="${syscompany?.fulladdress?:''}" />
          <label for="bik">БИК:</label>
          <input type="text" id="bik" name="bik" value="${syscompany?.bik?:''}" />
          <label for="bank">Название банка:</label>
          <input type="text" id="bank" name="bank" value="${syscompany?.bank?:''}" />
          <label for="ctype_id">Тип:</label>
          <g:select name="ctype_id" value="${syscompany?.ctype_id}" from="['ООО','ИП','ЗАО']" keys="123"/>
          <label for="chief">Руководитель:</label>
          <input type="text" id="chief" name="chief" value="${syscompany?.chief?:''}" />
        </div>
        <div class="grid_6">
          <label for="inn">ИНН:</label>
          <input type="text" id="inn" name="inn" value="${syscompany?.inn?:''}" />
          <label for="kpp">КПП:</label>
          <input type="text" id="kpp" name="kpp" value="${syscompany?.kpp?:''}" />
          <label for="corschet">Кор счет:</label>
          <input type="text" id="corschet" name="corschet" value="${syscompany?.corschet?:''}" />
          <label for="account">Расчетный счет:</label>
          <input type="text" id="account" name="account" value="${syscompany?.account?:''}" />
          <label for="ogrn">ОГРН:</label>
          <input type="text" id="ogrn" name="ogrn" value="${syscompany?.ogrn?:''}" />
          <label for="accountant">Бухгалтер:</label>
          <input type="text" id="accountant" name="accountant" value="${syscompany?.accountant?:''}" />
          <label for="nds">НДС:</label>
          <input type="text" id="nds" name="nds" value="${syscompany?.nds?:0}" />
        </div>
      </fieldset>
      <div class="btns">
        <input type="submit" id="submit_button" class="button" value="Сохранить" />
        <input type="reset" class="button" value="Сброс" />
      </div>
    </g:formRemote>
    <g:form  id="returnToListForm" name="returnToListForm" url="${[action:'syscompany']}">
    </g:form>
  </body>
</html>