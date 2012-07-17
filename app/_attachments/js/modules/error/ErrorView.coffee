class ErrorView extends Backbone.View

  initialize: ( options ) ->
    @message = options.message
    @details = options.details

  render: ->
    @$el.html "
    <h2>Oops</h2>
    <p>#{@message}</p>
    <p>Sorry about that.</p>
    <p>#{@details}</p>
    "
    
    @trigger "rendered"
