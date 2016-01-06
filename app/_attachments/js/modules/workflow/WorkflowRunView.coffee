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
    itsACurriculum  = @currentStep.getType() is "curriculum"
    itsANewObject   = @currentStep.getType() is "new"

    return false if !itIsRendered
    return @subView.next() if itExists and itIsntDone and itsAnAssessment
    return @subView.save() if itExists and itIsntDone and itsANewObject

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
      when "new"        then @renderNew()
      when "assessment" then @renderAssessment()
      when "curriculum" then @renderCurriculum()
      when "message"    then @renderMessage()
      when "login"
        @$el.find("##{@cid}_current_step").html "
          <h1>Login - #{@currentStep.get('userType')}</h1>
        "
      else
        @$el.find("##{@cid}_current_step").html "
          <h1>#{@currentStep.name()} - #{@currentStep.getType()}</h1>
        "

    if @currentStep.getShowLesson()
      
      subject      = @getVariable("subject")
      motherTongue = @getVariable("subject_mother_tongue")

      subject = ({"word": "kiswahili", "english_word" : "english", "operation" : "maths","3":"3"})[subject]
      grade   = @getVariable("class")
      week    = @getVariable("lesson_week")
      day     = @getVariable("lesson_day")

      $content = $("#content")

      unless $content.find("#display-switch").length > 0
        $content.append("<img src='images/icon_switch.png' id='display-switch'>")
        @$button = $content.find("#display-switch")
        @$button.on "click", @switch

      $content.append("<div id='lesson-container' style='display:none;'></div>")

      @$lessonContainer = $content.find("#lesson-container")

      lessonImage = new Image
      $(lessonImage).on "load",
        (event) =>
          if lessonImage.height is 0
            @$lessonContainer?.remove?()
            @$button?.remove?()
          else
            @$lessonContainer.append(lessonImage)

      if subject is "3"
        lessonImage.src = "/#{Tangerine.db_name}/_design/assets/lessons/#{motherTongue}_w#{week}_d#{day}.png"
      else
        lessonImage.src = "/#{Tangerine.db_name}/_design/assets/lessons/#{subject}_c#{grade}_w#{week}_d#{day}.png"

    else
      @lessonContainer?.remove?()
      @$button?.remove()

  renderMessage: ->
    @nextButton true

    coffeeMessage = @currentStep.getCoffeeMessage()
    jsMessage = CoffeeScript.compile.apply(@, ["return \"#{coffeeMessage}\""])

    htmlMessage = eval(jsMessage)

    @$el.find("##{@cid}_current_step").html htmlMessage
    @subViewRendered = true

  renderNew: ->
    @nextButton true

    view = @currentStep.getView
      workflowId : @workflow.id
      tripId     : @tripId

    @steps[@index].view   = view
    @steps[@index].result = view.getResult()

    @showView view


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

        itemType = @getString @currentStep.getCurriculumItemType()
        grade    = @getNumber @currentStep.getCurriculumGrade()

        thisYear = (new Date()).getFullYear()
        term1Start = moment "#{thisYear} Jan 1"
        term1End   = moment "#{thisYear} April 30"

        term2Start = moment "#{thisYear} May 1"
        term2End   = moment "#{thisYear} Aug 31"

        term3Start = moment "#{thisYear} Sept 1"
        term3End   = moment "#{thisYear} Dec 31"

        now = moment()
        term =
          if      term1Start <= now <= term1End
            1
          else if term2Start <= now <= term2End
            2
          else if term3Start <= now <= term3End
            3

        criteria =
          itemType : itemType
          part     : term
          grade    : grade

        subtest = _(subtests.where(
          itemType : itemType
          part     : term
          grade    : grade
        )).first()

        return Utils.midAlert "
          Subtest not found for <br>
          itemType: #{itemType}<br>
          term: #{term}<br>
          grade: #{grade}
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

  renderEnd: ->
    Utils.gpsPing
    @$el.find("##{@cid}_current_step").html "
      <p>You have completed this Classroom Observation.</p>
      <button class='nav-button'><a href='#feedback/#{@workflow.id}'>Go to feedback</a></button>
      <p>Once in feedback select the appropriate county, zone, school and date of this school visit to retrieve the feedback for this lesson observation. This information is to be used in your reflections and discussion with the teacher.</p>
      <button class='nav-button'><a href='#'>Main</a></button>
    "
    return

  nextButton: ( appropriate ) ->
    if appropriate
      @$el.find("button.next").show()
    else
      @$el.find("button.next").hide()
      


  onClose: ->
    @lessonContainer?.remove?()
    @$button?.remove?()

  showView: (subView, header = '') ->
    header = "<h1>#{header}</h1>" if header isnt ''
    @subView = subView
    @$el.find("#header-container").html header
    @subView.setElement @$el.find("##{@cid}_current_step")
    @listenTo @subView, "subViewDone save", @onSubViewDone
    @listenTo @subView, "rendered", =>
      @subViewRendered = true
      @trigger "rendered"
      #@afterRender()
    @subView.render()
