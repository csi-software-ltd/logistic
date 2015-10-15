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
      function initialize(iParam){
        switch(iParam){
          case 1:
            sectionSelected('shipmentold');
            $('shipmenttype').value = 1;
            $('shipment_submit_button').click();
            break;
          case 2:
            sectionSelected('shipmentcancel');
            $('shipmenttype').value = 2;
            $('shipment_submit_button').click();
            break;
          default:
            sectionSelected('shipmentnew');
            $('shipmenttype').value = 0;
            $('shipment_submit_button').click();
            break;
        }
      }
      function sectionSelected(sSection){
        $('shipmentnew').up('li').removeClassName('selected');
        $('shipmentold').up('li').removeClassName('selected');
        $('shipmentcancel').up('li').removeClassName('selected');
        $(sSection).up('li').addClassName('selected');
      }
      function cancelTrip(lId){
        if(confirm('Вы подтверждаете отмену погрузки?'))
          <g:remoteFunction action='canceltrip' params="\'id=\'+lId" onSuccess="\$('shipment_submit_button').click()"/>
      }
    </g:javascript>
  </head>
  <body onload="initialize(${type})">
    <h1>${infotext?.header?:''}</h1>
    <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
    <g:formRemote class="contact-form" name="shipmentForm" url="[action:'shipmentlist']" update="[success:'resultlist']" style="display:none">
      <fieldset>
        <input type="hidden" id="shipmenttype" name="type" value="0">
        <input type="submit" class="button" id="shipment_submit_button" value="Найти" style="margin-left:10px"/>
        <img src="${resource(dir:'images',file:'loader.gif')}" alt="" id="loader" style="display:none" />
      </fieldset>
    </g:formRemote>
    <div id="resultlist">
    </div>
  </body>
</html>
