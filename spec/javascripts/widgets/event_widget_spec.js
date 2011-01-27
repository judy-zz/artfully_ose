describe("EventWidget", function(){
  var options =  { base_uri:'http://localhost:3000/'};

  beforeEach(function(){
    spyOn(jQuery,'getJSON');
    artfully.widgets.event.display(3);
  });

  it("should call jQuery.getJSON()", function(){
    expect(jQuery.getJSON).toHaveBeenCalled();
  });
});