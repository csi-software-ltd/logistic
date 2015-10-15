<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <style type="text/css">
      @font-face {
        src: url('http://containerovoz.ru:80/font/arial.ttf');
        -fs-pdf-font-embed: embed;
        -fs-pdf-font-encoding: cp1251;
      }
      body { font-family: "Arial Unicode MS", Arial, sans-serif; }
      body { width: 210mm; margin-left: auto; margin-right: auto; font-size: 10px; }
      table.invoice_bank_rekv { border-collapse: collapse; border: 1px solid; }
      table.invoice_bank_rekv > tbody > tr > td, table.invoice_bank_rekv > tr > td { border: 1px solid; }
      table.invoice_items { border: 1px solid; border-collapse: collapse;}
      table.invoice_items td, table.invoice_items th { border: 1px solid;}
    </style>
  </head>
  <body style="width:600px">
    <table width="600" cellpadding="0" cellspacing="0">
      <tr>
        <td width="100%">
          <div><g:rawHtml>${infotext?.itext?:''}</g:rawHtml></div>
        </td>
      </tr>
    </table>
    <table width="600" cellpadding="2" cellspacing="2" class="invoice_bank_rekv">
      <tr>
        <td colspan="2" rowspan="2" style="min-height:13mm; width: 300px;">
          <table width="300" border="0" cellpadding="0" cellspacing="0" style="height: 13mm;">
            <tr>
              <td valign="top">
                <div>${syscompany?.bank?:''}</div>
              </td>
            </tr>
            <tr>
              <td valign="bottom" style="height: 3mm;">
                <div style="font-size:6pt;">Банк получателя        </div>
              </td>
            </tr>
          </table>
        </td>
        <td style="min-height:7mm;height:auto; width: 25mm;">
          <div>БИK</div>
        </td>
        <td rowspan="2" style="vertical-align: top; width: 60mm;">
          <div style="height: 7mm; line-height: 7mm; vertical-align: middle;margin-bottom:6px">${syscompany?.bik?:''}</div>
          <div>${syscompany?.corschet?:''}</div>
        </td>
      </tr>
      <tr>
        <td style="width: 25mm;">
          <div>Сч. №</div>
        </td>
      </tr>
      <tr>
        <td style="min-height:6mm; height:auto; width: 150px;">
          <div>ИНН ${syscompany?.inn?:''}</div>
        </td>
        <td style="min-height:6mm; height:auto; width: 150px;">
          <div>КПП ${syscompany?.kpp?:''}</div>
        </td>
        <td rowspan="2" style="min-height:19mm; height:auto; vertical-align: top; width: 25mm;">
          <div>Сч. №</div>
        </td>
        <td rowspan="2" style="min-height:19mm; height:auto; vertical-align: top; width: 60mm;">
          <div>${syscompany?.account?:''}</div>
        </td>
      </tr>
      <tr>
        <td colspan="2" style="min-height:13mm; height:auto;">
          <table border="0" cellpadding="0" cellspacing="0" style="height: 13mm; width: 300px;">
            <tr>
              <td valign="top">
                <div>${syscompany?.name?:''}</div>
              </td>
            </tr>
            <tr>
              <td valign="bottom" style="height: 3mm;">
                <div style="font-size: 6pt;">Получатель</div>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
    <br/>

    <div style="font-weight: bold; font-size: 16pt; padding-left:5px;width:600px">
      Счет на оплату № ${payorder.norder} от ${String.format('%td.%<tm.%<tY',payorder.orderdate)}</div>
    <br/>

    <div style="background-color:#000000; width:600px; font-size:1px; height:2px;">&nbsp;</div>

    <table width="600">
      <tr>
        <td style="width: 30mm;">
          <div style="padding-left:2px;">Поставщик:    </div>
        </td>
        <td>
          <div style="font-weight:bold;  padding-left:2px;">
            ${syscompany?.name+', ИНН '+(syscompany?.inn?:'')+', КПП '+(syscompany?.kpp?:'')+', '+(syscompany?.fulladdress?:'')}
          </div>
        </td>
      </tr>
      <tr>
        <td style="width: 30mm;">
          <div style="padding-left:2px;">Покупатель:    </div>
        </td>
        <td>
          <div style="font-weight:bold;  padding-left:2px;">
            ${clientrequisites?.payee?(clientrequisites?.payee+', ИНН '+(clientrequisites?.inn?:'')+', КПП '+(clientrequisites?.kpp?:'')+', '+(clientrequisites?.address?:'')):'Укажите полной название покупающей организации'}
          </div>
        </td>
      </tr>
    </table>

    <table class="invoice_items" width="600" cellpadding="2" cellspacing="2">
      <thead>
        <tr>
          <th style="width:13mm;">№</th>
          <th>Товары (работы, услуги)</th>
          <th style="width:20mm;">Кол-во</th>
          <th style="width:17mm;">Ед.</th>
          <th style="width:27mm;">Цена</th>
          <th style="width:27mm;">Сумма</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${payorder.contcarnumbers.split(',')}" var="record" status="i">
        <tr>
          <td align="center">${i+1}</td>
          <td align="left">Транспортно-экспедиционное обслуживание за доставку контейнера № ${record}</td>
          <td align="right">1</td>
          <td align="left">шт</td>
          <td align="right">${payorder.fullcost/payorder.contcarnumbers.split(',').size()}</td>
          <td align="right">${payorder.fullcost/payorder.contcarnumbers.split(',').size()}</td>
        </tr>
      </g:each>
      <g:if test="${payorder.idlesum}">
        <tr>
          <td align="center">${payorder.contcarnumbers.split(',').size()+1}</td>
          <td align="left">Простой</td>
          <td align="right">1</td>
          <td align="left">шт</td>
          <td align="right">${payorder.idlesum}</td>
          <td align="right">${payorder.idlesum}</td>
        </tr>
      </g:if>
      <g:if test="${payorder.forwardsum}">
        <tr>
          <td align="center">${payorder.contcarnumbers.split(',').size()+1}</td>
          <td align="left">Переадресация</td>
          <td align="right">1</td>
          <td align="left">шт</td>
          <td align="right">${payorder.forwardsum}</td>
          <td align="right">${payorder.forwardsum}</td>
        </tr>
      </g:if>
      </tbody>
    </table>
    
    <table border="0" width="600" cellpadding="1" cellspacing="1">
      <tr>
        <td></td>
        <td style="width:27mm; font-weight:bold;  text-align:right;">Итого:</td>
        <td style="width:27mm; font-weight:bold;  text-align:right;">${payorder.fullcost+payorder.idlesum+payorder.forwardsum}</td>
      </tr>
      <tr>
        <td></td>
      <g:if test="${syscompany?.nds}">
        <td style="width:27mm; font-weight:bold;  text-align:right;">В том числе НДС:</td>
        <td style="width:27mm; font-weight:bold;  text-align:right;">${Math.rint((payorder.fullcost+payorder.idlesum+payorder.forwardsum)*syscompany.nds*100/(syscompany.nds+100))/100}</td>
      </g:if><g:else>
        <td style="width:27mm; font-weight:bold;  text-align:right;">Без налога (НДС)</td>
        <td style="width:27mm; font-weight:bold;  text-align:right;">-</td>
      </g:else>
      </tr>
      <tr>
        <td></td>
        <td style="width:27mm; font-weight:bold;  text-align:right;">Всего к оплате:</td>
        <td style="width:27mm; font-weight:bold;  text-align:right;">${payorder.fullcost+payorder.idlesum+payorder.forwardsum}</td>
      </tr>
    </table>

    <br />
    <div>Всего наименований 1 на сумму ${payorder.fullcost+payorder.idlesum+payorder.forwardsum} рублей.<br />${priceASstring?:''}</div>
    <br /><br />
    <div style="background-color:#000000; width:600px; font-size:1px; height:2px;">&nbsp;</div>
    <br/>
    <div style="position:relative">
      <div>Руководитель ______________________ (${syscompany?.chief})</div>
    <g:if test="${chiefsign}">
      <div style="position:absolute;width:75px;height:40px;top:-20px;left:120px"><img height="35" src="${resource(dir:'images',file:chiefsign,absolute:true)}" /></div>
    </g:if>
    </div>
    <br/>
    <div style="position:relative">
      <div>Главный бухгалтер ______________________ (${syscompany?.accountant})</div>
    <g:if test="${accountantsign}">
      <div style="position:absolute;width:75px;height:40px;top:-10px;left:110px"><img height="25" src="${resource(dir:'images',file:accountantsign,absolute:true)}" /></div>
    </g:if>
    </div>
    <br/>
    <div style="position:relative">
      <div style="width: 85mm;text-align:center;">М.П.</div>
    <g:if test="${syscompany?.stampname}">
      <div style="position:absolute;width:135px;height:135px;top:-60px;left:90px"><img height="135" src="${resource(dir:'images',file:syscompany.stampname,absolute:true)}" /></div>
    </g:if>
    </div>
    <br/>
    <div style="width:600px;text-align:left;font-size:10pt;"><g:rawHtml>${infotext?.itext2?:''}</g:rawHtml></div>
  </body>
</html>