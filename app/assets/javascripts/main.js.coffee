#= require widgets
#= require probes
#= require clock

$ ->
	
	# create and start clock
	clock = new Clock '#clock'
			
	# create probes from generated json data
	for name, probe of $probes
		new Probe '.probes', probe

	# create widgets from generated json data
	for name, widget of $widgets
		new Widget widget
				
	# refresh widgets each time clock 'ticks'
	$("#clock").bind tick: ->
		Widget.refresh()
	