class KlassSubtestRunView extends Backbone.View

  className : "KlassSubtestRunView"

  events:
    'click .done'         : 'done'
    'click .cancel'       : 'cancel'
    'click .subtest_help' : 'toggleHelp'

  toggleHelp: -> @$el.find(".enumerator_help").fadeToggle(250)

  initialize: (options) ->

    @inWorkflow   = options.inWorkflow
    @tripId       = options.tripId
    @workflowId   = options.workflowId

    @linkedResult = options.linkedResult
    @student      = options.student
    @subtest      = options.subtest
    @questions    = options.questions

    @prototype = @subtest.get("prototype")

    @protoViews = Tangerine.config.get("prototypeViews")

    @prototypeRendered = false

    resultAttributes =
      if @prototype is "grid"
        prototype   : "grid"
        startTime   : (new Date()).getTime()
        itemType    : @subtest.getString("itemType")
        reportType  : @subtest.get("reportType")
        studentId   : @student.id
        subtestId   : @subtest.id
        part        : @subtest.get("part")
        klassId     : @student.get("klassId")
        timeAllowed : @subtest.get("timer")
      else if @prototype is "survey"
        prototype   : "survey"
        startTime   : (new Date()).getTime()
        studentId   : @student.id
        subtestId   : @subtest.id
        part        : @subtest.get("part")
        klassId     : @student.get("klassId")
        itemType    : @subtest.getString("itemType")
        reportType  : @subtest.get("reportType")

    if @inWorkflow
      resultAttributes.tripId     = @tripId
      resultAttributes.workflowId = @workflowId

    @result = new KlassResult resultAttributes

    if @questions?
      @questions.sort()
      @render()


  render: ->
    enumeratorHelp = if (@subtest.get("enumeratorHelp") || "") != "" then "<button class='subtest_help command'>help</button><div class='enumerator_help'>#{@options.subtest.get 'enumeratorHelp'}</div>" else ""
    studentDialog  = if (@subtest.get("studentDialog")  || "") != "" then "<div class='student_dialog'>#{@options.subtest.get 'studentDialog'}</div>" else ""

    htmlButton = "<button class='done nav-button'>Done</button>"
    
    htmlButton += "<button class='cancel nav-button'>Cancel</button>" unless @inWorkflow


    @$el.html "
      <h2>#{@options.subtest.get 'name'}</h2>
      #{enumeratorHelp}
      #{studentDialog}
      <div id='prototype_wrapper'></div>
      #{htmlButton}
    "

    # Use prototype specific views here
    @prototypeView = new window[@protoViews[@subtest.get 'prototype']['run']]
      model: @subtest
      parent: @
    @listenTo @prototypeView, "rendered", @onPrototypeRendered
    @prototypeView.setElement(@$el.find('#prototype_wrapper'))
    @prototypeView.render()

    @flagRender "subtest"

  afterRender: =>
    @prototypeView?.afterRender?()

  onPrototypeRendered: =>
    @prototypeRendered = true
    @flagRender "prototype"

  flagRender: ( flag ) =>
    @renderFlags = {} if not @renderFlags
    @renderFlags[flag] = true

    if @renderFlags['subtest'] && @renderFlags['prototype']
      @trigger "rendered"


  getGridScore: -> 
    return false if not @linkedResult.get("subtestData")? # no result found
    result = @linkedResult.get("subtestData")['attempted'] || 0 
    return result

  gridWasAutostopped: -> @linkedResult.get("subtestData")?['auto_stop'] || 0

  onClose: ->
    @prototypeView?.close?()

  isValid: ->
    if not @prototypeRendered then return false
    if @prototypeView.isValid?
      return @prototypeView.isValid()
    else
      return false
    true

  getSkipped: ->
    if @prototypeView.getSkipped?
      return @prototypeView.getSkipped()
    else
      throw "Prototype skipping not implemented"

  cancel: ->
    if @student.id == "test"
      history.back()
      return

    Tangerine.router.navigate "class/#{@options.student.get('klassId')}/#{@options.subtest.get('part')}", true

  done: ->
    if @student.id == "test"
      history.back()
      return

    if @isValid()
      if @inWorkflow
        @result.add @prototypeView.getResult(), success: => @trigger "subViewDone"
      else
        # Gaurantee single "new" result
        Tangerine.$db.view "#{Tangerine.design_doc}/resultsByStudentSubtest",
          key : [@options.student.id,@subtest.id]
          success: (data) =>
            rows = data.rows
            for datum in rows
              Tangerine.$db.saveDoc $.extend(datum.value, "old":true)
            # save this result
            @result.add @prototypeView.getResult(), success: =>
              Tangerine.router.navigate "class/#{@options.student.get('klassId')}/#{@options.subtest.get('part')}", true
    else
      @prototypeView.showErrors()