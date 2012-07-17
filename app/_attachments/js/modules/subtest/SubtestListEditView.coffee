class SubtestListEditView extends Backbone.View
  tagName : "ul"
  
  initialize: (options) ->
    @model = options.model
    @views = []

  render: =>
    @closeViews()
    @model.subtests.sort()
    @model.subtests.each (subtest) =>
      oneView = new SubtestListElementView
        model : subtest
      @views.push oneView
      oneView.render()
      oneView.on "subtest:delete", @deleteSubtest
      @$el.append oneView.el

  deleteSubtest: (model) =>
    @model.subtests.remove model
    model.destroy()
    
  closeViews: ->
    for view in @views
      view.close()
    @views = []
