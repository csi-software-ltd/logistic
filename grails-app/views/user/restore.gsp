<html>
  <head>
    <title>${infotext?.title?:''}</title>    
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />       
    <meta name="layout" content="main" />
    <g:javascript>
      function addReloadCaptcha(){
        <g:remoteFunction controller='index' action='reloadCaptcha' onSuccess='processRlResponse(e)'/>
      }
      function processRlResponse(e){
        $('add_captcha_picture').innerHTML = e.responseJSON.captcha;
        $('add_captcha_picture').firstChild.setStyle({width: '112px'});
      }
    </g:javascript>      
    <style type="text/css">
      .contact-form input.normal{width:210px!important}
    </style>
  </head>
  <body>
    <div class="grid_12">
      <h1>${infotext?.header?:''}</h1>
      <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>              
    <g:if test="${inrequest?.error}">
      <div class="error-box">
        <span class="icon icon-warning-sign icon-3x"></span>
        <ul id="errorlist">        
          <g:if test="${inrequest?.error==1}"><li>Пользователя с таким именем не существует</li></g:if>
          <g:if test="${inrequest?.error==2}"><li>Ошибка в адресе Email</li></g:if>
          <g:if test="${inrequest?.error==3}"><li>Неверный проверочный код</li></g:if>
          <g:if test="${inrequest?.error==5}"><li>Ваш запрос уже обработан</li></g:if>
          <g:if test="${inrequest?.error==6}"><li>Обратитесь к администратору системы</li></g:if>
          <g:if test="${inrequest?.error==-100}"><li>Ошибка</li></g:if>
        </ul>
      </div>
    </g:if>
      <g:form class="contact-form pad-top1" url="[controller:'user',action:'rest']" method="post" useToken="true">
        <fieldset class="grid_5">
          <label for="name" style="min-width:100px">Ваш email:</label>          
          <span class="input-prepend <g:if test="${inrequest?.error in [1,2]}">red</g:if>">
            <span class="add-on"><i class="icon-envelope"></i></span>
            <input type="text" name="name" value="${inrequest.name}" placeholder="Укажите ваш email" class="nopad normal" />
          </span><br/>  
          <label>Введите код, подтверждающий, что вы человек:</label><br/>
          <span id="add_captcha_picture" class="text-pad1 button-right1">
            <jcaptcha:jpeg name="image" width="112"/>
          </span>
          <input type="text" name="captcha" value="" class="mini <g:if test="${inrequest?.error==3}">red</g:if>" />
          <a class="button" href="javascript:void(0)" onclick="addReloadCaptcha()" title="Обновить"><i class="icon-repeat"></i></a>
          <input type="submit" class="button fright" value="Восстановить" />
        </fieldset>
      </g:form>
    </div>
  </body>
</html>
