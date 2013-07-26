# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class @Widget
	
	# store all created widgets
	@_widgets 		: []
	
	# used to store widget data (json)
	data					: {}

	# used to store graph data
	record				: {}
	graph_data		: []
	details_data	: []
	graph					: ''
	processing		: false
	
	constructor: (json_data) ->

		# init & first display 
		this.graph 				= null
		this.processing	= false
		this.graph_data 	= []
		this.details_data	= []
		this.record 			= {
			'value' 			: 0,
			'date'				: 0,
			'details'			: '',
		}
		
		#$(@element).sortable({

		#	stop: (event, ui) =>
		#		widget_id_array = $(@element).sortable('toArray')

		#		$.getJSON("/widgets/sort", { widget_id_array : widget_id_array  })
		#		.done( (json) =>
		#			console.log "getJSON /widgets/sort ok", json
		#		)
				
		#})
		this.data = json_data
		Widget._widgets.push this
		this.refresh()


	set_status_for_widget: (status) =>
		
		widget_name = '#widget-' + this.data.id
		
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
	
	
	refresh: =>
				
		
		# setup jQuery selector
		
		widget_name = '#widget-' + this.data.id
		template 		= '#' + this.data.template
		container		= '#probe-' + this.data.probe_id + '-widgets'

		# if widget doesn't exist, create and add an empty one
		
		if $(widget_name).length == 0
			
			content = $('#widget-empty-template').tmpl {'widget':this.data, 'record':this.record}
			$(container).append content
	
		elapased_time = new Date().getTime() - this.record.date
	
		# if refresh delay is up and widget is ready to process
		if elapased_time > this.data.refresh_delay and !this.processing

			this.processing = true
	    #display activity indicator while loading
			status = 'ok'
			$(widget_name).spin 'small', theme_color_for_class 'service-status-disabled'

			#
			# fetch data remotely (async)
			#
			probe = Probe.find_by_id(this.data.probe_id)
			$.getJSON(probe.data.url + "/" + this.data.uri)
			.fail () =>
				content = '<h3>Error</h3>'
				$(widget_name + ' .widget-content').html content;
				$(widget_name).spin false
				status = 'alert'
				this.processing = false
				this.set_status_for_widget(status)
			.done (json) => 
				this.record.value 		= json.value
				this.record.date  		= Date.parse(json.date)
				this.record.details 	= json.details
				this.processing 			= false
				$(widget_name).spin false
				
				
				content = $(template).tmpl {'widget':this.data, 'record':this.record};
				$(widget_name + ' .face-simple-view').html content;
				
				status = this.render_graph()
				this.set_status_for_widget(status)
		

	alertLevelForValue: (value) ->
		
		return 'ok' if !this.data.thresholds 
		
		for threshold in this.data.thresholds

			if threshold.operator == '>='
				if value >= threshold.value			
					return threshold.type
			else if threshold.operator == '>'
				if value > threshold.value				
					return threshold.type
			else if threshold.operator == '<'
				if value < threshold.value				
					return threshold.type
			else if threshold.operator == '<='
				if value <= threshold.value				
					return threshold.type
			else
				console.log '(alertLevelForValue) invalid comparison operator: ' + threshold.operator
				
	
	showTooltip: (x, y, date, value, details) =>

		h 	= ("0" + date.getHours()).slice -2
		m 	= ("0" + date.getMinutes()).slice -2
		s 	= ("0" + date.getSeconds()).slice -2
		alert_level = this.alertLevelForValue value

		data = 
			'hours'				: h
			'minutes'			: m
			'seconds'			: s
			'value'				: value
			'unit'				: this.data.unit
			'alert_level'	: alert_level
			'details'			: details
					
		content = $('#widget-details').tmpl data
		target	=	$('#widget-'+this.data.id).parent()
		
		# append tooltip if doesn't exist already
		# of just update it with new position / content
		if $('.tooltip').length == 0
			$(content)
			.css
		    display: 'none'
		    position: 'absolute'
		    top: y + 5 
		    left: x + 5
			.appendTo(target)
			.fadeIn(200)
		else
			$('.tooltip').replaceWith	$(content).css {
				display: 'block', 
				position: 'absolute', 
				top: y + 5, 
				left: x + 5
			}
		 
		# if mouse cursor is on the second half of the screen width, 
		# display popup on the left of the mouse cursor
		mouseX = window.event.clientX
		if mouseX > $(window).width() / 2
			$(content).css('left', x - $(content).width() )
	
	
	getDetailsForWidgetAtDatetime: (date) =>
				
		for data in this.details_data
			if data[0] >= Date.parse date
				return data[1]
				
				
	# draw graph for a given widget

	render_graph: ->

		service_warning			= false
		service_alert				= false

		time_scale 					= 60 #(in second)

		color_ok 						= theme_color_for_class 'service-status-ok'
		color_warning 			= theme_color_for_class 'service-status-warning'
		color_alert					= theme_color_for_class 'service-status-alert'
		fill_color					= theme_color_for_class 'very-light-color'
		grid_color					= theme_color_for_class 'service-status-disabled'

			
		# date set
		data_value 		= this.record.value
		data_time 		= this.record.date
		data_details 	= this.record.details
		now 					= Date.parse new Date()


		# set alert if out of thresholds

		alert_level = this.alertLevelForValue data_value
		
		if alert_level == 'alert'
			
			service_alert = true

		else if alert_level == 'warning'
			
			service_warning = true
		
		# add current value to graph data
		
		this.graph_data.push [data_time, data_value]
		this.details_data.push [data_time, data_details]


		# delete old value from temp array
		for data in this.graph_data
			
			if data[0] < now - (time_scale*1000)
				this.graph_data.shift
				this.details_data.shift
				break
				
		# setup thresholds for graph
		
		thresholds_constraints = []

		if this.data.thresholds
			for a_threshold in this.data.thresholds 
				if a_threshold.operator == '>='
					color = theme_color_for_class 'service-status-' + a_threshold.type
					constraint = { threshold: a_threshold.value
					, color: color
					, evaluate : (y, threshold) =>
						return y >= threshold }
				else if a_threshold.operator == '>'
					color = theme_color_for_class 'service-status-' + a_threshold.type
					constraint = { threshold: a_threshold.value
					, color: color
					, evaluate: (y, threshold) =>
						return y > threshold }
				else if a_threshold.operator == '<'
					color = theme_color_for_class 'service-status-' + a_threshold.type
					constraint = { threshold: a_threshold.value
					, color: color
					, evaluate: (y, threshold) =>
						return y < threshold }
				else if a_threshold.operator == '<='
					color = theme_color_for_class 'service-status-' + a_threshold.type
					constraint = { threshold: a_threshold.value
					, color: color
					, evaluate: (y, threshold) =>
						return y <= threshold }
				else
					console.log '(alertLevelForValue) invalid comparison operator: ' + a_threshold.operator
				
					
			thresholds_constraints.push constraint

		# draw graph if not hidden
		if !Probe.find_by_id(this.data.probe_id).hidden
			this.graph = $.plot $('#widget-'+ this.data.id + ' .plot-chart')
			,	[ 
				data: this.graph_data 
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
				min: this.data.min, 
				max: this.data.max
			,xaxis: 
				min: now-(time_scale*1000)
				max: now
		
			# on plot hover
			previousPoint = null
			$('#widget-' + this.data.id + ' .plot-chart').bind plothover: (event, pos, item) =>
				if item
					if previousoint != item.dataIndex
						previousoint = item.dataIndex
						#$('.tooltip').remove()
						date = new Date(item.datapoint[0])
						value = item.datapoint[1]

						target = $(event.currentTarget).closest(".widget")
						bound_widget_id = target.attr('id').replace('widget-','')
						bound_widget = Widget.find_by_id(bound_widget_id)
						details = bound_widget.getDetailsForWidgetAtDatetime(date)
						bound_widget.showTooltip item.pageX, item.pageY, date, value, details
				else
					$('.tooltip').remove()
					previousPoint = null

			$('#widget-'+ this.data.id + ' .plot-chart').bind plotclick: (event, pos, item) =>
				if item
					this.graph.highlight item.series, item.datapoint

		# return alert code
		
		if service_alert
			return 'alert'
		else if service_warning
			return 'warning'			
		else
			return 'ok'

	@all: ->
		return @_widgets
		
	@find_by_id: (id) ->
		for widget in Widget._widgets
			if widget.data and parseInt(widget.data.id) == parseInt(id)
				return widget

	@count: ->
		Widget._widgets.length
	
	@refresh: ->
		for widget in Widget._widgets
			widget.refresh()
	
	@is_id_used: (id) ->
		for widget in Widget._widgets
			if parseInt(widget.data.id) == parseInt(id)
				return true
		return false
		
	@find_unused_id: ->
		id = 0
		id++ while Widget.is_id_used(id)
		return id
		
		