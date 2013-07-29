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
	data							: {}
	_hidden						: false
	_edit_mode				: false
	_add_widget_mode 	: false
	_new_module 			: ''
	_new_command 			: '' 
	
	# where the probe will be added
	container 	: '.probes'
		
	constructor: (container, json_data) ->
		
		this.data = json_data
		this.init()
		Probe._probes.push this
		this._new_module = ''
		this._new_command = ''

	init: ->
		
		content = $('#probe-template').tmpl {'probe':this.data}
		$(this.container).append content

		this.edit_mode 				= false
		this.add_widget_mode 	= false	

		this.jquery_init()
		
	refresh: ->
		
		content = $('#probe-template').tmpl {'probe':this.data}
		$('#probe-' + this.data['id']).replaceWith content
		this.jquery_init()
	
	save: ->
		
		_this = this
		this.data.title = $(this.doc_path('.probe-title')).text()
		this.data.url 	= $(this.doc_path('.probe-url')).text()
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
		
	# return probe path for jQuery selectors
	# path parameter : helper to select class from the current probe
	doc_path: (path) ->

		path = '' if !path
		return '#probe-' + this.data.id + ' ' + path
		
	fetch_modules: ->
		
		_this = this

		# add dropdown buttons
		content = $('#add-widget-template').tmpl {'probe_id':_this.data.id}
		content.insertAfter($(this.doc_path(".probe-title-bar")));

		_this.new_module = ''

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
					_this.new_module = uri

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
				$(_this.doc_path() + ' .probe-command').click ->
					command = jQuery.parseJSON($(this).attr('data-command'))
					_this.new_command = command
					
					#_this.add_module()
	
	@property 'new_module',
	
		get: -> this._new_module
		set: (module) ->
			
			this._new_module = module
			if module == ''
				$(this.doc_path('.command-dropdown')).addClass('disabled')				
				$(this.doc_path('.add-widget-button')).addClass('disabled')				
			else
				this.fetch_commands(module)
				$(this.doc_path('.module-dropdown')).html("module: <b>#{module}</b><span class=\"dropdown-caret\"> </span>")
				$(this.doc_path('.command-dropdown')).removeClass('disabled')				
				$(this.doc_path('.command-dropdown')).html("<b>commands</b> <span class=\"dropdown-caret\"> </span>")
				$(this.doc_path('.add-widget-button')).addClass('disabled')
			
	@property 'new_command',
	
		get: -> this._new_command
		set: (command) ->
			
			_this = this
			this._new_command = command
			$(this.doc_path('.command-dropdown')).html("command: <b>#{command.title}</b><span class=\"dropdown-caret\"> </span>")
			$(this.doc_path('.add-widget-button')).removeClass('disabled')
			$(this.doc_path('.add-widget-button')).unbind()
			$(this.doc_path('.add-widget-button')).click (event) ->

				event.preventDefault()
				widget = command
				widget.module = _this.new_module
				widget.probe_id = _this.data.id
				widget.id = Widget.find_unused_id()
				
				new_widget = new Widget widget
				new_widget.create() 	
			
			
	#add_widget: (module, command)
	@property 'edit_mode',
	
		get: -> this._edit_mode
		set: (state) ->
			
			if state
				this._edit_mode = true
				$(this.doc_path()).addClass 'editing'
				$(this.doc_path('.probe-add-widget')).hide()
				$(this.doc_path('.probe-edit')).hide()
				$(this.doc_path('.probe-ok')).show()
				$(this.doc_path('.probe-cancel')).show()
				$(this.doc_path('.probe-url')).attr 'contentEditable', 'true'
				$(this.doc_path('.probe-title')).attr 'contentEditable', 'true'
			else
				this._edit_mode = false
				$(this.doc_path()).removeClass 'editing'
				$(this.doc_path('.probe-add-widget')).show()
				$(this.doc_path('.probe-edit')).show()
				$(this.doc_path('.probe-ok')).hide()
				$(this.doc_path('.probe-cancel')).hide()
				$(this.doc_path('.probe-url')).attr 'contentEditable', 'false'
				$(this.doc_path('.probe-title')).attr 'contentEditable', 'false'

	@property 'add_widget_mode',
	
		get: -> this._add_widget_mode
		set: (state) ->		
			
			if state		
				this.fetch_modules()
				$(this.doc_path('.probe-add-widget')).hide()
				$(this.doc_path('.probe-edit')).hide()
				$(this.doc_path('.probe-ok')).show()
				$(this.doc_path('.probe-cancel')).hide()
				this._add_widget_mode = true
			else
				$(this.doc_path('.probe-add-widget')).show()
				$(this.doc_path('.probe-edit')).show()
				$(this.doc_path('.probe-ok')).hide()
				$(this.doc_path('.probe-cancel')).hide()
				$(this.doc_path('.add-widget-form')).remove()
				this._add_widget_mode = false
		
	@property 'hidden',
	
		get: -> this._hidden 
		set: (state) -> 
			
			if state
				$(this.doc_path()).addClass('hidden')				
				$(this.doc_path('.widgets')).hide()
				this._hidden = true
				#this.refresh()
			else
				$(this.doc_path()).removeClass('hidden')	
				$(this.doc_path('.widgets')).show()
				this._hidden = false
				#this.refresh()
			
	jquery_init: ->

		_this = this
		$(this.doc_path('.probe-edit')).click (event) ->
			_this.edit_mode = true
			event.preventDefault()
			
		$(this.doc_path('.probe-cancel')).click (event) ->
			event.preventDefault()
			if _this.edit_mode
				_this.refresh()
				_this.edit_mode = false
			else if _this.add_widget_mode
				_this.add_widget_mode = false	
			
		$(this.doc_path('.probe-ok')).click (event) ->
			event.preventDefault()
			if _this.edit_mode
				_this.save()
				_this.edit_mode = false
			else if _this.add_widget_mode
				_this.add_widget_mode = false
			
		$(this.doc_path('.probe-add-widget')).click (event) ->
			_this.add_widget_mode = true
			event.preventDefault()	
			
		$(this.doc_path('.visibility-caret')).click (event) ->
			_this.hidden = !_this.hidden 
			
		$(this.doc_path('.widgets')).sortable({

			stop: (event, ui) =>
				widget_id_array = $(this.doc_path('.widgets')).sortable('toArray')

				$.getJSON("/widgets/sort", { widget_id_array : widget_id_array  })

					.fail (jqXHR, textStatus, errorThrown) =>
						jQuery.noticeAdd({
							title: 'Save error',
							text: 'Can\'t save widgets order',
							type: 'error',
							stay: false
						})
					.done( (json) =>
						jQuery.noticeAdd({
							title: 'Probe saved',
							text: 'Widgets order saved',
							type: 'ok',
							stay: false
						})
						console.log "getJSON /widgets/sort ok", json
					)
		})
		
	# class variables & methods
	
	@all: ->
		
		return Probe._probes
		
	@find_by_id: (id) ->
		
		for probe in Probe._probes
			if probe.data and parseInt(probe.data.id) == parseInt(id)
				return probe

	@count: ->
		
		Probe._probes.length
