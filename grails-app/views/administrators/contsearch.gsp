<html>
  <head>
    <title>Административное приложение containerovoz.ru</title>
    <meta name="layout" content="admin" />
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
    </g:javascript>
    <style type="text/css">
      .contact-form select{width:180px}
      .box-iframe,#map_canvas{width:930px;height:400px}       
    </style>
  </head>
	<body onload="\$('contsearch_submit_button').click()">
    <div class="menu admin">
      <div id="tripfilter" style="text-align:center">
        <g:formRemote class="contact-form nopad" name="contsearchForm" url="[action:'contsearchlist']" update="[success:'resultlist']">
          <fieldset>
            <label for="contnomer" style="font-size:14px;line-height:30px">Контейнер:</label>
            <span class="input-append">
              <input type="text" class="nopad normal" id="contnomer" name="cont" value="${cont}" style="height:30px;font-size:14px" />
              <span class="add-on" style="height:23px;width:25px" onclick="$('contsearch_submit_button').click()"><i class="icon-search icon-1x"></i></span>
            </span>
            <div id="cont_autocomplete" class="autocomplete" style="display:none"></div>
            <input type="submit" style="display:none" class="button" id="contsearch_submit_button" value="Показать" />
          </fieldset>
        </g:formRemote>
      </div>
    </div>
    <div id="resultlist"></div>
  </body>
</html>
