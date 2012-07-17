class GridEditView extends Backbone.View

  initialize: ( options ) ->
    @model = options.model

  save: ->
    # validation can be done on models, perhaps there is a better palce to do it
    if /\t|,/.test(@$el.find("#subtest_items").val()) then alert "Please remember\n\nGrid items need spaces separating them."
    @model.set
      timer    : parseInt( @$el.find("#subtest_timer").val() )
      items    : _.compact( @$el.find("#subtest_items").val().split(" ") ) # mild sanitization, happens at read too
      columns  : parseInt( @$el.find("#subtest_columns").val() )
      autostop : parseInt( @$el.find("#subtest_autostop").val() )
      variableName : @$el.find("#subtest_variable_name").val().replace(/\s/g, "_").replace(/[^a-zA-Z0-9_]/g,"")


  render: ->
    timer        = @model.get("timer") || 0
    items        = @model.get("items").join " "
    columns      = @model.get("columns") || 0
    autostop     = @model.get("autostop") || 0
    variableName = @model.get("variableName") || ""


    @$el.html "
      <div class='label_value'>
        <label for='subtest_variable_name'>Variable name</label>
        <input id='subtest_variable_name' value='#{variableName}'>
      </div>
      <div class='label_value'>
        <label for='subtest_items'>Grid Items (space delimited)</label>
        <textarea id='subtest_items'>#{items}</textarea>
      </div>
      <div class='label_value'>
        <label for='subtest_columns'>Columns</label>
        <input id='subtest_columns' value='#{columns}' type='number'>
      </div>
      <div class='label_value'>
        <label for='subtest_autostop'>Autostop</label>
        <input id='subtest_autostop' value='#{autostop}' type='number'>
      </div>
      <div class='label_value'>
        <label for='subtest_timer'>Timer</label>
        <input id='subtest_timer' value='#{timer}' type='number'>
      </div>"
    