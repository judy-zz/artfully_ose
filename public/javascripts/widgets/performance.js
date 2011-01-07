function Performance(data) { this.load(data); }
function PerformanceForm(){}

Performance.uri = function(id){
  return Config.base_uri + 'performances/' + id + '.jsonp?callback=?';
}

Performance.prototype = {
  render: function(target){
    this.$target = $(document.createElement('li')).appendTo(target);

    $(document.createElement('span'))
    .addClass('performance-datetime')
    .text(this.datestring(this.datetime))
    .appendTo(this.$target);

    $(document.createElement('a'))
    .addClass('ticket-search')
    .text('Buy Tickets')
    .attr("href","#")
    .click({performance: this}, function(e){
      E.charts[e.data.performance.chart_id].render(e.data.performance.$target);
      return false;
    })
    .appendTo(this.$target);

    return Boolean(this.$target);
  },

  load: function(data){
    this.datetime = new Date(data.datetime);
    this.chart_id = data.chart_id;
    this.id = data.id;
  },

  datestring: function(datetime){
    return datetime.toLocaleDateString() + " " + datetime.toLocaleTimeString();
  },

  render_form: function($target){
    new PerformanceForm().render($target);

    $('#performance-form').submit({performance:this},function(e){
      var form;

      Ticket.find(params, function(data){
        form = new TicketForm(data);
        form.render($target);
      });

      return false;
    });
  }
};

PerformanceForm.prototype = {
  render: function($target){
    var $form = $('#performance-form');
    if($form.length == 0){
      $form = $(document.createElement('form')).attr('id','performance-form');
      this.render_price($form);
      this.render_quantity($form);
      this.render_submit($form);
    }
    $target.append($form);
  },

  render_price: function($form){
    $(document.createElement('label'))
    .attr({'for':'ticket-price'})
    .text("Price")
    .appendTo($form);

    $(document.createElement('input'))
    .addClass('ticket-price')
    .attr({type:'text',name:'price'})
    .appendTo($form);
  },

  render_quantity: function($form){
    $(document.createElement('label'))
    .attr({'for':'ticket-quantity'})
    .text("Quantity")
    .appendTo($form);

    $(document.createElement('input'))
    .addClass('ticket-quantity')
    .attr({type:'text', name:'_limit'})
    .appendTo($form);
  },

  render_submit: function($form){
    $(document.createElement('input'))
    .addClass('ticket-submit')
    .attr({type:'submit', value:'Search'})
    .appendTo($form);
  }
};