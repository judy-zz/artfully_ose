jQuery.noConflict();
var currentState = true; //collapse state

function initMenu() {
    jQuery('#menu ul ul').hide();


  jQuery('#menu ul li a').each(function() {
    var hreflink = jQuery(this).attr("href");
        if (hreflink.toLowerCase()==location.href.toLowerCase()) {
        jQuery(this).parent().addClass("current");
    jQuery(this).parent().find("ul").slideDown('fast');

        }
    });
    jQuery('#menu ul li').hoverIntent(function() {
      jQuery(this).find("ul").slideDown('slow');

      }, function() {
      jQuery(this).find("ul").slideUp('slow');

      }

);
}

jQuery(document).ready(function() {

  jQuery(".currency").maskMoney({showSymbol:true, symbolStay:true, symbol:"$"});
  jQuery(".currency").closest('form').submit(function(){
    var input = jQuery(this).find(".currency"),
        cents = new Number(input.val().substr(1)) * 100,
        hiddenCurrency = input.clone().attr({type:"hidden"}).appendTo(this);
    hiddenCurrency.val(cents);
  });

  Cufon.replace('h1, h2, h5, .notification strong', { hover: 'true' }); // Cufon font replacement
  initMenu(); // Initialize the menu!
  //Nav collapse
   jQuery(".collapse").click(function() {
        jQuery("#menu ul li a span").fadeToggle();
        jQuery("#logo img").fadeToggle();
        if (currentState)
        {
        currentState = false;

        jQuery("#logoSmall").animate({
        opacity: 1}, 750);
        jQuery("#HelpBtn").animate({
        left: '-=145'}, 750);
        jQuery("#primary_right .inner").animate({
        left: '-=160',
        }, 750, function() {
        jQuery('#menu ul ul').hide();
        jQuery("#menu ul li").unbind('mouseover mouseout');
        jQuery('.collapse').html("expand");
        });
        }
        else
        {
        currentState = true;
        jQuery("#logoSmall").animate({
        opacity: 0}, 750);
        jQuery("#HelpBtn").animate({
        left: '+=145'}, 750);
        jQuery("#primary_right .inner").animate({
        left: '+=160',
        }, 750, function() {
        jQuery('.collapse').html("collapse");
        jQuery('#menu ul li').hoverIntent(function() {
        jQuery(this).find("ul").slideDown('slow');
        }, function() {
        jQuery(this).find("ul").slideUp('slow');
        });
        });
        }
        });
    //END nav collapse
  jQuery(".tablesorter").tablesorter(); // Tablesorter plugin

  jQuery(".new-performance-link").click(
    function() {
      jQuery("#new-performance-row").show();
      return false;
    }
  );

  jQuery(".cancel-new-performance-link").click(
    function() {
      jQuery("#new-performance-row").hide();
      return false;
    }
  );
  jQuery('#dialog').dialog({
    autoOpen: false,
    width: 650,
    buttons: {
      "Done": function() {
        jQuery(this).dialog("close");
      },
      "Cancel": function() {
        jQuery(this).dialog("close");
      }
    }
  }); // Default dialog. Each should have it's own instance.

  jQuery('.dialog_link').click(function(){
    jQuery('#dialog').dialog('open');
    return false;
  }); // Toggle dialog

  jQuery('.notification').hover(function() {
    jQuery(this).css('cursor','pointer');
  }, function() {
    jQuery(this).css('cursor','auto');
  }); // Close notifications

  jQuery('.checkall').click(
    function(){
      jQuery(this).parent().parent().parent().parent().find("input[type='checkbox']").attr('checked', jQuery(this).is(':checked'));
    }
  ); // Top checkbox in a table will select all other checkboxes in a specified column

  jQuery('.iphone').iphoneStyle(); //iPhone like checkboxes

  jQuery('.notification span').click(function() {
    jQuery(this).parents('.notification').fadeOut(800);
  }); // Close notifications on clicking the X button

  jQuery(".tooltip").easyTooltip({
    xOffset: -60,
    yOffset: 70
  }); // Tooltips!

  jQuery('#menu li:not(".current"), #menu ul ul li a').hover(function() {
    jQuery(this).find('span').animate({ marginLeft: '5px' }, 100);
  }, function() {
    jQuery(this).find('span').animate({ marginLeft: '0px' }, 100);
  }); // Menu simple animation

  jQuery('.fade_hover').hover(
    function() {
      jQuery(this).stop().animate({opacity:0.6},200);
    },
    function() {
      jQuery(this).stop().animate({opacity:1},200);
    }
  ); // The fade function

  //sortable, portlets
  jQuery(".sortable").sortable({
    connectWith: '.column',
    placeholder: 'ui-sortable-placeholder',
    forcePlaceholderSize: true,
    scroll: false,
    helper: 'clone'
  });

  jQuery(".portlet").addClass("ui-widget ui-widget-content ui-helper-clearfix ui-corner-all").find(".portlet-header").addClass("ui-widget-header ui-corner-all").prepend('<span class="ui-icon ui-icon-circle-arrow-s"></span>').end().find(".portlet-content");
  jQuery(".portlet2").addClass("ui-widget ui-widget-content ui-helper-clearfix ui-corner-all").find(".portlet-header").addClass("ui-widget-header ui-corner-all").prepend('<span class="ui-icon ui-icon-trash"></span><span class="ui-icon ui-icon-pencil"></span>').end().find(".portlet-content");
jQuery(".minimized").hide();
  jQuery(".portlet-header").click(function() {
    jQuery(this).toggleClass("ui-icon-minusthick");
    jQuery(this).parents(".portlet:first, .portlet2:first ").find(".portlet-content").toggle();
  });

  jQuery("table.stats").each(function() {
    if(jQuery(this).attr('rel')) { var statsType = jQuery(this).attr('rel'); }
    else { var statsType = 'area'; }

    var chart_width = (jQuery(this).parent().parent(".ui-widget").width()) - 60;
    jQuery(this).hide().visualize({
      type: statsType,  // 'bar', 'area', 'pie', 'line'
      width: '800px',
      height: '240px',
      colors: ['#6fb9e8', '#ec8526', '#9dc453', '#ddd74c']
    }); // used with the visualize plugin. Statistics.
  });

  jQuery(".tabs").tabs(); // Enable tabs on all '.tabs' classes

  jQuery( ".datepicker" ).datepicker();



  // Slider
  jQuery(".slider").slider({
    range: true,
    values: [20, 70]
  });

  // Progressbar
  jQuery(".progressbar").progressbar({
    value: 40
  });

  //Disable field labels (only use if labels are before!)
  jQuery("input:disabled"). prev().css("color","#e2e2e2");
});