<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>${infotext?.title?infotext.title:''}</title>
    <meta name="keywords" content="${infotext?.keywords?infotext.keywords:''}" />
    <meta name="description" content="${infotext?.description?infotext.description:''}" />
    <style type="text/css">
      @font-face {
        src: url('http://containerovoz.ru:80/font/arial.ttf');
        -fs-pdf-font-embed: embed;
        -fs-pdf-font-encoding: cp1251;
      }
      @page {
        size: 29.7cm 21cm;
      }
      @page page2 {size: 29.7cm 21cm;}
      .page2 { page: page2 }
      body { font-family: "Arial Unicode MS", Arial, sans-serif; }
      table { border-top: 2px solid #000; border-left: 1px solid #000; }
      table th { border-bottom: 2px solid #000; border-right: 1px solid #000 }
      table td { border-bottom: 1px solid #000; border-right: 1px solid #000 }
    </style>
  </head>
  <body style="width:1020px">
    <div class="page1">
    <g:if test="${report}">
      <div style="float:left;font-size:9pt">Отчет по менеджерам за ${reportMonth} ${reportYear}г.</div><br/>
      <div style="clear:both;text-align:center"></div><br/>
      <div>
        <table style="width:1020px;font-size:7pt">
          <thead>
            <tr>
              <th>Менеджер</th>
            <g:while test="${i<=15}">
              <th>${String.format('%td.%<tm',thismonth+i)}</th>
              <%i++%>
            </g:while>
            </tr>
          </thead>
          <tbody>
            <g:each in="${report.collect{it.manager_id}.unique()}" var="mng">
              <tr>
                <td>${Admin.get(mng)?.name?:'Неопределен'}</td>
              <g:each in="${thismonth..(thismonth+i-1)}" var="date">
                <td>${report.find{it.manager_id==mng&&it.inputdate.clone().clearTime()==date}?.toString(kprofit)?:''}</td>
              </g:each>
              </tr>
            </g:each>
              <tr>
                <td>Прибыль</td>
              <g:each in="${0..15}">
                <td>${dayprofit[it]}</td>
              </g:each>
              </tr>
              <tr>
                <td>Оборот</td>
              <g:each in="${0..15}">
                <td>${dayincome[it]}</td>
              </g:each>
              </tr>
          </tbody>
        </table>
      </div>
    </g:if><g:else>Нет данных</g:else>
    </div>
    <div class="page2">
    <g:if test="${report}">
      <div style="float:left;font-size:9pt">Отчет по менеджерам за ${reportMonth} ${reportYear}г.</div><br/>
      <div style="clear:both;text-align:center"></div><br/>
      <div>
        <table style="width:1020px;font-size:7pt">
          <thead>
            <tr>
              <th>Менеджер</th>
            <g:while test="${(thismonth+i).getMonth()==thismonth.getMonth()}">
              <th>${String.format('%td.%<tm',thismonth+i)}</th>
              <%i++%>
            </g:while>
              <th>Итого</th>
            </tr>
          </thead>
          <tbody>
            <g:each in="${report.collect{it.manager_id}.unique()}" var="mng">
              <tr>
                <td>${Admin.get(mng)?.name?:'Неопределен'}</td>
              <g:each in="${thismonth+16..(thismonth+i-1)}" var="date">
                <td>${report.find{it.manager_id==mng&&it.inputdate.clone().clearTime()==date}?.toString(kprofit)?:''}</td>
              </g:each>
                <td>${managerprofit[mng]}</td>
              </tr>
            </g:each>
              <tr>
                <td>Прибыль</td>
              <g:each in="${16..(i-1)}">
                <td>${dayprofit[it]}</td>
              </g:each>
                <td>${dayprofit.sum()}</td>
              </tr>
              <tr>
                <td>Оборот</td>
              <g:each in="${16..(i-1)}">
                <td>${dayincome[it]}</td>
              </g:each>
                <td>${dayincome.sum()}</td>
              </tr>
          </tbody>
        </table>
      </div>
    </g:if>
    </div>
  </body>
</html>