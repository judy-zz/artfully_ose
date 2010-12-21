function Performance(data) { this.load(data); }
Performance.prototype = {
  datetime: "",

  render: function(target){
    target.append(
      $(document.createElement('li'))
      .text(this.datestring(this.datetime))
    );
  },

  load: function(data){
    this.datetime = new Date(data.datetime);
  },

  datestring: function(datetime){
    return datetime.toLocaleDateString() + " " + datetime.toLocaleTimeString();
  }
};