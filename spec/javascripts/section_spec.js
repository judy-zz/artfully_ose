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
});