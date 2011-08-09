var offset = 0;
function nextLogo(){
  var visibleTime = 2000,
      fadeTime = 500,
      delta = 350,
      max = 2100;

  $("h1 .logo").delay(visibleTime).animate({ opacity: 0 }, fadeTime, function(){
    offset = offset + delta;
    if(offset > max){
      offset = 0;
    }

    $(this).css('background-position', "-" + offset + "px 0")

    $(this).animate({ opacity: 1 }, fadeTime, function(){
      nextLogo();
    });
  });
}

$(document).ready(function(){
  nextLogo();

  $(".form, #hide-form").hide();
  $("#mc-embedded-subscribe-form").submit(function(){
    $("#mce-success-response").show();
    $(".form, #hide-form").hide();
  });
	$(".button-hide-form, #show-form").show();

  $(".button-sign-up").click(function() {
  	$(".form").slideDown(250);
  	$("#show-form").fadeOut(100, function() {
  		$("#hide-form").fadeIn();
  	});
  });

  $(".button-hide-form").click(function() {
  	$(".form").slideUp(250);
  	$("#hide-form").fadeOut(100, function() {
  		$("#show-form").fadeIn();
  	});
  });

  $("a.modal").fancybox({
  	'titlePosition'		: 'outside',
  	'overlayColor'		: '#1f7e8f url("images/overlay-bg.png")',
  	'overlayOpacity'	: 0.9,
  	'padding' 			: 0
  });
});