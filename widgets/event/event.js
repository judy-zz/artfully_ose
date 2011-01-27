function Event(data){ this.load(data); }

Event.prototype = {
  load: function(data){
    this.name = data.name;
    this.venue = data.venue;
    this.producer = data.producer;
    this.load_performances({},data.performances);
    this.load_charts({},data.charts);
  },

  render: function($target){
    // Tech Debt: only really need to store the three properties.
    $target.data('event', this);

    $target.append($(document.createElement('h1')).addClass('event-name').text(this.name))
          .append($(document.createElement('h2')).addClass('event-venue').text(this.venue))
          .append($(document.createElement('h3')).addClass('event-producer').text(this.producer));

    this.render_performances($target);
  },

  render_performances: function($target){
    $ul = $(document.createElement('ul')).addClass('performances').appendTo($target);
    $.each(this.performances, function(index, performance){
      performance.render($ul);
    });
  },

  load_performances: function(collection, performances){
    var e = this;
    this.performances = collection;
    $.each(performances, function(i, data){
      e.performances[data.id] = new Performance(data);
    });
  },

  load_charts: function(collection, charts){
    var e = this;
    this.charts = collection;
    $.each(charts, function(i, data){
      e.charts[data.id] = new Chart(data);
    });
  }
};

