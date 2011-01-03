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
    if(params.hasOwnProperty(param)){
      uri += "&" + param + "=eq" + params[param];
    }
  }
  return uri;
};

Ticket.prototype = {
  id: null,
  event: null,
  venue: null,
  performance: null,
  price: null,

  base_uri:"http://localhost:3000/tickets.jsonp?callback=?",

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

function TicketForm(data) { this.load(data); }

TicketForm.prototype = {
  load: function(data){
    this.tickets = [];
    for(var i = 0; i < data.length; i++){
      this.tickets.push(new Ticket(data[i]));
    }
  },

  render: function($target){
    if (this.tickets.length > 0){
      var $form = $(document.createElement('form'))
                  .attr({'method': 'post','action': 'http://localhost:3000/orders'})
                  .submit(ShoppingCart.submit_tickets(this))
                  .appendTo($target);

      var $ul = $(document.createElement('ul')).appendTo($form);
      var $li = $(document.createElement('li'));
      $li.append($(document.createElement('input'))
          .attr({'type':'checkbox','name':'tickets[]','checked':'checked'}));

      for(var i = 0; i < this.tickets.length; i++){
        var tmp = $li.clone();
        tmp.children('input:checkbox').attr('value',this.tickets[i].id);
        this.tickets[i].render(tmp.appendTo($ul));
      }

      $(document.createElement('input'))
      .attr({type:'submit', value:'Add to Cart'})
      .appendTo($form);
    }
  }
};