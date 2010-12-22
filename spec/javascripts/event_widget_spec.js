describe("EventWidget", function(){
  var widget;

  beforeEach(function(){
    widget = new EventWidget(1);
    widget.data = $.parseJSON('{"name":"Some Venue", "venue":"Some Venue", "producer":"Some Producer", "performances":[]}')
  });

  it("should return true when run succeeds", function(){
    expect(widget.run()).toBeTruthy();
  });

  it("should call fetch", function(){
    spyOn(widget, 'fetch');
    widget.run();
    expect(widget.fetch).toHaveBeenCalled();
  });

  it("should return true when fetch succeeds", function(){
    expect(widget.fetch()).toBeTruthy();
  });

  it("should call render", function(){
    spyOn(widget, 'render');
    widget.run();
    expect(widget.render).toHaveBeenCalled();
  });

  it("should return true when render succeeds", function(){
    widget.fetch();
    expect(widget.render()).toBeTruthy();
  });
});