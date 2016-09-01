(function() {
	
	document.addEventListener("DOMContentLoaded", function(event) {
		
		var clearThemeSwitchLink = document.querySelector('#clearThemeSwitchLink');
		
		if(clearThemeSwitchLink && clearThemeSwitchLink != null) {
		
			clearThemeSwitchLink.addEventListener("click", function(event) {
				
				event.preventDefault();
				
				var httpRequest = new XMLHttpRequest()
				httpRequest.onreadystatechange = function () {
					console.log('reload');
					location.href = location.href
									.replace(/_pagecomposer_[^&]*&?/g, '')
									.replace(/\\?$/g, '');
				}
				httpRequest.open('POST', '/c/page_composer/clear_theme_switch', true);
				httpRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
				httpRequest.send('');
			});
		
		}
	});
})();