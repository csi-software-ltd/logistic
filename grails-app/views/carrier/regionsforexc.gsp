<g:if test="${regions}">
<div class="grid_11 alpha">
  <fieldset id="regionset" class="bord" style="width:920px">
    <legend>Кроме регионов:</legend>
    <table width="100%" cellpadding="0" cellspacing="0" border="0">    
    <g:each in="${regions}" var="region" status="i">
      <g:if test="${(i % 4)==0}"><tr></g:if>
        <td width="25%">
          <label class="nopadd" for="${region.name}">
            <input type="checkbox" name="regions" value="${region.id}" />${region.name}
          </label>
        </td>
      <g:if test="${((i % 4)==0) && (regions.size() == 1)}">
        <td width="25%">&nbsp;</td><td width="25%">&nbsp;</td><td width="25%">&nbsp;</td>
      </g:if><g:elseif test="${((i % 4)==1) && (regions.size() == 2)}">
        <td width="25%">&nbsp;</td><td width="25%">&nbsp;</td>
      </g:elseif><g:elseif test="${((i % 4)==2) && (regions.size() == 3)}">
        <td width="25%">&nbsp;</td>
      </g:elseif><g:elseif test="${(i % 4)==3}">
      </tr>
      </g:elseif>                  
    </g:each>
    </table>
  </fieldset>
</div>
<div class="clear"></div>
<div class="btns padding-bottom3">
  <input type="submit" id="submit_button" class="button" value="Сохранить" />
  <input type="button" class="button" onclick="checkallregion()" value="Отметить все" />
  <input type="reset" class="button" value="Отмена" onclick="jQuery('#selectExcRegionForm').slideUp();"/>
</div>
</g:if>
