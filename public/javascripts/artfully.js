(function(window, document, undefined){
  window.artfully = {};
}(this,document));

artfully.config = {
  base_uri: 'http://api.lvh.me:3000/',
  maxHeight: '400'
}

artfully.widgets = (function(){
  var event, cart;

  event = (function(){
    function prep(data){
      var charts = artfully.utils.keyOnId(data.charts);

      // Modelize charts and their sections.
      artfully.utils.modelize(charts, artfully.models.chart, function(chart){
        artfully.utils.modelize(chart.sections, artfully.models.section);
      });

      // Modelize performance and assign charts.
      artfully.utils.modelize(data.performances, artfully.models.performance, function(performance){
        performance.chart = charts[performance.chart_id];
      });

      return artfully.utils.modelize(data, artfully.models.event);
    }

    function render(data){
      e = prep(data);
      e.render($('#event'));
    }

    return {
      display: function(id){
        artfully.widgets.cart.display();
        $.getJSON(artfully.utils.event_uri(id), function(data){
          render(data);
        });
      }
    };
  }());

  cart = (function(){
    function hiddenFormFor(tickets){
      var $form = $(document.createElement('form')).attr({'method':'post','target':artfully.widgets.cart.$iframe.attr('name'), 'action':artfully.config.base_uri + 'order.widget'});

      $.each(tickets, function(i,ticket){
        $(document.createElement('input')).attr({'type':'hidden', 'name':'tickets[]','value':ticket.id}).appendTo($form);
      });

      return $form.appendTo($('body'));
    }

    // This is our ShoppingCart object.
    var internal_cart = {
      init: function(){
        this.$cart = $("<div id='shopping-cart' class='hidden' />");

        this.$controls = $("<div id='shopping-cart-controls' />").appendTo(this.$cart);
        $("<span class='timer' />").text("(Countdown)").appendTo(this.$controls);
        $("<span class='cart-name' />").text("Shopping Cart").appendTo(this.$controls);

        this.$iframe = $("<iframe name='shopping-cart-iframe' />")
                        .attr('src',artfully.config.base_uri + 'order.widget')
                        .height(artfully.config.maxHeight)
                        .hide()
                        .appendTo(this.$cart);

        return this.$cart;
      },

      display: function(){
        this.$cart.appendTo('body');
      },

      add: function(tickets){
        hiddenFormFor(tickets).submit().remove();
        this.show();
      },

      show: function(){
        this.$cart.addClass('shown').removeClass('hidden');
        this.$iframe.slideDown();
      },

      hide: function(){
        this.$cart.addClass('hidden').removeClass('shown');
        this.$iframe.slideUp();
      },

      toggle: function(){
        if(this.$cart.hasClass('shown')){
          this.hide();
        } else {
          this.show();
        }
      }
    };

    internal_cart.init();
    internal_cart.$controls.click(function(){ cart.toggle(); });

    return internal_cart;
  }());

  donation = (function(){
    function prep(donation){
      return artfully.utils.modelize(donation, artfully.models.donation);
    }

    function render(data){
      var donation = prep(data);
      donation.render($('#donation'));
    }

    return {
      display: function(id){
        var data = { id:id }
        render(data);
      }
    }
  }());

  return {
    event: event,
    cart: cart,
    donation: donation
  };
}());

