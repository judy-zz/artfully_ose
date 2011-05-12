$(document).ready(function(){
    
});

(function(window, document, undefined){
  window.artfully = {};
  window.artfully.config = {};

  artfully.configure = function(obj){
    $.extend(artfully.config, obj);
  };

  artfully.alert = function(msg){
    $("#artfully-alert").fadeOut('fast',function(){
      $(this).html(msg);
      $(this).fadeIn('slow');
    });
  };
}(this,document));

artfully.config = {
  base_uri: 'http://api.lvh.me:3000/',
  store_uri: 'http://localhost:3000/store/',
  maxHeight: '350'
};

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

  function order_uri(){
    return artfully.config.store_uri + 'order';
  }

  function donation_uri(id){
    return artfully.config.base_uri + 'organizations/' + id + '/authorization.jsonp?callback=?';
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
        $.extend(data,model());
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
    donation_uri: donation_uri,
    order_uri: order_uri,
    keyOnId: keyOnId,
    modelize: modelize
  };
}());

artfully.widgets = (function(){
  var event, cart, donation,
      widgetCache = {};

  event = function(){
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

    if(widgetCache.event === undefined){
      widgetCache.event = {
        display: function(id){
          artfully.widgets.cart().display();
          $.getJSON(artfully.utils.event_uri(id), function(data){
            render(data);
          });
        }
      };
    }

    return widgetCache.event;
  };
  cart = function(){
    function hiddenFormFor(tickets){
      var $form = $(document.createElement('form')).attr({'method':'post','target':artfully.widgets.cart().$iframe.attr('name'), 'action':artfully.utils.order_uri()});

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
                        .attr('src',artfully.utils.order_uri())
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
    internal_cart.$controls.click(function(){ cart().toggle(); });

    if(widgetCache.cart === undefined){
      widgetCache.cart = internal_cart;
    }

    return widgetCache.cart;
  };
  donation = function(){
    function prep(donation){
      return artfully.utils.modelize(donation, artfully.models.donation);
    }
    function authorize(donation){
      $.getJSON(artfully.utils.donation_uri(donation.organizationId), function(data){
        if(data.authorized){
          donation.type = data.type;
          donation.render($('#donation'));
        }
      });
    }
    function render(data){
      var donation = prep(data);
      authorize(donation);
    }
    if(widgetCache.donation === undefined){
      widgetCache.donation = {
        display: function(id){
          var data = { organizationId:id };
          render(data);
        }
      };
    }

    return widgetCache.donation;
  };

  return {
    event: event,
    cart: cart,
    donation: donation
  };
}());

artfully.models = (function(){

  var chart, section, performance, event,
      modelCache = {};

  chart = function(){
    if(modelCache.chart === undefined){
      modelCache.chart = {
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
    }
    return modelCache.chart;
  };

  section = function(){
    if(modelCache.section === undefined){
      modelCache.section = {
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
          $(document.createElement('span')).addClass('section-price').text("$" + (new Number(this.price) / 100)).appendTo($target);
        },
        render_form: function($target){
          var $select,
              $form = $(document.createElement('form')).appendTo($target),
              obj = this,
              i;

          $select = $(document.createElement('select')).attr({'name':'ticket_count'}).appendTo($form);
          $(document.createElement('option')).text("1 Ticket").attr('value', 1).appendTo($select);
          for(i = 2; i <= 10; i++){
            $(document.createElement('option')).text(i + " Tickets").attr('value', i).appendTo($select);
          }

          $(document.createElement('input')).attr('type','submit').val('Buy').appendTo($form);

          $form.submit(function(){
            var params = {
              'limit': $select.val(),
              'performance_id': $(this).closest('.performance').data('performance').id,
              'price': obj.price
            };

            $.getJSON(artfully.utils.ticket_uri(params), function(data){
              if(data.length > 0){
                if(data.length < $select.val()){
                  artfully.alert("Only " + data.length + " ticket(s) could be found for this performance.");
                }
                artfully.widgets.cart().add(data);
                $('.sections').slideUp();
              } else {
                artfully.alert("Sorry! No tickets were available for purchase at this time.");
              }
            });

            return false;
          });
        }
      };
    }
    return modelCache.section;
  };

  performance = function(){
    if(modelCache.performance === undefined){
      modelCache.performance = {
        render: function(target){
          var $t;
          $t = $(document.createElement('li')).addClass('performance').appendTo(target);
          $t.data('performance', this);

          $(document.createElement('span'))
          .addClass('performance-datetime')
          .text(this.performance_time)
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
    }
    return modelCache.performance;
  };

  event = function(){
    if(modelCache.event === undefined){
      modelCache.event = {
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
    }
    return modelCache.event;
  };

  donation = function(){
    if(modelCache.donation === undefined){
      modelCache.donation = {
        message: function($key){
          var messages = {
            'regular': "This is the notice for regular donations.",
            'sponsored': "This is the notice for fiscally sponsored programs."
          };
          return messages[$key] || "";
        },
        render: function($t){
          var $form = $(document.createElement('form')).attr({'method':'post','target':artfully.widgets.cart().$iframe.attr('name'), 'action':artfully.utils.order_uri()}),
              $producer = $(document.createElement('input')).attr({'type':'hidden','name':'donation[organization_id]','value':this.organizationId}),
              $amount = $(document.createElement('input')).attr({'type':'text', 'name':'donation[amount]'}).addClass('currency'),
              $submit = $(document.createElement('input')).attr({'type':'submit', 'value':'Make Donation'}),
              $notice = $(document.createElement('p')).html(this.message(this.type));

          $form.submit(function(){
            artfully.widgets.cart().show();
          });

          $notice.appendTo($t);

          $form.append($amount)
               .append($producer)
               .append($submit)
               .appendTo($t);
         $(".currency").maskMoney({showSymbol:true, symbolStay:true, allowZero:true, symbol:"$"});
         $(".currency").closest("form").submit(function(){
           var input = $(this).find(".currency"),
               cents = Math.round( parseFloat(input.val().substr(1).replace(/,/,"")) * 100 ),
               hiddenCurrency = input.clone().attr({type:"hidden"}).appendTo(this);
           hiddenCurrency.val(cents);
         });
        }
      };
    }
    return modelCache.donation;
  };

  return {
    chart: chart,
    section: section,
    performance: performance,
    event: event,
    donation: donation
  };
}());
