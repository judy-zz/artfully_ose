function Section(data){ this.load(data); }

Section.prototype = {
  load: function(data){
    this.id = data.id;
    this.price = data.price;
    this.name = data.name;
    this.capacity = data.capacity;
  },

  render: function($target){
    this.$target = $(document.createElement('li')).text(this.name).appendTo($target);
  }
}