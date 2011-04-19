$(document).ready(function(){
  var $container = $(".viewport")
  var $panels = $(".viewport > ol > li");

  var $ol = $container.find('ol');
  $panels.css('float', 'left');

  $(window).resize(function(){
    $ol.width(($panels.size() + 1 ) * $container.width())
    $panels.css('width', $container.width());
    $ol.css('margin-left', calculateMarginFor(pos));
  });

  $ol.width(($panels.size() + 1 ) * $container.width())
  $panels.css('width', $container.width());

  $('.sliding-wizard :submit').hide();
  $next = $(document.createElement('input')).addClass('next').attr({'type':'button','value':'Next \u2192'}).appendTo($(".sliding-wizard"));
  $previous = $(document.createElement('input')).addClass('previous').attr({'type':'button','value':'\u2190 Previous'}).appendTo($(".sliding-wizard"));
  $previous.attr('disabled','disabled')


  $(document.createElement('a')).attr({'href':'#'}).html("Complete Purchase").appendTo("#checkout-now.disabled");
  $("#checkout-now a").click(function(){
    if(!$("#checkout-now").hasClass('disabled')){
      $('.sliding-wizard :submit').click();
    }
  });

  var pos = 0;

  $("#steps").children("li").removeClass('active');
  $("#steps").children("li").eq(pos).addClass('active');

  $(".previous").click(function(){
    $("#checkout-now").addClass('disabled')
    $next.removeAttr('disabled');
    if(pos == 0) { return; }
    pos--;
    $ol.animate({marginLeft: calculateMarginFor(pos) });
    if(pos == 0) {
      $previous.attr('disabled','disabled');
    }

    $("#steps").children("li").removeClass('active');
    $("#steps").children("li").eq(pos).addClass('active');

  });

  $(".next").click(function(){
    $previous.removeAttr('disabled');
    if(pos == $panels.size() - 1) { return; }
    pos++;
    $ol.animate({marginLeft: calculateMarginFor(pos) });
    if(pos == $panels.size() - 1) {
      $next.attr('disabled','disabled')
      $("#checkout-now").removeClass("disabled");
      updateConfirmation();
    }

    $("#steps").children("li").removeClass('active');
    $("#steps").children("li").eq(pos).addClass('active');
  });

  function updateConfirmation(){
    $confirmation = $("#confirmation");

    $(document.createElement('h3')).html("Confirmation").prependTo($confirmation);

    $(document.createElement('h4')).html("Customer Information").appendTo($("#customer-confirmation"));
    var creditCard = $("#customer").find("input:visible, select").serializeArray()
    $.each(creditCard, function(i,field){
      key = field.name.match(/\]\[(.*)\]$/)[1].replace(/_/,' ');
      value = field.value
      $(document.createElement('p')).html(key + ": " + value).appendTo($("#customer-confirmation"))
    });

    $(document.createElement('h4')).html("Credit Card Information").appendTo($("#credit_card-confirmation"));
    var creditCard = $("#credit_card").find("input:visible, select").serializeArray()
    $.each(creditCard, function(i,field){
      key = field.name.match(/\]\[(.*)\]$/)[1].replace(/_/,' ');
      value = field.value
      $(document.createElement('p')).html(key + ": " + value).appendTo($("#credit_card-confirmation"))
    });

    $(document.createElement('h4')).html("Billing Address").appendTo($("#billing_address-confirmation"));
    var creditCard = $("#billing_address").find("input:visible, select").serializeArray()
    $.each(creditCard, function(i,field){
      key = field.name.match(/\]\[(.*)\]$/)[1].replace(/_/,' ');
      value = field.value
      $(document.createElement('p')).html(key + ": " + value).appendTo($("#billing_address-confirmation"))
    });
  }

  function calculateMarginFor(pos){
    return -(width() * pos);
  }

  function width(){
    return $container.width();
  }

  function height(){
    $container.height();
  }
});