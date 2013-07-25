# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# getter / setter methods
Function::property = (prop, desc) ->
  Object.defineProperty @prototype, prop, desc
	
class @Probe
	
	# probes class variable
	# store all created probes with this class
	@_probes 		: []
	
	# used to store probe data (json)
	data				: {}
	_hidden			: false
	_edit_mode	: false
	
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
		
	@property 'edit_mode',
	
		get: -> this._edit_mode
		set: (state) ->
			if state
				$(this.doc_path()).addClass 'editing'
				$(this.doc_path()).children('.probe-url').attr 'contentEditable', 'true'
				$(this.doc_path()).children('.probe-title').attr 'contentEditable', 'true'
				this._edit_mode = true
			else
				$(this.doc_path()).removeClass 'editing'
				$(this.doc_path()).children('.probe-url').attr 'contentEditable', 'false'
				$(this.doc_path()).children('.probe-title').attr 'contentEditable', 'false'
				this._edit_mode = false
				this.refresh()
				
		
	@property 'hidden',
	
		get: -> this._hidden 
		set: (state) -> 
			if state
				this.data.hidden_class = 'hidden'
				this._hidden = true
				this.refresh()
			else
				this.data.hidden_class = ''
				this._hidden = false
				this.refresh()
			
	jquery_init: ->

		this_instance = this
		$(this.doc_path() + ' .probe-edit').click (event) ->
			this_instance.edit_mode = true
			event.preventDefault()
			
		$(this.doc_path() + ' .probe-cancel').click (event) ->
			this_instance.edit_mode = false
			event.preventDefault()
			
		$(this.doc_path() + ' .visibility-caret').click (event) ->
			this_instance.hidden = !this_instance.hidden 

	# class variables & methods
	
	@all: ->
		
		return Probe._probes
		
	@find_by_id: (id) ->
		for probe in Probe._probes
			if probe.data and parseInt(probe.data.id) == parseInt(id)
				return probe

	@count: ->
		
		Probe._probes.length
