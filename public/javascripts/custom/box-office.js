function bulletedListItem(person){
  var $li = $("li.template").clone().removeClass("template hidden"),
      $label = $(document.createElement("label")).attr({
        "for": "person_id"
      }).html(person.first_name + " " + person.last_name),
      $radio = $(document.createElement("input")).attr({
        "name":"person_id",
        "type":"radio",
        "value": person.id
      });

  $li.find(".radio").append($radio);
  $li.find(".label").append($label);
  $li.appendTo($(".target"));
}

$("document").ready(function(){
	
	$('.ticket-quantity-select').change(function(){
	   	$(this).closest("form").submit()
	});

	$('.ticket-quantity-select').closest("form")
		.bind("ajax:success", function(xhr, sale){
	   		$('#total').find('.price').html(sale.total / 100).formatCurrency();
			$("#total").removeClass("loading");
    		$('input[type="submit"]').removeAttr('disabled');
    		$('input[type="submit"]').removeClass('disabled');
		})
		.bind("ajax:beforeSend", function(){
    		$("#total").addClass("loading");
    		$('input[type="submit"]').addClass('disabled');
    		$('input[type="submit"]').attr('disabled', 'disabled');
  		});
	
  $("#terms").keypress(function(e){
    if (e.which == 13) {
      e.stopImmediatePropagation();
      e.stopPropagation();
      $("#people-for-sales").click();
      return false;
    }
  });

  var mappings = {
    "#anonymous": "#person-search",
    "#cash": "#payment-info"
  }

  $.each(mappings, function(checkbox, section){
    if($(checkbox).is(":checked")){
      $(section).addClass("hidden");
    }
  });

  $("#anonymous").change(function(){
    if($(this).is(":checked")){
      $("#person-search").addClass("hidden");
      $(".target li:visible").remove();
      $("#terms").val("");
      $("#dummy").click();
    } else {
      $("#person-search").removeClass("hidden");
    }
  });

  $("#cash").change(function(){
    if($(this).is(":checked")){
      $("#payment-info").addClass("hidden");
      $("#credit_card_card_number").val("")
    } else {
      $("#payment-info").removeClass("hidden");
    }
  });

  $("#people-for-sales").bind("click", function(){
    $(".target li:visible").remove();
    var input = $(this).siblings("#terms"),
        terms = input.val(),
        url = $(this).attr("data-url"),
        params = {
          "commit": 1,
          "search": terms
        };

    if("" !== terms){
      $.getJSON(url, params, function(people){
        $.each(people, function(index, person){
          bulletedListItem(person);
        });
      });
    }
  });
});