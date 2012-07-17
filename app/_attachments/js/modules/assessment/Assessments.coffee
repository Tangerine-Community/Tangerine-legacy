class Assessments extends Backbone.Collection
  model: Assessment
  url: 'assessment'

  comparator : (model) ->
    model.get "name"

  initialize: (options) ->
    if options?.group then @group = options.group
  