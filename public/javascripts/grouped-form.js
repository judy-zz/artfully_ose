Array.prototype.unique = function() {
  var a = [],
      l = this.length,
      i, j;

  for(i = 0; i < l; i++) {
    for(j = i+1; j < l; j++) {
      if (this[i] === this[j]){
        j = ++i;
      }
    }
    a.push(this[i]);
  }
  return a;
};

$(document).ready(function(){
  var methods = {
    hideGroups: function(){
      $(".grouped-form").css('display', 'none');
    },

    findItems: function(){
      var items = [];
      $(".grouped-form form input:checkbox").each(function(){
          items.push($(this).attr('class'));
      });
      return items.unique();
    },

    generateCheckboxes: function(items){
      $.each(items, function(index, id){
        var target = $('.row_' + id),
            $td = $(document.createElement('td'));

        $checkbox = $(document.createElement('input')).attr({'type':'checkbox'}).prependTo($td);
        $checkbox.change(function(){
          $("." + id).attr("checked", $(this).is(":checked"));
        });
        $td.prependTo(target);
      });
    },

    generateControls: function(){
      var controls = $(document.createElement('div')).addClass('table-controls'),
          ul =       $(document.createElement('ul')).appendTo(controls);

      $(".grouped-form").find("input:submit").each(function(){
        var original = this,
            button = $(document.createElement('input')).attr({'type':'button', 'value':$(this).attr('value')}),
            $li = $(document.createElement('li'));

        button.click(function(){ $(original).click(); });
        $li.append(button).appendTo(ul);
      });

      controls.prependTo($(".grouped-form-target form"));
    }
  };

  methods.hideGroups();
  methods.generateCheckboxes(methods.findItems());
  methods.generateControls();

});