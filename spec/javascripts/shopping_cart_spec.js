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

    it("remove_iframe should remove the iframe from the page", function(){
      ShoppingCart.remove_iframe();
      expect($('iframe')).not.toExist();
    });
  });

  describe("hidden form generation", function(){
    var data, $form;

    beforeEach(function(){
      data = [ { id: "1" }, { id: "2" }, { id: "3" } ];
      $form = ShoppingCart.hidden_form_for(data);
    });

    it("should be a form element", function(){
      expect($form).toBe('form');
    });

    it("should target the iframe", function(){
      expect($form.attr('target')).toEqual(ShoppingCart.iframe().attr('name'));
    });

    it("should generate a hidden form with the authenticity token", function(){
      expect($form).toContain('input[name=authenticity_token]');
    });

    it("should generate a hidden form with the ticket ids", function(){
      expect($form.children('input[name="tickets[]"]').length).toEqual(data.length);
      $form.children('input[name="tickets[]"]').each(function(index){
        expect($(this).val()).toEqual(data[index].id);
      })
    });
  });
});