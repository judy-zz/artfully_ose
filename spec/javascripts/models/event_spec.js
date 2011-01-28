describe("Event", function() {
  var event = {},
  data = {
    "name": "Some Event",
    "venue": "Some Venue",
    "producer": "Some Producer",
    "performances": [
      {
          "chart_id": "10",
          "datetime": "2011-01-04T19:12:00-05:00",
          "id": "14"
      },
      {
          "chart_id": "10",
          "datetime": "2011-01-03T19:12:00-05:00",
          "id": "13"
      },
      {
          "chart_id": "10",
          "datetime": "2011-01-05T19:12:00-05:00",
          "id": "15"
      }
    ],
    "charts": [
      {
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
    ]
  };

  beforeEach(function() {
    var charts = artfully.utils.keyOnId(data.charts);

    // Modelize charts and their sections.
    artfully.utils.modelize(charts, artfully.models.chart, function(chart){
      artfully.utils.modelize(chart.sections, artfully.models.section);
    });

    // Modelize performance and assign charts.
    artfully.utils.modelize(data.performances, artfully.models.performance, function(performance){
      performance.chart = charts[performance.chart_id];
    });

    $.extend(event, data, artfully.models.event);
  });

  describe("event attributes", function(){
    it("should be have the same name as the data", function(){
      expect(event.name).toEqual(data.name);
    });

    it("should have the same producer as the data", function(){
      expect(event.producer).toEqual(data.producer);
    });

    it("should have the same venue as the data", function(){
      expect(event.venue).toEqual(data.venue);
    });

    it("should have the same number performances as the data", function(){
      expect(event.performances).toEqual(data.performances)
    });
  });

  describe("event render", function(){
    var target;

    beforeEach(function(){
      jasmine.getFixtures().set('<div id="event">');
      target = $("#event");
      event.render(target);
    });

    it("should render the name in an h1.event-name", function(){
      expect(target).toContain('h1.event-name');
      expect(target.children('h1.event-name')).toHaveText(data.name);
    });

    it("should render the venue in an h2.event-venue", function(){
      expect(target).toContain('h2.event-venue');
      expect(target.children('h2.event-venue')).toHaveText(data.venue);
    });

    it("should render the producer in an h3.event-producer", function(){
      expect(target).toContain('h3.event-producer');
      expect(target.children('h3.event-producer')).toHaveText(data.producer);
    });
  });
});