class AssessmentRunView extends Backbone.View

  className : "AssessmentRunView"

  events :
    "click .next" : "next"
    "click .skip" : "skip"

  initialize: (options) ->

    @model = options.model

    @inWorkflow = options.inWorkflow
    @tripId     = options.tripId
    @workflowId = options.workflowId


    @abortAssessment = false
    @index = 0
    @orderMap = []

    Utils.dataClear()

    @rendered = {
      "assessment" : false
      "subtest" : false
    }

    Tangerine.activity = "assessment run"
    @subtestViews = []
    @model.subtests.sort()
    @model.subtests.each (model) =>
      @subtestViews.push new SubtestRunView
        model  : model
        parent : @

    hasSequences = @model.has("sequences") && not _.isEmpty(_.compact(_.flatten(@model.get("sequences"))))

    if hasSequences
      sequences = @model.get("sequences")

      # get or initialize sequence places
      places = Tangerine.settings.get("sequencePlaces")
      places = {} unless places?
      places[@model.id] = 0 unless places[@model.id]?

      if places[@model.id] < sequences.length - 1
        places[@model.id]++
      else
        places[@model.id] = 0

      Tangerine.settings.save("sequencePlaces", places)

      @orderMap = sequences[places[@model.id]]
      @orderMap[@orderMap.length] = @subtestViews.length
    else
      for i in [0..@subtestViews.length]
        @orderMap[i] = i

    resultAttributes =
      assessmentId   : @model.id
      assessmentName : @model.get "name"
      blank          : true

    if @inWorkflow
      resultAttributes.tripId     = @tripId
      resultAttributes.workflowId = @workflowId

    @result = new Result resultAttributes

    if hasSequences then @result.set("order_map" : @orderMap)

    resultView = new ResultView
      model          : @result
      assessment     : @model
      assessmentView : @

    @subtestViews.push resultView

  render: ->

    currentView = @subtestViews[@orderMap[@index]]

    if @model.subtests.length == 0
      @$el.html "<h1>Oops...</h1><p>\"#{@model.get 'name'}\" is blank. Perhaps you meant to add some subtests.</p>"
      @trigger "rendered"
      @flagRender "assessment"
      return

    skippable = currentView.model.get("skippable") == true || currentView.model.get("skippable") == "true"
    skipButton = "<button class='skip nav-button'>Skip</button>" if skippable
    controlls = "
      <div id='controlls' class='clearfix'>
        <button class='next nav-button'>#{t('next')}</button>
        #{skipButton || ''}
      </div>
    " unless @index is @subtestViews.length - 1 or @inWorkflow?

    @$el.html "
      <h1>#{@model.get 'name'}</h1>
      <div id='progress'></div>
      <div id='subtest'></div>
      #{controlls || ''}
    "

    @$el.find('#progress').progressbar value : ( ( @index + 1 ) / ( @model.subtests.length + 1 ) * 100 )

    @listenTo currentView, "rendered",    => @flagRender "subtest"
    @listenTo currentView, "subRendered", => @trigger "subRendered"
    @listenTo currentView, "hideNext",    => @hideNext()
    @listenTo currentView, "showNext",    => @showNext()
    @listenTo currentView, "skip",        => @skip()


    currentView.setElement(@$el.find("#subtest"))
    currentView.render()

    @flagRender "assessment"

  afterRender: ->
    @subtestViews[@orderMap[@index]]?.afterRender?()

  showNext: -> @$el.find(".next_subtest").show()
  hideNext: -> @$el.find(".next_subtest").hide()

  flagRender: (object) ->
    @rendered[object] = true

    if @rendered.assessment && @rendered.subtest
      @trigger "rendered"

  onClose: ->
    for view in @subtestViews
      view.close()
    @result.clear()
    $("#current_student_id").fadeOut(250, -> $(@).html("").show())
    $("#current_student").fadeOut(250)

  abort: ->
    @abortAssessment = true
    @next()

  skip: =>
    @isSkipping = true
    currentView = @subtestViews[@orderMap[@index]]
    @result.add
      name      : currentView.model.get "name"
      data      : currentView.getSkipped()
      subtestId : currentView.model.id
      skipped   : true
      prototype : currentView.model.get "prototype"
      sum       : currentView.getSum()
    ,
      success: =>
        # plus 2 because it hasn't been incremented yet. normally plus 1 for 0 index
        atLastSubtest = @orderMap[@index] + 2 is @subtestViews.length
        if @inWorkflow and atLastSubtest
          @trigger "subViewDone"
        else
          @resetNext()

  next: =>
    if @abortAssessment
      currentView = @subtestViews[@orderMap[@index]]
      @saveResult( currentView )
      return

    currentView = @subtestViews[@orderMap[@index]]
    if currentView.isValid()
      @saveResult( currentView )
    else
      currentView.showErrors()

  getResult: -> @result

  saveResult: ( currentView ) =>
    subtestResult = currentView.getResult()

    @result.add
      name        : currentView.model.get "name"
      data        : subtestResult.body
      subtestHash : subtestResult.meta.hash
      subtestId   : currentView.model.id
      prototype   : currentView.model.get "prototype"
      sum         : currentView.getSum()
    ,
      success : =>
        @trigger "subViewDone" if @index is @subtestViews.length - 2
        @resetNext()

  resetNext: =>
    @rendered.subtest = false
    @rendered.assessment = false
    currentView = @subtestViews[@orderMap[@index]]
    currentView.close()
    @index =
      if @abortAssessment == true
        @subtestViews.length-1
      else
        @index + 1

    @hideNext() if @index is @subtestViews.length - 1

    @render()
    window.scrollTo 0, 0
