$(document).ready(function(){

  // show/hide extended event descriptions
  $('.truncated a.toggle, .not-truncated a.toggle').click(function(e) {
    e.preventDefault();
    $(this).parents('.toggle-truncated').find('.truncated, .not-truncated').toggle();
  })

  // toggle a showing's sections
  $('.title').click(function() {
    $(this).siblings('.sections').slideToggle();
    $(this).toggleClass('active');
  })

  // display the first showing's sections
  $('.title').first().siblings('.sections').slideToggle();
  $('.title').first().addClass('active');

  // when calendar is clicked
  $('td.show').click(function() {
    $("ul#shows li").hide();
    var date = $(this).attr('data-date');
    $("ul#shows li[data-date='" + date + "']").show();
    $("ul#shows li[data-date='" + date + "'] .title").addClass('active');
    $("ul#shows li[data-date='" + date + "'] .sections").show();
  });

  // click "add to cart" button on tickets
  $('.add-tickets-to-cart').submit(function(e) {
    e.preventDefault();
    $('#shopping-cart #steps').slideDown(); // not sure why this isn't slideUp

    // show the cart tab
    switchTabs('#cart');

    params = {
      sectionId:   $(this).find('#section_id').val(),
      showId:      $(this).find('#show_id').val(),
      sectionName: $(this).find('#section_name').val(),
      ticketCount: parseInt($(this).find('#ticket_count').val()),
      ticketPrice: parseFloat($(this).find('#ticket_price').val()),
      showingName: $(this).find('#showing_name').val()
    }

    addItemToCart('ticket', params);
  });

  // click "make donation" button on donation
  $('.add-donation-to-cart').submit(function(e) {
    e.preventDefault();
    donationAmount = $(this).find('#donation_amount').asNumber();
    if (donationAmount > 0) {
      $('#shopping-cart #steps').slideDown(); // not sure why this isn't slideUp
      addItemToCart('donation', { donationAmount: donationAmount}); 
    }
  });

  // click "complete purchase" to submit payment
  $('form#shopping-cart-form').submit(function(e) {
    e.preventDefault();
    // dont let people submit form twice
    if (!($('#complete-purchase').hasClass('disabled'))) {
      checkout();
    }
  });

  // show shopping cart when clicked
  $('#shopping-cart-controls').click(function() {
    $('#shopping-cart #steps').slideToggle();
  })

  // add * to required field labels
  $('label.required').append('&nbsp;<strong>*</strong>&nbsp;');

  // switch shopping cart tabs
  $('[data-toggle="tab"]').click(function(e) {
    e.preventDefault();
    currentSectionId = $('li.active a').attr('href');

    // dont switch if continue is disabled
    if (!($(currentSectionId+' .continue a').hasClass('disabled'))) {

      // validate section before switching tabs
      if (validateSection(currentSectionId)) {
        switchTabs($(this).attr('href'));
      };
      // else, dont switch
      // errors will be shown 
    }
  });

  // click "remove" on a cart item
  $(document).on('click', 'td.remove a', function(e) {
    e.preventDefault();
    $(this).parents('tr').remove();
    updateTotal();
    $('.formatCurrency').formatCurrency();
    updateOrderOnServer();
  })

  // change drop down on tickets in cart
  $(document).on('change', '#cart select.ticket-count', function(e) {
    updateQuantityInCart();
    updateTotal();
    $('.formatCurrency').formatCurrency();
    updateOrderOnServer();
  });
});

