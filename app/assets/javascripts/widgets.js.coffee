# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class @Widget
	
	# store all created widgets
	@_widgets 		: []
	
	# used to store widget data (json)
	data					: {}

	# template to render widget
	template			: ''
	
	# time range for samples in seconds
	time_range		: 60

	# live mode fetch data from probes
	# non-live mode fetch data from db history
	live_mode			: true
	
	# used to store graph data
	record				: {}
	graph_data		: []
	details_data	: []
	graph					: ''
	processing		: false
	
	constructor: (json_data, template, time_range, live_mode) ->

		# init & first display 
		this.graph 				= null
		this.processing		= false
		this.graph_data 	= []
		this.details_data	= []
		this.record 			= {
			'value' 			: 0,
			'date'				: 0,
			'details'			: '',
		}
		this.data 				= json_data
		this.template 		= template || json_data.template
		this.time_range 	= time_range || 60
		
		this.live_mode = live_mode if live_mode?
		
		
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
	
	# return widget path for jQuery selectors
	# path parameter : helper to select class from the current probe
	doc_path: (path) ->

		path = '' if !path
		return '#widget-' + this.data.id + ' ' + path
		
	init_jquery: =>
		
		_this = this
		
		$(this.doc_path('.widget-delete')).unbind()
		$(this.doc_path('.widget-delete')).click (event) ->
			event.preventDefault()
			_this.delete()
							
	refresh: =>
		
		# setup jQuery selector
		
		this.init_jquery()

		# if widget doesn't exist, create and add an empty one
		
		if $(this.doc_path('')).length == 0
			
			this.record 			= {
				'value' 			: '----',
				'date'				: 0,
				'details'			: '',
			}
			content = $("#"+this.template).tmpl {'widget':this.data, 'record':this.record};
			container		= '#probe-' + this.data.probe_id + '-widgets'
			$(container).append content
			this.set_status_for_widget('disabled')
			$(this.doc_path('')).spin 'small', theme_color_for_class 'service-status-disabled'		
	
		if this.live_mode
			
			elapased_time = new Date().getTime() - this.record.date
	
			# if refresh delay is up and widget is ready to process
			if elapased_time > this.data.refresh_delay and !this.processing

				this.processing = true
		    #display activity indicator while loading
				status = 'ok'
				$(this.doc_path('')).spin 'small', theme_color_for_class 'service-status-disabled'
			
				this.fetch_live_data()
				
		else
			
			this.fetch_db_data()
	#
	# fetch live data from remote probes (async)
	#
	
	fetch_live_data: ->	

		probe = Probe.find_by_id(this.data.probe_id)
		args = "?#{this.data.args.replace(/&amp;/g, '&')}" || ''
		
		$.getJSON("#{probe.data.url}/#{this.data.uri}#{args}")
		
		.fail () =>
			this.record 			= {
				'value' 			: '----',
				'date'				: 0,
				'details'			: '',
			}
			
			status = this.render_graph(false)
			
		.done (json, textStatus, jqXHR) => 
			this.record 			= {
				'value' 			: json.value,
				'date'				: Date.parse(json.date),
				'details'			: json.details,
			}
			
			# add current value to graph data
	
			this.graph_data.push [this.record.date , this.record.value]
			this.details_data.push [this.record.date, this.record.details]

			# delete old values from temp array
			for data in this.graph_data
		
				if data[0] < Date.parse new Date() - (this.time_range*1000)
					this.graph_data.shift
					this.details_data.shift
					break
							
			status = this.render_graph(true)
			
	fetch_db_data: ->	
		
		delete this.graph_data
		delete this.details_data
		this.graph_data 	= []
		this.details_data = []
		this.record 			= {
			'value' 			: '----',
			'date'				: 0,
			'details'			: '',
		}

		days = $(".probes-report").attr('data-days')
		this.time_range = days * 3600 * 24
		$.getJSON("/widgets/#{this.data.id}/process_samples?days=#{days}")
		.fail () =>
			status = this.render_graph(false)
			
		.done (json, textStatus, jqXHR) => 
			
			total_value = 0
			valid_sample_count = 0
			for sample in json.samples
				if sample.value != -1
					total_value += sample.value
					valid_sample_count++
				this.graph_data.push [Date.parse(sample.date) , sample.value]
				this.details_data.push [Date.parse(sample.date), sample.details]
			
			average_value = Math.round(total_value / valid_sample_count * 100) / 100
						
			this.record 			= {
				'value' 			: average_value
				'date'				: Date.parse new Date(),
				'details'			: {},
			}
					
			status = this.render_graph(true)

	alertLevelForValue: (value) ->
		
		return 'ok' if !this.data.thresholds_attributes 
		
		for threshold in this.data.thresholds_attributes

			if threshold.operator == '>='
				if value >= threshold.value			
					return threshold.alert
			else if threshold.operator == '>'
				if value > threshold.value				
					return threshold.alert
			else if threshold.operator == '<'
				if value < threshold.value				
					return threshold.alert
			else if threshold.operator == '<='
				if value <= threshold.value				
					return threshold.alert
			else if threshold.operator == '='
				if value == threshold.value				
					return threshold.alert
			else if threshold.operator == '=='
				if value == threshold.value				
					return threshold.alert
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

	render_graph: (is_reachable)->


		service_warning			= false
		service_alert				= false
			
		color_ok 						= theme_color_for_class 'service-status-ok'
		color_warning 			= theme_color_for_class 'service-status-warning'
		color_alert					= theme_color_for_class 'service-status-alert'
		fill_color					= theme_color_for_class 'very-light-color'
		grid_color					= theme_color_for_class 'service-status-disabled'

			
		# date set
		if is_reachable
			data_value 	= this.record.value
		else
			data_value 	= '---' 
		data_time 		= this.record.date
		data_details 	= this.record.details
		now 					= Date.parse new Date()

		
		this.processing	= false
		$(this.doc_path('')).spin false
		
		content = $("#"+this.template).tmpl {'widget':this.data, 'record':this.record};
		$(this.doc_path('')).replaceWith content;
		
		# set alert if out of thresholds

		if is_reachable
			alert_level = this.alertLevelForValue data_value
		else
			alert_level = 'alert'
			
		if alert_level == 'alert'
			
			service_alert = true

		else if alert_level == 'warning'
			
			service_warning = true
				
		# setup thresholds for graph
		
		thresholds_constraints = []

		if this.data.thresholds_attributes
			for a_threshold in this.data.thresholds_attributes 
				if a_threshold.operator == '>='
					color = theme_color_for_class 'service-status-' + a_threshold.alert
					constraint = { threshold: a_threshold.value
					, color: color
					, evaluate : (y, threshold) =>
						return y >= threshold }
				else if a_threshold.operator == '>'
					color = theme_color_for_class 'service-status-' + a_threshold.alert
					constraint = { threshold: a_threshold.value
					, color: color
					, evaluate: (y, threshold) =>
						return y > threshold }
				else if a_threshold.operator == '<'
					color = theme_color_for_class 'service-status-' + a_threshold.alert
					constraint = { threshold: a_threshold.value
					, color: color
					, evaluate: (y, threshold) =>
						return y < threshold }
				else if a_threshold.operator == '<='
					color = theme_color_for_class 'service-status-' + a_threshold.alert
					constraint = { threshold: a_threshold.value
					, color: color
					, evaluate: (y, threshold) =>
						return y <= threshold }
				else if a_threshold.operator == '=='
					color = theme_color_for_class 'service-status-' + a_threshold.alert
					constraint = { threshold: a_threshold.value
					, color: color
					, evaluate: (y, threshold) =>
						return y == threshold }
				else if a_threshold.operator == '='
					color = theme_color_for_class 'service-status-' + a_threshold.alert
					constraint = { threshold: a_threshold.value
					, color: color
					, evaluate: (y, threshold) =>
						return y == threshold }
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
				min: now-(this.time_range*1000)
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
			this.set_status_for_widget('alert')
			return 'alert'
		else if service_warning
			this.set_status_for_widget('warning')
			return 'warning'			
		else
			this.set_status_for_widget('ok')
			return 'ok'


	create: ->
		
		_this = this
		console.log 'widget:', this.data
		
		$.ajax '/widgets.json',
			type: 'POST',
			data: {'widget':this.data},
			error: (jqXHR, textStatus, errorThrown) ->
				console.log "AJAX Error: #{textStatus} #{errorThrown}"
				jQuery.noticeAdd({
					title: 'Error',
					text: 'Error saving widget.',
					type: 'error',
					stay: false
				});
			success: (jqXHR, textStatus, errorThrown) ->
				console.log "Successful AXAX call: #{textStatus}"
				jQuery.noticeAdd({
					title: 'Widget created',
					text: 'Widget successfully created.',
					type: 'ok',
					stay: false
				});
	
	save: ->
		
		_this = this
		console.log 'widget:', this.data
		
		# TODO :
		# - [OK] rename data.thresholds -> data.thresholds_attributes in widget.js.coffee
		# - fix column "refresh_delay" / "interval"
		# - [OK] change column "alert" -> "type" in thresholds
		$.ajax "/widgets/#{_this.data.id}.json",
			type: 'PUT',
			data: {'widget':this.data},
			error: (jqXHR, textStatus, errorThrown) ->
				console.log "AJAX Error: #{textStatus} #{errorThrown}"
				jQuery.noticeAdd({
					title: 'Error',
					text: 'Error saving widget.',
					type: 'error',
					stay: false
				});
			success: (jqXHR, textStatus, errorThrown) ->
				console.log "Successful AXAX call: #{textStatus}"
				jQuery.noticeAdd({
					title: 'Widget created',
					text: 'Widget successfully created.',
					type: 'ok',
					stay: false
				});
	
	delete: ->
		
		# remove widget html code
		$(this.doc_path()).remove()
		
		# remove widget from Widgets
		this_array = Widget._widgets.indexOf(this)
		Widget._widgets.splice(this_array, 1)
		
		$.ajax "/widgets/#{this.data.id}.json",
			type: 'DELETE',
			data: {'widget':{'id':this.data.id}},
			error: (jqXHR, textStatus, errorThrown) ->
				console.log "AJAX Error: #{textStatus} #{errorThrown}"
				jQuery.noticeAdd({
					title: 'Error',
					text: 'Error deleting widget.',
					type: 'error',
					stay: false
				});
			success: (jqXHR, textStatus, errorThrown) ->
				console.log "Successful AXAX call: #{textStatus}"
				jQuery.noticeAdd({
					title: 'Widget deleted',
					text: 'Widget successfully deleted.',
					type: 'ok',
					stay: false
				});
				
  # class method
		
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
		
	@sort: (widget_id_array) ->
		
		$.ajax '/widgets/sort.json',
			type: 'POST',
			data: { widget_id_array : widget_id_array },
			error: (jqXHR, textStatus, errorThrown) ->
				console.log "AJAX Error: #{textStatus} #{errorThrown}"
				jQuery.noticeAdd({
					title: 'Save error',
					text: 'Can\'t save widgets order',
					type: 'error',
					stay: false
				})
			success: (jqXHR, textStatus, errorThrown) ->
				console.log "Successful AXAX call: #{textStatus}"
				jQuery.noticeAdd({
					title: 'Probe saved',
					text: 'Widgets order saved',
					type: 'ok',
					stay: false
				})

		
		