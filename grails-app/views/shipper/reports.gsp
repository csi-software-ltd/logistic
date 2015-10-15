<html>
  <head>
    <title>${infotext?.title?:''}</title>    
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />
    <meta name="layout" content="main" />
    <style type="text/css">
      .contact-form fieldset.bord { width: auto!important }
      .contact-form select { width: 150px!important }
    </style>
  </head>
  <body>
    <h1>${infotext?.header?:''}</h1>
    <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
    <div id="contreport" class="grid_12 omega">
      <g:form class="contact-form" name="contreportForm" controller="shipper" target="_blank">
        <fieldset class="bord">
          <legend>Отчет по доставленным контейнерам</legend>
          <g:datePicker name="contreport_date" precision="month" value="${new Date()}" relativeYears="[113-new Date().getYear()..0]"/>
          <g:actionSubmit value="PDF" class="button aligntop" action="contreport"/>
          <g:actionSubmit value="XLS" class="button aligntop" action="contreportXLS"/>
        </fieldset>
      </g:form>
    </div>
  </body>
</html>
