<html>
  <head>
    <title>${infotext?.title?:''}</title>    
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />
    <meta name="layout" content="main" />
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
  </head>
  <body onload="\$('contsearch_submit_button').click()">
    <h1>${infotext?.header?:''}</h1>
    <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
    
    <g:formRemote class="contact-form" name="contsearchForm" url="[action:'contsearchlist']" update="[success:'resultlist']">
      <fieldset>
        <label for="contnomer">Контейнер:</label>
        <span class="input-append">
          <input type="text" class="nopad normal" id="contnomer" name="cont" value="${cont}" style="width:130px!important" />
          <span class="add-on" onclick="$('contsearch_submit_button').click()"><i class="icon-search"></i></span>
        </span>
        <div id="cont_autocomplete" class="autocomplete" style="display:none"></div>
        <input type="submit" style="display:none" id="contsearch_submit_button" />
        <img src="${resource(dir:'images',file:'loader.gif')}" alt="" id="loader" style="display:none" />  
      </fieldset>
    </g:formRemote>          
    <div id="resultlist"></div>
  </body>
</html>
