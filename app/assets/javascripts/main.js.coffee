#= require widgets
#= require probes

$ ->
		
	alert 'yo'
	dashboard = new Dashboard '.widgets', $widgets 

	probe = new Probe '.probes', $probes
	
	# each time clock 'ticks'
	$("#clock").bind tick: ->
		dashboard.refresh_all()
	