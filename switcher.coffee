# only called when container is bound to "this"
defaultTransitions = 
  exit : ( exitingView, callback ) ->
    this.height( this.height() )
    exitingView.fadeOut 500, ->
      callback()
  prepare : ( exitingView, enteringView, callback ) ->
    newHeight = enteringView.outerHeight() + parseInt(this.css("padding-top"), 10) + parseInt(this.css("padding-bottom"), 10)
    this.animate
      height : newHeight
    , 500, ->
      callback()
  enter : ( enteringView, callback ) ->
    enteringView.fadeIn 500, ->
      callback()

do ( root = do ->
  if typeof exports isnt "undefined"
    return exports
  else
    return window
) ->

  root.ViewSwitcher = ( options ) ->

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

    hub = $({})
    _on = ->
      hub.on.apply( hub, arguments )
    _off = ->
      hub.off.apply( hub, arguments )
    _trigger = ->
      hub.trigger.apply( hub, arguments )

    state =
      activeView : $("")
      pastViews : []

    finishRender = ( incomingView ) ->
      state.pastViews.push( state.activeView )
      state.activeView = incomingView
      _trigger( "renderComplete", state.activeView )

    switchView = ( incomingViewName ) ->

      incomingView = views[incomingViewName]

      # Not sure if this exactly works.
      if timedOffsets
        setTimeout exit.bind( container, incomingView, $.noop ), 0
        setTimeout prepare.bind( container, state.activeView, incomingView, $.noop ), options.exitDelay
        setTimeout enter.bind( container, incomingView, $.noop ), options.exitDelay + options.prepareDelay
        setTimeout finishRender.bind(null, incomingView ), options.exitDelay + options.prepareDelay + options.enterDelay

      else
        boundCleanup = finishRender.bind(null, incomingView )
        boundEnter = enter.bind( container, incomingView, boundCleanup )
        boundPrepare = prepare.bind( container, state.activeView, incomingView, boundEnter )
        exit.bind( container, state.activeView, boundPrepare )()

    # render the initial view
    prepare.bind( container, state.activeView, views[initialView], enter.bind( container, views[initialView], finishRender.bind(null, views[initialView] ) ) )()

    switchView.views = ->
      return views

    switchView.addView = ( view ) ->
      return views.addView( view )

    switchView.selectView = ( name ) ->
      return views.selectById( name )

    switchView.removeView = ( name ) ->
      return views.removeView( name )

    # use same on/off/trigger syntax that you would with a jQuery object.
    switchView.on = _on
    switchView.off = _off
    switchView.trigger = _trigger

    return switchView