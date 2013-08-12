
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

	$('#e_stars').click(function(e) {
		$('#stars_menu').show();
	});

	$('#stars_menu').mouseleave(function(e) {
		$('#stars_menu').hide();
	});

	$('#stars_menu li').click(function(e) {
		var it = e.target.innerText;
		if (it.indexOf('+') != -1) {
			$('#e_stars_selected').text(e.target.innerText+' stars');
			$('#e_stars').addClass('selected');
		} else {
			$('#e_stars_selected').text('stars');
			$('#e_stars').removeClass('selected');
		}
		$('#stars_menu').hide();
	});

	$('#e_updated').click(function(e) {
		$('#updated_menu').show();
	});

	$('#updated_menu').mouseleave(function(e) {
		$('#updated_menu').hide();
	});

	$('#updated_menu li').click(function(e) {
		var it = e.target.innerText;
		if (it.indexOf('.') != -1) {
			$('#e_updated_selected').text(e.target.innerText);
			$('#e_updated').addClass('selected');
		} else {
			$('#e_updated_selected').text('updated since');
			$('#e_updated').removeClass('selected');
		}
		$('#updated_menu').hide();
	});
});

