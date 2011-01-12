var ShoppingCart = {
  $iframe: null,

  iframe: function(){
    if(this.$iframe === null){
      this.$iframe = $(document.createElement('iframe'))
        .attr({'name':'shopping-cart','id':'shopping-cart'})
        .appendTo('body');
    }
    return this.$iframe;
  },

  remove_iframe: function(){
    if(this.$iframe && this.$iframe.remove()){
      this.$iframe = null;
    }
  },

  buy: function(tickets){
    this.iframe().show();
    this.hidden_form_for(tickets).submit().remove();
  },

  hidden_form_for: function(tickets){
    var $form = $(document.createElement('form')).attr({'method':'post','target':ShoppingCart.iframe().attr('name'), 'action':Config.base_uri + 'orders.widget'});

    $(document.createElement('input')).attr({'type':'hidden', 'name': 'authenticity_token','value': Config.token}).appendTo($form);
    $.each(tickets, function(i,ticket){
      $(document.createElement('input')).attr({'type':'hidden', 'name':'tickets[]','value':ticket.id}).appendTo($form);
    });

    return $form.appendTo($('body'))
  }
};