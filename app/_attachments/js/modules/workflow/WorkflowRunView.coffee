class WorkflowRunView extends Backbone.View

  events:
    "click .previous" : "previousStep"
    "click .next"     : "nextStep"

  switch: =>
    @$el.toggle()
    @$lessonContainer.toggle()

  initialize: (options) ->
    @[key] = value for key, value of options
    @tripId = Utils.guid() unless @tripId?
    @index = 0 unless @index?
    @steps = [] unless @steps?
    @currentStep = @workflow.stepModelByIndex @index
    @subViewRendered = false

  shouldSkip: ->
    currentStep = @workflow.stepModelByIndex @index
    return false unless currentStep?
    skipLogicCode = currentStep.getString("skipLogic-cooked")
    unless _(skipLogicCode).isEmptyString()

      try
        shouldSkip = eval(skipLogicCode)
      catch e
        Utils.sticky "Workflow skip logic error<br>#{e.message}"

      return shouldSkip

    return false

  render: ->
    if @shouldSkip()
      @subViewRendered = true
      return @nextStep()

    stepIndicator = "<div id='workflow-progress'></div>"

    nextButton = "
      <div class='clearfix'><button class='nav-button next'>Next</button></div>
    " if @index isnt @workflow.getChildren().length - 1

    @$el.html "
      #{stepIndicator}
      <div id='header-container'></div>
      <section id='#{@cid}_current_step'></section>
      <!--button class='nav-button previous'>Previous</button-->
      #{nextButton || ''}
    "

    @renderStep()
    @checkIncompletes()

    @$el.find('#workflow-progress').progressbar value : ( (@index+1) / (@workflow.getLength()+1) * 100 )

    @trigger "rendered"


  afterRender: =>
    subView?.afterRender?()

  onSubViewDone: =>
    @subViewDone = true
    @nextStep()

  nextStep: =>
    itExists        = @subView?
    itIsRendered    = @subViewRendered
    itIsntDone      = not @subViewDone
    itsAnAssessment = @currentStep.getType() is "assessment"

    return false if !itIsRendered
    return @subView.next() if itExists and itIsntDone and itsAnAssessment

    @subViewRendered = false
    @subViewDone = false
    @subView?.remove?()
    @subView?.unbind?()

    @subView = null

    oldIndex = @index

    # intentionally lets you go one over
    # handled with "if currentStep is null"
    @index = Math.min @index + 1, @workflow.getLength()

    @render() if oldIndex isnt @index

    @checkIncompletes()


  checkIncompletes: ->
    return if @checkingIncompletes is true

    # if the workflow is complete, then remove it, if possible, from resumables
    if @workflow.stepModelByIndex(@index).getName() is "Complete"
      @checkingIncompletes = true
      incomplete = Tangerine.user.getPreferences("tutor-workflows", "incomplete") || {}
      incomplete[@workflow.id] = _(incomplete[@workflow.id]).without @tripId
      Tangerine.user.setPreferences "tutor-workflows",
        "incomplete",
        incomplete, =>
          @checkingIncompletes = false


  previousStep: ->
    oldIndex = @index
    @index = Math.max( @index - 1, 0 )
    @render() if oldIndex isnt @index

  getNumber: ( key ) -> parseInt @getVariable key
  getString: ( key ) -> @getVariable key

  getVariable: ( key ) ->
    for step in @steps
      if step?.result?
        result = step.result.getVariable(key)
      if result?
        return result


  renderStep: =>
    @steps[@index] = {} unless @steps[@index]?
    @currentStep = @workflow.stepModelByIndex @index
    @steps[@index].model = @currentStep

    if @index == @workflow.getLength()-1
      Tangerine.activity = ""
      @$el.find(".next").hide()

    return if @index == @workflow.getLength()

    switch @currentStep.getType()
      when "assessment" then @renderAssessment()
      when "curriculum" then @renderCurriculum()
      when "message"    then @renderMessage()
      else
        @$el.find("##{@cid}_current_step").html "
          <h1>#{@currentStep.name()} - #{@currentStep.getType()}</h1>
        "


  renderMessage: ->
    @nextButton true

    coffeeMessage = @currentStep.getCoffeeMessage()
    jsMessage = CoffeeScript.compile.apply(@, ["return \"#{coffeeMessage}\""])

    htmlMessage = eval(jsMessage)

    @$el.find("##{@cid}_current_step").html htmlMessage
    @subViewRendered = true

  renderAssessment: ->
    @nextButton true

    @currentStep.fetch
      success: =>
        assessment = @currentStep.getTypeModel()

        view = new AssessmentRunView
          model      : assessment
          inWorkflow : true
          tripId     : @tripId
          workflowId : @workflow.id

        if @assessmentResumeIndex?
          view.index = @assessmentResumeIndex
          delete @assessmentResumeIndex

        @listenTo view, "skip", =>
          @nextStep()

        @steps[@index].view   = view
        @steps[@index].result = view.getResult()
        @showView view


  renderCurriculum: ->
    @nextButton false

    curriculumId = @currentStep.getTypesId()
    subtests = new Subtests
    subtests.fetch
      key : curriculumId
      success: =>

        console.log @

        criteria = {}

        unless @currentStep.getCurriculumItemType() is ""
          criteria.itemType = @getString @currentStep.getCurriculumItemType()

        unless @currentStep.getCurriculumGrade() is ""
          criteria.grade    = @getNumber @currentStep.getCurriculumGrade()

        unless @currentStep.getCurriculumWeek() is ""
          criteria.part     = @getNumber @currentStep.getCurriculumWeek()

        subtest = _(subtests.where(criteria)).first()

        return Utils.midAlert "
          Subtest not found for <br>
          itemType: #{@getString @currentStep.getCurriculumItemType()}<br>
          version: #{@getNumber @currentStep.getCurriculumGrade()}<br>
          grade: #{@getNumber @currentStep.getCurriculumWeek()}
        " unless subtest?

        view = new KlassSubtestRunView
          student      : new Student
          subtest      : subtest
          questions    : new Questions
          linkedResult : new KlassResult
          inWorkflow   : true
          tripId       : @tripId
          workflowId   : @workflow.id
        @steps[@index].view = view
        @showView view, @currentStep.getName()

  nextButton: ( appropriate ) ->
    if appropriate
      @$el.find("button.next").show()
    else
      @$el.find("button.next").hide()


  showView: (subView, header = '') ->
    header = "<h1>#{header}</h1>" if header isnt ''
    @subView = subView
    @$el.find("#header-container").html header
    @subView.setElement @$el.find("##{@cid}_current_step")
    @listenTo @subView, "subViewDone save", @onSubViewDone
    @listenTo @subView, "rendered", =>
      @subViewRendered = true
      @trigger "rendered"
      @subView.afterRender?()
    @subView.render()
