var Config = {
  base_uri: 'http://localhost:3000/'
};

$.ajaxSetup({
  beforeSend: function(xhr) {xhr.setRequestHeader("Accept","text/javascript")}
})

var E;
EventWidget = function(id, options){
  Config = $.extend(Config, options);
  $.getJSON(Event.uri(id), function(data){
    E = new Event(data);
    E.render($('#event'));
  });
};