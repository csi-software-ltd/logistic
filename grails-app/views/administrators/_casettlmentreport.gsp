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
              <th>Заказ<br/>Дата заказа</th>
              <th>Поездка</th>
              <th>Водитель<br/>Тягач</th>
              <th>Маршрут</th>
              <th>Контейнеры</th>
              <th>Дата сдачи<br/>документов</th>
              <th>К оплате<br/>ставка<br/>простой<br/>переадресация<br/>абон. плата</th>
              <th>Оплачено<br/>(Дата)</th>
              <th>Срок оплаты</th>
              <th>Долг</th>
              <th>Платежи<br/>Дата Сумма Номер</th>
            </tr>
          </thead>
          <tbody>
          <g:each in="${searchresult.records}" status="i" var="record">
            <tr align="center" style="line-height:16px;font-size:11px">
              <td>${record.zakaz_id}<br/>${String.format('%td.%<tm.%<tY',record.zakazdate)}</td>
              <td>${record.id}</td>
              <td>${record.drivername}<br/>${record.cargosnomer}</td>
              <td>${record.is_longtrip?'дальний':'ближний'}</td>
              <td>${record.cont1}<g:if test="${record.cont2}"><br/>${record.cont2}</g:if></td>
              <td>${record.docdate?String.format('%td.%<tm.%<tY',record.docdate):'документы не сданы'}</td>
              <td>${record.ca_price+(record.cont2?record.ca_price:0)+record.ca_idlesum+record.ca_forwardsum-record.ca_trackertax}<br/>${record.ca_price}<br/>${record.ca_idlesum}<br/>${record.ca_forwardsum}<br/>${record.ca_trackertax}</td>
              <td>${record.ca_paid?:''}<br/>${record.ca_lastpaydate?String.format('%td.%<tm.%<tY',record.ca_lastpaydate):'нет'}</td>
              <td>${record.ca_maxpaydate?String.format('%td.%<tm.%<tY',record.ca_maxpaydate):'документы не сданы'}</td>
              <td>${record.debt>0&&record.ca_maxpaydate?.before(new Date().clearTime())?record.debt:'нет'}</td>
              <td><g:each in="${payments[record.id]}" var="payment">${String.format('%td.%<tm.%<tY',payment.paydate)} ${payment.summa} ${payment.norder}<br/></g:each></td>
            </tr>
          </g:each>
            <g:if test="${inrequest.client_id}"><tr><td colspan="2"></td><td colspan="2">СУММА ОПЛАЧЕННОЙ АБОНЕНТСКОЙ ПЛАТЫ</td><td>${taxsum}</td><td colspan="6"></td></tr></g:if>
            <tr><td colspan="2"></td><td colspan="2">ИТОГО ПОЕЗДОК</td><td>${searchresult.records?.size()?:0}</td><td colspan="6"></td></tr>
            <tr><td colspan="2"></td><td colspan="2">ИТОГО К ВЫПЛАТАМ</td><td>${pricesum}</td><td colspan="6"></td></tr>
            <tr><td colspan="2"></td><td colspan="2">ИТОГО ВЫПЛАЧЕНО</td><td>${paidsum}</td><td colspan="6"></td></tr>
            <tr><td colspan="2"></td><td colspan="2">ИТОГО ЗАДОЛЖЕННОСТЬ</td><td>${pricesum-paidsum}</td><td colspan="6"></td></tr>
            <tr><td colspan="2"></td><td colspan="2">ИТОГО ДОЛГ</td><td>${debtsum}</td><td colspan="6"></td></tr>
          </tbody>
        </table>
      </div>
    </g:if>
    </div>
  </body>
</html>