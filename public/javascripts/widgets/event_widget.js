var Config = {
  base_uri: 'http://localhost:3000/'
};

$.ajaxSetup({
  beforeSend: function(xhr) {xhr.setRequestHeader("Accept","text/javascript")}
})

EventWidget = function(id, options){
  Config = $.extend(Config, options);
  var e;
  $.getJSON(Event.uri(id), function(data){
    e = new Event(data);
    e.render($('#event'));
  });
};