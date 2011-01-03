describe("Ticket", function(){
  var ticket, data;
  beforeEach(function(){
    data = {
      event: "Some Event",
      venue: "Some Venue",
      performance: "2002-05-30T09:00:00",
      price: "$50"
    };

    ticket = new Ticket(data);
  });

  describe("search_uri", function(){
    it("should add search parameters to the URI", function(){
      params = {
        performance: "2002-05-30T09:00:00",
        price: 5,
        quantity: 10
      };

      expect(Ticket.search_uri(params)).toEqual(Ticket.uri + "&performance=eq2002-05-30T09:00:00&price=eq5&quantity=eq10")
    });
  });

  describe("render", function(){
    var target;
    beforeEach(function(){
      jasmine.getFixtures().set('<ul id="target">');
      target = $("#target");
    });

    it("should add the class 'ticket' to the target", function(){
      ticket.render(target);
      expect(target).toHaveClass('ticket');
    });

    it("should output the Ticket's event", function(){
      ticket.render(target);
      expect(target.children('span.ticket-event')).toHaveText(data.event);
    });

    it("should output the Ticket's performance date", function(){
      ticket.render(target);
      expect(target.children('span.ticket-date')).toHaveText(data.performance);
    });
  });


});