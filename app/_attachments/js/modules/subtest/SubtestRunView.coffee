class SubtestRunView extends Backbone.View

  className : "SubtestRunView"

  events:
    'click .next'         : 'next'
    'click .subtest_help' : 'toggleHelp'
    'click .skip'         : 'skip'

  toggleHelp: -> @$el.find(".enumerator_help").fadeToggle(250)

  initialize: (options) ->
    @protoViews  = Tangerine.config.get "prototypeViews"
    @model       = options.model
    @parent      = options.parent
    @fontStyle = "style=\"font-family: #{@model.get('fontFamily')} !important;\"" if @model.get("fontFamily") != ""

    @prototypeRendered = false

  render: ->

    enumeratorHelp = if (@model.get("enumeratorHelp") || "") != "" then "<button class='subtest_help command'>help</button><div class='enumerator_help' #{@fontStyle || ""}>#{@model.get 'enumeratorHelp'}</div>" else ""
    studentDialog  = if (@model.get("studentDialog")  || "") != "" then "<div class='student_dialog' #{@fontStyle || ""}>#{@model.get 'studentDialog'}</div>" else ""
    transitionComment = @getTransitionComment()

    @$el.html "
      <h2>#{@model.get 'name'}</h2>
      #{enumeratorHelp}
      #{studentDialog}
      <div id='prototype_wrapper'></div>

      <div class='clearfix' id='transition-comment-container'>
        #{transitionComment}
      </div>
    "

    # Use prototype specific views here
    @prototypeView = new window[@protoViews[@model.get 'prototype']['run']]
      model  : @model
      parent : @
    @listenTo @prototypeView, "rendered",    => @flagRender("prototype")
    @listenTo @prototypeView, "subRendered", => @trigger "subRendered"
    @listenTo @prototypeView, "showNext",    => @trigger "showNext"
    @listenTo @prototypeView, "hideNext",    => @trigger "hideNext"
    @listenTo @prototypeView, "ready",       => @prototypeRendered = true;
    @prototypeView.setElement(@$el.find('#prototype_wrapper'))
    @prototypeView.render()

    @flagRender "subtest"

  getTransitionComment: (html = @model.getString('transitionComment')) ->
    return "<div class='student_dialog' #{@fontStyle || ""}>#{html}</div> <br>" if html isnt ""
    return ""

  setTransitionComment: (html = "") ->
    @$el.find("#transition-comment-container").html @getTransitionComment(html)


  flagRender: ( flag ) =>
    @renderFlags = {} if not @renderFlags
    @renderFlags[flag] = true

    if @renderFlags['subtest'] && @renderFlags['prototype']
      @trigger "rendered"


  afterRender: =>

    @prototypeView?.afterRender?()
    @onShow()

  WithPrevious: (callback) ->

    if @parent.inWorkflow
      Utils.withPrevious
        workflow : @parent.workflowId
        callback : callback
    else
      Utils.withPrevious
        assessmentId : @model.get("assessmentId")
        callback : callback

  skip: ->
    @trigger "skip"

  onShow: ->
    displayCode = @model.getString("displayCode")
    if not _.isEmptyString(displayCode)
      try
        CoffeeScript.eval.apply(@, [displayCode])
      catch error
        name = ((/function (.{1,})\(/).exec(error.constructor.toString())[1])
        message = error.message
        alert "#{name}\n\n#{message}"
        console.log "displayCode Error: " + JSON.stringify(error)

    @prototypeView.updateExecuteReady?(true)

  getGridScore: ->
    link = @model.get("gridLinkId") || ""
    if link == "" then return
    grid = @parent.model.subtests.get @model.get("gridLinkId")
    gridScore = @parent.result.getGridScore grid.id
    gridScore

  gridWasAutostopped: ->
    link = @model.get("gridLinkId") || ""
    if link == "" then return
    grid = @parent.model.subtests.get @model.get("gridLinkId")
    gridWasAutostopped = @parent.result.gridWasAutostopped grid.id

  onClose: ->
    @prototypeView?.close?()

  isValid: ->
    if not @prototypeRendered then return false
    if @prototypeView.isValid?
      return @prototypeView.isValid()
    else
      return false
    true

  showErrors: ->
    @prototypeView.showErrors()

  getSum: ->
    if @prototypeView.getSum?
      return @prototypeView.getSum()
    else
      # maybe a better fallback
      return {correct:0,incorrect:0,missing:0,total:0}

  abort: ->
    @parent.abort()

  getResult: ->
    result = @prototypeView.getResult()
    hash = @model.get("hash") if @model.has("hash")
    return {
      'body' : result
      'meta' :
        'hash' : hash
    }

  getSkipped: ->
    if @prototypeView.getSkipped?
      return @prototypeView.getSkipped()
    else
      throw "Prototype skipping not implemented"

