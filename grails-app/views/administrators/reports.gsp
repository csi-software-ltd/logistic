<html>
  <head>
    <title>Административное приложение containerovoz.ru</title>
    <meta name="layout" content="admin" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'kendo.default.min.css')}" type="text/css" />
    <link rel="stylesheet" href="${resource(dir:'css',file:'kendo.common.min.css')}" type="text/css" />
    <g:javascript library="kendo.culture.ru-RU.min" />
    <g:javascript library="kendo.web.min" />
    <g:javascript>
      function initialize(iParam){
        switch(iParam){
          case 0:
            sectionColor('reports');
            $('reportslist').show();
            $('contfilter').hide();
            $('carrfilter').hide();
            $('taxfilter').hide();
            $('resultlist').hide();
            break;
          case 1:
            sectionColor('cont');
            $('reportslist').hide();
            $('carrfilter').hide();
            $('taxfilter').hide();
            $('contfilter').show();
            $('contreport_submit_button').click();
            break;
          case 2:
            sectionColor('carr');
            $('reportslist').hide();
            $('contfilter').hide();
            $('taxfilter').hide();
            $('carrfilter').show();
            $('carreport_submit_button').click();
            break;
          case 3:
            sectionColor('tax');
            $('reportslist').hide();
            $('contfilter').hide();
            $('carrfilter').hide();
            $('taxfilter').show();
            $('taxreport_submit_button').click();
            break;
        }
      }
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
      function sectionColor(sSection){
        $('reports').style.color = 'black';
        $('cont').style.color = 'black';
        $('carr').style.color = 'black';
        $('tax').style.color = 'black';
        $(sSection).style.color = '#0080F0';
      }
    </g:javascript>
    <style type="text/css">
      .contact-form select {width: 142px}
      .contact-form input.k-input[type="text"]{ width: 112px !important }
      .grid_6 .link{color:#fff;font-size:18px;margin-left:15px;text-decoration:underline}
    </style>
  </head>
	<body onload="initialize(0)">
    <div class="menu admin">
      <div class="grid_6 p3 fright" align="right">
        <a class="link" href="javascript:void(0)" onclick="initialize(0)" id="reports">Отчеты</a>
        <a class="link" href="javascript:void(0)" onclick="initialize(1)" id="cont">Контейнеры</a>
        <a class="link" href="javascript:void(0)" onclick="initialize(2)" id="carr">Перевозчики</a>
        <a class="link" href="javascript:void(0)" onclick="initialize(3)" id="tax">Абон. плата</a>
      </div>
      <div class="clear"></div>
      <div id="reportslist">
        <div id="managerstat" class="grid_6 omega">
          <g:form class="contact-form nopad" name="managerstatForm" controller="administrators" target="_blank">
            <fieldset class="bord">
              <legend>Эффективность менеджеров</legend>
              <g:datePicker name="managerstat_date" precision="month" value="${new Date()}" relativeYears="[113-new Date().getYear()..0]"/>
              <g:actionSubmit value="PDF" class="button aligntop" action="managerstat"/>
            </fieldset>
          </g:form>
        </div>
        <div id="zakazreport" class="grid_5">
          <g:form class="contact-form nopad" name="zakazreportForm" controller="administrators" target="_blank">
            <fieldset class="bord">
              <legend>Отчет по заказам</legend>
              <g:datePicker name="zakazreport_date" precision="month" value="${new Date()}" relativeYears="[113-new Date().getYear()..0]"/>
              <g:actionSubmit value="PDF" class="button aligntop" action="zakazreport"/>
              <g:actionSubmit value="XLS" class="button aligntop" action="zakazreportXLS"/>
            </fieldset>
          </g:form>
        </div>
        <div id="shippersettlment" class="grid_6 omega">
          <g:form class="contact-form nopad" name="shippersettlmentForm" controller="administrators" target="_blank">
            <fieldset class="bord">
              <legend>Сверка расчетов с клиентом</legend>
              <g:select name="client_id" from="${clientnames.collect{it[0]}}" keys="${clientnames.collect{it[1]}}" noSelection="${['0':'Все']}"/>
              <g:select name="year" from="${2013..new Date().getYear()+1900}" value="${new Date().getYear()+1900}"/>
              <g:actionSubmit value="PDF" class="button aligntop" action="shsettlmentreport"/>
              <g:actionSubmit value="XLS" class="button aligntop" action="shsettlmentreportXLS"/>
            </fieldset>
          </g:form>
        </div>
        <div id="carriersettlement" class="grid_5">
          <g:form class="contact-form nopad" name="carriersettlementForm" controller="administrators" target="_blank">
            <fieldset class="bord">
              <legend>Сверка расчетов с перевозчиками</legend>
              <g:select name="client_id" from="${carriernames.collect{it[0]}}" keys="${carriernames.collect{it[1]}}" noSelection="${['0':'Все']}"/>
              <g:select name="year" from="${2013..new Date().getYear()+1900}" value="${new Date().getYear()+1900}"/>
              <g:actionSubmit value="PDF" class="button aligntop" action="casettlmentreport"/>
              <g:actionSubmit value="XLS" class="button aligntop" action="casettlmentreportXLS"/>
            </fieldset>
          </g:form>
        </div>
      <g:if test="${admin?.menu?.find{it.id==18}}">
        <div id="shipperbenefit" class="grid_6 omega">
          <g:form class="contact-form nopad" name="shippersettlmentForm" controller="administrators" target="_blank">
            <fieldset class="bord">
              <legend>Клиентские вознаграждения</legend>
              <g:select class="nopad" name="client_id" from="${clientnames.collect{it[0]}}" keys="${clientnames.collect{it[1]}}" noSelection="${['0':'Все']}"/>
              <g:datepicker style="width:142px" name="benefitreport_date" value="${String.format('%td.%<tm.%<tY',new Date())}"/>
              <g:actionSubmit value="PDF" class="button aligntop" action="benefitreport"/>
              <g:actionSubmit value="XLS" class="button aligntop" action="benefitreportXLS"/>
            </fieldset>
          </g:form>
        </div>
        <div id="carrierpayment" class="grid_5">
          <g:form class="contact-form nopad" name="carriersettlementForm" controller="administrators" target="_blank">
            <fieldset class="bord">
              <legend>Отчет по выплатам перевозчикам</legend>
              <g:select class="nopad" name="client_id" from="${carriernames.collect{it[0]}}" keys="${carriernames.collect{it[1]}}" noSelection="${['0':'Все']}"/>
              <g:datepicker style="width:142px" name="capaymentreport_date" value="${String.format('%td.%<tm.%<tY',new Date())}"/>
              <g:actionSubmit value="PDF" class="button aligntop" action="capaymentreport"/>
              <g:actionSubmit value="XLS" class="button aligntop" action="capaymentreportXLS"/>
            </fieldset>
          </g:form>
        </div>
      </g:if>
        <div id="totalshreport" class="grid_6 omega">
          <g:form class="contact-form nopad" name="totalshreportForm" controller="administrators" target="_blank">
            <fieldset class="bord">
              <legend>Сводный отчет по клиентам</legend>
              <g:actionSubmit value="PDF" class="button aligntop" action="totalshreport"/>
            </fieldset>
          </g:form>
        </div>
        <div id="totalcareport" class="grid_5">
          <g:form class="contact-form nopad" name="totalcareportForm" controller="administrators" target="_blank">
            <fieldset class="bord">
              <legend>Сводный отчет по перевозчикам</legend>
              <g:actionSubmit value="PDF" class="button aligntop" action="totalcareport"/>
            </fieldset>
          </g:form>
        </div>
      </div>
      <div id="contfilter" style="display:none">
        <g:form class="contact-form nopad" name="allForm" controller="administrators" target="_blank">
          <fieldset>
            <label class="auto" for="contreport_date">Дата отчета:</label>
            <g:datePicker name="contreport_date" precision="month" value="${new Date()}" relativeYears="[113-new Date().getYear()..0]"/>
            <label for="manager_id" class="auto">Менеджер:</label>
            <g:select class="auto" name="manager_id" optionKey="id" optionValue="name" from="${Admin.findAllByIs_manager(1)}" value="" noSelection="${['0':'Все']}"/>
            <div class="btns">
              <g:actionSubmit value="PDF" class="button" action="contreport"/>
              <g:actionSubmit value="XLS" class="button" action="contreportXLS"/>
              <g:submitToRemote class="button" id="contreport_submit_button" value="Показать" url="[action:'contreport',params:[viewtype:'table']]" update="[success:'resultlist']" onSuccess="\$('resultlist').show();"/>
            </div>
          </fieldset>
        </g:form>
      </div>
      <div id="carrfilter" style="display:none">
        <g:formRemote class="contact-form nopad" name="allForm" url="[action:'totalcareport']" onSuccess="\$('resultlist').show();" update="[success:'resultlist']">
          <fieldset>
            <label class="auto" for="daydiff">Давность долга, дней:</label>
            <input class="mini" type="text" name="daydiff" value="" />
            <input type="hidden" name="viewtype" value="table" />
            <div class="btns">
              <input type="submit" class="button" id="carreport_submit_button" value="Показать" />
            </div>
          </fieldset>
        </g:formRemote>
      </div>
      <div id="taxfilter" style="display:none">
        <g:formRemote class="contact-form nopad" name="allForm" url="[action:'taxreport']" onSuccess="\$('resultlist').show();" update="[success:'resultlist']">
          <fieldset>
            <label class="auto" for="taxreport_date">Дата отчета:</label>
            <g:datePicker name="taxreport_date" precision="month" value="${new Date()}" relativeYears="[113-new Date().getYear()..0]"/>
            <input type="hidden" name="viewtype" value="table" />
            <div class="btns">
              <input type="submit" class="button" id="taxreport_submit_button" value="Показать" />
            </div>
          </fieldset>
        </g:formRemote>
      </div>
    </div>
    <div id="resultlist" style="display:none"></div>
  </body>
</html>