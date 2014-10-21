var includedCategories = [];
var includedPlatforms = [];
var requiresMakefile, requiresExample, requiredVersion, requiredStars=0;
var sortBy = "star-sort";

$(document).ready(function() {
    $("img.lazy").lazy();
});

$(window).load(function () {

	$('.toggle').click(function(e) {
	    $(this).toggleClass('selected');
	});

	// STARS
	$('#e_stars').click(function(e) {
		$('#stars_menu').show();
	});

	$('#e_stars').mouseleave(function(e) {
		$('#stars_menu').hide();
	});

	$('#stars_menu').mouseleave(function(e) {
		$('#stars_menu').hide();
	});

	$('#stars_menu li').click(function(e) {
		var val = parseInt(e.target.getAttribute('value'), 10);
		if (val > 0) {
			$('#e_stars_selected').text(val+' stars');
			$('#e_stars').addClass('selected');
		} else {
			$('#e_stars_selected').text('stars');
			$('#e_stars').removeClass('selected');
		}
		$('#stars_menu').hide();
		requiredStars = val;
		filter();
	});

	// RELEASE
	$('#e_updated').click(function(e) {
		$('#updated_menu').show();
	});

	$('#e_updated').mouseleave(function(e) {
		$('#updated_menu').hide();
	});

	$('#updated_menu').mouseleave(function(e) {
		$('#updated_menu').hide();
	});

	$('#updated_menu li').click(function(e) {
		var val = parseInt(e.target.getAttribute('value'), 10);
		if (val > 0) {
			$('#e_updated_selected').text(e.target.innerText);
			$('#e_updated').addClass('selected');
		} else {
			$('#e_updated_selected').text('updated since');
			$('#e_updated').removeClass('selected');
		}
		$('#updated_menu').hide();
		requiredVersion = val;
		filter();
	});


	// SORT BY
	$('#e_sort_by').click(function(e) {
		$('#sort_by_menu').show();
	});

	$('#e_sort_by').mouseleave(function(e) {
		$('#sort_by_menu').hide();
	});

	$('#sort_by_menu').mouseleave(function(e) {
		$('#sort_by_menu').hide();
	});

	$('#sort_by_menu li').click(function(e) {
		var val = e.target.getAttribute('value');
		$('#e_sort_by_selected').text(e.target.innerText);
		$('#e_sort_by').addClass('selected');

		$('#sort_by_menu').hide();
		sortBy = val;
		filter();
	});

	// CATEGORIES
	$('.cat_toggle').click(function(ev) {
		includedCategories = [];
		$('.cat_toggle').each(function(i, elt) {
			if ($(elt).hasClass('selected')) {
				includedCategories.push($(elt).attr('value'));
			}
		});
		filter();
	});

	$('.clear-all').click(function(ev) {
		includedCategories = [];
		$('.cat_toggle').removeClass('selected');
		filter();
	});

	$('.clear-all').click(function(ev) {
		includedCategories = [];
		$('.cat_toggle').removeClass('selected');
		filter();
	});

	$('.select-all').click(function(ev) {
		selectAllCats();
		$('.cat_toggle').addClass('selected');
		filter();
	});


	// MAKEFILE
	$('#e_makefile').click(function(e) {
		requiresMakefile = !requiresMakefile;
		filter();
	});

	// EXAMPLE
	$('#e_example').click(function(e) {
		requiresExample = !requiresExample;
		filter();
	});


	// STARTUP
	// selectAllCats();
	// filter();

});

function selectAllCats() {
	$('.cat_toggle').each(function(i, elt) {
		includedCategories.push($(elt).attr('value'));
	});
}

function filter(){
	if (window.location.pathname == "/" || window.location.pathname == "/render") {
		var n = 0;
		console.log(sortBy);
		var repos = (sortBy == "alpha-sort") ? $('.repo').sort(repoAlphaSort) : $('.repo').sort(repoStarSort);
		repos.each(function(i,e){
			if( shown($(e)) ){
				$(e).fadeIn();
				if (n%3 == 0) {
					$(e).addClass('clear');
				} else {
					$(e).removeClass('clear');
				}

				if (n%3 == 2) {
					$(e).addClass('last');
				} else {
					$(e).removeClass('last');
				}
				n++;
			}
			else{
				$(e).fadeOut();
			}
			//console.log( "class is " + $(e).class() );
			$('#body').append($(e));
		});
		$('#repo_count').text("found "+n+" addons");
	}
}


function repoAlphaSort(a, b) {
	var id_a = $(a).attr('id').toLowerCase();
	var id_b = $(b).attr('id').toLowerCase();
	var val;
	if (id_a < id_b) val = -1;
	else if (id_a > id_b) val = 1;
	else val = 0;
	return val;
}


function repoStarSort(a, b) {
	var re = /.*s_([0-9]*).*/g;
	console.log($(a).attr('class')+" "+$(b).attr('class'));

	var stars_a = parseInt(re.exec($(a).attr('class'))[1], 10);
	re.lastIndex = 0;
	var stars_b = parseInt(re.exec($(b).attr('class'))[1], 10);
	re.lastIndex = 0;
	console.log(stars_a+" "+stars_b);
	return stars_b - stars_a;
}

function shown(e){
	// check cats
	if (includedCategories.length) {

		var include = false;
		for (var i=0; i<includedCategories.length; i++) {
			if (e.hasClass( includedCategories[i] )) {
				include = true;
				break;
			}
		}
		if (!include) {
			//console.log("no included category " + e.attr('class') );
			return false;
		}
	}
	/*
	//TODO
		// check plats
		if (includedPlatforms) {
			var include = false;
			for (var i=0; i<includedPlatforms; i++) {
				if (e.hasClass(includedPlatforms[i])) {
					include = true;
					break;
				}
			}
			if (!include) return false;
		}
	*/

	if(requiresMakefile && e.hasClass('m_false')){
		//console.log("no make file! " + e.attr('class') );
		return false;
	}

	if(requiresExample && e.hasClass('e_false')) {
		//console.log("no example! " + e.attr('class') );
		return false;
	}

	var re = /.*s_([0-9]*).*/g;
	var stars = parseInt(re.exec(e.attr('class'))[1], 10);

	if(stars < requiredStars){
		//console.log("not popular enough =( " + e.attr('class') );
		return false;
	}

	re = /.*of_([0-9]\.[0-9]\.[0-9]).*/g;
	var version = parseInt( re.exec(e.attr('class'))[1].split(".").join(""), 10 );
	if(version < requiredVersion){
		//console.log("toooo oooolldd " + e.attr('class') );
		return false;
	}

	//console.log("passed " + e.attr('class') );
	return true;//!
}
