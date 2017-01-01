var main = function () {

	
	
	$('#newsong').click(function() {
		var index = $('.songs span').size();
		$('.songs').append("<span> " + (index+1) + " | <input type='text' id='long-input' placeholder='Name' name='songs[]'></span>");
	});
	$('#minussong').click(function() {
		$('.songs span:last-child').remove();
	});

}
$(document).ready(main);