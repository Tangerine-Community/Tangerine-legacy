class FeedbackTripsView extends Backbone.View

  className: "FeedbackTripsView"

  events: ->

    "change #county" : "onCountySelectionChange"
    "change #zone"   : "onZoneSelectionChange"
    "change #school" : "onSchoolSelectionChange"

    "click .show-feedback"    : "showFeedback"
    "click .hide-feedback"    : "hideFeedback"

    "click .show-survey-data" : "showSurveyData"
    "click .hide-survey-data" : "hideSurveyData"

    "click .sortable" : "sortTable"
    "click .back" : "goBack"

  #
  showSurveyData: (event) ->
    $target = $(event.target)

    $target.toggle()
    $target.siblings().toggle()

    tripId = $target.attr("data-trip-id")
    $output = @$el.find(".#{tripId}-result")
    $output.html "<img class='loading' src='images/loading.gif'>"


    view = new WorkflowResultView
      workflow : @workflow
      trip : @trips.get(tripId)
    view.setElement($output)


    @subViews.push view
    @["WorkflowResultView-#{tripId}"] = view

  hideSurveyData: (event) ->
    $target = $(event.target)

    $target.toggle()
    $target.siblings().toggle()

    tripId = $target.attr("trip-id")
    @$el.find(".show-survey-data, .hide-survey-data").toggle()
    @subViews = _(@subViews).without @["WorkflowResultView-#{tripId}"]
    @["WorkflowResultView-#{tripId}"].close()

  goBack: ->
    Tangerine.router.navigate "", true

  initialize: (options) ->
    @[key] = value for key, value of options

    @subViews = []

    @trips = new TripResultCollection
    @trips.fetch
      resultView : "tutorTrips"
      queryKey   : "workflow-#{@workflow.id}"
      success: =>
        @isReady = true
        @render()


  hideFeedback: (event) ->

    $target = $(event.target)

    $target.toggle()
    $target.siblings().toggle()

    tripId = $target.attr("data-trip-id")
    @$el.find(".#{tripId}").empty()


  showFeedback: (event) ->
    $target = $(event.target)

    $target.toggle()
    $target.siblings().toggle()


    tripId = $target.attr("data-trip-id")

    trip = @trips.get(tripId)

    view = new FeedbackRunView
      trip     : trip
      feedback : @feedback

    view.render()

    @subViews.push view

    @$el.find(".#{tripId}").empty().append view.$el

  onClose: ->
    for view in @subViews
      view.close()

  sortTable: ( event ) ->
    newSortAttribute = $(event.target).attr("data-attr")
    if @sortAttribute isnt newSortAttribute or @sortAttribute is null
      @sortAttribute = newSortAttribute
      @sortDirection = 1
    else
      if @sortDirection is -1
        @sortDirection = 1
        @sortAttribute = null
      else if @sortDirection is 1
        @sortDirection = -1


    @updateFeedbackList()





  render: =>

    if @isReady and @trips.length == 0
      @$el.html "
        <h1>Feedback</h1>
        <button class='nav-button back'>Back</button>
        <p>No visits yet.</p>
      "
      return @trigger "rendered"

    return unless @isReady


    html = "
      <h1>Feedback</h1>
      <h2>Visits</h2>
      <div id='dropdown-selector'>
      </div>

      <br>
      <div id='feedback-list'>

      </div>
    "

    @$el.html html

    @dropdownView = new DropdownView
      variables : @feedback.get('dropdownVariables')
      collection : @trips

    @dropdownView.setElement(@$el.find("#dropdown-selector"))
    @dropdownView.render()

    @subViews.push @dropdownView

    @listenTo @dropdownView, "change", @handleSelection

    @trigger "rendered"

  onCountySelectionChange: (event) ->

    selectedCounty = $(event.target).val()
    tripsByCounty  = @trips.indexBy("County")

    zones = _(tripsByCounty[selectedCounty]).chain().map((a)->a.attributes['Zone']).compact().uniq().value().sort()

    zoneOptions = ''
    for zone in zones
      countInZone = tripsByCounty[selectedCounty]?.map?((a)->a.get("Zone")).filter((a)->a is zone)?.length || 0
      zoneOptions += "<option value='#{_(zone).escape()}'>#{zone} (#{countInZone})</option>"
    zoneOptions = "<option disabled='disabled' selected='selected'>Select a zone</option>" + zoneOptions


    @$el.find("#zone").html zoneOptions

    tripsByCounty[selectedCounty]?.map?((a)-> a.get("Zone")).filter?
    ((a)->a==zone).length || 0

  onZoneSelectionChange: ( event ) ->
    selectedZone = $(event.target).val()
    tripsByZone  = @trips.indexBy("Zone")

    schools = _(tripsByZone[selectedZone]).chain().map((a)->a.attributes['SchoolName']).compact().uniq().value().sort()

    schoolOptions = ''
    for school in schools
      countInSchool = tripsByZone[selectedZone]?.map?((a)->a.get("SchoolName")).filter((a)->a is school)?.length || 0
      schoolOptions += "<option value='#{_(school).escape()}'>#{_(school).escape()} (#{countInSchool})</option>"
    schoolOptions = "<option disabled='disabled' selected='selected'>Select a school</option>" + schoolOptions

    @$el.find("#school").html schoolOptions

    tripsByZone[selectedZone]?.map?((a)-> a.get("SchoolName")).filter?
    ((a)->a==zone).length || 0

  getSortArrow: (attributeName) ->
    return "&#x25bc;" if @sortAttribute is attributeName and @sortDirection is 1
    return "&#x25b2;" if @sortAttribute is attributeName and @sortDirection is -1
    return ""

  handleSelection: ( selectionObject ) ->

    feedbackVariableLength = @feedback.get('dropdownVariables')
    allSelectionsMade = Object.keys(selectionObject) is feedbackVariableLength
    unless allSelectionsMade
      @selectedTrips = @trips.where selectionObject
      @updateFeedbackList()




  updateFeedbackList: ->

    # to sort strings
    sortFunction = (a, b) =>
      a = a.getString(@sortAttribute).toLowerCase()
      b = b.getString(@sortAttribute).toLowerCase()
      if (a < b)
        result = -1
      else if (a > b)
        result = 1
      else
        result = 0
      return result * @sortDirection

    # sorting numbers
    # sortFunction = (a, b) => ( b.get(@sortAttribute) - a.get(@sortAttribute) ) * @sortDirection

    @selectedTrips = @selectedTrips.sort sortFunction

    sortVariables = @feedback.get("sortVariables").split(/\s*,\s*/)

    feedbackHtml = "
      <table id='feedback-table'>
        <thead>
          <tr>
            #{
              ("
              <th nowrap class='sortable' data-attr='#{_.escape(attribute)}'>#{attribute.underscore().humanize()} #{@getSortArrow(attribute)}</th>
              " for attribute in sortVariables).join('')
            }
            <th nowrap class='sortable' data-attr=''>&nbsp;</th>
          </tr>
        </thead>
        <tbody>
    "

    formatTime = (time) -> moment(time).format("MMM-DD HH:mm")

    for trip,index in @selectedTrips

      tripId = trip.get('tripId')

      resultButtonHtml = "
        <button class='command show-survey-data' data-trip-id='#{tripId}'>Show survey data</button>
        <button class='command hide-survey-data' data-trip-id='#{tripId}' style='display:none;'>Hide survey data</button>
      "


      feedbackHtml += "
        <tr>
            #{
              ("
              <td>
                #{
                  if ~attribute.indexOf("time")
                    formatTime(trip.getNumber(attribute))
                  else
                    trip.getString(attribute)
                }
                </td>
              " for attribute in sortVariables).join('')
            }
          <td>
            <button class='command show-feedback' data-trip-id='#{tripId}'>Show feedback</button>
            <button class='command hide-feedback' data-trip-id='#{tripId}' style='display:none;'>Hide feedback</button>
          </td>
          <td>
            #{resultButtonHtml || ''}
          </td>

        </tr>
        <tr>
          <td colspan='5' class='#{tripId}-result'></td>
        </tr>
        <tr>
          <td colspan='5' class='#{tripId}'></td>
        </tr>
      "
    feedbackHtml += "</tbody></table>"

    @$el.find("#feedback-list").html feedbackHtml


