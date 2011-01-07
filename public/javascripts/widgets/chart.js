function Chart(data) { this.load(data); }

Chart.fetch = function(id){
  var c;

  $.getJSON(Chart.uri(id), function(data){
    c = new Chart(data);
  });

  return c;
}

Chart.prototype = {
  load: function(data){
    this.id = data.id;
    this.name = data.name;
    this.sections = [];
    this.load_sections(data.sections);
  },

  load_sections: function(sections){
    if(sections){
      for(var i = 0; i < sections.length; i++){
        this.sections.push(new Section(sections[i]));
      }
    }
  },

  render: function(){
  }

};