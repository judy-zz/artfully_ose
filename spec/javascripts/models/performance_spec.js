describe("Performance", function() {
  var performance = {},
  data = {
    "chart_id": "10",
    "datetime": "2011-01-04T19:12:00-05:00",
    "id": "14"
  },

  chart = {
    "id": "10",
    "name": "Test Chart",
    "sections": [
      {
        "capacity": "5",
        "id": "11",
        "name": "General",
        "price": "10"
      }
    ]
  }

  beforeEach(function() {
    $.extend(performance, data, artfully.models.performance);
    performance.chart = $.extend(chart, artfully.models.chart);
    $.each(chart.sections, function(index, section){
      $.extend(section, artfully.models.section);
    });
  });

  describe("attributes", function(){
    it("should be have a datetime", function(){
      expect(performance.datetime).toEqual(data.datetime);
    });

    it("should have an id", function(){
      expect(performance.id).toEqual(data.id);
    })

    it("should have a chart_id", function(){
      expect(performance.chart_id).toEqual(data.chart_id);
    });
  });

  describe("render", function(){
    var $target;

    beforeEach(function(){
      jasmine.getFixtures().set('<ul class="performances">');
      $target = $(".performances");
      performance.render($target);
    });

    it("should render the name in an li .performance-datetime", function(){
      expect(performance.$target).toContain('.performance-datetime');
      expect(performance.$target.children('.performance-datetime')).toHaveText(artfully.utils.datestring(new Date(data.datetime)));
    });

    it("should add a 'Buy Tickets' link to the <li>", function(){
      expect(performance.$target).toContain('a.ticket-search');
      expect(performance.$target.children('a')).toHaveText('Buy Tickets')
    });

    xit("should call render_form when 'Buy Tickets' is clicked", function(){
      spyOn(performance, 'render_form')
      performance.$target.children('.ticket-search').click();
      expect(performance.render_form).toHaveBeenCalled();
    });
  });
});