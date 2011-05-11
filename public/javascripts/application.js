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
      $(this).find(".controls").fadeIn('fast'); },
    function(){
      $(this).find(".controls").fadeOut('fast'); });

  $(".close").click(function(){
    $(this).closest('.flash').remove();
  })

  $("#header-controls").click(function(){
    if($("#header-content").is(":visible")){
      $("#header-controls > a").html("&#9660;");
    } else {
      $("#header-controls > a").html("&#9650;");
    }

    $("#header-content").slideToggle();
  });

  $(".stats-controls").click(function(){
    $(this).parent("li").toggleClass("selected");
    $(this).siblings(".hidden-stats").slideToggle("fast");
    return false;
  });

  $(".currency").maskMoney({showSymbol:true, symbolStay:true, allowZero:true, symbol:"$"});
  $(".currency").closest("form").submit(function(){
    var input = $(this).find(".currency"),
        cents = Math.round( parseFloat(input.val().substr(1).replace(/,/,"")) * 100 ),
        hiddenCurrency = input.clone().attr({type:"hidden"}).appendTo(this);
    hiddenCurrency.val(cents);
  });

  $(".tablesorter").tablesorter();
  $(".datepicker" ).datepicker();

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
});

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
