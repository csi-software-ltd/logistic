<html>
  <head>
    <title>Административное приложение containerovoz.ru</title>
    <meta name="layout" content="chief" />
    <style type="text/css">
      .contact-form select{width:100px}
      .box-text1 em{font-size:20px}      
      .box3{height:auto}
      .box3 .padding{width:295px}
      input.button[type="submit"]{font:15px/15px Tahoma,Arial!important;padding:4px 17px;margin-right:20px}
      
      noindex:-o-prefocus, .box-text1 em, .box3-text span {font-weight:bold}     
      noindex:-o-prefocus, input.button[type="submit"]{padding:5px 21px}
       @media screen and (-webkit-min-device-pixel-ratio:0){
        .box-text1 em, .box3-text span{font-weight:bold}
        input.button[type="submit"]{padding:7px 21px}       
      }      
    </style>
    <g:javascript>
      function processResponse(e){
        if(e.responseJSON.error){
          var sErrorMsg = '';
          ['kprofit'].forEach(function(ids){
            $(ids).removeClassName('red');
          });
          e.responseJSON.errorcode.forEach(function(err){
            switch (err) {
              case 1: sErrorMsg+='${message(code:"error.blank.message",args:["Параметр эффективности"])}'; break;
              case 2: sErrorMsg+='${message(code:"error.incorrect.message",args:["Параметр эффективности"])}'; $("kprofit").addClassName('red'); break;
              case 3: sErrorMsg+='${message(code:"error.incorrect.message",args:["Параметр эффективности"])}'; $("kprofit").addClassName('red'); break;
              case 100: sErrorMsg+='${message(code:"error.bderror.message")}'; break;
            }
          });
          alert(sErrorMsg);
        } else {
          alert('Сохранено');
        }
      }
    </g:javascript>
  </head>
	<body>
    <div class="grid_8">
    	<h1>Отчетность о работе системы</h1>
      <div class="img-top img-bottom1">
        <div class="box3-pad">
          <div class="box3">
            <div class="padding">
              <div class="wrapper">
                <img src="${resource(dir:'images',file:'box3-img.jpg')}" width="54" alt="" class="img-indent4" />
                <div class="extra-wrap">
                  <div class="box3-text">
                    <span>Эффективность менеджеров</span>
                  </div>
                </div>
                <g:form class="contact-form" name="managerstatForm" controller="administrators" target="_blank">
                  <span class="fleft">
                    <g:datePicker name="managerstat_date" precision="month" value="${new Date()}" relativeYears="[113-new Date().getYear()..0]"/>
                  </span>
                  <g:actionSubmit value="PDF" class="button fright" action="managerstat"/>
                </g:form>
              </div>
            </div>
          </div>
        </div>
        <div class="box3-pad">
          <div class="box3">
            <div class="padding">
              <div class="wrapper">
                <img src="${resource(dir:'images',file:'box3-img.jpg')}" width="54" alt="" class="img-indent4" />
                <div class="extra-wrap">
                  <div class="box3-text">
                    <span>Параметр эффективности прибыли</span>
                  </div>
                </div>
                <g:formRemote class="contact-form" name="editkprofitForm" url="[action:'editkprofit']" onSuccess="processResponse(e);">
                  <label for="kprofit" class="auto">Значение:</label>
                  <input type="text" class="mini" id="kprofit" name="kprofit" value="${kprofit}" />
                  <a class="button" href="javascript:void(0)" onclick="$('editkprofit_submit_button').click();" title="Сохранить"><i class="icon-ok"></i></a>
                  <input type="submit" class="button" id="editkprofit_submit_button" value="Отправить" style="display:none"/>
                </g:formRemote>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="grid_4 padding-top1">
      <div class="box2-top">
        <div class="border2">
          <a class="box1" href="javascript:void(0)">
            <div class="padding">
              <div class="wrapper">
                <img class="img-indent4" src="${resource(dir:'flash/images',file:'tfile_image_3.png')}" alt="" />
                <div class="extra-wrap">
                  <div class="box-text1">
                    <em>Нам должны<br>${intnumber(value:usarrearssum)} руб</em>
                  </div>
                </div>
              </div>
            </div>
          </a>
        </div>
      </div>
      <div class="box2-top1">
        <div class="border2">
          <a class="box1" href="javascript:void(0)">
            <div class="padding">
              <div class="wrapper">
                <img class="img-indent4" src="${resource(dir:'flash/images',file:'tfile_image_3.png')}" alt="" />
                <div class="extra-wrap">
                  <div class="box-text1">
                    <em>Мы должны<br>${intnumber(value:ourarrearssum)} руб</em>
                  </div>
                </div>
              </div>
            </div>
          </a>
        </div>
      </div>
      <div class="box2-top1">
        <div class="border2">
          <a class="box1" href="<g:createLink controller='administrators' action='totalcareport'/>" target="_blank">
            <div class="padding">
              <div class="wrapper">
                <img class="img-indent4" src="${resource(dir:'flash/images',file:'tfile_image_1.png')}" alt="" />
                <div class="extra-wrap">
                  <div class="box-text1">
                    <em>сводный отчет<br>по перевозчикам</em>
                  </div>
                </div>
              </div>
            </div>
          </a>
        </div>
      </div>
      <div class="box2-top1">
       	<div class="border2">
          <a class="box1" href="<g:createLink controller='administrators' action='totalshreport'/>" target="_blank">
            <div class="padding">
            	<div class="wrapper">
                <img class="img-indent4" src="${resource(dir:'flash/images',file:'tfile_image_1.png')}" alt="" />
                <div class="extra-wrap">
                 	<div class="box-text1">      
                    <em>сводный отчет<br>по клиентам</em>
                  </div>
                </div>
              </div>                      
            </div>
          </a>
        </div>
      </div>
    </div>
  </body>
</html>
