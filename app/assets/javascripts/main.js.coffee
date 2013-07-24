#= require widgets
#= require probes
#= require clock

$ ->
	
	# create and start clock
	clock = new Clock '#clock'
			
	# create widgets
	#dashboard = new Dashboard '.widgets', $widgets 

	# create probes
	
	for name, probe of $probes
		new Probe '.probes', probe
		
	console.log "count : ", Probe.count()
	console.log "first : ", Probe.find_by_id(1)
	
	# refresh widgets each time clock 'ticks'
	#$("#clock").bind tick: ->
	#	dashboard.refresh_all()
	