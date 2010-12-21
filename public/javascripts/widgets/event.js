function Event(data){ this.load(data); }
Event.prototype = {
  name: "",
  venue: "",
  producer: "",
  performances: [],

  render: function(target){
    target.append(
      $(document.createElement('h1'))
      .addClass('event-name')
      .text(this.name)
    );

    target.append(
      $(document.createElement('h2'))
      .addClass('event-venue')
      .text(this.venue)
    );

    target.append(
      $(document.createElement('h2'))
      .addClass('event-producer')
      .text(this.producer)
    );
  },

  load: function(data){
    this.name = data.name;
    this.venue = data.venue;
    this.producer = data.producer;
  },

  load_performances: function(data){
    for(var i = 0; i < data.performances.length; i++){
      this.performances.push(new Performance(data.performances[i]));
    }
  }
};

//    target.append($(document.createElement('ul')).addClass('performances'));
//    for (var i = 0; i < performances.length; i++){