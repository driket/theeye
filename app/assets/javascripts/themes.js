function active_theme() {
	
	$background_color = $('html').css('background-color');
	//alert($background_color);
	if ($background_color == 'rgba(255, 255, 255, 0.796875)') {
		return 'white';
	}
	else {
		return 'black';
	}
}
