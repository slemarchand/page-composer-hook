(function() {
	document.addEventListener("DOMContentLoaded", function(event) {
		
		var themeId = getQueryParameter('_pagecomposer_themeId');
		var colorSchemeId = getQueryParameter('_pagecomposer_colorSchemeId');
		
		var extraQueryString = '_pagecomposer_themeId=' + themeId;
		if(colorSchemeId && colorSchemeId.trim().length > 0) {
			extraQueryString += '&_pagecomposer_colorSchemeId=' + colorSchemeId;
		}
		
		var portalURL = Liferay.ThemeDisplay.getPortalURL();
		
		var matches = document.querySelectorAll('a[href^="' + portalURL + '"], a[href^="/"]');
		
		for(var i = 0; i < matches.length; i++) {
			var a = matches.item(i);
			var href = a.getAttribute('href');
			href += (href.indexOf('?') == -1?'?':'&') + extraQueryString;
			a.setAttribute('href', href);
		}
	});
	
	function getQueryParameter(name)
	{
		var query = window.location.search.substring(1);
		
		var vars = query.split("&");
		
		for (var i=0;i<vars.length;i++) {
			var pair = vars[i].split("=");
			if(pair[0] == name) {
				return pair[1];
			}
		}
		
		return(false);
	}
	
	
})();



	