function updateOrderOnServer() {
  $('#cart .continue a').addClass('disabled');
  $('.continue #cart-total').hide();
  $('#cart .over-limit').remove();
  var params = {};

  sections = [];
  $('tr.ticket').each(function() {
    sections.push({
      section_id: $(this).attr('data-section-id'),
      show_id: $(this).attr('data-show-id'),
      limit:  $(this).find('.quantity').attr('data-quantity')
    });
  });
  if (sections.length > 0) {
    params.sections = sections;
  }

  // console.log(params);

  donationAmount = parseFloat($('tr.donation td.price').attr('data-price')) * 100;
  if (donationAmount > 0) {
    params.donation = {
      organization_id: organizationId,
      amount: donationAmount
    }
  }

  $.ajax({
    url: storefront_sync_store_order_path,
    type: "POST",
    data: params,
    success: function(data) {
      // we dont have enough tickets available
      if (data.over_section_limit) {
        jQuery.each(data.over_section_limit, function(index, section) {
          ticket = $("tr.ticket[data-section-id='" + section.section_id + "'][data-show-id='" + section.show_id + "']");
          // change ticket dropdown value
          ticket.find('.quantity select').val(section.limit);
          var message = "";
          if (section.limit == 0) {
            message += "No tickets available for this show's section."
          } else if (section.limit == 1) {
            message += "Only 1 ticket available for this show's section."
          } else {
            message += "Only " + section.limit + " tickets available for this show's section."
          }
          // add error message
          ticket.find('.quantity select').after("<span class='over-limit'><br />" + message + "</span>");
        });
        updateQuantityInCart();
        updateTotal();
        $('.formatCurrency').formatCurrency();
      };

      // add service charge line item
      $('tr#service-charge td.price h5').html(data.service_charge);
      $('tr#service-charge td.price').attr('data-price', data.service_charge);
      if (data.service_charge > 0) {
        $('tr#service-charge').show();
      } else {
        $('tr#service-charge').hide();
      }
      
      // todo validate amount
      $('.continue #cart-total').html(data.total);
      $('.continue #cart-total').show();

      $('.formatCurrency').formatCurrency();

			console.log(data.tickets)
			console.log(data.tickets.length)
			
			if(data.tickets.length > 0 || data.donations.length > 0) {
      	$('#cart .continue a').removeClass('disabled');		
			} else {
      	$('#cart .continue a').addClass('disabled');	
			}

    },
    error: function(data) {
      // console.log("updateOrderOnServer: ERROR");
      // console.log(data);
    }
  });
}

function updateQuantityInCart() {
  $('#cart select.ticket-count').each(function() {
    ticketCount = parseInt($(this).val());
    sectionId = $(this).parents('tr').attr('data-section-id');
    showId = $(this).parents('tr').attr('data-show-id');
    unitPrice = $(this).parent('td').attr('data-unit-price')

    $(this).parent('td').attr('data-quantity', ticketCount);
    subTotal = parseFloat(unitPrice) * ticketCount;
    $(this).parents('tr').find('td.price').attr('data-price', subTotal);
    $(this).parents('tr').find('td.price h5').text(subTotal);
  })
}

function checkout() {
  // POST "/store/checkout" // Store::CheckoutsController#create as HTML // Parameters: {"utf8"=>"✓", "authenticity_token"=>"oGmh5IrGv6CU3aPbpERHFNTpZg6YAiwLXY66d0zev6I=", "athena_payment"=>{"athena_customer"=>{"first_name"=>"test", "last_name"=>"test", "phone"=>"test", "email"=>"test@test.com"}, "athena_credit_card"=>{"cardholder_name"=>"test test", "card_number"=>"4242424242424242", "cvv"=>"123", "expiration_date(3i)"=>"1", "expiration_date(2i)"=>"2", "expiration_date(1i)"=>"2015"}, "billing_address"=>{"street_address1"=>"test", "city"=>"test", "state"=>"AL", "postal_code"=>"12345"}, "user_agreement"=>"1"}, "confirmation"=>"1", "commit"=>"Purchase"}
  $('#complete-purchase').addClass('disabled');

  // make sure agreement checkbox is checked
  if ($('#agreement-checkbox').is(':checked')) {
    $('#purchase .error').hide();
    $.ajax({
      type: 'POST',
      url: storefront_create_store_checkout_path,
      data: $("form#shopping-cart-form").serialize(),
      success: function(data) {
        $('#nav').hide();
        // console.log("SUCCESS!");
        // console.log(data);
        $('.tab-pane').hide();
        $('.tab-pane#thanks').show();
      },
      error: function(data) {
        $('#nav li').removeClass('active');
        // console.log("ERROR!");
        // console.log(data);
        $('.tab-pane').hide();
        $('.tab-pane#result').show();
        $('.tab-pane#result').html("<h4>Your payment did not go through.</h4><p>" + data.responseText + ".</p>");
        $('#complete-purchase').removeClass('disabled');
      }
    });
  } else {
    // have to add this error message manually for some reason
    $('#purchase .error').show();
    $('#complete-purchase').removeClass('disabled');
  }
}