artfully.models = (function(){

  var chart, section, performance, event;

  chart = {
    render: function($target){
      this.container().hide().appendTo($target);
    },

    container: function(){
      var $c = $(document.createElement('ul')).addClass('sections');

     $.each(this.sections, function(index, section){
       section.render($c);
      });

      return $c;
    }
  };

  section = {
    render: function($t){
      this.$target = this.container();
      this.render_info(this.$target);
      this.render_form(this.$target);
      this.$target.appendTo($t);
    },
    container: function(){
      return $(document.createElement('li'));
    },
    render_info: function($target){
      $(document.createElement('span')).addClass('section-name').text(this.name).appendTo($target);
      $(document.createElement('span')).addClass('section-price').text("$" + this.price).appendTo($target);
    },
    render_form: function($target){
      var $select,
          $form = $(document.createElement('form')).appendTo($target),
          obj = this,
          i;

      $select = $(document.createElement('select')).attr({'name':'ticket_count','id':'ticket-count'}).appendTo($form);
      $(document.createElement('option')).text("1 Ticket").attr('value', 1).appendTo($select);
      for(i = 2; i <= 10; i++){
        $(document.createElement('option')).text(i + " Tickets").attr('value', i).appendTo($select);
      }

      $(document.createElement('input')).attr('type','submit').val('Buy').appendTo($form);

      $form.submit(function(){
        var params = {
          'limit': $('#ticket-count').val(),
          'performanceId': $(this).closest('.performance').data('performance').id,
          'price': obj.price
        };

        $.getJSON(artfully.utils.ticket_uri(params), function(data){
          artfully.widgets.cart.add(data);
        });

        $('.sections').slideUp();

        return false;
      });
    }
  };

  performance = {
    render: function(target){
      var $t;
      $t = $(document.createElement('li')).addClass('performance').appendTo(target);
      $t.data('performance', this);

      $(document.createElement('span'))
      .addClass('performance-datetime')
      .text(artfully.utils.datestring(this.datetime))
      .appendTo($t);

      $(document.createElement('a'))
      .addClass('ticket-search')
      .text('Buy Tickets')
      .attr("href","#")
      .click(function(){
        $(this).closest(".performance").children(".sections").slideToggle();
        return false;
      })
      .appendTo($t);

      this.chart.render($t);
      this.$target = $t;
    }
  };

  event = {
    render: function($target){
      // Tech Debt: only really need to store the three properties.
      $target.data('event', this);

      $target.append($(document.createElement('h1')).addClass('event-name').text(this.name))
            .append($(document.createElement('h2')).addClass('event-venue').text(this.venue))
            .append($(document.createElement('h3')).addClass('event-producer').text(this.producer));

      this.render_performances($target);
    },
    render_performances: function($target){
      $ul = $(document.createElement('ul')).addClass('performances').appendTo($target);
      $.each(this.performances, function(index, performance){
        performance.render($ul);
      });
    }
  };

  donation = {
    render: function($t){
      var $form = $(document.createElement('form')).attr({'method':'post','target':artfully.widgets.cart.$iframe.attr('name'), 'action':artfully.config.base_uri + 'order.widget'});
          $producer = $(document.createElement('input')).attr({'type':'hidden','name':'donation[producer_id]','value':this.id }),
          $amount = $(document.createElement('input')).attr({'name':'donation[amount]'}),
          $submit = $(document.createElement('input')).attr({'type':'submit', 'value':'Add Donation'});

      $form.submit(function(){
        artfully.widgets.cart.show();
      });

      $form.append($amount)
           .append($producer)
           .append($submit)
           .appendTo($t);
    }
  };

  return {
    chart: chart,
    section: section,
    performance: performance,
    event: event,
    donation: donation
  };
}());

artfully.utils = (function(){
  function ticket_uri(params){
    var u = artfully.config.base_uri + 'tickets.jsonp?callback=?';
    $.each(params, function(k,v){
      u += "&" + k + (k === "limit" ? "=" : "=eq") + v;
    });
    return u;
  }

  function event_uri(id){
    return artfully.config.base_uri + 'events/' + id + '.jsonp?callback=?';
  }

  function performance_uri(id){
    return artfully.config.base_uri + 'performances/' + id + '.jsonp?callback=?';
  }

  function datestring(datetime){
    datetime = new Date(datetime);
    return datetime.toLocaleDateString() + " " + datetime.toLocaleTimeString();
  }

  function keyOnId(list){
    var result = [];
    $.each(list, function(index, item){
      result[item.id] = item;
    });
    return result;
  }

  function modelize(data, model, callback){
    if(data){
      if(data instanceof Array){
        $.each(data, function(index, item){
          modelize(item, model, callback);
        });
      } else {
        $.extend(data,model);
        if(callback !== undefined){
          callback(data);
        }
      }
    }
    return data;
  }

  return {
    ticket_uri: ticket_uri,
    performance_uri: performance_uri,
    event_uri: event_uri,
    datestring: datestring,
    keyOnId: keyOnId,
    modelize: modelize
  };
}());
