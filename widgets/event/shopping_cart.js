var ShoppingCart = (function(){

  var _ = {
    hiddenFormFor: function(tickets){
      var $form = $(document.createElement('form')).attr({'method':'post','target':ShoppingCart.$iframe.attr('name'), 'action':Config.base_uri + 'order.widget'});

      // Hidden field with authenticity token
      $(document.createElement('input')).attr({'type':'hidden', 'name': 'authenticity_token','value': Config.token}).appendTo($form);
      $.each(tickets, function(i,ticket){
        $(document.createElement('input')).attr({'type':'hidden', 'name':'tickets[]','value':ticket.id}).appendTo($form);
      });

      return $form.appendTo($('body'));
    }
  };

  // This is our ShoppingCart object.
  var cart = {
    init: function(){
      this.$cart = $("<div id='shopping-cart' class='hidden' />");

      this.$controls = $("<div id='shopping-cart-controls' />").appendTo(this.$cart);
      $("<span class='timer' />").text("(Countdown)").appendTo(this.$controls);
      $("<span class='cart-name' />").text("Shopping Cart").appendTo(this.$controls);

      this.$iframe = $("<iframe name='shopping-cart-iframe' />")
                      .attr('src',Config.base_uri + 'order.widget')
                      .height(Config.maxHeight)
                      .hide()
                      .appendTo(this.$cart);

      return this.$cart;
    },

    add: function(tickets){
      _.hiddenFormFor(tickets).submit().remove();
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

  cart.init();
  cart.$controls.click(function(){ cart.toggle(); });

  // Reveal private methods for unit testing.
  cart._ = _;

  // Return the cart object
  return cart;
}());

