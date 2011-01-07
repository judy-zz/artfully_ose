function Ticket(data){ this.load(data); }

var Config = {
  base_uri: 'http://localhost:3000/'
};

Ticket.uri = Config.base_uri + 'tickets.jsonp?callback=?';

Ticket.find = function(params, callback){
  $.getJSON(Ticket.search_uri(params), function(data){
    callback(data);
  });
};

Ticket.search_uri = function(params){
  var uri = this.uri;
  for(var param in params){
    if(params.hasOwnProperty(param)){
      if(param != "limit"){
        uri += "&" + param + "=eq" + params[param];
      } else {
        uri += "&" + param + "=" + params[param];
      }
    }
  }
  return uri;
};

Ticket.prototype = {
  load: function(data){
    this.id = data.id;
    this.event = data.event;
    this.venue = data.venue;
// TODO: Global date formatter?
//    this.performance = new Date(data.performance);
    this.performance = data.performance;
    this.price = data.price;
  },

  render: function($target){
    this.$target = $target.addClass('ticket');

    $(document.createElement('span'))
    .addClass('ticket-event')
    .text(this.event)
    .appendTo(this.$target);

    $(document.createElement('span'))
    .addClass('ticket-date')
    .text(this.performance)
    .appendTo(this.$target);

    return $target;
  }
};