function switchTabs(newSectionId) {
  $('#nav li').removeClass('active');
  $('li a[href="' + newSectionId + '"]').parent('li').addClass('active');
  $('.tab-pane').hide();
  $(newSectionId+'.tab-pane').show();
}

// validate fields inside a shopping cart tab
// return true if everything valid, false otherwise
// add error classes and labels if its invalid
function validateSection(sectionId) {
  var everythingValid = true;
  $(sectionId + ' input.required').each(function() {
    v = $('#shopping-cart-form').validate().element("#" + $(this).attr('id'));
    if (!(v)) {everythingValid = false};
  });
  return everythingValid;
}

function addItemToCart(type, params) {
  if (type === 'ticket') {
    // if exisiting line item for this secion and show, dont add it again
    if (!($("[data-section-id='" + params.sectionId + "'][data-show-id='" + params.showId + "']").size() > 0)) {
      createTicketLineItem(params); 
    }
    
  } else if (type === 'donation') {
    createOrUpdateDonationLineItem(params);
  }

  updateTotal();
  $('.formatCurrency').formatCurrency();
  updateOrderOnServer();
}

function createTicketLineItem(params) {
  $('#cart table').prepend(
    "<tr class='ticket' data-section-id='" + params.sectionId + "' data-show-id='" + params.showId + "'>" +
      "<td class='remove'><a href='#'>remove</a></td>" +
      "<td class='details'>" +
        "<h5>" + params.sectionName + " ticket</h5>" +
        eventName + "<br />" +
        params.showingName +
      "</td>" +
      "<td class='quantity' data-quantity='" + params.ticketCount + "' data-unit-price='" + params.ticketPrice + "'>" +
        "<select class=\"ticket-count\" id=\"tickets__count\" name=\"tickets[][count]\"><option value=\"0\">0 Tickets<\/option>\n<option value=\"1\">1 Ticket<\/option>\n<option value=\"2\">2 Tickets<\/option>\n<option value=\"3\">3 Tickets<\/option>\n<option value=\"4\">4 Tickets<\/option>\n<option value=\"5\">5 Tickets<\/option>\n<option value=\"6\">6 Tickets<\/option>\n<option value=\"7\">7 Tickets<\/option>\n<option value=\"8\">8 Tickets<\/option>\n<option value=\"9\">9 Tickets<\/option>\n<option value=\"10\">10 Tickets<\/option><\/select>" +
        "<br /><span class='formatCurrency'>" + params.ticketPrice + "</span> each" +
        "<input id='section_id' name='tickets[][section_id]' type='hidden' value='" + params.sectionId +"'>" +
      "</td>" +
      "<td class='price' data-price='" + (params.ticketPrice * params.ticketCount) + "'>" +
        "<h5 class='formatCurrency'>" +
          (params.ticketPrice * params.ticketCount) +
        "</h5>" + 
      "</td>" +
    "</tr>"
  );

  $("[data-section-id='" + params.sectionId + "'][data-show-id='" + params.showId + "'] .ticket-count").val(params.ticketCount);
};

function createOrUpdateDonationLineItem(params) {
  $('#cart table tr.donation').remove();
  $('#cart table').prepend(
    "<tr class='donation'>" +
      "<td class='remove'><a href='#'>remove</a></td>" +
      "<td class='details'><h5>Donation</h5></td>" +
      "<td class='quantity'></td>" +
      "<td class='price' data-price='" + params.donationAmount + "'>" +
        "<h5 class='formatCurrency'>" + params.donationAmount + "</h5>" +
      "</td>" +
    "</tr>"
  );
}

function updateTotal() {
  total = 0;
  $('[data-price]').each(function() {
    total += parseFloat($(this).attr('data-price'));
  });
  $('.continue #cart-total').html(total);
}