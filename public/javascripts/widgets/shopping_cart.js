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

  show_iframe: function(){
    this.iframe().show();
  },

  hide_iframe: function(){
    this.iframe().hide();
  },

  remove_iframe: function(){
    if(this.$iframe && this.$iframe.remove()){
      this.$iframe = null;
    }
  },

  buy: function(tickets){
    this.show_iframe();
    this.hidden_form_for(tickets)
  },

  hidden_form_for: function(tickets){
    var $form = $(document.createElement('form')).attr({'method':'post','target':'shopping-cart', 'action':Config.base_uri + 'orders.widget'});

    for(var i = 0; i < tickets.length; i++){
      $(document.createElement('input')).attr({'type':'hidden', 'name':'tickets[]','value':tickets[i].id}).appendTo($form);
    }
    $(document.createElement('input')).attr({'type':'hidden', 'name': 'authenticity_token','value': Config.token}).appendTo($form);
    $form.appendTo($('body')).submit().remove();
  }
};