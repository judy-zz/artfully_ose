describe("uri", function(){
  describe("ticket_uri", function(){
    it("should add search parameters to the URI", function(){
      params = {
        performance: "2002-05-30T09:00:00",
        price: 5,
        quantity: 10
      };

      expect(artfully.utils.ticket_uri(params)).toEqual(Config.base_uri + 'tickets.jsonp?callback=?&performance=eq2002-05-30T09:00:00&price=eq5&quantity=eq10')
    });
  });
});