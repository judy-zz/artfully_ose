describe("TicketForm", function(){
  var form, data, $target;

  beforeEach(function(){
    jasmine.getFixtures().set('<div class="target">');
    $target = $("div.target");

    data = [
      {id: "1", event:"Some Event", performance:"2002-05-30T09:00:00", price:"$50"},
      {id: "2", event:"Some Event", performance:"2002-05-30T09:00:00", price:"$50"}
    ];

    form = new TicketForm(data);
  });

  describe("render", function(){
    var $ul;

    beforeEach(function(){
      form.render($target);
      $ul = $target.find('ul');
    });

    afterEach(function(){
      ShoppingCart.remove_iframe();
    })

    it("should add a <ul> to the target", function(){
      expect($target).toContain('ul');
    });

    it("should render each ticket added to the form", function(){
      expect($ul.children('li').length).toBe(data.length);
    });

    it("should add a checkbox next to each ticket", function(){
      $ul.children('li').each(function(index){
        expect($(this)).toContain('input:checkbox');
      });
    });

    it("should have checkboxes named tickets[]", function(){
      $ul.find('input:checkbox').each(function(index){
        expect($(this)).toHaveAttr('name','tickets[]')
      });
    });

    it("should have selected checkboxes", function(){
      $ul.find('input:checkbox').each(function(index){
        expect($(this)).toBeChecked();
      });
    });

    it("should use the ticket id as the value of the checkbox",function(){
      $ul.find('input:checkbox').each(function(index){
        expect($(this).val()).toBe(data[index].id);
      });
    });
  });
});