describe("EventWidget", function(){
  beforeEach(function(){
    spyOn(jQuery,'getJSON');
    var options =  { base_uri:'http://localhost:3000/'};
    EventWidget(1,options);
  });

  it("define a function", function(){
    expect(EventWidget).toBeDefined();
  });

  it("should call jQuery.getJSON()", function(){
    expect(jQuery.getJSON).toHaveBeenCalled();
  });
});