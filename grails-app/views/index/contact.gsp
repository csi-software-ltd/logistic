<html>
  <head>
    <title>${infotext?.title?:''}</title>
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />
    <meta name="layout" content="main" />
    <g:javascript>
      var iX=30.303099,
          iY=59.842879,
          map=null;
      function processResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['email','u_name','tel','message'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='<li>${message(code:"error.incorrect.message",args:["Email"])}</li>'; $("email").addClassName('red'); break;
              case 2: sErrorMsg+='<li>${message(code:"error.blank.message",args:["Имя"])}</li>'; $("u_name").addClassName('red'); break;
              case 3: sErrorMsg+='<li>${message(code:"error.blank.message",args:['Телефон'])}</li>'; $("tel").addClassName('red'); break;
              case 4: sErrorMsg+='<li>${message(code:"error.blank.message",args:['Сообщение'])}</li>'; $("message").addClassName('red'); break;
              case 5: sErrorMsg+='<li>Превышен лимит отправленных сообщений</li>'; break;
              case 99: sErrorMsg+='<li>Неправильно введен проверочный код</li>'; break;
              case 100: sErrorMsg+='<li>${message(code:"error.bderror.message")}</li>'; break;
            }
          });
          $("errorlist").innerHTML=sErrorMsg;
          $("errorlist").up('div').show();
          $("infolist").up('div').hide();
          reloadCaptcha();
        } else {
          //$("infolist").up('div').show();
          //$("resetbutton").click();          
          location.assign('${createLink(action:'contact',params:[success:1])}');
        }
      }
      function Yandex(){
        ymaps.ready(function()  {
          map = new ymaps.Map("map_canvas",{center:[iY,iX],zoom:15,behaviors:["default","scrollZoom"]});
          map.controls.add("smallZoomControl").add("scaleLine")
          placemark = new ymaps.Placemark([iY,iX],{},{
            draggable: false,
            hasBalloon: false,
            iconImageHref:"${resource(dir:'images',file:'marker.png')}",
            iconImageSize: [19,37],
            iconImageOffset:[-14,-35],
            iconContentOffset:[-1,10]
          });
          map.geoObjects.add(placemark);
        });
      }
      function reloadCaptcha(){
        <g:remoteFunction controller='index' action='reloadCaptcha' onSuccess='processRelResponse(e)' />
      }
      function processRelResponse(e){
        $('captcha_picture').innerHTML = e.responseJSON.captcha;
        $('captcha_picture').firstChild.setStyle({width: '120px'});
      }      
    </g:javascript>
  </head>
  <body onload="Yandex()">
              <div class="wrapper">                
                <div class="grid_6">
                  <h2>${infotext?.promotext1?:''}</h2>
                  <div class="box-iframe">
                    <div id="map_canvas"></div>
                  </div>
                  <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
                </div><!--noindex-->
                <div class="grid_6">
                  <h2>${infotext?.promotext2?:''}</h2>
                  <div class="text-pad1">
                    <g:rawHtml>${infotext?.itext2?:''}</g:rawHtml>
                  </div>
                  <div class="error-box" style="display:none">
                    <span class="icon icon-warning-sign icon-3x"></span>
                    <ul id="errorlist">
                      <li></li>
                    </ul>
                  </div>
                  <div class="info-box" style="${!flash.success?'display:none':''}">
                    <span class="icon icon-info-sign icon-3x"></span>
                    <ul id="infolist">
                      <li>Ваше сообщение принято</li>
                    </ul>
                  </div>
                  <g:formRemote class="contact-form" name="sendForm" url="[controller:'index',action:'add']" method="post" onSuccess="processResponse(e)">
                    <fieldset>
                      <label for="name">Имя:</label>
                      <input type="text" id="u_name" name="name" value="${user?.name}" placeholder="Имя" /><br/>
                      <label for="email">Email:</label>
                      <input type="text" id="email" name="email" value="${!user?.email?.isInteger()?user?.email:''}" placeholder="Email" /><br/>
                      <label for="tel">Телефон:</label>
                      <input type="text" id="tel" name="tel" value="${user?.tel}" placeholder="Телефон" /><br/>
                      <label for="message">Сообщение:</label>
                      <textarea id="message" name="message" placeholder="Сообщение"></textarea>
                      <div id="captcha">
                      <label>Введите код, подтверждающий, что вы человек:</label><br/>            
                      <div id="captcha_picture" class="button-right fleft">
                        <jcaptcha:jpeg name="image" width="112"/>
                      </div>
                      <input type="text" class="mini" id="captcha_text" name="captcha" value="" style="border-width:1px" />
                      <a class="button" href="javascript:void(0)" onclick="reloadCaptcha()" title="Обновить"><i class="icon-repeat"></i></a>            
                      <div class="btns">
                        <input id="resetbutton" type="reset" class="button" value="очистить" />
                        <input type="submit" class="button" value="отправить сообщение" />
                      </div>
                    </fieldset>
                  </g:formRemote>
                </div><!--/noindex-->
              </div>
  </body>
</html>
