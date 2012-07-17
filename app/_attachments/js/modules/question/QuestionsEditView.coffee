class QuestionsEditView extends Backbone.View

  tagName : "ul"
  className : "questions_edit_view"
  
  initialize: ( options ) ->
    @views = []
    @questions = options.questions

  onClose: ->
    @closeViews()

  closeViews: ->
    for view in @views
      view.close()

  render: =>
    @closeViews()
    for question, i in @questions.models
      view = new QuestionsEditListElementView
        "question" : question
      @views.push view
      view.on "deleted", @render
      view.render()
      @$el.append view.el

    # make it sortable
    @$el.sortable
      handle : '.sortable_handle'
      start: (event, ui) -> ui.item.addClass "drag_shadow"
      stop:  (event, ui) -> ui.item.removeClass "drag_shadow"

      update : (event, ui) =>
        for id, i in ($(li).attr("data-id") for li in @$el.find("li.question_list_element"))
          oneQuestion = @questions.get(id)
          @questions.get(id).set({"order":i},{silent:true}).save(null,{silent:true})
        #@render()
