class Assessment extends Backbone.Model

  url: 'assessment'

  initialize: (options={}) ->
    # this collection doesn't get saved
    # changes update the subtest view, it keeps order
    @subtests = new Subtests

  # Hijacked success() for later
  # fetchs all subtests for the assessment
  fetch: (options) =>
    oldSuccess = options.success
    options.success = (model) =>
        allSubtests = new Subtests
        allSubtests.fetch
          key: @id
          success: (collection) =>
            @subtests = collection
            @subtests.maintainOrder()
            oldSuccess? @
    Assessment.__super__.fetch.call @, options

  duplicate: (assessmentAttributes, subtestAttributes, questionAttributes, callback) ->

    originalId = @id

    newModel = @clone()
    newModel.set assessmentAttributes
    newModel.set "_id", Utils.guid()
    newModel.save(null, {"wait":true})
    
    questions = new Questions
    questions.fetch
      success: ( questions ) =>
        filteredQuestions = questions.where { "assessmentId" : originalId }
        subtests = new Subtests
        subtests.fetch
          key: originalId
          success: ( subtests ) =>
        
            filteredSubtests = subtests.models
            subtestIdMap = {}
            newSubtests = []
            # link new subtests to new assessment
            for model, i in filteredSubtests
              newSubtest = model.clone()
              newSubtest.set "assessmentId", newModel.id
              newSubtestId = Utils.guid()
              subtestIdMap[newSubtest.id] = newSubtestId
              newSubtest.set "_id", newSubtestId
              newSubtests.push newSubtest


            # update the links to other subtests
            for model, i in newSubtests
              gridId = model.get( "gridLinkId" )
              if ( gridId || "" ) != ""
                model.set "gridLinkId", subtestIdMap[gridId]
              model.save()

            newQuestions = []
            # link questions to new subtest
            for question in filteredQuestions
              newQuestion = question.clone()
              oldId = newQuestion.get "subtestId"
              newQuestion.set "assessmentId", newModel.id
              newQuestion.set "_id", Utils.guid() 
              newQuestion.set "subtestId", subtestIdMap[oldId]
              newQuestions.push newQuestion
              newQuestion.save()
            
            callback()

  destroy: ->

    # remove children
    assessmentId = @id
    subtests = new Subtests
    subtests.fetch
      key: assessmentId
      success: (collection) -> collection.pop().destroy() while collection.length != 0
    questions = new Questions
    questions.fetch
      success: (collection) ->
        for model in collection.where { "assessmentId" : assessmentId }
          model.destroy()

    # remove model
    super()

