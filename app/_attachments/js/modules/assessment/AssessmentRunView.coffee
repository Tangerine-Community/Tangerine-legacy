class AssessmentRunView extends Backbone.View
  
  initialize: (options) ->
    @abortAssessment = false
    @index = 0
    @model = options.model
    @initializeViews()

  initializeViews: ->
    @subtestViews = []
    @model.subtests.sort()
    @model.subtests.each (model) =>
      @subtestViews.push new SubtestRunView 
        model  : model
        parent : @
    @result = new Result
      assessmentId   : @model.id
      assessmentName : @model.get "name"
      blank          : true
      starttime     : (new Date()).getTime()
    resultView = new ResultView
        model          : @result
        assessment     : @model
        assessmentView : @
    @subtestViews.push resultView
  
  render: ->
    # this prevents doubling up results
    # the inefficiency is that it gets called twice the first time
    if @index == 0 && @result?
      @initializeViews()
      
    currentView = @subtestViews[@index]
    
    if @model.subtests.length == 0
      @$el.append "<h1>Oops...</h1><p>This assessment is blank. Perhaps you meant to add some subtests.</p>"
    else
      @$el.html "
        <h1>#{@model.get 'name'}</h1>
        <div id='progress'></div>
      "
      @$el.find('#progress').progressbar value : ( ( @index + 1 ) / ( @model.subtests.length + 1 ) * 100 )
      currentView.on "rendered", @onSubtestRendered
      currentView.render()
      @$el.append currentView.el

    @trigger "rendered"

  onSubtestRendered: =>
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

  skip: ->
    currentView = @subtestViews[@index]
    @result.add
      name      : currentView.model.get "name"
      data      : currentView.getSkipped()
      subtestId : currentView.model.id
      sum       : currentView.getSum()
    currentView.close()
    @index++ unless @abortAssessment == true
    @index = @subtestViews.length-1 if @abortAssessment == true
    @render()
    window.scrollTo 0, 0

  next: ->
    currentView = @subtestViews[@index]
    if currentView.isValid()
      @result.add
        name      : currentView.model.get "name"
        data      : currentView.getResult()
        subtestId : currentView.model.id
        prototype : currentView.model.get "prototype"
        sum       : currentView.getSum()
      currentView.close()
      @index++ unless @abortAssessment == true
      @index = @subtestViews.length-1 if @abortAssessment == true
      @render()
      window.scrollTo 0, 0
    else
      currentView.showErrors()