# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class Dashboard
	
	constructor: (@element, @widgets) ->

		# init & first display 
		graph = null
		$(@element).sortable()
		this.refresh()


	set_status_for_widget: (name, widget, status) =>
		
		widget_name = '#' + name
		
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
			
			content = $('#widget-empty-template').tmpl template_variables
			$('#widgets').append content
	
	
		# if refresh delay is up
	
		elapased_time = new Date().getTime() - widget.data.date
		
		if  elapased_time > widget.refresh_delay

	    #display activity indicator while loading
			status = 'ok'
			$(widget_name).spin 'small', '#eee'

			#
			# fetch data remotely (async)
			#
			
			$.getJSON(widget.data_source)
			
			.fail () =>
				content = '<h3>Error</h3>'
				$(widget_name + ' .widget-content').html content;
				$(widget_name).spin false
				status = 'alert'
				this.set_status_for_widget(name, widget, status)
			.done (json) => 
				widget.data.value 	= json.value
				widget.data.date  	= Date.parse(json.date)
				widget.data.details = json.details
				$(widget_name).spin false
				
				content = $(template).tmpl template_variables;
				$(widget_name + ' .face-simple-view').html content;
				
				status = this.render_graph name, widget
				this.set_status_for_widget(name, widget, status)

		

	# refresh all dashboard's widgets
	
	refresh: => 
	
		# for each widget
		
		for name, widget of @widgets

			this.refresh_widget name, widget
	
	alertLevelForValue: (value, widget) ->
		
		return 'ok' if !widget.thresholds 
		
		for threshold in widget.thresholds

			if threshold.operator == '&gt;='
				if value >= threshold.value			
					return threshold.alert
			else if threshold.operator == '&gt;'
				if value > threshold.value				
					return threshold.alert
			else if threshold.operator == '&lt;'
				if value < threshold.value				
					return threshold.alert
			else if threshold.operator == '&lt;='
				if value <= threshold.value				
					return threshold.alert
			else
				console.log '(alertLevelForValue) invalid comparison operator: ' + threshold.operator
				
	
	showTooltip: (x, y, date, value, widget) =>

		h 	= ("0" + date.getHours()).slice -2
		m 	= ("0" + date.getMinutes()).slice -2
		s 	= ("0" + date.getSeconds()).slice -2
		alert_level = this.alertLevelForValue value, widget

		data = 
			'hours'				: h
			'minutes'			: m
			'seconds'			: s
			'value'				: value
			'unit'				: widget.unit
			'alert_level'	: alert_level
			'details'			: widget.details
					
		content = $('#widget-details').tmpl data
		$(content)
		.css
	    display: 'none'
	    position: 'absolute'
	    top: y + 5
	    left: x + 5
		.appendTo(@element)
		.fadeIn(200)
				
			
	# draw graph for a given widget

	render_graph: (name, widget) ->

		service_warning			= false
		service_alert				= false

		time_scale 					= 60 #(in second)

		color_ok 						= theme_color_for_class 'service-status-ok'
		color_warning 			= theme_color_for_class 'service-status-warning'
		color_alert					= theme_color_for_class 'service-status-alert'
		fill_color					= theme_color_for_class 'very-light-color'
		grid_color					= theme_color_for_class 'service-status-disabled'

			
		# date set
		
		data_value 	= widget.data.value
		data_time 	= widget.data.date
		now = Date.parse new Date()


		# set alert if out of thresholds

		alert_level = this.alertLevelForValue data_value, widget
		
		if alert_level == 'alert'
			
			service_alert = true

		else if alert_level == 'warning'
			
			service_warning = true
		
		
		# add current value to graph data

		widget.graph_data.push [data_time, data_value]
		widget.details_data.push [data_time, widget.data.value]


		# delete old value from temp array
		for data in widget.graph_data
			
			if data[0] < now - (time_scale*1000)
				widget.graph_data.shift 
				widget.details_data.shift
				break
				
		# setup thresholds for graph
		
		thresholds_constraints = []

		for a_threshold in widget.thresholds 
			if a_threshold.operator == '&gt;='
				color = theme_color_for_class 'service-status-' + a_threshold.alert
				constraint = { threshold: a_threshold.value
				, color: color
				, evaluate : (y, threshold) =>
					return y >= threshold }
			else if a_threshold.operator == '&gt;'
				color = theme_color_for_class 'service-status-' + a_threshold.alert
				constraint = { threshold: a_threshold.value
				, color: color
				, evaluate: (y, threshold) =>
					return y > threshold }
			else if a_threshold.operator == '&lt;'
				color = theme_color_for_class 'service-status-' + a_threshold.alert
				constraint = { threshold: a_threshold.value
				, color: color
				, evaluate: (y, threshold) =>
					return y < threshold }
			else if a_threshold.operator == '&lt;='
				color = theme_color_for_class 'service-status-' + a_threshold.alert
				constraint = { threshold: a_threshold.value
				, color: color
				, evaluate: (y, threshold) =>
					return y <= threshold }
					
			thresholds_constraints.push constraint

		# draw graph

		graph = $.plot $('#'+ name + ' .plot-chart')
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
			min: widget.min, 
			max: widget.max
		,xaxis: 
			min: now-(time_scale*1000)
			max: now
		
		# on plot hover
		previousPoint = null
		$('#'+ name + ' .plot-chart').bind plothover: (event, pos, item) =>
			if item
				if previousoint != item.dataIndex
					previousoint = item.dataIndex
					$(@element + ' .tooltip').remove()
					date = new Date(item.datapoint[0])
					value = item.datapoint[1].toFixed(0)

					target = $(event.currentTarget).closest(".widget")
					bound_widget_id = target.attr 'id'
					bound_widget = @widgets[bound_widget_id]

					this.showTooltip item.pageX, item.pageY, date, value, bound_widget
			else
				$(@element + ' .tooltip').remove()
				previousPoint = null

		$('#'+ name + ' .plot-chart').bind plotclick: (event, pos, item) =>
			if item
				graph.highlight item.series, item.datapoint

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
	