describe("the chart model", function(){
  var chart = {},
  data = {
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
    $.extend(chart,data,artfully.models.chart);
    $.each(chart.sections, function(index, section){
      $.extend(section,artfully.models.section);
    });
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

  describe("render", function(){
    var $target;

    beforeEach(function(){
      jasmine.getFixtures().set('<div class="target">');
      $target = $(".target");
      chart.render($target);
    });

    it("should add a ul to the list", function(){
      expect($target).toContain('ul');
    });

    it("should add the class sections to the ul", function(){
      expect($('ul', $target)).toHaveClass('sections');
    });
  });
});