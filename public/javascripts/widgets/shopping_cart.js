var ShoppingCart = {
  $iframe: null,

  iframe: function(){
    if(this.$iframe === null){
      this.$iframe = $(document.createElement('iframe'))
        .attr({'name':'shopping_cart','id':'shopping-cart'})
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

  submit_tickets: function(){
    return function(form){
      ShoppingCart.show_iframe();
//      $(form).attr('target',ShoppingCart.iframe().attr('name'))
//      return false;
    };
  }
};