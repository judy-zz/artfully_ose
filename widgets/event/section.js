function Section(data){ this.load(data); }

Section.prototype = {
  load: function(data){
    this.id = data.id;
    this.price = data.price;
    this.name = data.name;
    this.capacity = data.capacity;
  },

  render: function($target){
    this.$target = $(document.createElement('li'));

    this.render_info(this.$target);
    this.render_form(this.$target);
    this.$target.appendTo($target);
  },

  render_info: function($target){
    $(document.createElement('span')).addClass('section-name').text(this.name).appendTo($target);
    $(document.createElement('span')).addClass('section-price').text("$" + this.price).appendTo($target);
  },

  render_form: function($target){
    var $select,
        $form = $(document.createElement('form')).appendTo($target),
        obj = this;

    $select = $(document.createElement('select')).attr({'name':'ticket_count','id':'ticket-count'}).appendTo($form);
    $(document.createElement('option')).text("1 Ticket").attr('value', 1).appendTo($select);
    for(var i = 2; i <= 10; i++){
      $(document.createElement('option')).text(i + " Tickets").attr('value', i).appendTo($select);
    }

    $(document.createElement('input')).attr('type','submit').val('Buy').appendTo($form);

    $form.submit(function(){
      var params = {
        'limit': $('#ticket-count').val(),
        'performance': $(this).parents('.performance').data('performance').raw_datetime,
        'price': obj.price
      };

      Ticket.find(params, function(data){
        ShoppingCart.add(data);
      });

      $('.sections').slideUp();

      return false;
    });
  }
}