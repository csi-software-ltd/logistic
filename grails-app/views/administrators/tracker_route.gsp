<script type="text/javascript">
  aTracker_route=[];
  <g:each in="${tracker_route}">
    var tmp={y:${it.y},x:${it.x},kurs:${it.kurs},tracktime:"${String.format('%tF %<tT', it?.tracktime)}",speed:${it.speed}};
    aTracker_route.push(tmp);
  </g:each>
  if(aTracker_route.length)
    proccessTrackerRoute();
  else{    
    bTrackerPlace=true;
    showTracker(1);
    $("tracker_tmp").update('');
  }      
</script>
