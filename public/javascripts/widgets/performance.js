function Performance(data) { this.load(data); }
function PerformanceForm(){}

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
    new PerformanceForm().render(this.$target);

    this.$target.children('.ticket.submit').click({performance:this},function(e){
      params = {
        performance: e.data.performance,
        price:$('input.ticket-price').value(),
        quantity:$('input.ticket-quantity').value()
      };
      var form = new TicketForm(Ticket.find(e.data.params));
      form.render(this.$target);
    });
  },

  uri: function(id){
    return "http://localhost:3000/performances/" + id + ".jsonp?callback=?";
  }
};

PerformanceForm.prototype = {

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