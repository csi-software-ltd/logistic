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
      body { font-family: "Arial Unicode MS", Arial, sans-serif; }
      table { border-top: 2px solid #000; border-left: 1px solid #000; }
      table th { border-bottom: 2px solid #000; border-right: 1px solid #000 }
      table td { border-bottom: 1px solid #000; border-right: 1px solid #000 }
    </style>
  </head>
  <body style="width:1020px">
    <div>
    <g:if test="${report}">
      <div style="float:left;font-size:9pt">Сводный отчет по клиентам на ${String.format('%td.%<tm.%<tY',new Date())}.</div><br/>
      <div style="clear:both;text-align:center"></div><br/>
      <div>
        <table style="width:1020px;font-size:9pt">
          <thead>
            <tr>
              <th>Клиент</th>
              <th>Ожидаемый доход</th>
              <th>Общая задолженность</th>
              <th>Общий долг</th>
              <th>Долг</th>
              <th>Пони</th>
            </tr>
          </thead>
          <tbody>
          <g:each in="${report}" status="i" var="record">
            <tr align="center" style="line-height:16px;font-size:11px">
              <td>${record.clientname}</td>
              <td>${virtualprofit[record.client_id]+record.arrears}</td>
              <td>${record.arrears}</td>
              <td>${record.totaldebt}</td>
              <td><g:each in="${detailed.records}"><g:if test="${it.client_id==record.client_id}">${it.norder?:'нет номера'}-${String.format('%td.%<tm.%<tY',it.orderdate)}-${it.debt}<br/></g:if></g:each></td>
              <td>${record.totalponi}</td>
            </tr>
          </g:each>
            <tr>
              <td colspan="3">Итого должников</td>
              <td>${report.size()}</td>
              <td colspan="2"></td>
            </tr>
            <tr>
              <td colspan="3">Итого задолженность</td>
              <td>${arrearssum}</td>
              <td colspan="2"></td>
            </tr>
            <tr>
              <td colspan="3">Итого долг</td>
              <td>${debtsum}</td>
              <td colspan="2"></td>
            </tr>
          </tbody>
        </table>
      </div>
    </g:if>
    </div>
  </body>
</html>