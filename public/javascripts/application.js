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
      $(this).find(".controls").stop(false,true).fadeIn('fast');},
    function(){
      $(this).find(".controls").stop(false,true).fadeOut('fast');});

  $(".close").click(function(){
    $(this).closest('.flash').remove();
  })

  $("#main-menu").hover(
    function(){$("#main-menu li ul").stop().animate({height: '106px'}, 'fast')},
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

  $(".popup").dialog({autoOpen: false, draggable:false, modal:true, width:600, height:400, title:"Log Action"})

  $(".popup-link").bind("ajax:complete", function(et, e){
    $(".popup").dialog( "open" );
    $(".popup").html(e.responseText);
    activateControls();
    return false;
  });

  $(".super-search").bind("ajax:complete", function(evt, data, status, xhr){
      $(".super-search-results").html(data.responseText);
  });

  $("form.sprited").live("ajax:before", function(){
    $(this).find("input:submit").attr('disabled','disabled');
  });

  $("form.sprited input:submit").live("click", function(event){
    var $dialog = $(this).siblings(".confirmation.dialog").clone(),
        $submit = $(this);

    console.log($dialog);

    if($dialog.length !== 0){
      var $confirmation = $(document.createElement('input')).attr({type: 'hidden', name:'confirm', value: 'true'});

      $dialog.dialog({
        autoOpen: false,
        modal: true,
        buttons: {
          Cancel: function(){
            $submit.removeAttr('disabled');
            $dialog.dialog("close")
          },
          Ok: function(){
            $dialog.dialog("close")
            $submit.closest('form').append($confirmation);
            $submit.closest('form').submit();
            $confirmation.remove();
          }
        }
      });
      $dialog.dialog("open");
      return false;
    }
  });

  $("form.sprited").live("ajax:success", function(xhr, performance){
    $(this).find(":submit").removeAttr('disabled');
    $(this).closest("tr").attr("class", performance.state)
  });

  $("form.sprited").live("ajax:error", function(xhr, status, error){
    $(this).find(":submit").removeAttr('disabled');
    data = eval("(" + status.responseText + ")");
    console.log(data.errors)
    for(var i = 0; i < data.errors.length; i++){
      $.gritter.add({
        title: "Oops!",
        text: data.errors[i]
      });
    }
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

$(document).bind('grouped-form-ready', function(){
    $('#ticket-table').dataTable({
        "iDisplayLength": 100,
        "bPaginate": true,
        "bJQueryUI": true,
        "sDom": '<"H"lfip>t<"F"ip>',
        "aoColumns": [
        null,
        null,
        {
            "sType": "currency"
        },
        null
        ]
    });
});