#= require tools/jquery.notifications
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
	
	save: ->
		
		_this = this
		this.data.title = $(this.doc_path()).children('.probe-title').text()
		this.data.url 	= $(this.doc_path()).children('.probe-url').text()
		$.ajax '/probes/' + this.data.id,
			type: 'PUT',
			data: {'probe':this.data},
			error: (jqXHR, textStatus, errorThrown) ->
				console.log "AJAX Error: #{textStatus} #{errorThrown}"
				jQuery.noticeAdd({
					title: 'Error',
					text: 'Error saving probe.',
					type: 'error',
					stay: false
				});
			success: (jqXHR, textStatus, errorThrown) ->
				console.log "Successful AXAX call: #{textStatus}"
				jQuery.noticeAdd({
					title: 'Probe saved',
					text: 'Probe settings saved.',
					type: 'ok',
					stay: false
				});
				_this.refresh()
		
		
	doc_path: ->

		this_id = this.data.id
		return '#probe-' + this_id
		
	fetch_modules: ->
		_this = this

		# add dropdown buttons
		content = $('#add-widget-template').tmpl {'probe_id':_this.data.id}
		$(this.doc_path()).append content

		$.getJSON(this.data.url + "/index")
			.fail (jqXHR, textStatus, errorThrown) =>
				console.log "AJAX Error: #{textStatus} #{errorThrown}"
				jQuery.noticeAdd({
					title: 'Probe error',
					text: 'Can\'t connect to this probe',
					type: 'error',
					stay: false
				});
			.done (modules_json) => 
				content = $('#list-probe-modules').tmpl {
					'modules':modules_json
					'probe_id':_this.data.id
				}
				$(_this.doc_path()).append content
				$(_this.doc_path() + ' .probe-module').click ->
					uri = $(this).attr('data-uri')
					_this.fetch_commands(uri)
					$(_this.doc_path() + ' .module-dropdown').text("module: #{uri}")

	fetch_commands: (module) ->
		_this = this
		console.log "url:", this.data.url + "/" + module + "/index"
		$.getJSON(this.data.url + "/" + module + "/index")
			.fail (jqXHR, textStatus, errorThrown) =>
				console.log "AJAX Error: #{textStatus} #{errorThrown}"
				jQuery.noticeAdd({
					title: 'Probe error',
					text: 'Can\'t connect to this probe',
					type: 'error',
					stay: false
				});
			.done (commands_json) => 
				console.log commands_json
				content = $('#list-probe-commands').tmpl {
					'module':module
					'commands':commands_json
					'probe_id':_this.data.id
				}
				dropdown_tmpl = "#probe-#{_this.data.id}-list-commands"
				if $(dropdown_tmpl).length > 0
					$("#probe-#{_this.data.id}-list-commands").replaceWith content
				else
					$(this.doc_path()).append content
				$('.probe-command').click ->
					console.log $(this)
					#_this.add_module()
	
	#add_widget: (module, command)
	@property 'edit_mode',
	
		get: -> this._edit_mode
		set: (state) ->
			if state
				this._edit_mode = true
				$(this.doc_path()).addClass 'editing'
				$(this.doc_path()).children('.probe-url').attr 'contentEditable', 'true'
				$(this.doc_path()).children('.probe-title').attr 'contentEditable', 'true'
				this.fetch_modules()
			else
				this._edit_mode = false
				$(this.doc_path()).removeClass 'editing'
				$(this.doc_path()).children('.probe-url').attr 'contentEditable', 'false'
				$(this.doc_path()).children('.probe-title').attr 'contentEditable', 'false'
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

		_this = this
		$(this.doc_path() + ' .probe-edit').click (event) ->
			_this.edit_mode = true
			event.preventDefault()
			
		$(this.doc_path() + ' .probe-cancel').click (event) ->
			_this.edit_mode = false
			event.preventDefault()
			
		$(this.doc_path() + ' .probe-ok').click (event) ->
			_this.save()
			_this.edit_mode = false
			event.preventDefault()
		
			
		$(this.doc_path() + ' .visibility-caret').click (event) ->
			_this.hidden = !_this.hidden 

	# class variables & methods
	
	@all: ->
		
		return Probe._probes
		
	@find_by_id: (id) ->
		for probe in Probe._probes
			if probe.data and parseInt(probe.data.id) == parseInt(id)
				return probe

	@count: ->
		
		Probe._probes.length
