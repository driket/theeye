# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class @Probe
	
	constructor: (@element, @probes) ->
		
		this.refresh_all()
		this.add_js_handle()

	refresh_all: ->
		for name, probe of @probes			
				console.log "probe " + probe + ":", probe 
				template_variables =
					'name': name
					'probe': probe
		
				content = $('#probe-template').tmpl template_variables
				$(@element).append content

	add_js_handle: (probe) ->
		$('.probe-edit').click (event) ->
			probe_element = $(this).parent().parent()
			$(probe_element).addClass 'editing'
			$(probe_element).children('.probe-url').attr 'contentEditable', 'true'
			$(probe_element).children('.probe-title').attr 'contentEditable', 'true'
			event.preventDefault()
			
		$('.probe-cancel').click (event) ->
			probe_element = $(this).parent().parent()
			$(probe_element).removeClass 'editing'
			$(probe_element).children('.probe-url').attr 'contentEditable', 'false'
			$(probe_element).children('.probe-title').attr 'contentEditable', 'false'
			event.preventDefault()

	 
