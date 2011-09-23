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

$("document").ready(function(){
  $("#terms").keypress(function(e){
    if (e.which == 13) {
      e.stopImmediatePropagation();
      e.stopPropagation();
      $("#people-for-sales").click();
      return false;
    }
  });

  $("#anonymous").change(function(){
    if($(this).is(":checked")){
      $("#person-search").addClass("hidden");
      $(".target li:visible").remove();
      $("#dummy").click();
    } else {
      $("#person-search").removeClass("hidden");
    }
  });

  $("#cash").change(function(){
    if($(this).is(":checked")){
      $("#payment-info").addClass("hidden");
      $("#credit_card_card_number").val("")
    } else {
      $("#payment-info").removeClass("hidden");
    }
  });

  $("#people-for-sales").bind("click", function(){
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
        $.each(people, function(index, person){
          bulletedListItem(person);
        });
      });
    }
  });
});