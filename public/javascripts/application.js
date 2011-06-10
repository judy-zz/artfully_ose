zebra = function(table) {
    $("tr", table).removeClass("odd");
    $("tr", table).removeClass("even");
    $("tr:even", table).addClass("even");
    $("tr:odd", table).addClass("odd");
}

$(document).ready(function() {
  $(".zebra tbody").each(function(){
    zebra($(this));
  });

  $(".detailed-list li").hover(
    function(){
      $(this).find(".controls").stop(false,true).fadeIn('fast'); },
    function(){
      $(this).find(".controls").stop(false,true).fadeOut('fast'); });

  $(".close").click(function(){
    $(this).closest('.flash').remove();
  })

  $("#main-menu").hover(
    function(){ $("#main-menu li ul").stop().animate({height: '106px'}, 'fast') },
    function(){ $("#main-menu li ul").stop().animate({height: '0px'}, 'fast') }
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
    $(this).closest('form').find("input[type='checkbox']").each(function(){
      if(isChecked != $(this).is(":checked")){
        $(this).click();
      }
    });
  });

  $(".sortedstar").tablesorter( {sortList: [[0,1], [1,1]]} );

  $(".zebra tbody").each(function(){
    zebra($(this));
  });

  $(".dropdown-controller").click(function() {
    $('.dropdown').toggle();
  });

  $(".popup").dialog({ autoOpen: false, draggable:false, modal:true, width:600, height:400, title:"Log Action" })

  $(".popup-link").bind("ajax:complete", function(et, e){
    $(".popup").dialog( "open" );
    $(".popup").html(e.responseText); 
    activateControls();
    return false;
  });
  
  $(".super-search").bind("ajax:complete", function(evt, data, status, xhr){
      $(".super-search-results").html(data.responseText);
  });
});

function activateControls() {
  $(".currency").maskMoney({showSymbol:true, symbolStay:true, allowZero:true, symbol:"$"});
  $(".currency").closest("form").submit(function(){
    var input = $(this).find(".currency"),
        cents = Math.round( parseFloat(input.val().substr(1).replace(/,/,"")) * 100 ),
        hiddenCurrency = input.clone().attr({type:"hidden"}).appendTo(this);
    hiddenCurrency.val(cents);
  });

  $(".tablesorter").tablesorter();
  $(".datepicker" ).datepicker();
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
