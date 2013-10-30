class @Clock

	@interval : 0
	
	constructor: (@element, interval) ->
		
		# init by lauching timer and first display 
		
		@interval = interval * 1000 || 1000
		this.display()
		this.resume()
		this.jquery_handle()

	# display clock with current time at element

	display: =>
		
		date = new Date
		h 	= ("0" + date.getHours()).slice -2
		m 	= ("0" + date.getMinutes()).slice -2
		s 	= ("0" + date.getSeconds()).slice -2

		$(@element + ' .hours').html h
		$(@element + ' .minutes').html m
		$(@element + ' .seconds').html s
	
	
	# pause clock

	pause: ->
		
		clearInterval @clock_interval
		$('#time-controls' + ' .play' ).removeClass 'disabled'
		$('#time-controls' + ' .pause').addClass 		'disabled'


	# start/resume clock
	
	resume: ->
		
		@clock_interval = setInterval =>
			this.display()
			$(@element).trigger('tick');
		, @interval
		$('#time-controls' + ' .pause').removeClass 'disabled'
		$('#time-controls' + ' .play' ).addClass 		'disabled'

		
	jquery_handle: ->
		
		this_class = this
		# if buttons are clicked 
		$('#time-controls' + ' .pause').on click: ->
			this_class.pause()
		
		$('#time-controls' + ' .play').on click: ->
			this_class.resume()
		
