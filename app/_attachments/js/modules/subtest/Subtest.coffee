class Subtest extends Backbone.Model

  url: "subtest"

  initialize: (options) ->
    @templates = Tangerine.config.prototypeTemplates

  loadPrototypeTemplate: (prototype) ->
    for key, value of @templates[prototype]
      @set key, value
    @save()
      
  