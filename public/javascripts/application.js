zebra = function(table) {
    $("tr", table).removeClass("odd");
    $("tr", table).removeClass("even");
    $("tr:even", table).addClass("even");
    $("tr:odd", table).addClass("odd");
}

bindControlsToListElements = function () {
  $(".detailed-list li").hover(
    function(){
      $(this).find(".controls").stop(false,true).fadeIn('fast');},
    function(){
      $(this).find(".controls").stop(false,true).fadeOut('fast');});
}

$(document).ready(function() {
  if (typeof(Zenbox) !== "undefined") {
    Zenbox.init({
      dropboxID:   "20016501",
      url:         "https://artfully.zendesk.com",
      tabID:       "help",
      tabColor:    "black",
      tabPosition: "Left"
    });
  }

  $("form .description").siblings("input").focusin(function(){
    $("form .description").addClass("active");
  }).focusout(function(){
    $("form .description").removeClass("active");
  });

  $(".zebra tbody").each(function(){
    zebra($(this));
  });

  $('input, textarea').placeholder();

  $(".close").click(function(){
    $(this).closest('.flash').remove();
  })

  $("#main-menu").hover(
    function(){$("#main-menu li ul").stop().animate({height: '124px'}, 'fast')},
    function(){$("#main-menu li ul").stop().animate({height: '0px'}, 'fast')}
  );

  $(".stats-controls").click(function(){
    $(this).parent("li").toggleClass("selected");
    $(this).siblings(".hidden-stats").slideToggle("fast");
    return false;
  });

  activateControls();

  $(".new-performance-link").click(function() {
    $("#new-performance-row").show();
    return false;
  });

  $(".cancel-new-performance-link").click(function() {
    $("#new-performance-row").hide();
    return false;
  });

  $(".checkall").click(function(){
    var isChecked = $(this).is(":checked")
    $(this).closest('form').find("input[type='checkbox']:enabled").each(function(index, element){
      element.checked = isChecked;
      $(element).change();
    });
  });

  $(".zebra tbody").each(function(){
    zebra($(this));
  });

  $(".search-help-popup").dialog({autoOpen: false, draggable:false, modal:true, width:700, title:"Search help"})
  $("#search-help-link").click(function(){
    $(".search-help-popup").dialog("open")
    return false;
  });

  $(".popup").dialog({autoOpen: false, draggable:false, modal:true, width:600, title:"Log Action"})

  $(".popup-link").bind("ajax:complete", function(et, e){
    $(".popup").dialog( "open" );
    $(".popup").html(e.responseText);
    activateControls();
    return false;
  });

  $(document).ready(function() {
    var eventId = $("#calendar").attr("data-event");
    $('#calendar').fullCalendar({
      height: 150,
      events: '/events/'+ eventId + '.json'
    });
    $('#calendar').fullCalendar( 'changeView', 'basicWeek' )
  });

  $('.subject-tag').each(function() {
	createControlsForTag($(this));
  });

  $(".new-tag-form").bind("ajax:beforeSend", function(evt, data, status, xhr){
	var tagText = $('#new-tag-field').attr('value');
	if(!validTagText(tagText)) {
		$('.tag-error').text("Only letters, number, or dashes allowed in tags")
		return false;
	} else {
		$('.tag-error').text("")
	}

    newTagLi = $(document.createElement('li'));
	newTagLi.addClass('tag').addClass('subject-tag').html(tagText).appendTo($('.tags'));
	$('.tags').append("\n");
	createControlsForTag(newTagLi);
    $('#new-tag-field').attr('value', '');

	bindControlsToListElements();
	bindXButton();
  });

  bindControlsToListElements();
  bindXButton();

  $(".delete").bind("ajax:beforeSend", function(evt, data, status, xhr){
    $(this).closest('.tag').remove();
  });

  $(".super-search").bind("ajax:complete", function(evt, data, status, xhr){
      $(".super-search-results").html(data.responseText);
      $(".super-search-results").removeClass("loading");
  }).bind("ajax:beforeSend", function(){
    $(".super-search-results").addClass("loading");
  });

  $('.editable .value').each(function(){
    var url = $(this).attr('data-url'),
        name = $(this).attr('data-name');

    $(this).editable(url, {
      method: "PUT",
      submit: "OK",
      cssclass: "jeditable",
      height: "15px",
      width: "90px",
      name: "athena_person[athena_person][" + name + "]",
      callback: function(value, settings){
        $(this).html(value[name]);
        $(this).trigger('done')
      },
      ajaxoptions: {
        dataType: "json"
      }
    });
  });
});



bindXButton = function() {
  $(".delete").bind("ajax:beforeSend", function(evt, data, status, xhr){
    $(this).closest('.tag').remove();
  });
}

/*
 * Validates alphanumeric and -
 */
validTagText = function(tagText) {
	var alphaNumDashRegEx = /^[0-9a-zA-Z-]+$/;
	return alphaNumDashRegEx.test(tagText);
}

createControlsForTag = function(tagEl) {
	var tagText = tagEl.html().trim();
	var subjectName = tagEl.parent("ul").attr('id').split("-")[0];
	var subjectId = tagEl.parent("ul").attr('id').split("-")[1];

	var deleteLink = '<a href="/'+subjectName+'/'+ subjectId +'/tag/'+ tagText +'" data-method="delete" data-remote="true" rel="nofollow">X</a>'
	var controlsUl =  $(document.createElement('ul')).addClass('controls')
	var deleteLi = $(document.createElement('li')).addClass('delete').append(deleteLink)

	controlsUl.append(deleteLi);

    tagEl.append(controlsUl);
	tagEl.append("\n");
}

function activateControls() {
  $(".currency").each(function(index, element){
    var name = $(this).attr('name'),
        input = $(this),
        form = $(this).closest('form'),
        hiddenCurrency = $(document.createElement('input'));

    input.maskMoney({showSymbol:true, symbolStay:true, allowZero:true, symbol:"$"});
    input.attr({"id":"old_" + name, "name":"old_" + name});
    hiddenCurrency.attr({'name': name, 'type': 'hidden'}).appendTo(form);

    form.submit(function(){
      hiddenCurrency.val(Math.round( parseFloat(input.val().substr(1).replace(/,/,"")) * 100 ));
    });
  });

  $(".datepicker" ).datepicker({dateFormat: 'yy-mm-dd'});
  $('.datetimepicker').datetimepicker({dateFormat: 'yy-mm-dd', timeFormat:'hh:mm tt', ampm: true });
}

function togglePrintPreview(){
    var screenStyles = $("link[rel='stylesheet'][media='screen']"),
        printStyles = $("link[rel='stylesheet'][href*='print']");

    if(screenStyles.get(0).disabled){
      screenStyles.get(0).disabled = false;
      printStyles.attr("media","print");
    } else {
      screenStyles.get(0).disabled = true;
      printStyles.attr("media","all");
  }
}
