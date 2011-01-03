var Config = {
  base_uri: 'http://localhost:3000/'
};

$.ajaxSetup({
  beforeSend: function(xhr) {xhr.setRequestHeader("Accept","text/javascript")}
})

EventWidget = function(id, options){
  Config = $.extend(Config, options);

  var event;

  $.getJSON(Event.uri(id), function(data){
    event = new Event(data);
    event.render($('#event'));
  });
};