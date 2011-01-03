var Config = {
  base_uri: 'http://localhost:3000/'
};

function EventWidget(id, options){
  this.id = id;
  Config = $.extend(Config, options);
}

EventWidget.prototype = {
  run: function(){
    return this.fetch() && this.render();
  },

  fetch: function(){
    if(!this.data){
      $.getJSON(Event.uri(this.id), function(data){
        this.data = data;
      });
    }
    this.event = new Event(this.data);
    return this.data;
  },

  render: function(){
    return this.event.render($('#event'));
  }
};