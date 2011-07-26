$(document).ready(function() {
  var is_star = function(htmlElement) {
    return (htmlElement === "\u272D");
  };

  $(".starable").click(function() {
    var star      = $.trim($(this).html()),
        person_id = $(this).attr("data-person-id"),
        type      = $(this).attr("data-type"),
        id        = $(this).attr("data-action-id"),
        this_table = $(this).parents('table'),
        this_row   = $(this).parents('tr');

    $.ajax({
       type: "POST",
       url: "/people/" + person_id + "/star/" + type + "/" + id
    });

    if(is_star(star)) {
      $(this).html("&#10025;");
      this_table.append(this_row);
    } else {
      $(this).html("&#10029;");
      this_row.prependTo('tbody:first', this_table);
    }

    //resort the table on star and date, we'll lose whatever sort they had
    this_table.tablesorter();

    //and re-zebra the table
    zebra(this_table);
  });

  $(".relationship_starred").click(function() {
    var star      = $.trim($(this).html()),
        person_id = $(this).attr("data-person-id"),
        type      = $(this).attr("data-type"),
        id        = $(this).attr("data-action-id"),
        relationship_type  = $.trim($('.relationship_type',this.parent).html()),
        name               = $.trim($('.relationship_person',this.parent).html()),
        relationships_list = $('#key_relationships');

    if(is_star(star)) {
      relationships_list.append("<li id='"+id+"'><div class='key'>"+relationship_type+"</div><div class='value'>"+name+"</div></li>");
    } else {
      $(('#'+id), relationships_list).remove();
    }
  });
});