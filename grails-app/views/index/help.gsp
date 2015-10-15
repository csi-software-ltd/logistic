<html>
  <head>
    <title>${infotext?.title?:''}</title>    
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />
    <meta name="layout" content="main" />
    <style type="text/css">     
      table.list td{font:13px/18px Arial;padding:5px 10px;}
      table.list td:last-child{text-align:center;width:15%;}      
    </style>
  </head>
  <body>
    <h1 class="padding-bottom">${infotext?.header?:''}</h1>
    <div class="grid_6 alpha">            
      <h3>Статусы заявок</h3>
      <table class="list" width="100%" cellspacing="0" cellpadding="0" border="0">        
      <g:each in="${zakazstatus}" var="item">
        <tr>
          <td>${item?.modstatus}</td>
          <td><i class="icon-${item?.icon} icon-large"></i></td>
        </tr>
      </g:each>      
      </table>
      
      <h3>Статусы поездок</h3>
      <table class="list" width="100%" cellspacing="0" cellpadding="0" border="0">
      <g:each in="${tripstatus}" var="item">
        <tr>
          <td>${item?.status}</td>
          <td><i class="icon-${item?.icon} icon-large"></i></td>
        </tr>
      </g:each>
      </table> 

      <h3>Статусы мониторинга</h3>
      <table class="list" width="100%" cellspacing="0" cellpadding="0" border="0">
        <tr>
          <td>Тракер не привязан</td>
          <td><i class="icon-off icon-large"></i></td>
        </tr>
        <tr>
          <td>Тракер доступен</td>
          <td><i class="icon-ok icon-large"></i></td>
        </tr>
        <tr>
          <td>Тракер не доступен</td>
          <td><i class="icon-pause icon-large"></i></td>
        </tr>
      </table>
      
      <h3>Статусы сдачи</h3>
      <table class="list" width="100%" cellspacing="0" cellpadding="0" border="0">
      <g:each in="${taskstatus}" var="item">
        <tr>
          <td>${item?.status}</td>
          <td><i class="icon-${item?.icon} icon-large"></i></td>
        </tr>
      </g:each>
      </table>
    </div>
    <div class="grid_6 omega">      
      <h3>Статусы событий</h3>
      <table class="list" width="100%" cellspacing="0" cellpadding="0" border="0">
      <g:each in="${tripeventtype}" var="item">
        <tr>
          <td>${item?.name}</td>
          <td><i class="icon-${item?.icon} icon-large"></i></td>
        </tr>
      </g:each>
      </table>
    </div>
  </body>
</html>
