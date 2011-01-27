artfully = {};
artfully.utils = {};
artfully.utils.uri = (function(){

  function ticket(params){
    var u = Config.base_uri + 'tickets.jsonp?callback=?';

    $.each(params, function(k,v){
      u += "&" + k + (k === "limit" ? "=" : "=eq") + v;
    });

    return u;
  }

  function event(id){
    return Config.base_uri + 'events/' + id + '.jsonp?callback=?';
  }

  return {
    ticket: ticket,
    event: event
  };

}());
