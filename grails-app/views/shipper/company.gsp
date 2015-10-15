<html>
  <head>
    <title>${infotext?.title?:''}</title>    
    <meta name="keywords" content="${infotext?.keywords?:''}" />
    <meta name="description" content="${infotext?.description?:''}" />
    <meta name="layout" content="main" />
  </head>
  <body>
    <h1>${infotext?.header?:''}</h1>
    <fieldset class="contact-form">  
      <div class="grid_6 alpha">
        <label for="fullname">Название:</label>
        <input type="text" disabled value="${client?.fullname}" />
        <label for="name">Email:</label>
        <input type="text" disabled value="${client?.name}" />
        <label for="payee">Получатель:</label>
        <input type="text" disabled value="${requisites?.payee}" />
        <label for="inn">ИНН:</label>
        <input type="text" disabled value="${requisites?.inn}" />
        <label for="kpp">КПП:</label>
        <input type="text" disabled value="${requisites?.kpp}" />
        <label for="bankname">Название банка:</label>
        <input type="text" disabled value="${requisites?.bankname}" />
        <label for="bik">БИК:</label>
        <input type="text" disabled value="${requisites?.bik}" />
      </div>
      <div class="grid_6 omega">
        <label for="ctype_id">Тип компании:</label>
        <g:select name="ctype_id" value="${requisites?.ctype_id}" keys="${1..3}" from="${['ООО', 'ИП', 'ЗАО']}" noSelection="${['0':'Не задано']}" disabled="disabled" />
        <label for="nds">НДС, %:</label>
        <input type="text" disabled value="${requisites?.nds}" />
        <label for="corraccount">Корр. счет:</label>
        <input type="text" disabled value="${requisites?.corraccount}" />
        <label for="settlaccount">Расчетный счет:</label>
        <input type="text" disabled value="${requisites?.settlaccount}" />
        <label for="ogrn">ОГРН:</label>
        <input type="text" disabled value="${requisites?.ogrn}" />
        <label for="license">Лицензия:</label>
        <input type="text" disabled value="${requisites?.license}" />
        <label for="address">Адрес:</label>
        <input type="text" disabled value="${requisites?.address}" />
      </div>
    </fieldset>
  </body>
</html>
