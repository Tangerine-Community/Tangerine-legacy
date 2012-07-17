class MessageView extends Backbone.View

  initialize: ( options ) ->
    @model = options.model
    


  render: ->
    @$el.html "
    <label for='to'>To</label>
    <select id='name'></select>
    
    
    
    "
    @trigger "rendered"
