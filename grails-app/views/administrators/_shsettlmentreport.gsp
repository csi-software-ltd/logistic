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
      <div style="float:left;font-size:9pt">Сверка ${client?.fullname?'с '+client.fullname:'сводная'} за ${inrequest.year?:(new Date().getYear()+1900)}г.</div><br/>
      <div style="clear:both;text-align:center"></div><br/>
    <g:if test="${searchresult.records}">
      <div>
        <table style="width:1020px;font-size:9pt">
          <thead>
            <tr>
              <th>Счет<br/>Дата счета</th>
              <th>Контейнеры</th>
              <th>Срок оплаты</th>
              <th>К оплате<br/>в.т.ч. простой<br/>в.т.ч. переадресация</th>
              <th>Оплачено<br/>(Дата)</th>
              <th>Долг</th>
            </tr>
          </thead>
          <tbody>
          <g:each in="${searchresult.records}" status="i" var="record">
            <tr align="center" style="line-height:16px;font-size:11px">
              <td>${record.norder}<br/>${String.format('%td.%<tm.%<tY',record.orderdate)}</td>
              <td><g:rawHtml>${record.contnumbers.split(',').join('<br/>')}</g:rawHtml></td>
              <td>${!record.debt?'оплачено':record.maxpaydate?String.format('%td.%<tm.%<tY',record.maxpaydate):'документы не переданы'}</td>
              <td>${record.fullcost+record.idlesum+record.forwardsum}<br/>${record.idlesum}<br/>${record.forwardsum}</td>
              <td>${record.paid?:''}<br/>${record.lastpayment?String.format('%td.%<tm.%<tY',record.lastpayment):'нет'}</td>
              <td>${record.debt>0&&record.maxpaydate?.before(new Date().clearTime())?record.debt:'нет'}</td>
            </tr>
          </g:each>
            <tr><td></td><td colspan="2">ИТОГО ЗАКАЗОВ</td><td>${searchresult.records?.size()?:0}</td><td colspan="2"></td></tr>
            <tr><td></td><td colspan="2">ИТОГО ОБОРОТ</td><td>${pricesum}</td><td colspan="2"></td></tr>
            <tr><td></td><td colspan="2">ИТОГО ЗАДОЛЖЕННОСТЬ С УЧЕТОМ ПЕРЕПЛАТ</td><td>${arrearssum}</td><td colspan="2"></td></tr>
            <tr><td></td><td colspan="2">ИТОГО ДОЛГ</td><td>${debtsum}</td><td colspan="2"></td></tr>
          </tbody>
        </table>
      </div>
    </g:if>
    </div>
  </body>
</html>