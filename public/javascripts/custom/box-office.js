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
	$('.picked-person-clear').html("")
	$('input#search').val('')	
	$('input#person_id').val('')
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

function updateSelectedPerson(personId, personName, personEmail, personCompanyName) {
	$("input#search").val(personName)
	$(".picked-person-name").html(personName)
	$(".picked-person-email").html(personEmail)
	$(".picked-person-company-name").html(personCompanyName)
	$("input#person_id").val(personId)	
}

function clearNewPersonForm() {
	$('#person_first_name', '#new_person').val('')
	$('#person_last_name', '#new_person').val('')
	$('#person_email', '#new_person').val('')
}

$("document").ready(function(){

  $("#new_person").bind("ajax:beforeSend", function(xhr, person){
    $(this).addClass('loading')
		$('.flash', '#new-person-popup').remove();
  });
	
  $("#new_person").bind("ajax:success", function(xhr, person){
    $(this).removeClass('loading')
    $(this).find("input:submit").removeAttr('disabled');
		updateSelectedPerson(person.id, person.first_name + " " + person.last_name, person.email, person.company)
		clearNewPersonForm()
    $("#new-person-popup").dialog("close")
  });

  $("#new_person").bind("ajax:error", function(xhr, status, error){
    $(this).find("input:submit").removeAttr('disabled');
    data = eval("(" + status.responseText + ")");
    $(this).removeClass('loading')
		$('#error', '#new-person-popup').after($(document.createElement('div')).addClass('flash').addClass('error').html(data.errors[0]));
  });
	
	$("input#search").autocomplete({
    html: true,
		minLength: 3,
		focus: function(event, person) { 
			event.preventDefault()
		},
    source: function(request, response) {
    	$.getJSON("/people?utf8=%E2%9C%93&commit=Search", { search: request.term }, function(people) {
				responsePeople = new Array();
		  
				$.each(people, function (i, person) {
					responsePeople[i] =  "<div id='search-result-name'>"+ ( person.first_name == null ? "" : person.first_name ) +" "+ ( person.last_name == null ? "" : person.last_name ) +"</div>"
					responsePeople[i] += "<div id='search-result-email' class='search-result-details'>"+ ( person.email == null ? "" : person.email ) +"</div>"
					responsePeople[i] += "<div class='clear'></div>"
					responsePeople[i] += "<div id='search-result-company-name' class='search-result-details'>"+ ( person.company_name == null ? "" : person.company_name ) +"</div>"	
					responsePeople[i] +=  "<div id='search-result-id'>"+person.id+"</div>"				        
	      });
				response(responsePeople)
			});
  	},
    select: function(event, person) { 
      event.preventDefault()
			var personId = $(person.item.value).filter("#search-result-id").html()
			var personName = $(person.item.value).filter("#search-result-name").html()
			var personEmail = $(person.item.value).filter("#search-result-email").html()
			var personCompanyName = $(person.item.value).filter("#search-result-company-name").html()
      updateSelectedPerson(personId, personName, personEmail, personCompanyName)
    }
  });

  $("#new-person-popup").dialog({autoOpen: false, draggable:false, modal:true, width:500, height:225, title: 'Create New Person'})
  $("#new-person-link").click(function(){
    $("#new-person-popup").dialog("open")
    return false;
  });
	
  $("#sell-popup").dialog({autoOpen: false, draggable:false, modal:true, width:500, height:500, title: 'Confirm Sale'})
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
    setTimeout( function(){ $("input[name=hack-cc-number]").focus(); }, 100 );
  });
  
  $("#cancel-button").click(function(){
    $("#sell-popup").dialog("close")
  });

  $("#sell-button").click(function(){
    form = $('.ticket-quantity-select').closest("form")
	  form.find('input[name="commit"]').val('submit')
	  $("#sell-button").addClass('disabled')
  	$('#sell-button').attr('disabled', true)
	  $('#sell-button').html('Processing...')
	  form.submit()
  });
	
	$('.ticket-quantity-select').change(function(){
	   	$(this).closest("form").submit()
	});

	$('.ticket-quantity-select').closest("form")
		.bind("ajax:beforeSend", function(){
    	$("#total").addClass("loading");
    	$("#checkout-now-button").addClass('disabled')
    	$('#checkout-now-button').attr('disabled', true)
			$('.flash').remove()
  	})
		.bind("ajax:failure", function(){
			showError("Sorry, but Artful.ly could not process the payment.  An error report has been recorded.")
			resetPayment()
		})
		.bind("ajax:success", function(xhr, sale){
	   	setPriceDisplay(sale.total)
			$("#total").removeClass("loading");
    		
    	$('input[name="payment_method"]').attr('disabled', (sale.total == 0))
			$('#popup-ticket-list tbody tr').remove()
	        $.each(sale.tickets, function () {
	          $("#popup-ticket-list").find('tbody')
	            .append($('<tr>')
	              .append($('<td>').html(this.section.name))
	              .append($('<td>').html(this.price / 100).formatCurrency())
	          );         
	        });
  	  $("#checkout-now-button").removeClass('disabled')
  	  $('#checkout-now-button').attr('disabled', false)
	
			$("#sell-popup").dialog("close")
  	  $("#sell-button").removeClass('disabled')
  	  $('#sell-button').attr('disabled', false)
	    $('#sell-button').html('Sell')
	  		
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

  $(".payment-method").change(function(){
    if($(this).attr('value') != 'credit_card_manual'){
      $("#payment-info").addClass("hidden");
      $("#credit_card_card_number").val("")
      $("#credit_card_cardholder_name").val("")
    } else {
      $("#payment-info").removeClass("hidden");
    }
  });
});