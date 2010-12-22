function Performance(data) { this.load(data); }
Performance.prototype = {
  id: "",
  datetime: "",
  $target: null,

  render: function(target){
    this.$target = $(document.createElement('li'))
                    .appendTo(target);

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
    var $form = $(document.createElement('form'))
                .appendTo(this.$target);

    this.render_price($form);
    this.render_quantity($form);
    this.render_submit($form)
  },

  render_price: function($form){
    return $(document.createElement('input'))
    .addClass('ticket-price')
    .attr('type','text')
    .attr('name','price')
    .appendTo($form);
  },

  render_quantity: function($form){
    return $(document.createElement('input'))
    .addClass('ticket-quantity')
    .attr('type','text')
    .attr('name','quantity')
    .appendTo($form);
  },

  render_submit: function($form){
    return $(document.createElement('input'))
    .addClass('ticket-submit')
    .attr('type','submit')
    .attr('value','Search')
    .click({performance:this},function(e){
      $.getJSON(e.data.performance.uri(e.data.performance.id), function(data){
        e.data.performance.create_tickets(data);
      });
    })
    .appendTo($form);
  },

  uri: function(id){
    return "http://localhost:3000/performances/" + id + ".jsonp?callback=?";
  }
  create_tickets: function(data){
    for(var i = 0; i < data.length; i++){
      this.tickets.push(new Ticket(data[i]));
    }
  }
};