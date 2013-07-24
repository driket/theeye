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
	
	doc_path: ->

		this_id = this.data.id
		return '#probe-' + this_id
		
	set_edit_mode: (state) ->

		if state == 'true'
			$(this.doc_path()).addClass 'editing'
			$(this.doc_path()).children('.probe-url').attr 'contentEditable', 'true'
			$(this.doc_path()).children('.probe-title').attr 'contentEditable', 'true'
		else
			$(this.doc_path()).removeClass 'editing'
			$(this.doc_path()).children('.probe-url').attr 'contentEditable', 'false'
			$(this.doc_path()).children('.probe-title').attr 'contentEditable', 'false'
		
	jquery_init: ->

		this_instance = this
		$(this.doc_path() + ' .probe-edit').click (event) ->
			this_instance.set_edit_mode 'true'
			event.preventDefault()
			
		$(this.doc_path() + ' .probe-cancel').click (event) ->
			this_instance.set_edit_mode 'false'
			Probe.find_by_id(this_instance.data.id).refresh()
			event.preventDefault()

	# class variables & methods
	
	@all: ->
		
		return Probe._probes
		
	@find_by_id: (id) ->
		for probe in Probe._probes
			if probe.data and probe.data.id == id
				return probe

	@count: ->
		
		Probe._probes.length
