var Config = {
  base_uri: 'http://localhost:3000/',
  maxHeight: '200'
};

var E;
EventWidget = function(id, options){
  Config = $.extend(Config, options);
  $.getJSON(Event.uri(id), function(data){
    E = new Event(data);
    E.render($('#event'));
  });
  ShoppingCart.$cart.appendTo('body')
};