function Section(data){ this.load(data); }

Section.prototype = {
  load: function(data){
    this.id = data.id;
    this.price = data.price;
    this.name = data.name;
    this.capacity = data.capacity;
  }
}