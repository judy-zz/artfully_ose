function Performance(data) { this.load(data); }
Performance.prototype = {
  id: "",
  datetime: "",
  $target: null,

  render: function(target){
    this.$target = $(document.createElement('li')).appendTo(target);

    $(document.createElement('span'))
    .addClass('performance-datetime')
    .text(this.datestring(this.datetime))
    .appendTo(this.$target);

    $(document.createElement('a'))
    .addClass('ticket-search')
    .text('Buy Tickets')
    .click({performance: this}, function(e){
      e.data.performance.render_form();
    })
    .appendTo(this.$target);

    return Boolean(this.$target);
  },

  load: function(data){
    this.datetime = new Date(data.datetime);
    this.id = data.id;
  },

  datestring: function(datetime){
    return datetime.toLocaleDateString() + " " + datetime.toLocaleTimeString();
  },

  render_form: function(){
    new TicketSearchForm().render(this.$target);

    this.$target.children('.ticket.submit').click({performance:this},function(e){
      params = {
        performance: e.data.performance,
        price:$('input.ticket-price').value(),
        quantity:$('input.ticket-quantity').value()
      };

      add_tickets(Ticket.find(e.data.params)) && render_tickets();
    })
  },

  uri: function(id){
    return "http://localhost:3000/performances/" + id + ".jsonp?callback=?";
  },

  add_tickets: function(data){
    for(var i = 0; i < data.length; i++){
      this.tickets.push(new Ticket(data[i]));
    }
    return (this.tickets.length > 0);
  },

  render_tickets: function(){
    var $ul = $(document.createElement('ul'))
              .appendTo(this.$target);

    for(var i = 0; i < this.tickets.length; i++){
      this.tickets[i].render($ul);
    }
  }
};