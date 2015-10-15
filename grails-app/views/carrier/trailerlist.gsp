<div id="trailerEditForm" style="display:none"></div>
<div class="clear"></div>
<div id="ajax_wrap">
  <div id="resultList">
    <table class="list" width="100%" cellpadding="0" cellspacing="0" border="0">
      <thead>
        <th>Код</th>
        <th>Номер</th>
        <th>Тип прицепа</th>
        <th>Тягачи</th>
        <th>Действия</th>
      </thead>
      <tbody>
      <g:each in="${trailers}" status="i" var="record">
        <tr>
          <td align="center">${record.id}</td>
          <td>${record.trailnumber}</td>
          <td>${record.trailertype_id==1?'короткий':record.trailertype_id==2?'длинный':'не задано'}</td>
          <td>${carTrailers_id[record.id].collect{ car_id -> cars.find{it.id==car_id}?.gosnomer }.findAll({it != null}).join(', ')}</td>
          <td class="btns" style="text-align:center" nowrap>
            <a class="button" href="javascript:void(0)" title="Редактировать" onclick="editTrailer(${record.id});"><i class="icon-pencil"></i></a>
          </td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
</div>
<g:formRemote name="trailerdetailForm" url="[action:'trailerdetail']" update="[success:'trailerEditForm']" onComplete="jQuery('#trailerEditForm').slideDown();" style="display:none">
  <input type="text" id="trailer_id" name="trailer_id" value=""/>
  <input type="submit" class="button" id="trailerDetail_submit_button" value="Показать"/>
</g:formRemote>
