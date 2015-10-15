<html>
  <head>
    <title>${infotext?.title?:''}</title>    
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />
    <meta name="layout" content="main" />  
    <g:javascript>
      function startOrderSearch(){
        $('submit_button').click();
      }                           
      function showLoader(){
        $("loader").show();
      } 
      function hideLoader(){
        $("loader").hide();
      }       
      function remZakaz(lId){
        if (confirm('Вы уверены в операции удаления заявки?'))
          <g:remoteFunction action='remZakaz'  params="\'id=\'+lId" onLoading="showLoader()" onLoaded="hideLoader()" onSuccess="startOrderSearch()"/>
      }      
    </g:javascript>
    <g:setupObserve function='clickPaginate' id='ajax_wrap'/>
  </head>  
  <body onload="startOrderSearch();">
  <body>
    <div class="grid_8">
      <h1>${infotext?.header?:''}</h1>
      <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>    
      <g:formRemote class="contact-form" name="orderForm" url="[action:'orderlist']" update="[success:'order_list']" onLoading="showLoader()" onLoaded="hideLoader()" onSuccess="proccessCopyZakaz(e)">
        <label for="modstatus">Статус заявки:</label>
        <g:select class="auto" name="modstatus" optionKey="id" optionValue="modstatus" from="${modstatus}" value="${inrequest?.modstatus?:100}" onchange="startOrderSearch()" value="${inrequest?.modstatus}"/>      
        <input type="submit" id="submit_button" value="Найти" style="display:none"/>
        <img src="${resource(dir:'images',file:'loader.gif')}" alt="" id="loader" style="display:none" />
      </g:formRemote>
    </div>
    <div class="grid_4">    
      <div class="box2-top">
        <div class="border2">                        
          <a class="box1" href="<g:createLink controller='shipper' action='order'/>">
            <div class="padding">
              <div class="wrapper">
                <img src="${resource(dir:'flash/images',file:'tfile_image_1.png')}" alt="" class="img-indent4" />
                <div class="extra-wrap">
                  <div class="box-text1">
                    <em>подать<br>заявку</em>
                  </div>
                </div>
              </div>
            </div>
          </a>
        </div>
      </div>
    </div>
    <div class="error-box box2-top1" style="display:none">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul id="errorlist">
        <li></li>
      </ul>        
    </div>
    <div class="info-box box2-top1" style="display:none">
      <span class="icon icon-info-sign icon-3x"></span>
      <ul id="infolist">
        <li></li>        
      </ul>
    </div>
    <div class="clear"></div>
    <div id="order_list">        
    </div>
  </body>
</html> 
