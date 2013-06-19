class Clock

	constructor: (@element) ->
		
	# sleep for xxxx milliseconds

	sleep: (milliseconds) ->
		start = new Date.getTime
		for i in [0..1e7] by 1
			if (new Date().getTime() - start) > milliseconds
				break;


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
			# todo -> trigger 'refresh widget' event
		, 1000
		$('#time-controls' + ' .pause').removeClass 'disabled'
		$('#time-controls' + ' .play' ).addClass 		'disabled'
		
	
$ ->

	# create and start clock

	clock = new Clock '#clock'
	clock.resume()

	# if buttons are clicked 

	$('#time-controls' + ' .pause').on click: ->
		clock.pause()
		
	$('#time-controls' + ' .play').on click: ->
		clock.resume()
		
		