$(document).ready(function () {
  $("form.sprited").live("ajax:before", function(){
    $(this).find("input:submit").attr('disabled','disabled');
  });

  $("form.sprited input:submit").live("click", function(event){
    var $dialog = $(this).siblings(".confirmation.dialog").clone(),
        $submit = $(this);

    if($dialog.length !== 0){
      event.preventDefault();
      event.stopImmediatePropagation();
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
    var $row = $(this).closest("tr");
    $(this).find(":submit").removeAttr('disabled');
    $row.removeClass("pending built published unpublished")
    $row.addClass(performance.state);
    $row.find(".available").html(performance.glance.tickets.available);
    $row.find(".gross").html(performance.glance.tickets.sold.gross);
    $row.find(".comped").html(performance.glance.tickets.comped);
  });

  $("form.sprited").live("ajax:error", function(xhr, status, error){
    var data;

    $(this).find(":submit").removeAttr('disabled');
    data = eval("(" + status.responseText + ")");
    for(var i = 0; i < data.errors.length; i++){
      $.gritter.add({
        title: "Oops!",
        text: data.errors[i]
      });
    }
  });
});