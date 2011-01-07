describe("Event", function() {
  var event, data = {
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
    event = new Event(data);
  });

  describe("event attributes", function(){
    it("should be have a name", function(){
      expect(event.name).toBeDefined();
    });

    it("should have a producer", function(){
      expect(event.producer).toBeDefined();
    });

    it("should have a venue", function(){
      expect(event.venue).toBeDefined();
    });
  });

  describe("performances", function(){
    it("should store performances by their id", function(){
      $.each(event.performances, function(index, performance){
        expect(index).toEqual(performance.id);
      });
    });
  });

  describe("charts", function(){
    it("should store performances by their id", function(){
      $.each(event.charts, function(index, chart){
        expect(index).toEqual(chart.id);
      });
    });
  });

  describe("event render", function(){
    var target;

    beforeEach(function(){
      jasmine.getFixtures().set('<div id="event">');
      target = $("#event");
    });

    it("should render the name in an h1.event-name", function(){
      event.render(target);
      expect(target).toContain('h1.event-name');
      expect(target.children('h1.event-name')).toHaveText(data.name);
    });

    it("should render the venue in an h2.event-venue", function(){
      event.render(target);
      expect(target).toContain('h2.event-venue');
      expect(target.children('h2.event-venue')).toHaveText(data.venue);
    });

    it("should render the producer in an h2.event-producer", function(){
      event.render(target);
      expect(target).toContain('h2.event-producer');
      expect(target.children('h2.event-producer')).toHaveText(data.producer);
    });

    it("should call to_dom when rendering", function(){
      spyOn(event,'to_dom');
      event.render(target);
      expect(event.to_dom).toHaveBeenCalled();
    });
  });
});