describe("Event", function() {
  var event, data;

  beforeEach(function() {
    data = {
      name: "Some Event",
      venue: "Some Venue",
      producer: "Some Producer",
      performances: []
    };

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