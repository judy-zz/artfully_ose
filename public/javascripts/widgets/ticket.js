function Ticket(data){ this.load(data); }

Ticket.find = function(data){
  params = {
    performance:data.performance,
    price: data.price,
    quantity: data.quantity
  };

  $.getJSON(Ticket.search_uri(params), function(data){
    return data;
  });
};

Ticket.search_uri = function(params){
  var uri = Ticket.base_uri;
  for(var param in params){
    uri += "&" + param + "=eq" + params[param];
  }
  return uri;
}

Ticket.prototype = {
  event: null,
  venue: null,
  performance: null,
  price: null,

  base_uri:"http://localhost:3000/tickets.jsonp?callback=?",

  load: function(data){
    this.event = data.event;
    this.venue = data.venue;
// TODO: Global date formatter?
//    this.performance = new Date(data.performance);
    this.performance = data.performance;
    this.price = data.price;
  },

  render: function($target){
    this.$target = $target.addClass('ticket')

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

function TicketSearchForm(){}

TicketSearchForm.prototype = {

  render: function($target){
    $form = $(document.createElement('form'));
    this.render_price($form);
    this.render_quantity($form);
    this.render_submit($form);

    $form.appendTo($target);
  },

  render_price: function($form){
    $(document.createElement('input'))
    .addClass('ticket-price')
    .attr({type:'text',name:'price'})
    .appendTo($form);
  },

  render_quantity: function($form){
    $(document.createElement('input'))
    .addClass('ticket-quantity')
    .attr({type:'text', name:'quantity'})
    .appendTo($form);
  },

  render_submit: function($form){
    $(document.createElement('input'))
    .addClass('ticket-submit')
    .attr({type:'submit', value:'Search'})
    .appendTo($form);
  }
};