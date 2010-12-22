describe("Performance", function() {
  var performance, data;

  beforeEach(function() {
    data = {
      datetime: "2002-05-30T09:00:00"
    };

    performance = new Performance(data);
  });

  describe("performance attributes", function(){
    it("should be have a datetime", function(){
      expect(performance.datetime).toBeDefined();
    });
  });

  describe("render", function(){
    var target;

    beforeEach(function(){
      jasmine.getFixtures().set('<ul class="performances">');
      $target = $(".performances");
      performance.render($target);
    });

    it("should render the name in an li .performance-datetime", function(){
      expect(performance.$target).toContain('.performance-datetime');
      expect(performance.$target.children('.performance-datetime')).toHaveText(performance.datestring(new Date(data.datetime)));
    });

    it("should add a 'Buy Tickets' link to the <li>", function(){
      expect(performance.$target).toContain('a.ticket-search');
      expect(performance.$target.children('a')).toHaveText('Buy Tickets')
    });


    describe("search form", function(){
      var $form;

      beforeEach(function(){
        performance.$target.children('.ticket-search').click();
        $form = performance.$target.children('form');
      });

      it("should add a form to the <li> when 'Buy Tickets' is clicked", function(){
        expect(performance.$target).toContain('form');
      });

      it("should have a ticket price input", function(){
        expect($form).toContain('input.ticket-price');
      });

      it("should have a ticket quantity input", function(){
        expect($form).toContain('input.ticket-price');
      });

      it("should have a ticket search submit", function(){
        expect($form).toContain('input[type="submit"].ticket-submit');
      });

    });
  });
});