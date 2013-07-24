# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class @Probe
	
	# probes class variable
	# store all created probes with this class
	@_probes 		: []
	
	# used to store probe data (json)
	data				: {}
	
	# where the probe will be added
	container 	: '.probes'
		
	constructor: (container, json_data) ->
		
		this.data = json_data
		this.init()
		Probe._probes.push this

	init: ->
		
		content = $('#probe-template').tmpl {'probe':this.data}
		$(this.container).append content
		this.jquery_init()
		
	refresh: ->
		
		content = $('#probe-template').tmpl {'probe':this.data}
		$('#probe-' + this.data['id']).replaceWith content
		this.jquery_init()
		
	@find_by_id: (id) ->
		
		for probe in Probe._probes
			if probe.data and probe.data['id'].to_i == id
				return probe

	@count: ->
		Probe._probes.length
		
	jquery_init: ->

		this_id = this.data['id']
		console.log 'this_id:', this_id
		console.log 'element:', 'probe-' + this_id + ' .probe-edit'
		$('#probe-' + this_id + ' .probe-edit').click (event) ->
			probe_element = $(this).parent().parent()
			$(probe_element).addClass 'editing'
			$(probe_element).children('.probe-url').attr 'contentEditable', 'true'
			$(probe_element).children('.probe-title').attr 'contentEditable', 'true'
			event.preventDefault()
			
		$('#probe-' + this_id + ' .probe-cancel').click (event) ->
			probe_element = $(this).parent().parent()
			$(probe_element).removeClass 'editing'
			$(probe_element).children('.probe-url').attr 'contentEditable', 'false'
			$(probe_element).children('.probe-title').attr 'contentEditable', 'false'
			id = $(probe_element).attr('id').replace('probe-','').to_i
			Probe.find_by_id(id).refresh()
			event.preventDefault()

	 
