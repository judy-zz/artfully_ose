$("document").ready(function(){
	
	$('#generate-link').bind("click", function() {
		$('.the-code').removeClass('hidden')
		return false;
	})

  $(".widget_type").change(function(){
		console.log($(this).attr('value'))
    if($(this).attr('value') == 'event' || $(this).attr('value') == 'both') { 
      $('.events').removeClass('hidden');
    } else {
      $('.events').addClass('hidden');
    }   
  });

})