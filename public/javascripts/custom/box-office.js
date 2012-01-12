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

function showError(message) {
	$('#heading').after($(document.createElement('div')).addClass('flash').addClass('error').html(message));
}

function showMessage(message) {
	$('#heading').after($(document.createElement('div')).addClass('flash').addClass('success').html(message));
}

function resetPerson() {
	$('#anonymous').attr('checked','checked');
	$('#person-search').addClass("hidden");
    $("#person-results li:visible").remove();
	$('#terms').val('')	
}

function resetPayment() {
	$("#payment_method_cash").click()
	$("#credit_card_card_number").val()
	$("#credit_card_cardholder_name").val()
	$("#credit_card_expiration_date_2i_").val($('option:first', $("#credit_card_expiration_date_2i_")).val())
	$("#credit_card_expiration_date_1i_").val($('option:first', $("#credit_card_expiration_date_1i_")).val())
	$('input[name="commit"]').val('')
}

function resetQuantites() {
	$.each($('.ticket-quantity-select'), function() {
		$('option[value="0"]', this).attr('selected','selected')
	});	
}

function setPriceDisplay(amountInCents) {
	if (amountInCents > 0) {
		amountInCents = amountInCents / 100;
	}
	$('#total').find('.price').html(amountInCents).formatCurrency();	
	$('#sell-total').find('.price').html(amountInCents).formatCurrency();
}

$("document").ready(function(){
	
  $("#sell-popup").dialog({autoOpen: false, draggable:false, modal:true, width:500, height:500})
  $("#checkout-now-button").click(function(){
    if($("input[name=payment_method]:checked").val() == 'credit_card_swipe') {
      $('#sell-button').hide()
      $('#swipe-now').show()
    } else {
      $('#sell-button').show()
      $('#swipe-now').hide()      
    }
    
    $("#sell-popup").dialog("open")

    if($("input[name=payment_method]:checked").val() == 'credit_card_swipe') {
	  $("input[name=hack-cc-number]").removeClass("hidden")
	  $("input[name=hack-cc-number]").focus()
    } else {
	  $("#hack-cc-number").addClass("hidden")
	}

    return false;
  });

  //copy the hack CC number (swiped data) into the actual CC number field
  $("input[name=hack-cc-number]").change(function(){
    $("#credit_card_card_number").val($("input[name=hack-cc-number]").val())
	form = $('.ticket-quantity-select').closest("form")
	form.find('input[name="commit"]').val('submit')
	$("input[name=hack-cc-number]").val('')
	$("#sell-popup").dialog("close")
	form.submit()
  });

  //Force the hack CC field to never lose focus in an attempt to 
  //ensure the swiped data always lands in the field
  $("input[name=hack-cc-number]").blur(function(){
    $("input[name=hack-cc-number]").focus()
  });
  
  $("#cancel-button").click(function(){
    $("#sell-popup").dialog("close")
  });

  $("#sell-button").click(function(){
    form = $('.ticket-quantity-select').closest("form")
	form.find('input[name="commit"]').val('submit')
	form.submit()
  });
	
	$('.ticket-quantity-select').change(function(){
	   	$(this).closest("form").submit()
	});

	$('.ticket-quantity-select').closest("form")
		.bind("ajax:beforeSend", function(){
    		$("#total").addClass("loading");
    		$('input[type="submit"]').addClass('disabled');
    		$('input[type="submit"]').attr('disabled', 'disabled');
			$('.flash').remove()
  		})
		.bind("ajax:failure", function(){
			showError("Sorry, but Artful.ly could not process the payment.  An error report has been recorded.")
			resetPayment()
		})
		.bind("ajax:success", function(xhr, sale){
	   		setPriceDisplay(sale.total)
			$("#total").removeClass("loading");
    		$('input[type="submit"]').removeAttr('disabled');
    		$('input[type="submit"]').removeClass('disabled');
    		
    		$('input[name="payment_method"]').attr('disabled', (sale.total == 0))
			$('#popup-ticket-list tbody tr').remove()
	        $.each(sale.tickets, function () {
	          $("#popup-ticket-list").find('tbody')
	            .append($('<tr>')
	              .append($('<td>').html(this.section.name))
	              .append($('<td>').html(this.price / 100).formatCurrency())
	          );         
	        });
	
			$("#sell-popup").dialog("close")
	  		
			if(sale.sale_made == true) {
				$.each(sale.door_list_rows, function () {
					$("#door-list").find('tbody')
					  .append($('<tr>')
					    .append($('<td>').html("☐"))
					    .append($('<td>').html(this.buyer))
					    .append($('<td>').html(this.email))
					    .append($('<td>').html(this.section))
					    .append($('<td>').html(this.price / 100).formatCurrency())
					);         	
				});
				resetPayment();
				resetPerson();
			  	resetQuantites();
				setPriceDisplay(0);
				showMessage(sale.message);
  	   		
  			} else if (sale.sale_made == false) {
				showError(sale.message);
				resetPayment();
  			}
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
    "#anonymous": "#person-search"
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

  $(".payment-method").change(function(){
    if($(this).attr('value') != 'credit_card_manual'){
      $("#payment-info").addClass("hidden");
      $("#credit_card_card_number").val("")
      $("#credit_card_cardholder_name").val("")
    } else {
      $("#payment-info").removeClass("hidden");
    }
  });

  $("#people-for-sales").bind("click", function(){
    $(this).parent().addClass('loading')
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
        $("#people-for-sales").parent().removeClass('loading')
        $(".target li:visible").remove();
        
        if(people.length == 0) {
          $(".people-search-message").html('No people found')
        } else {        
          $(".people-search-message").html('')
          $.each(people, function(index, person){
            bulletedListItem(person);
          });
        }
      });
    }
  });
});