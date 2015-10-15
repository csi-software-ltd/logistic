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
  <g:if test="${!report?.records}">
    <h1>Нет данных за указанный период</h1>
  </g:if><g:else>
    <div>
      <div style="float:left;font-size:9pt">Отчет по доставленным контейнерам за ${reportMonth} ${reportYear}г.</div><br/>
      <div style="clear:both;text-align:center"></div><br/>
      <table style="width:1020px;font-size:9pt">
        <thead>
          <tr>
            <th>Код поездки</th>
            <th>ФИО водителя</th>
            <th>Госномер автомобиля</th>
            <th>Номер контейнера</th>
            <th>Дата отправления</th>
            <th>Дата сдачи<br/>контейнера</th>
            <th>Маршрут</th>
            <th>Ставка</th>
            <th>Дата сдачи<br/>документов</th>
          </tr>
        </thead>
        <tbody>
        <g:each in="${report.records}" var="record">
          <tr>
            <td>${record.id}</td>
            <td>${record.driver_fullname}</td>
            <td>${record.cargosnomer}</td>
            <td>${record.containernumber1}</td>
            <td>${String.format('%td/%<tm/%<tY',record.dateA)}</td>
            <td>${record.taskstatus>4?String.format('%td/%<tm/%<tY',record.taskdate):'не сдан'}</td>
            <td>${record.addressA}<g:if test="${record.addressB}"><br/>${record.addressB}</g:if><g:if test="${record.addressC}"><br/>${record.addressC}</g:if><g:if test="${record.addressD}"><br/>${record.addressD}</g:if></td>
            <td>${record.price}</td>
            <td>${record.docdate?String.format('%td/%<tm/%<tY',record.docdate):'не сданы'}</td>
          </tr>
        <g:if test="${record.containernumber2}">
          <tr>
            <td>${record.id}</td>
            <td>${record.driver_fullname}</td>
            <td>${record.cargosnomer}</td>
            <td>${record.containernumber2}</td>
            <td>${String.format('%td/%<tm/%<tY',record.dateA)}</td>
            <td>${record.taskstatus>4?String.format('%td/%<tm/%<tY',record.taskdate):'не сдан'}</td>
            <td>${record.addressA}<g:if test="${record.addressB}"><br/>${record.addressB}</g:if><g:if test="${record.addressC}"><br/>${record.addressC}</g:if><g:if test="${record.addressD}"><br/>${record.addressD}</g:if></td>
            <td>${record.price}</td>
            <td>${record.docdate?String.format('%td/%<tm/%<tY',record.docdate):'не сданы'}</td>
          </tr>
        </g:if>
        </g:each>
          <tr>
            <td>ИТОГО</td>
            <td colspan="2"></td>
            <td>${contcol}</td>
            <td colspan="3"></td>
            <td>${pricesum}</td>
            <td></td>
          </tr>
        </tbody>
      </table><br/><br/><br/>
    </div>
  </g:else>
  </body>
</html>