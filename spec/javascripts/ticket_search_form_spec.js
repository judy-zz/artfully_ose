describe("TicketSearchForm", function(){
  var form, target;

  beforeEach(function(){
    form = new TicketSearchForm()
    jasmine.getFixtures().set('<div id="target">');
    target = $("#target");
  });

  describe("render", function(){
    it("should add a form to the target", function(){
      form.render(target);
      expect(target).toContain('form');
    });
  });

  describe("render_price", function(){
    it("should add an input.ticket-price to the target", function(){
      form.render_price(target);
      expect(target).toContain('input[type="text"].ticket-price');
    });
  });

  describe("render_quantity", function(){
    it("should add an input.ticket-quantity to the target", function(){
      form.render_quantity(target);
      expect(target).toContain('input[type="text"].ticket-quantity');
    });
  });

  describe("render_submit", function(){
    it("should add an input.ticket-price to the target", function(){
      form.render_submit(target);
      expect(target).toContain('input[type="submit"].ticket-submit');
    });
  });

});