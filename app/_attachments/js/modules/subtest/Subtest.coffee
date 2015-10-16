class Subtest extends Backbone.Model

  url: "subtest"

  initialize: (options) ->
    @templates = Tangerine.templates.get("prototypeTemplates")

    # guarentee survey pseudo model for observations
    if @has("surveyAttributes")
      if @get("assessmentId") != @get("surveyAttributes").assessmentId
        @save "surveyAttributes",
          "_id" : @id
          "assessmentId" : @get("assessmentId")

  loadPrototypeTemplate: (prototype) ->
    for key, value of @templates[prototype]
      @set key, value
    @save()

  copyTo: (options) ->

    assessmentId = options.assessmentId
    callback     = options.callback
    order        = options.order || 0

    newSubtest = new Subtest @attributes
    newId = Utils.guid()

    newSubtest.save
      "_id"          : newId
      "assessmentId" : assessmentId
      "order"        : order
      "gridLinkId"   : ""
    ,
      success: =>
        questions = new Questions
        questions.fetch
          key: @id
          error: -> Utils.sticky "There was an error copying."
          success: =>

            doOne = ->
              question = questions.pop()
              if question
                newQuestion = new Question question.attributes
                newQuestion.save
                  "assessmentId" : assessmentId
                  "_id"          : Utils.guid()
                  "subtestId"    : newId
                ,
                  success: ->
                    doOne()
                  error: -> Utils.sticky "There was an error copying."
              else
                # send user to edit page for reordering subtests
                Utils.midAlert "Subtest copied"
                callback()

            doOne()