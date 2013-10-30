#= require widgets
#= require probes
#= require clock

$ ->
	
	# create and start clock
	clock = new Clock '#clock', 60
			
	# if it is live view
	if $('body').hasClass 'probes'

		# create probes from generated json data
		for name, probe of $probes
			new Probe '.probes', probe

		# create widgets from generated json data
		for name, widget of $widgets
			new Widget widget, 'widget-graph', 3600, false
				
		# refresh widgets each time clock 'ticks'
		$("#clock").bind tick: ->
			Widget.refresh()


	# if it is report view
	else if $('body').hasClass 'samples'

		# create probes from generated json data
		for name, probe of $probes
			new Probe '.probes-report', probe

		# create widgets from generated json data
		for name, widget of $widgets
			new Widget widget, 'widget-report-graph', 3600 * 24, false
			
		# refresh widgets each time clock 'ticks'
		$("#clock").bind tick: ->
			Widget.refresh()