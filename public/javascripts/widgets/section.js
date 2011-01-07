function Section(data){ this.load(data); }

Section.prototype = {
  load: function(data){
    this.id = data.id;
    this.price = data.price;
    this.name = data.name;
    this.capacity = data.capacity;
  },

  render: function($target){
    var $select;

    this.$target = $(document.createElement('li'));

    $(document.createElement('span')).addClass('section-name').text(this.name).appendTo(this.$target);
    $(document.createElement('span')).addClass('section-price').text("$" + this.price).appendTo(this.$target);

    $select = $(document.createElement('select')).appendTo(this.$target);
    $(document.createElement('option')).text("1 Ticket").attr('value', 1).appendTo($select);
    for(var i = 2; i <= 10; i++){
      $(document.createElement('option')).text(i + " Tickets").attr('value', i).appendTo($select);
    }

    this.$target.appendTo($target);
  }
}