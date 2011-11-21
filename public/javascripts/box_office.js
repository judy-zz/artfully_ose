$(document).ready(function() {
	$('.ticket-quantity-select').change(function(){
    	$(this).closest("form").submit()
  	});

	$('.ticket-quantity-select').closest("form").bind("ajax:success", function(xhr, sale){
	   $('#total').find('.price').html(sale.total / 100).formatCurrency()
	});
})
