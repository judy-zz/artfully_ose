describe("Chart", function(){
  var chart, data = {
      "id": "10",
      "name": "Test Chart",
      "sections": [{
          "capacity": "5",
          "id": "11",
          "name": "General",
          "price": "10"
        },
        {
          "capacity": "5",
          "id": "12",
          "name": "Balcony",
          "price": "100"
      }]
  };

  beforeEach(function(){
    chart = new Chart(data);
  });

  it("should save the id", function(){
    expect(chart.id).toEqual(data.id);
  });

  it("should save the name", function(){
    expect(chart.name).toEqual(data.name);
  });

  it("should have the same number of sections as the data", function(){
    expect(chart.sections.length).toBe(data.sections.length);
  });

  it("should have the same sections as the data", function(){
    for(var i = 0; i < chart.sections.length; i++){
      expect(chart.sections[i]).toEqual(new Section(data.sections[i]));
    }
  });

});