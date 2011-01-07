describe("Section", function(){
  var section;

  beforeEach(function(){
    data = {
      "capacity": "5",
      "id": "11",
      "name": "General",
      "price": "10"
    };

    section = new Section(data);
  });

  it("should save the capacity", function(){
    expect(section.capacity).toBeDefined();
    expect(section.capacity).toBe("5");
  });

  it("should save the price", function(){
    expect(section.price).toBeDefined();
    expect(section.price).toBe("10");
  });

  it("should save the id", function(){
    expect(section.id).toBeDefined();
    expect(section.id).toBe("11");
  });

  it("should save the name", function(){
    expect(section.name).toBeDefined();
    expect(section.name).toBe("General");
  });

  describe("render", function(){
    var $target;

    beforeEach(function(){
      jasmine.getFixtures().set('<ul class="target">');
      $target = $(".target");
      section.render($target);
    });

    it("should add a list item to the target", function(){
      expect($target).toContain('li');
    });

    it("should insert the section name into the list item", function(){
      expect($('li', $target)).toHaveText(section.name);
    });
  });
});