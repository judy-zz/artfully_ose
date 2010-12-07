function display_event(data){
  $("#event").append($(document.createElement('h1')).text(data['name']))
  $("#event").append($(document.createElement('h2')).text(data['venue']))
  $("#event").append($(document.createElement('h2')).text(data['producer']))
}

function display_performances(performances){
  $("#event").append($(document.createElement('ul')).addClass('performances'));
  for (var i = 0; i < performances.length; i++){
	var $dt = new Date(performances[i]['datetime'])
    $(".performances").append($(document.createElement('li')).text($dt.toLocaleDateString() + " " + $dt.toLocaleTimeString());
  }
}