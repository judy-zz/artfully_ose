
$(document).bind('grouped-form-ready', function(){
    $('#ticket-table').dataTable({
        "iDisplayLength": 100,
        "bPaginate": true,
        "bJQueryUI": true,
        "sDom": '<"H"lf>t<"F"ip>',
				"oLanguage": {
					"sZeroRecords": "No tickets match your filter",
					"sEmptyTable": "There are no tickets.  Click 'Add Tickets' to add tickets to this show."
    		},
        "aoColumns": [
        null,
        null,
        null,
        null
        ]
    });
});

$(document).ready( function(){
    var $table = $('#kits-table').dataTable({
        "iDisplayLength": 20,
        "bPaginate": true,
        "bJQueryUI": true,
        "sDom": '<"H"lf>t<"F"ip>'
    });
});

$(document).ready( function(){
    var $table = $('#all-kits-table').dataTable({
        "iDisplayLength": 20,
        "bPaginate": true,
        "bJQueryUI": true,
        "sDom": '<"H"lf>t<"F"ip>'
    });
});

$(document).ready( function(){
    var $table = $('#action-list').dataTable({
        "iDisplayLength": 20,
        "bPaginate": true,
        "bJQueryUI": true,
        "sDom": '<"H"lf>t<"F"ip>',
        "aoColumns": [
        { "asSorting": [ 'desc', 'asc' ], "bSortable": false },
        null,
        null,
        null,
        { "bSortable": false }
        ]
    });
});

$(document).ready( function(){
	$('#order-table').dataTable({
	    "iDisplayLength": 100,
	    "bPaginate": true,
	    "bJQueryUI": true,
	    "sDom": '<"H"lf>t<"F"ip>'
	});
	$('#donation-table').dataTable({
	    "iDisplayLength": 100,
	    "bPaginate": true,
	    "bJQueryUI": true,
	    "sDom": '<"H"lf>t<"F"ip>'
	});
	$('#settlement-table').dataTable({
	    "iDisplayLength": 100,
	    "bPaginate": true,
	    "bJQueryUI": true,
	    "sDom": '<"H"lf>t<"F"ip>'
	});
	$('#shows-table').dataTable({
	    "iDisplayLength": 100,
	    "bPaginate": true,
	    "bJQueryUI": true,
	    "sDom": '<"H"lf>t<"F"ip>'
	});
});