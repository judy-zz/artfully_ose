describe("Shopping Cart", function(){

  describe("controls", function(){
    it("should be in the DOM", function(){
      expect($("#shopping-cart-controls")).toBeDefined();
    });

    it("should have the class 'hidden' when it is hidden", function(){
      ShoppingCart.hide();
      expect(ShoppingCart.$cart).toHaveClass('hidden')
    });

    it("should have the class 'hidden' when toggling from 'shown'", function(){
      ShoppingCart.show();
      ShoppingCart.toggle();
      expect(ShoppingCart.$cart).toHaveClass('hidden')
    });

    it("should have the class 'shown' when it is shown", function(){
      ShoppingCart.show();
      expect(ShoppingCart.$cart).toHaveClass('shown')
    });

    it("should have the class 'shown' when toggling from 'hidden'", function(){
      ShoppingCart.hide();
      ShoppingCart.toggle();
      expect(ShoppingCart.$cart).toHaveClass('shown')
    });

    it("should call toggle when clicked", function(){
      spyOn(ShoppingCart,'toggle');
      ShoppingCart.$controls.click();
      expect(ShoppingCart.toggle).toHaveBeenCalled();
    });
  });

  describe("iframe", function(){
    it("should store a reference to the injected iframe",function(){
      expect(ShoppingCart.$iframe).toBeDefined();
    });
  });

  describe("(private) form generation", function(){
    var data, $form;

    beforeEach(function(){
      tickets = [ { id: "1" }, { id: "2" }, { id: "3" } ];
      $form = ShoppingCart._.hiddenFormFor(tickets);
    });

    it("should be a form element", function(){
      expect($form).toBe('form');
    });

    it("should target the iframe", function(){
      expect($form.attr('target')).toEqual(ShoppingCart.$iframe.attr('name'));
    });

    it("should generate a hidden form with the authenticity token", function(){
      expect($form).toContain('input[name=authenticity_token]');
    });

    it("should generate a hidden form with the ticket ids", function(){
      expect($form.children('input[name="tickets[]"]').length).toEqual(tickets.length);
      $form.children('input[name="tickets[]"]').each(function(index){
        expect($(this).val()).toEqual(tickets[index].id);
      })
    });
  });
});