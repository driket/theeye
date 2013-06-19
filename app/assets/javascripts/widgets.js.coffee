# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class Dashboard
	
	constructor: (@element, @widgets) ->

		# init & first display 
		
		$(@element).sortable()
		this.refresh()


	# refresh a given widget
	
	refresh_widget: (name, widget) =>
		
		# setup jQuery selector
		
		widget_name = '#' + name
		template 		= '#' + widget.template


		# prepare data for template
		
		template_variables =
			'name': name
			'widget': widget
			
			
		# if widget doesn't exist, create and add an empty one
		
		if $(widget_name).length == 0
			
			content = $('#empty_template').tmpl template_variables
			$('#widgets').append content
	
	
		# if refresh delay is up
	
		if new Date().getTime() - widget.data.date > widget.refresh_delay

	    #display activity indicator while loading
		
			$(widget_name).spin 'large', '#888'

			#
			# fetch data remotely (async)
			#
		
			# simulate monitored value
		
			widget.data.monitored_value = parseInt Math.random() * 100;
			widget.data.date = new Date().getTime()
	
			content = $(template).tmpl template_variables;
			$(widget_name + ' .face-simple-view').html content;
	
			# hide activity indicator (loaded)
		
			$(widget_name).spin false
	
			status = this.render_graph name, widget		

			$(widget_name).removeClass 'service-status-ok'
			$(widget_name).removeClass 'service-status-disabled'
			$(widget_name).removeClass 'service-status-alert'
			$(widget_name).removeClass 'service-status-warning'

			if status 			== 'alert'
				$(widget_name).addClass 'service-status-alert'	
			else if status 	== 'warning'
				$(widget_name).addClass 'service-status-warning'	
			else
				$(widget_name).addClass 'service-status-ok'	
		

	# refresh all dashboard's widgets
	
	refresh: => 
	
		# for each widget
		
		for name, widget of @widgets

			this.refresh_widget name, widget
			
			
	# draw graph for a given widget

	render_graph: (name, widget) =>

		service_warning			= false
		service_alert				= false

		threshold_warning 	= 90
		threshold_alert			= 97

		time_scale 					= 60 #(in second)

		color_ok 						= theme_color_for_class 'service-status-ok'
		color_warning 			= theme_color_for_class 'service-status-warning'
		color_alert					= theme_color_for_class 'service-status-alert'
		fill_color					= theme_color_for_class 'very-light-color'
		grid_color					= theme_color_for_class 'service-status-disabled'

			
		# date set
		
		data_value 	= widget.data.monitored_value
		data_time 	= widget.data.date
		now = Date.parse new Date()


		# set alert if out of thresholds

		if data_value > threshold_alert
			
			service_alert = true

		else if data_value > threshold_warning
			
			service_warning = true
		
		
		# init graph data if needed
		
		if widget.graph_data == null
	
			widget.graph_data  = []

		
		# add current value to graph data

		widget.graph_data.push [data_time, data_value]


		# delete old value from temp array
	
		for data in widget.graph_data
			
			widget.graph_data.shift if data[0] < now - (time_scale*1000)
			
			
		# setup thresholds for graph
		
		thresholds_constraints = [
			{ threshold: threshold_alert
			, color: color_alert
			, evaluate : (y, threshold) =>
				return y > threshold }
			{ threshold: threshold_warning
			, color: color_ok
			, evaluate : (y, threshold) =>
				return y > threshold }
		]


		# draw graph

		$.plot $('#'+ name + ' .plot-chart')
		,	[ 
			data: widget.graph_data 
			color: color_ok
			shadowSize: 0
			constraints: thresholds_constraints 
		]
		,series:  
			lines:
				lineWidth: 1
				show: true
				fill: true
				fillColor: fill_color 
			points:
				show: false
		,grid: 
			hoverable: true
			clickable: true
			color: grid_color
		,yaxis: 
			min: 0, 
			max: 100
		,xaxis: 
			min: now-(time_scale*1000)
			max: now

		
		# on plot hover
		
		$('#'+ name + ' .plot-chart').bind plothover: (event, pos, item) =>
			#alert 'plothover'


		# return alert code
		
		if service_alert
			return 'alert'
		else if service_warning
			return 'warning'			
		else
			return 'ok'

$ ->
	
	dashboard = new Dashboard '#widgets', $widgets 

	# each time clock 'ticks'
	
	$("#clock").bind tick: ->
		
		dashboard.refresh()
	