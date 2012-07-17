class QuestionEditView extends Backbone.View

  className : "question_list_element"

  events : 
    'click .back'             : 'goBack'
    'click .done'             : 'done'
    'click .add_option'       : 'addOption'
    'click .delete_option'    : 'showDeleteConfirm'
    'click .delete_cancel'    : 'hideDeleteConfirm'
    'click .delete_delete'    : 'deleteOption'
    'click input:radio'       : 'changeQuestionType'
    'click .delete_question'  : 'deleteQuestion'
    'keypress'                : 'hijackEnter'
    'change .option_select'   : 'templateFill'

  templateFill: (event) ->
    index = $(event.target).find("option:selected").attr('data-index')
    @model.set "options", Tangerine.config.optionTemplates[index].options
    @$el.find('#option_list_wrapper').html @getOptionList()
    return false

  goBack: =>
    Tangerine.router.navigate "subtest/#{@model.get 'subtestId'}", true
    return false

  initialize: (options) ->
    @parent = options.parent
    @model  = options.model

  getOptionList: ->
    options = @model.get "options" 
    html = "<div id='option_list_wrapper'>
      <h2>Options</h2>
      <div class='menu_box'>
        <ul class='option_list'>"
    for option, i in options
      
      html += "
      <li class='question'>
        <table><tr><td>
          <img src='images/icon_drag.png' class='sortable_handle'>
        </td>
        <td>
          <div style='display: block;'>
            <div class='option_label_value'>
              <label class='edit' for='options.#{i}.label'>Label</label>
              <input id='options.#{i}.label' value='#{_.escape(option.label)}' placeholder='Option label' class='option_label'><br>
              <label class='edit' for='options.#{i}.value' title='Allowed characters&#58; A-Z, a-z, 0-9, and underscores.'>Value</label>
              <input id='options.#{i}.value' value='#{_.escape(option.value)}' placeholder='Option value' class='option_value'><br>
            </div>
            <img src='images/icon_delete.png' class='delete_option' data-index='#{i}'>
            <div class='confirmation delete_confirm_#{i}'>
              <button class='delete_delete' data-index='#{i}'>Delete</button>
              <button data-index='#{i}' class='delete_cancel'>Cancel</button>
            </div>
          </div>
        </td></tr></table>
      </li>
      "
    html += "</ul>

      <button class='add_option command'>Add option</button>
      </div>
    </div>"

  #
  # Adding an option
  #
  addOption: ->
    @updateModel()
    options = @model.get "options"
    options.push
      label : ""
      value : ""
    @model.set "options", options
    @$el.find('#option_list_wrapper').html(@getOptionList())


  render: ->
    name            = @model.escape("name") || ""
    prompt          = @model.escape("prompt") || ""
    hint            = @model.escape("hint") || ""
    type            = @model.get "type"
    options         = @model.get "options"
    linkedGridScore = @model.get("linkedGridScore") || 0
    skippable       = @model.get("skippable") == true || @model.get("skippable") == "true"

    checkOrRadio = if type == "multiple" then "checkbox" else "radio"

    @$el.html "
      <button class='back navigation'>Back</button>
      <h1>Question Editor</h1>
      <button class='done command'>Done</button>
      <div class='edit_form question'>
        <div class='label_value'>
          <label for='name'>Variable name</label>
          <input id='name' type='text' value='#{name}'>
        </div>
        <div class='label_value'>
          <label for='prompt'>Prompt</label>
          <input id='prompt' type='text' value='#{prompt}'>
        </div>
        <div class='label_value'>
          <label for='hint'>Hint</label>
          <input id='hint' type='text' value='#{hint}'>
        </div>
        <div class='label_value'>
          <label>Skippable</label>
          <div id='skip_radio' class='buttonset'>
            <label for='skip_true'>Yes</label><input name='skippable' type='radio' value='true' id='skip_true' #{'checked' if skippable}>
            <label for='skip_false'>No</label><input name='skippable' type='radio' value='false' id='skip_false' #{'checked' if not skippable}>
          </div>
        </div>
        <div class='label_value'>
          <label for='linked_grid_score'>Linked grid score</label>
          <input id='linked_grid_score' type='number' value='#{linkedGridScore}'>
        </div>
        <div class='label_value' id='question_type' class='question_type'>
          <label>Question Type</label>
          <div class='buttonset'>
            <label for='single'>single</label>
            <input id='single' name='type' type='radio' value='single' #{'checked' if type == 'single'}>
            <label for='multiple'>multiple</label>
            <input id='multiple' name='type'  type='radio' value='multiple' #{'checked' if type == 'multiple'}>
            <label for='open'>open</label>
            <input id='open' name='type'  type='radio' value='open' #{'checked' if type == 'open'}>
          </div>
        </div>
        "

    if type != "open"
      optionHTML = "
        <div class='label_value'>
        <label for='question_template_select'>Fill from template</label><br>
        <div class='menu_box'>
          <select id='question_template_select' class='option_select'>
            <option disabled selected>Select template</option>
        "
      # ok to refernce things by index if not an object
      for option, i in Tangerine.config.optionTemplates
        optionHTML += "<option data-index='#{i}' class='template_option'>#{option.name}</option>"

      optionHTML += "</select>
        </div>
        <div id='option_list_wrapper'>#{@getOptionList()}</div>
        "
      @$el.append optionHTML

      @$el.find(".option_list").sortable
        handle : '.sortable_handle'
        start: (event, ui) -> ui.item.addClass "drag_shadow"
        stop:  (event, ui) -> ui.item.removeClass "drag_shadow"
        update : (event, ui) =>
          @updateModel()

    @$el.append "<button class='done command'>Done</button>
      </div>
      "
    @trigger "rendered"



  hijackEnter: (event) -> 
    if event.which == 13
      @$el.find(event.target).blur()
      return false

  changeQuestionType: (event) ->
    $target = $(event.target)
    # list to open
    if ($target.val() != "open" && @model.get("type") == "open") || ($target.val() == "open" && @model.get("type") != "open")
      @model.set "type", $target.val()
      @model.set "options", []
      @render false

  #
  # Saving
  #
  done: ->
    @updateModel()
    # show a message and any we've collected along the way
    if @model.save()
      Utils.midAlert "Question Saved"
      setTimeout @goBack, 500
    else
      Utils.midAlert "Save error"
    return false
  
  deleteQuestion: ->
    @parent.questions.remove @model
    @model.destroy()
    @parentView.render()
    return false
  
  updateModel: =>
    # basics
    @model.set 
      "prompt"          : @$el.find("#prompt").val() 
      "name"            : @$el.find("#name").val()
      "hint"            : @$el.find("#hint").val()
      "linkedGridScore" : @$el.find("#linked_grid_score").val()
      "type"            : @$el.find("#question_type input:checked").val()
      "skippable"       : @$el.find("#skip_radio input:radio[name=skippable]:checked").val()

    # options
    options = []
    i = 0
    optionListElements = @$el.find(".option_list li")
    for li in optionListElements
      label = $(li).find(".option_label").val()
      value = $(li).find(".option_value").val().replace(/\s/g, "_").replace(/[^a-zA-Z0-9_]/g,"")

      if label? || value?
        options[i] =
          label : label
          value : value
        i++

    @model.set "options", options


        
  #
  # Deleting an option
  #
  showDeleteConfirm: (event) -> @$el.find(".delete_confirm_#{@$el.find(event.target).attr('data-index')}").fadeIn(250)
  hideDeleteConfirm: (event) -> @$el.find(".delete_confirm_#{@$el.find(event.target).attr('data-index')}").fadeOut(250)
  deleteOption: (event) ->
    @updateModel()
    options = @model.get "options"
    options.splice @$el.find(event.target).attr('data-index'), 1
    @model.set "options", options
    @model.save()
    @render false
    return false