class WorkflowResultView extends Backbone.View

  events:
    "change select" : "updateDisplay"

  updateDisplay: ->
    @$el.find(".result-display").hide()
    selectedId = @$el.find("select").val()
    @$el.find(".subtest-#{selectedId}").show()

  initialize: (options) ->

    self = @
    @[key] = value for key, value of options

    assessmentSteps = _(@workflow.getChildren()).where({"type":"assessment"})
    assessmentModelBlanks = assessmentSteps.map( (el) -> { "_id" : el.typesId })
    loadOne = (assessments) ->

      if assessmentModelBlanks.length == 0
        self.render()
      else
        blank = assessmentModelBlanks.pop()
        assessment = new Assessment blank
        assessments.push assessment
        assessment.fetch
          error: -> alert "Loading assessment failed. Please try again."
          success: ->
            assessment.questions = new Questions
            assessment.questions.fetch
              key : assessment.id
              success: ->
                loadOne(assessments)

    @assessments = []
    loadOne(@assessments)

  render: ->
    optionsHtml = []
    displayHtml = ""
    first = true

    for assessment in @assessments
      for subtest in assessment.subtests.models
        if subtest.get("prototype") is "survey"

          hidden = if not first then "style='display:none;'" else ""
          first = false if first
          displayHtml += "<section #{hidden} class='subtest-#{subtest.id} result-display'>"
          optionsHtml += "<option value='#{subtest.id}'>#{subtest.get('name')}</option>"

          for question in assessment.questions.models

            tableHtml = ""

            type = question.get('type')

            if type is "multiple" or type is "single"
              for option in question.get("options")
                unless @trip.get(question.get('name'))
                  answer = "<span color='grey'>no data</span>"
                else
                  answer = if @trip.get(question.get('name')) is option.value then "<span style='color:green'>checked</span>" else "<span style='color:red'>unchecked</span>"
                tableHtml += "
                  <tr>
                    <th>#{option.label}</th>
                    <td>#{answer}</td>
                  </tr>
                "
            else
              tableHtml += "
                <tr>
                  <td colspan='2'>#{@trip.get(question.get('name'))}</td>
                </tr>
              "
            displayHtml += "
              <h3>#{question.get('prompt')}</h3>
              <table>#{tableHtml}</table>
            "
          displayHtml += "</section>"
    selectorHtml = "<select>#{optionsHtml}</select>"


    html = "
      <h2>Section</h2>
      #{selectorHtml}
      #{displayHtml}
    "

    @$el.html html


