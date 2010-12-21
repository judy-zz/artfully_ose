describe("Performance", function() {
  var performance, data;

  beforeEach(function() {
    data = {
      datetime: "2002-05-30T09:00:00"
    };

    performance = new Performance(data);
  });

  describe("performance attributes", function(){
    it("should be have a datetime", function(){
      expect(performance.datetime).toBeDefined();
    });
  });

  describe("performance render", function(){
    var target;

    beforeEach(function(){
      jasmine.getFixtures().set('<ul class="performances">');
      $target = $(".performances");
    });

    it("should render the name in an li .performance-datetime", function(){
      var real_datetime = new Date(data.datetime)
      performance.render($target);
      expect($target).toContain('li');
      expect($target.children('li')).toHaveText(performance.datestring(new Date(real_datetime)));
    });
  });
});