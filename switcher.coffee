window.ViewSwitcher = ( options ) ->

  # only called when container is bound to "this"
  defaultTransitions = 
    exit : ( exitingView, callback ) ->
      this.height( this.height() )
      exitingView.fadeOut 1000, ->
        callback()
    prepare : ( exitingView, enteringView, callback ) ->
      newHeight = enteringView.outerHeight() + parseInt(this.css("padding-top"), 10) + parseInt(this.css("padding-bottom"), 10)
      this.animate
        height : newHeight
      , 1000, ->
        callback()
    enter : ( enteringView, callback ) ->
      enteringView.fadeIn 1000, ->
        callback()

  rawViews = options.views
  container = $( options.container )
  attrIdentifier = options.attrIdentifier or "id"
  initialView = options.initialView
  useHistory = options.useHistory
  onFinish = options.onFinish
  timedOffsets = options.timedOffsets 

  exit = options.exit or defaultTransitions.exit
  prepare = options.prepare or defaultTransitions.prepare
  enter = options.enter or defaultTransitions.enter

  views = {}

  views.selectView = ( name ) ->
    return ( this[name] or $( "" ) )

  views.addView = ( view ) ->
    view = $( view )
    name = view.attr( attrIdentifier )
    console.log name
    if this[name]
      console.error( "A view or method named #{name} is already registered on this ViewSwitcher")
    else
      views[name] = view

  views.removeView = ( name ) ->
    this[name] = undefined

  if rawViews instanceof jQuery
    rawViews.each ->
      views.addView( this )
  else if rawViews instanceof Array
    rawViews.forEach ( el ) ->
      views.addView( el )
  else if rawViews.substr
    views.addView( rawViews )

  state =
    activeView : views[initialView]
    pastViews : []

  switchView = ( incomingViewName ) ->

    incomingView = views[incomingViewName]

    cleanup = ( callback ) ->
      state.pastViews.push( state.activeView )
      state.activeView = incomingView
      callback() if callback


    if timedOffsets
      setTimeout exit.bind( container, incomingView, $.noop ), options.exitDelay
      setTimeout prepare.bind( container, state.activeView, incomingView, $.noop ), options.exitDelay + options.prepareDelay
      setTimeout enter.bind( container, incomingView, $.noop ), options.exitDelay + options.prepareDelay + options.enterDelay
      setTimeout cleanup.bind(null, onFinish ), options.exitDelay + options.prepareDelay + options.enterDelay

    else
      boundCleanup = cleanup.bind(null, onFinish )
      boundEnter = enter.bind( container, incomingView, boundCleanup )
      boundPrepare = prepare.bind( container, state.activeView, incomingView, boundEnter )
      exit.bind( container, state.activeView, boundPrepare )()

  switchView.views = ->
    return views

  switchView.addView = ( view ) ->
    views.addView( view )

  switchView.selectView = ( name ) ->
    views.selectById( name )

  switchView.removeView = ( name ) ->
    views.removeView( name )

  return switchView