class Results extends Backbone.Collection

  url : "result"
  model : Result
  db:
    view: "resultsByAssessmentId"

  comparator: (model) ->
    model.get('timestamp') || 0
