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
  <g:if test="${!report}">
    <h1>Нет данных за указанный период</h1>
  </g:if><g:else>
    <div>
      <div style="float:left;font-size:9pt">Отчет по заказам за ${reportMonth} ${reportYear}г.</div>
      <div style="clear:both;text-align:center"></div><br/>
      <table style="width:1020px;font-size:9pt">
        <thead>
          <tr>
            <th>Номер</th>
            <th>Дата начала</th>
            <th>Отправитель</th>
            <th>Тип контейнера</th>
            <th>Кол-во<br/>контейнеров</th>
            <th>Маршрут</th>
            <th>Кол-во<br/>поездок</th>
            <th>Ставка<br/>отправителя</th>
            <th>Сумма<br/>заказа</th>
            <th>Сумма<br/>услуг по перевозке</th>
          </tr>
        </thead>
        <tbody>
        <g:each in="${report}" var="record">
          <tr>
            <td>${record.id}</td>
            <td>${String.format('%td/%<tm/%<tY',record.date_start)}</td>
            <td>${record.shippername}</td>
            <td>${containers[record.container]}</td>
            <td>${record.zcol}</td>
            <td>${record.addressA}<g:if test="${record.addressB}"><br/>${record.addressB}</g:if><g:if test="${record.addressC}"><br/>${record.addressC}</g:if><g:if test="${record.addressD}"><br/>${record.addressD}</g:if></td>
            <td>${record.tripcount}</td>
            <td>${record.price}</td>
            <td>${record.price*record.zcol}</td>
            <td>${record.trippricesum}</td>
          </tr>
        </g:each>
          <tr>
            <td>ИТОГО</td>
            <td>${report.size()}</td>
            <td colspan="4"></td>
            <td>${tripcount}/${carriersum}</td>
            <td></td>
            <td>${priceshsum}</td>
            <td>${pricesum}</td>
          </tr>
          <tr>
            <td colspan="2">ИТОГО ДОХОД</td>
            <td>${priceshsum-pricesum}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </g:else>
  </body>
</html>