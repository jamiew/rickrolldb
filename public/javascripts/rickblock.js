// ------
// rickrolldb.com javascriptzzz
// jamiew says: "jquery is #1"
// ------


// firebug decoy
if (!("console" in window) || !("firebug" in console)) {
  var names = ["log", "debug", "info", "warn", "error", "assert", "dir", "dirxml",
  "group", "groupEnd", "time", "timeEnd", "count", "trace", "profile", "profileEnd"];

  window.console = {};
  for (var i = 0; i < names.length; ++i)
    window.console[names[i]] = function() {};
}


// application
$(document).ready(function(){

  // loading indicators
	$("#loading").ajaxStart(function(){
	  $(this).css('top', $(document).scrollTop() + 30).show();
	}).ajaxStop(function(){
	  $(this).hide();
	});


	// clear input on click
	$('input.clear-on-click').click(function(){
		$(this).val('');
	});
	
	// editable name
	$('.username.editable').click(function(){
  	var name = prompt("What is your name?");
  	$(this).hide().html(name).fadeIn('fast');
  	// TODO set cookie & hidden form field
	});
	
  // hijax links
  $('a.flag.hijax').click(function(){
    $(this).parent().parent().parent().find('.flags a').hide(); // hide immediately
    $(this).parent().find('.count').load($(this).attr('href'), {method: 'POST'} ); // update vote count w/ result
    return false;
  });

  // hide things you've flagged
  // TODO benchmark this
  
  $('.what').each(function(){
    console.log($(this));
    
  });  
});