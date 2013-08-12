
console.log("loadhi");
$(window).load(function () {
	$('.toggle').click(function(e) {
    $(this).toggleClass('selected');
    if ($(this).hasClass('selected')) {
    	$("."+e.target.id).fadeIn();
    } else {
    	$("."+e.target.id).fadeOut();
    }
	});
});
