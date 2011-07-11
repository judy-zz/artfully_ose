$(document).ready(function(){
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