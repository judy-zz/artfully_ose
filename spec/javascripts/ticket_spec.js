describe("Ticket", function(){
  var ticket;
  beforeEach(function(){
    ticket = new Ticket({});
  });

  describe("search_uri", function(){
    it("should add search parameters to the URI", function(){
      params = {
        performance: "2002-05-30T09:00:00",
        price: 5,
        quantity: 10
      };

      expect(Ticket.search_uri(params)).toEqual(Ticket.base_uri + "&performance=eq2002-05-30T09:00:00&price=eq5&quantity=eq10")
    });
  });


});