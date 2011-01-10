var Ticket = {
  find: function(params, callback){
    $.getJSON(Ticket.uri(params), function(data){
      callback(data);
    });
  },

  uri: function(params){
    var u = Config.base_uri + 'tickets.jsonp?callback=?';

    $.each(params, function(k,v){
      u += "&" + k + (k === "limit" ? "=" : "=eq") + v;
    });

    return u;
  }
};