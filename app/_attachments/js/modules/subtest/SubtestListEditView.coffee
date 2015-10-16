class SubtestListEditView extends Backbone.View

  className: "SubtestListEditView"

  tagName : "ul"

  initialize: (options) ->
    @assessment = options.assessment
    @views = []

  render: =>
    @closeViews()
    @assessment.subtests.sort()
    @assessment.subtests.each (subtest) =>
      oneView = new SubtestListElementView
        "subtest" : subtest
      @views.push oneView
      oneView.render()
      oneView.on "subtest:delete", @deleteSubtest
      oneView.on "subtest:copy", @copySubtest
      @$el.append oneView.el

  # looks for subtests that are marked and copies them
  # if none are marked, copies only one
  copySubtest: (targetAssessmentId, subtestId) =>

    Utils.midAlert "Copying..."
    # create array of models that were marked for copying
    subtests = @views.filter( (view) -> view.selected == true ).map( (view) -> view.model )

    # copy just one subtest
    if subtests.length is 0
      subtests = [@assessment.subtests.get(subtestId)]

    # get the subtests from the target assessment so
    # we know the length and we can put the new subtests
    # at the bottom of the list with the order attribute.
    targetSubtestCount = 0
    (new Subtests).fetch
      key: targetAssessmentId
      success: (collection) =>

        targetSubtestCount = collection.length
        newSubtestCount = 0
        
        # Do one subtest at a time.
        doOne = ->

          if subtests.length is 0
            return Tangerine.router.navigate("edit/#{targetAssessmentId}", true)

          subtest = subtests.shift()
          newSubtestCount++
          subtest.copyTo
            assessmentId : targetAssessmentId
            order: targetSubtestCount + newSubtestCount
            callback: -> doOne()
        doOne()


  deleteSubtest: (subtest) =>
    @assessment.subtests.remove subtest
    subtest.destroy()

  closeViews: ->
    for view in @views
      view.close()
    @views = []
