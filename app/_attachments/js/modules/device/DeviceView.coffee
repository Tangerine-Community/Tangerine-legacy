class DeviceView extends Backbone.View

  events:
    'click #context input' : 'set'
    'click #continue' : 'continue'


  continue: ->
    @model.save()
    Tangerine.router.navigate "", true

  set: ->
    console.log @$el.find('input:radio[name=context]:checked').val()
    @model.set
      'context': @$el.find('input:radio[name=context]:checked').val()
    

  initialize: ( options ) ->
    @model = options.model

  render: ->
    @$el.html "
      <h1>Tangerine Setup</h1>
      <p>Please select your configuration:</p>
      <div class='label_value buttonset' id='context'>
        <label for='context_cloud'>cloud</label><input id='context_cloud' name='context' type='radio' value='cloud' #{'checked' if @model.get('context') == 'cloud'}>
        <label for='context_mobile'>mobile</label><input id='context_mobile' name='context' type='radio' value='mobile' #{'checked' if @model.get('context') == 'mobile'}>
      </div>
      <button id='continue'>continue</button>
    "

    @trigger "rendered"
