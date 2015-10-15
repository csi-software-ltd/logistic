<g:if test="${containers}">
<div class="grid_11 alpha">
  <fieldset id="containerset" class="bord" style="width:920px">
    <legend>Допустимые типы контейнеров:</legend>
    <table width="100%" cellpadding="0" cellspacing="0" border="0">
    <g:each in="${containers}" var="cont" status="i">
      <g:if test="${(i % 2)==0}"><tr></g:if>
        <td width="25%">
          <label class="nopadd" for="${cont.name}">
            <input type="checkbox" name="containers" value="${cont.id}" />${cont.name}
          </label>
        </td>
      <g:if test="${((i % 2)==0) && (containers.size() == 1)}">
        <td width="50%">&nbsp;</td>
      </g:if><g:elseif test="${(i % 2)==1}">
      </tr>
      </g:elseif>
    </g:each>
    </table>
  </fieldset>
</div>
<div class="clear"></div>
<div class="btns">
  <input type="submit" id="submit_button" class="button" value="Сохранить" />
  <input type="button" class="button" onclick="checkallcont()" value="Отметить все" />
  <input type="reset" class="button" value="Отмена" onclick="jQuery('#selectAcceptContForm').slideUp();"/>
</div>
</g:if>
