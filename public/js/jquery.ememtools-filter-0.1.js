/**
 * jQuery searcher plugin
 * This jQuery plugin add support to search filtering
 * @name jquery.ememtools-filter-0.1.js
 * @author Denis Ovchinnikov aka Corwin (den_corwin@mail.ru)
 * @version 0.1
 * @date July 14, 2009
 * @category jQuery plugin
 * @copyright (c) 2009 Denis Ovchinnikov
 * @license MIT
 * @example $("#Search").filtering("#someTbl tr", { minLength : 4, caseSensitive: true });
 */

(function($) {
	/*
	// Can be used instead of "$(rowSelector).each(function() {..." construction, to provide 
	// .filter(":contains_ci()") functionality, but since beeing more simple it is a bit slower (about 12%)
	
	jQuery.expr[':'].contains_ci = function(a,i,m){
		return jQuery(a).text().toUpperCase().indexOf(m[3].toUpperCase())>=0;
	};
	*/
	
    $.fn.filtering = function(items, options) {
        // Extend our default options with those provided.
        // Note that the first arg to extend is an empty object -
        // this is to keep from overriding our "defaults" object.
        var opts = $.extend({}, $.fn.filtering.defaults, options);

        filt = function() {
            var c_text = (opts.caseSensitive)?$(this).val():$(this).val().toUpperCase();
            if (c_text.length < opts.minLength) {
				// Showing full list of filtered items and breaking filter execution
                $(items).fadeIn(opts.speed);
                return;
            }

			if (opts.caseSensitive) {
				// SHOW all elements that matches the c_text
				$(items).filter(":contains(" + c_text + ")").fadeIn(opts.speed);
	
				// HIDE all elements that NOT matches the c_text
				$(items).filter(":not(:contains(" + c_text + "))").fadeOut(opts.speed);
			} else {
				$(items).each(function() {
					// SHOW all elements that matches the c_text
					if ($(this).text().toUpperCase().indexOf(c_text)>=0) $(this).fadeIn(opts.speed);
					
					// HIDE all elements that NOT matches the c_text
					else $(this).fadeOut(opts.speed);
				});
			}
		};

        if (opts.focus == true) this.focus();

        // Perform filtering with the current element state
        filt();

        return this.keyup(filt);
    };

    // defaults
    $.fn.filtering.defaults = {
        minLength: 2,           // minimum length to perform search
		caseSensitive:false,
		speed:30, // fadeIn\fadeOut effect speed
        focus: false // set focus on filter textfield
    };

})(jQuery);