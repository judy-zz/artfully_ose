$(document).ready(function(){
  $("#new_athena_person").bind("ajax:success", function(xhr, person){
    console.log(person)
    var $target = $(".hidden-target").clone();
    $target.find("input[name='person_id']").val(person.id);
    $target.find(".name").html(person.first_name + " " + person.last_name + " (" + person.email + ")");
    $li = $(document.createElement('li'));
    $li.append($target.children()).appendTo(".wizard-list");
  });

  $("#new_athena_person").bind("ajax:error", function(xhr, status, error){
    data = eval("(" + status.responseText + ")");
    for(var i = 0; i < data.errors.length; i++){
      $.gritter.add({
        title: "Oops!",
        text: data.errors[i]
      });
    }
  });
});