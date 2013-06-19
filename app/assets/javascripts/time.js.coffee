window.sleep = (milliseconds) ->
	start = new Date.getTime
	for i in [0..1e7] by 1
		if (new Date().getTime() - start) > milliseconds
			break;
