class ResultView extends Backbone.View

  className: "result_view"

  events:
    'click .save'    : 'save'
    'click .another' : 'another'

  another: ->
    Tangerine.router.navigate "restart/#{@assessment.id}", true

  save: ->
    @model.add
      name : "Assessment complete"
      prototype: "complete"
      data :
        "comment" : @$el.find('#additional_comments').val() || ""
      subtestId : "result"
      sum :
        correct : 1
        incorrect : 0
        missing : 0
        total : 1

    if @model.save()
      Utils.midAlert "Result saved"
      @$el.find('.save_status').html "saved"
      @$el.find('.save_status').removeClass('not_saved')
      @$el.find('button.save, .question').fadeOut(250)
      @$el.find('.confirmation').removeClass('confirmation')
    else
      Utils.midAlert "Save error"
      @$el.find('.save_status').html "Results may not have saved"

  initialize: ( options ) ->
    @model = options.model
    @assessment = options.assessment
    @saved = false
    @resultSumView = new ResultSumView
      model : @model

  render: ->
    @$el.append "<h2>Assessment complete</h2>
    <div class='label_value'>
      <label>Result</label>
      <div class='info_box save_status not_saved'>Not saved yet</div>
        <h2>Subtests completed</h2>
    "
    @resultSumView.render()
    
    @$el.append @resultSumView.el
    
    @$el.append "

      <div class='question'>
      <div class='prompt'>Additional comments (optional)</div>
      <textarea id='additional_comments' class='full_width'></textarea>
      </div>
      <button class='save command'>Save result</button><br>
      <div class='confirmation'><button class='another command'>Perform another assessment</button></div>
    "

    @trigger "rendered"
    
  onClose: ->
    @resultSumView.close()