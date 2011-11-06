$(document).ready(function(){
  $("#new_person").bind("ajax:success", function(xhr, person){
    var $target = $(".hidden-target").clone();
    $target.find("input#person_id").val(person.id);
    $target.find(".name").html(person.first_name + " " + person.last_name + " (" + person.email + ")");
    $li = $(document.createElement('li'));
    $li.append($target.children()).appendTo(".wizard-list");
    $(this).find("input:submit").removeAttr('disabled');
  });

  $("#new_person").bind("ajax:error", function(xhr, status, error){
    $(this).find("input:submit").removeAttr('disabled');
    data = eval("(" + status.responseText + ")");
    for(var i = 0; i < data.errors.length; i++){
      $.gritter.add({
        title: "Oops!",
        text: data.errors[i]
      });
    }
  });

  $("#new_person").live("ajax:before", function(){
    $(this).find("input:submit").attr('disabled','disabled');
  });
});