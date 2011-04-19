(function( $ ){
  $.fn.proxySubmit = function($proxy) {
    var $submit = this;
    $submit.hide();
    $proxy.click(function(){
      if(!$proxy.hasClass('disabled')){
        $submit.click();
      }
    });
    return this;
  };
})( jQuery );

(function( $ ){
  $.fn.stepsFor = function($wizard) {
    var $steps = this,
        $children = $steps.children("li");

    $children.removeClass('active');
    $children.eq(pos).addClass('active');

    $wizard.bind("onSlide", function(){
      $children.removeClass('active');
      $children.eq(pos).addClass('active');
    });

    return this;
  };
})( jQuery );




var pos = 0;
$(document).ready(function(){

  var $wizard, $viewport, $ol, $panels,
      $next, $previous;

  function init(){
    $wizard = $(".sliding-wizard");
    $viewport = $(".viewport");
    $ol = $viewport.find('ol');
    $panels = $(".viewport > ol > li");

    setupSlider();
  }

  function setupSlider(){
    $panels.css('float', 'left');

    addNavigation();
    addSubmitLink();
    resizePanels();

    $(window).resize(resizePanels);
  }

  function resizePanels(){
    $ol.width(($panels.size() + 1 ) * $viewport.width());
    $panels.css('width', $viewport.width());
    $ol.css('margin-left', calculateMarginFor(pos));
  }

  function addNavigation(){
    $next = $(document.createElement('input')).addClass('next').attr({'type':'button','value':'Next \u2192'}).appendTo($(".sliding-wizard"));
    $previous = $(document.createElement('input')).addClass('previous').attr({'type':'button','value':'\u2190 Previous'}).appendTo($(".sliding-wizard"));
    $previous.attr('disabled','disabled');
    $panels.last().bind("slideIn", function(){
      disableButton($next);
    });

    $panels.last().bind("slideOut", function(){
      enableButton($next);
    });

    $panels.first().bind("slideIn", function(){
      disableButton($previous);
    });

    $panels.first().bind("slideOut", function(){
      enableButton($previous);
    });

    $(".previous").click(function(){
      if($(this).is(":enabled")){
        slide("left");
      }
    });

    $(".next").click(function(){
      if($(this).is(":enabled")){
        slide("right");
      }
    });
  }

  function addSubmitLink(){
    $(document.createElement('a')).attr({'href':'#'}).html("Complete Purchase").appendTo("#checkout-now.disabled");
  }

  function slide(direction){
    switch(direction){
      case "left":
        $panels.eq(pos).trigger("slideOut");
        pos--;
        $ol.animate({marginLeft: calculateMarginFor(pos) });
        $panels.eq(pos).trigger("slideIn");
        break;
      case "right":
        $panels.eq(pos).trigger("slideOut");
        pos++;
        $ol.animate({marginLeft: calculateMarginFor(pos) });
        $panels.eq(pos).trigger("slideIn");
        break;
      default:
        return;
    }
    $wizard.trigger("onSlide");
  }

  function enableButton($btn){
    $btn.removeAttr('disabled');
  }

  function disableButton($btn){
    $btn.attr('disabled','disabled');
  }

  function updateConfirmation(){
    $confirmation = $("#confirmation");
    $confirmation.empty();
    $(document.createElement('h3')).html("Confirmation").prependTo($confirmation);

    $(document.createElement('div')).attr('id','customer-confirmation').appendTo($confirmation);
    $(document.createElement('div')).attr('id','credit_card-confirmation').appendTo($confirmation);
    $(document.createElement('div')).attr('id','billing_address-confirmation').appendTo($confirmation);


    $(document.createElement('h4')).html("Customer Information").appendTo($("#customer-confirmation"));
    var customer = $("#customer").find("input:visible, select").serializeArray();
    $.each(customer, function(i,field){
      key = field.name.match(/\]\[(.*)\]$/)[1].replace(/_/,' ');
      value = field.value;
      $(document.createElement('p')).html(key + ": " + value).appendTo($("#customer-confirmation"));
    });

    $(document.createElement('h4')).html("Credit Card Information").appendTo($("#credit_card-confirmation"));
    var creditCard = $("#credit_card").find("input:visible, select").serializeArray();

    $.each(creditCard, function(i,field){
      key = field.name.match(/\]\[(.*)\]$/)[1].replace(/_/,' ');
      value = field.value;
      $(document.createElement('p')).html(key + ": " + value).appendTo($("#credit_card-confirmation"));
    });

    $(document.createElement('h4')).html("Billing Address").appendTo($("#billing_address-confirmation"));
    var address = $("#billing_address").find("input:visible, select").serializeArray();
    $.each(address, function(i,field){
      key = field.name.match(/\]\[(.*)\]$/)[1].replace(/_/,' ');
      value = field.value;
      $(document.createElement('p')).html(key + ": " + value).appendTo($("#billing_address-confirmation"));
    });
  }

  function calculateMarginFor(pos){
    return -($viewport.width() * pos);
  }

  function position(){
    return pos;
  }

  init();

  $("#steps").stepsFor($(".sliding-wizard"));

  // Setup submit button
  $('.sliding-wizard :submit').proxySubmit($("#checkout-now a"));
  $panels.last().bind("slideIn", function(){
    $("#checkout-now").removeClass("disabled");
    updateConfirmation();
  });

  $panels.last().bind("slideOut", function(){
    $("#checkout-now").addClass('disabled');
  });
});