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
	
    #display activity indicator while loading
		
		$(widget_name).spin 'large', '#888'
	
		#
		# fetch data remotely (async)
		#
	
		# simulate monitored value
		
		widget.data.monitored_value = parseInt Math.random() * 100;
	
		content = $(template).tmpl template_variables;
		$(widget_name + ' .face-simple-view').html content;
	
		# hide activity indicator (loaded)
		
		$(widget_name).spin false
	
		status = test_graph_template_did_appear name, widget		

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

$ ->

	dashboard = new Dashboard '#widgets', $widgets 

	# each time clock 'ticks'
	
	$("#clock").bind tick: ->
		
		dashboard.refresh()
	