function Performance(data) { this.load(data); }

Performance.uri = function(id){
  return Config.base_uri + 'performances/' + id + '.jsonp?callback=?';
};

Performance.prototype = {
  render: function(target){
    this.$target = $(document.createElement('li')).addClass('performance').appendTo(target);
    this.$target.data('performance', this);

    $(document.createElement('span'))
    .addClass('performance-datetime')
    .text(this.datestring(this.datetime))
    .appendTo(this.$target);

    $(document.createElement('a'))
    .addClass('ticket-search')
    .text('Buy Tickets')
    .attr("href","#")
    .click({performance: this}, function(e){
      E.charts[e.data.performance.chart_id].render(e.data.performance.$target);
      return false;
    })
    .appendTo(this.$target);

    return Boolean(this.$target);
  },

  load: function(data){
    this.raw_datetime = data.datetime;
    this.datetime = new Date(data.datetime);
    this.chart_id = data.chart_id;
    this.id = data.id;
  },

  datestring: function(datetime){
    return datetime.toLocaleDateString() + " " + datetime.toLocaleTimeString();
  },
};