class DropdownView extends Backbone.View

  events :
    "change select" : "onSelect"

  onSelect: (event) ->

    $target = $(event.target)
    value = $target.val()
    level = parseInt($(event.target.selectedOptions[0]).attr('data-level'))
    console.log "I found level #{level} and value #{value}"

    @selected[level] = value
    @selected = @selected[0..level]

    @update
      startLevel : level

    if @selected.length is @variables.length
      @trigger "change", @getSelection()

  getSelection: ->
    result = {}
    for value, i in @selected
      result[@variables[i]] = value
    return result

  initialize: (options) ->
    @variables = options.variables.split(/\s*,\s*/)
    @collection = options.collection
    @selected = []

  @template:
    options: ( args ) ->
      DropdownView.template.emptyOption() +
      args.values.map( (value) ->
        DropdownView.template.oneOption(level:args.level,value:value)
      ).join('')

    oneOption: (args) ->
      "<option data-level='#{args.level}' #{if args.selected then 'selected="selected"' else ''} value='#{_.escape(args.value)}'>#{args.value}</option>"

    emptyOption: ->
      "<option selected='selected'>---</option>"

    fullSelect: ( args ) ->
      "
        <label for='#{args.cid}-select-level-#{args.level}'>#{args.variable}</label>
        <select id='#{args.cid}-select-level-#{args.level}'>
          #{DropdownView.template.options(level : args.level, values:args.values)}
        </select>
      "

    emptySelect: ( args ) ->
      "
        <label for='#{args.cid}-select-level-#{args.level}'>#{args.variable}</label>
        <select id='#{args.cid}-select-level-#{args.level}' disabled='disabled'>
          #{DropdownView.template.emptyOption()}
        </select>
      "

  render: ->
    html = ""
    for variable, i in @variables

      if i is 0

        html += DropdownView.template.fullSelect
          variable : variable
          level : i
          values : @getValues(variable)
          cid: @cid

      else

        html += DropdownView.template.emptySelect
          cid      : @cid
          level    : i
          variable : variable

    @$el.html html

  # get values for variable with currently selected values
  getValues: ( variable ) ->

    if @selected.length is 0
      variables = @collection.pluck(variable)
    else
      variables = (new Backbone.Collection @collection.where @getSelection()).pluck(variable)

    variables = variables.filter (a) -> !!a

    return _(variables).uniq().sort()

  renderLevel: (options) ->
    if options.clear or not options.values
      @$el.find("##{@cid}-select-level-#{options.level}").attr("disabled",true).html DropdownView.template.emptyOption()
    else if options.values.length is 1
      @$el.find("##{@cid}-select-level-#{options.level}").removeAttr('disabled').html DropdownView.template.oneOption(level: options.level,value: options.values[0], selected:true)
    else
      @$el.find("##{@cid}-select-level-#{options.level}").removeAttr('disabled').html DropdownView.template.options(level: options.level,values: options.values)

  # updates levels, recursive
  update: (options) ->

    startLevel = options.startLevel || 0

    return if startLevel >= @variables.length # recursive end condition

    thisLevel = startLevel + 1

    values = @getValues @variables[thisLevel]

    if values.length is 1 # if only one choice, auto select
      @selected[thisLevel] = values[0]
      @renderLevel
        level  : thisLevel
        values : values

      @update
        startLevel : thisLevel
    else
      shouldClear = thisLevel > @selected.length
      @renderLevel
        level  : thisLevel
        values : values
        clear  : shouldClear
      @update
        startLevel : thisLevel
