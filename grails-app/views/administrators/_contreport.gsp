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
    <g:each in="${pages}" var="it" status="i">
    <g:if test="${i}">
      @page report${it} {size: 29.7cm 21cm;}
      .report${it} { page: report${it} }
    </g:if>
    </g:each>
      body { font-family: "Arial Unicode MS", Arial, sans-serif; }
      table { border-top: 2px solid #000; border-left: 1px solid #000; }
      table th { border-bottom: 2px solid #000; border-right: 1px solid #000 }
      table td { border-bottom: 1px solid #000; border-right: 1px solid #000 }
    </style>
  </head>
  <body style="width:1020px">
  <g:each in="${report.records}" var="record" status="i">
  <g:if test="${!manager_id||manager_id==orders[record.id]?.manager_id?:0}">
  <g:if test="${pages.find{it==record.id}}">
  <g:if test="${pages[0]!=record.id}">
        </tbody>
      </table>
    </div>
  </g:if>
    <div class="report${record.id}">
    <g:if test="${i==0}">
      <div style="float:left;font-size:9pt">Отчет по доставленным контейнерам за ${reportMonth} ${reportYear}г.</div><br/>
      <div style="clear:both;text-align:center"></div><br/>
    </g:if>
      <table style="width:1020px;font-size:9pt">
        <thead>
          <tr>
            <th>Дата отправления</th>
            <th>Отправитель</th>
            <th>Маршрут</th>
            <th>Ставка<br/>отправителя</th>
            <th>Ставка<br/>перевозчика<br/>/ возн.</th>
            <th>Доход</th>
            <th>Номер контейнера</th>
            <th>Дата сдачи<br/>документов</th>
            <th>ФИО водителя</th>
            <th>Госномер автомобиля</th>
            <th>Перевозчик</th>
          </tr>
        </thead>
        <tbody>
    </g:if>
          <tr>
            <td>${String.format('%td/%<tm/%<tY',record.dateA)}</td>
            <td>${record.shippername}</td>
            <td>${record.addressA}<g:if test="${record.addressB}"><br/>${record.addressB}</g:if><g:if test="${record.addressC}"><br/>${record.addressC}</g:if><g:if test="${record.addressD}"><br/>${record.addressD}</g:if></td>
            <td>${record.price_sh}</td>
            <td>${record.price} / ${orders[record.id]?.benefit}</td>
            <td>${record.price_sh-record.price-orders[record.id]?.benefit}</td>
            <td>${record.containernumber1}</td>
            <td>${record.taskstatus>5?String.format('%td/%<tm/%<tY',record.docdate):'не сданы'}</td>
            <td>${record.driver_fullname}</td>
            <td>${record.cargosnomer}</td>
            <td>${record.carriername}</td>
          </tr>
        <g:if test="${record.containernumber2}">
          <tr>
            <td>${String.format('%td/%<tm/%<tY',record.dateA)}</td>
            <td>${record.shippername}</td>
            <td>${record.addressA}<g:if test="${record.addressB}"><br/>${record.addressB}</g:if><g:if test="${record.addressC}"><br/>${record.addressC}</g:if><g:if test="${record.addressD}"><br/>${record.addressD}</g:if></td>
            <td>${record.price_sh}</td>
            <td>${record.price} / ${orders[record.id]?.benefit}</td>
            <td>${record.price_sh-record.price-orders[record.id]?.benefit}</td>
            <td>${record.containernumber2}</td>
            <td>${record.taskstatus>5?String.format('%td/%<tm/%<tY',record.docdate):'не сданы'}</td>
            <td>${record.driver_fullname}</td>
            <td>${record.cargosnomer}</td>
            <td>${record.carriername}</td>
          </tr>
        </g:if>
  </g:if>
  </g:each>
  <g:if test="${report?.records&&contcol>0}">
          <tr>
            <td>ИТОГО</td>
            <td colspan="2"></td>
            <td>${priceshsum}</td>
            <td>${pricesum}</td>
            <td>${priceshsum-pricesum-benefitsum}</td>
            <td>${contcol}</td>
            <td colspan="4"></td>
          </tr>
        </tbody>
      </table>
    </div>
  </g:if><g:else>
    <h1>Нет данных за указанный период</h1>
  </g:else>
  </body>
</html>