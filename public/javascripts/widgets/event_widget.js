function EventWidget(id){
  this.id = id;
}

EventWidget.prototype = {
  id: 0,
  event: null,
  data: null,

  run: function(){
    return this.fetch() && this.render();
  },

  fetch: function(){
    if(!this.data){
      $.getJSON(this.uri(this.id), function(data){
        this.data = data;
      });
    }
    this.event = new Event(this.data);
    return this.data
  },

  render: function(){
    return this.event.render($('#event'));
  },

  uri: function(id){
    return "http://localhost:3000/events/" + id + ".jsonp?callback=?";
  }
};