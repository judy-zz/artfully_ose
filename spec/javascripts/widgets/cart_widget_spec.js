describe("Shopping Cart", function(){

  describe("controls", function(){
    it("should be in the DOM", function(){
      expect($("#shopping-cart-controls")).toBeDefined();
    });

    it("should have the class 'hidden' when it is hidden", function(){
      artfully.widgets.cart.hide();
      expect(artfully.widgets.cart.$cart).toHaveClass('hidden')
    });

    it("should have the class 'hidden' when toggling from 'shown'", function(){
      artfully.widgets.cart.show();
      artfully.widgets.cart.toggle();
      expect(artfully.widgets.cart.$cart).toHaveClass('hidden')
    });

    it("should have the class 'shown' when it is shown", function(){
      artfully.widgets.cart.show();
      expect(artfully.widgets.cart.$cart).toHaveClass('shown')
    });

    it("should have the class 'shown' when toggling from 'hidden'", function(){
      artfully.widgets.cart.hide();
      artfully.widgets.cart.toggle();
      expect(artfully.widgets.cart.$cart).toHaveClass('shown')
    });

    it("should call toggle when clicked", function(){
      spyOn(artfully.widgets.cart,'toggle');
      artfully.widgets.cart.$controls.click();
      expect(artfully.widgets.cart.toggle).toHaveBeenCalled();
    });

    it("should call show when adding tickets to the cart", function(){
      spyOn(artfully.widgets.cart,'show');
      artfully.widgets.cart.add([ { id: "1" }, { id: "2" }, { id: "3" } ]);
      expect(artfully.widgets.cart.show).toHaveBeenCalled();
    });
  });
});