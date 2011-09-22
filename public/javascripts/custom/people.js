String.prototype.startsWith = function(str)
{return (this.match("^"+str)==str)}

$(document).ready(function() {
  var is_star = function(htmlElement) {
    return (htmlElement === "\u272D");
  };

  $(".starable").live('click', function() {
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
      $(this).trigger("unstarred");
    } else {
      $(this).html("&#10029;");
      $(this).trigger("starred");
    }

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

  function generateLink(field, $link){
    var href = $(field).html();

    if("Click to edit" !== href && "" !== href){
      $link.html("[ &#9656; ]").attr('target','_blank').appendTo($(field).parent());

      $link.hover(function(){
        if(!href.startsWith("http://")){
          href = "http://" + href;
        }
        $(this).attr("href", href);
      });
    }
  }

  $(".website.value").each(function(){
    var $link = $(document.createElement('a')),
        field = this;

    generateLink(field, $link);

    $(this).bind('done', function(){
      $link.remove();
      console.log($(field).html());
      generateLink(field, $link);
    });
  });

});