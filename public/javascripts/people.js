is_star = function(htmlElement) {
	return (htmlElement == "\u272D")
}

$(document).ready(function() {
  $(".starable").click(function() {
    star = $(this).html().trim()
    person_id = $(this).attr("id").split("_")[0]
    type = $(this).attr("id").split("_")[1]
    id = $(this).attr("id").split("_")[2]
    
    $.ajax({
       type: "POST",
       url: "/people/" + person_id + "/star/" + type+ "/" + id,
     });
     this_table = $(this).parents('table')
     this_row = $(this).parents('tr')
     
    if(is_star(star)) {
      $(this).html("&#10025;")
      this_table.append(this_row) 
    } else {  
      $(this).html("&#10029;")  
      this_row.prependTo('tbody:first', this_table)	  
    }
	
	//resort the table on star and date, we'll lose whatever sort they had
	this_table.tablesorter( {sortList: [[0,1], [1,1]]} );
	
	//and re-zebra the table
	zebra(this_table)
  });

  $(".relationship_starred").click(function() {
    star = $(this).html().trim()
    person_id = $(this).attr("id").split("_")[0]
    type = $(this).attr("id").split("_")[1]
    id = $(this).attr("id").split("_")[2]
	relationship_type = $('.relationship_type',this.parent).html().trim()
	name = $('.relationship_person',this.parent).html().trim()
	relationships_list = $('#key_relationships')
  
    if(is_star(star)) {
		relationships_list.append("<li id='"+id+"'><div class='key'>"+relationship_type+"</div><div class='value'>"+name+"</div></li>")
    } else {  
		$(('#'+id), relationships_list).remove()
    }
  });
});