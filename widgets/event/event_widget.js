var Config = {
  base_uri: 'http://localhost:3000/'
};

var E;
EventWidget = function(id, options){
  Config = $.extend(Config, options);
  $.getJSON(Event.uri(id), function(data){
    E = new Event(data);
    E.render($('#event'));
  });
};