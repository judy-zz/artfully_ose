
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

$(document).ready( function(){
    $('#action-list').dataTable({
        "iDisplayLength": 20,
        "bPaginate": true,
        "bJQueryUI": true,
        "sDom": '<"H"lfip>t<"F"ip>',
        "aoColumns": [
        null,
        null,
        null,
        null,
        null
        ]
    });
});