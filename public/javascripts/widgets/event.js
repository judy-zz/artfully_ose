function Event(data){ this.load(data); }

Event.uri = function(id){
  return Config.base_uri + 'events/' + id + '.jsonp?callback=?';
}

Event.prototype = {
  load: function(data){
    this.name = data.name;
    this.venue = data.venue;
    this.producer = data.producer;
    this.performances = [];
  },

  render: function(target){
    return this.to_dom(target) && this.render_performances(target);
  },

  to_dom: function(target){
    return Boolean(
      target.append(
        $(document.createElement('h1'))
        .addClass('event-name')
        .text(this.name)
      ).append(
        $(document.createElement('h2'))
        .addClass('event-venue')
        .text(this.venue)
      ).append(
        $(document.createElement('h2'))
        .addClass('event-producer')
        .text(this.producer)
      )
    );
  },

  render_performances: function($target){
    var success = true;
    if(this.performances.length > 0){
      $ul = $(document.createElement('ul'))
                .addClass('performances')
                .appendTo($target);

      for(var i = 0; i < this.performances.length && success; i++){
        success &= performances[i].render($ul);
      }
    }
    return success;
  },

  load_performances: function(data){
    for(var i = 0; i < data.performances.length; i++){
      this.performances.push(new Performance(data.performances[i]));
    }
  }
};

