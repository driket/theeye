#= require widgets
#= require probes
#= require clock

$ ->
	
	# create and start clock
	clock = new Clock '#clock'
			
	# create widgets
	dashboard = new Dashboard '.widgets', $widgets 

	# create probes
	probe = new Probe '.probes', $probes
	
	# refresh widgets each time clock 'ticks'
	$("#clock").bind tick: ->
		dashboard.refresh_all()
	