<html>
  <head>
    <title>Административное приложение containerovoz.ru</title>
    <meta name="layout" content="admin" />
    <g:javascript>  
      function selectOnchange(el){
        var objSel = document.getElementById(el); 
        var statusID = objSel.options[objSel.selectedIndex].value;      
        if (statusID == 1)
          objSel.className = 'icon active always';
        else if(statusID == 0)
          objSel.className = 'icon inactive always';
      }	
      function returnToList(){
        $("returnToListForm").submit();
      }
      function textCounter(sId,sLimId,iMax){
        var symbols = $F(sId);
        var len = symbols.length;
        if(len > iMax){
          symbols = symbols.substring(0,iMax);
          $(sId).value = symbols;
          return false;
        }
        $(sLimId).value = iMax-len;
      }
    </g:javascript>
    <style type="text/css">
      .contact-form fieldset{width:944px!important}
      .contact-form label{padding:0;margin:0}
      .contact-form input[type="text"],.contact-form textarea{width:98%}
      .contact-form input.limit{width:25px;}      
      .contact-form textarea{height:100px}      
    </style>
  </head>  
  <body onload="textCounter('title1','titles_limit',250);textCounter('keywords1','keywords_limit',255);">
  <g:if test="${flash?.save_error}">
    <div class="error-box">
      <span class="icon icon-warning-sign icon-3x"></span>
      <ul>
        <g:if test="${flash?.save_error==101}"><li>Непоправимая ошибка. Данные не сохранены.</li></g:if>
      </ul>
    </div>
  </g:if>
    <h1>${type!=1?'Инфотекст':'Шаблон письма'} &laquo;${inrequest.name}&raquo;</h1>
    <a class="link fright" href="javascript:void(0)" onclick="returnToList()">К списку ${type!=1?'инфотекстов':'шаблонов'}</a>
    <div class="clear"></div>
    <g:form class="contact-form nopad" name="infotexteditForm" url="[controller:'administrators',action:'infotextedit', id:inrequest.id]" method="post">
      <g:if test="${type!=1}">
      <fieldset class="bord">
        <legend>Метатеги</legend>
        <label for="title1">Title:</label>
        <textarea class="nopad" id="title1" rows="5" cols="40" name="title" onkeydown="textCounter(this.id,'titles_limit',250);" onkeyup="textCounter(this.id,'titles_limit',250);">${inrequest?.title}</textarea>
        <font color="#025fbf" nowrap>осталось <input type="text" class="limit" id="titles_limit" readonly /> символов</font><br/>
        <label class="button-top" for="keywords1">Keywords:</label>
        <textarea class="nopad" id="keywords1" rows="5" cols="40" name="keywords" onkeydown="textCounter(this.id,'keywords_limit',255);" onkeyup="textCounter(this.id,'keywords_limit',255);">${inrequest?.keywords?:''}</textarea>
        <font color="#025fbf" nowrap>осталось <input type="text" class="limit" id="keywords_limit" readonly /> символов</font><br/>
        <label class="button-top" for="description">Description:</label>
        <textarea class="nopad" rows="5" cols="40" name="description">${inrequest?.description?:''}</textarea>
      </fieldset>
      <fieldset class="bord">
        <legend>Заголовки</legend>
        <label for="header">H1:</label>
        <input type="text" name="header" value="${inrequest?.header?:''}" />
        <label for="promotext1">К промо-тексту 1:</label>
        <input type="text" name="promotext1" value="${inrequest?.promotext1?:''}" />
        <label for="promotext2">К промо-тексту 2:</label>
        <input type="text" name="promotext2" value="${inrequest?.promotext2?:''}" />
      </fieldset>
      <fieldset class="bord">      
        <legend>Промо-тексты</legend>
        <label for="itext">Промотекст 1:</label>
        <fckeditor:editor name="itext" height="300" toolbar="LG" fileBrowser="default">
          <g:rawHtml>${inrequest?.itext}</g:rawHtml>
        </fckeditor:editor>            
        <label for="itext2">Промотекст 2:</label>
        <fckeditor:editor name="itext2" height="300" toolbar="LG" fileBrowser="default">
          <g:rawHtml>${inrequest?.itext2?:''}</g:rawHtml>
        </fckeditor:editor>            
        <label for="itext3">Промотекст 3:</label>
        <fckeditor:editor name="itext3" height="300" toolbar="LG" fileBrowser="default">
          <g:rawHtml>${inrequest?.itext3?:''}</g:rawHtml>
        </fckeditor:editor>
      </fieldset>
      </g:if><g:else>
      <fieldset>
        <label for="name">Название:</label>
        <textarea rows="5" cols="40" name="name">${inrequest?.name}</textarea>
        <label for="title">Тема письма:</label>
        <textarea rows="5" cols="40" name="title">${inrequest?.title}</textarea>        
        <label for="itext">Текст письма:</label>
        <fckeditor:editor name="itext" height="300" toolbar="LG" fileBrowser="default">
          <g:rawHtml>${inrequest?.itext}</g:rawHtml>
        </fckeditor:editor>
      </fieldset>
      </g:else>      
      <div class="btns">
        <input type="submit" class="button" value="Сохранить"/>
      </div>
      <input type="hidden" id="save" name="save" value="1" />
      <input type="hidden" id="type" name="type" value="${type?:0}" />
    </g:form>    
    <g:form name="returnToListForm" url="${[controller:'administrators',action:'infotext', params:[fromEdit:1, type:type?:0]]}">
    </g:form>    
  </body>
</html>
