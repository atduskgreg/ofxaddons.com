


var includedCategories = [];
var includedPlatforms = [];
var requiresMakefile, requiresExample, requiredVersion, requiredStars=1;

$(window).load(function () {
	$('.toggle').click(function(e) {
    $(this).toggleClass('selected');
	});

	// STARS
	$('#e_stars').click(function(e) {
		$('#stars_menu').show();
	});

	$('#stars_menu').mouseleave(function(e) {
		$('#stars_menu').hide();
	});

	$('#stars_menu li').click(function(e) {
		var val = parseInt(e.target.getAttribute('value'), 10);
		if (val > 0) {
			$('#e_stars_selected').text(e.target.innerText+' stars');
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
	selectAllCats();
	filter();

});

function selectAllCats() {
	$('.cat_toggle').each(function(i, elt) {
		includedCategories.push($(elt).attr('value'));
	});
}

function filter(){
	var n = 0;
	$('.repo').each(function(i,e){
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
	});

}


function shown(e){
	// check cats
	if (includedCategories.length == 0) return false;

	var include = false;
	for (var i=0; i<includedCategories.length; i++) {
		if (e.hasClass( includedCategories[i] )) {
			include = true;
			break;
		}
	}
	if (!include) {
		console.log("no included category " + e.attr('class') );
		return false;
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
		console.log("no make file! " + e.attr('class') );
		return false;  
	} 

	if(requiresExample && e.hasClass('e_false')) {
		console.log("no example! " + e.attr('class') );
		return false;
	}

	var re = /.*s_([0-9]*).*/g;
	var stars = parseInt(re.exec(e.attr('class'))[1], 10);
	
	if(stars < requiredStars){
		console.log("not popular enough =( " + e.attr('class') );
		return false;
	} 

	re = /.*of_([0-9]\.[0-9]\.[0-9]).*/g;
	var version = parseInt( re.exec(e.attr('class'))[1].split(".").join(""), 10 );
	if(version < requiredVersion){
		console.log("toooo oooolldd " + e.attr('class') );		
		return false;
	} 

	console.log("passed " + e.attr('class') );
	return true;//!
}


