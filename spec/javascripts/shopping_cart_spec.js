describe("Shopping Cart", function(){
  afterEach(function(){
    ShoppingCart.remove_iframe();
  });

  describe("the iframe", function(){
    it("should store a reference to the injected iframe",function(){
      expect(ShoppingCart.iframe()).toBeDefined();
    });

    it("should inject the iframe if it does not yet exist", function(){
      ShoppingCart.iframe();
      expect($('#shopping-cart')).toExist();
    });

    it ("show_iframe should ensure the iframe is visible", function(){
      ShoppingCart.show_iframe();
      expect(ShoppingCart.iframe()).toBeVisible();
    });

    it ("hide_iframe should ensure the iframe is not visible", function(){
      ShoppingCart.hide_iframe();
      expect(ShoppingCart.iframe()).not.toBeVisible();
    });

    it("remove_iframe should remove the iframe from the page", function(){
      ShoppingCart.remove_iframe();
      expect($('iframe')).not.toExist();
    })
  });
});