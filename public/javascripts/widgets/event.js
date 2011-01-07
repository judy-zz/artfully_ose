function Event(data){ this.load(data); }

Event.uri = function(id){
  return Config.base_uri + 'events/' + id + '.jsonp?callback=?';
}

Event.prototype = {
  load: function(data){
    this.name = data.name;
    this.venue = data.venue;
    this.producer = data.producer;
    this.load_performances({},data.performances);
    this.load_charts({},data.charts);
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
    $ul = $(document.createElement('ul'))
              .addClass('performances')
              .appendTo($target);
    $.each(this.performances, function(index, performance){
      success &= performance.render($ul);
    });
    return success;
  },

  load_performances: function(collection, performances){
    this.performances = collection;
    if(performances){
      for(var i = 0; i < performances.length; i++){
        this.performances[performances[i].id] = new Performance(performances[i]);
      }
    }
  },

  load_charts: function(collection, charts){
    this.charts = collection;
    if(charts){
      for(var i = 0; i < charts.length; i++){
        this.charts[charts[i].id] = new Chart(charts[i]);
      }
    }
  }
};

