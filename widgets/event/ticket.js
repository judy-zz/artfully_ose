var Ticket = {
  find: function(params, callback){
    $.getJSON(Ticket.uri(params), function(data){
      callback(data);
    });
  },
};