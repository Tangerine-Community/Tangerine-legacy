class LocationRunView extends Backbone.View

  events:
    "click #school_list li" : "autofill"
    "keyup input" : "showOptions"
    "click clear" : "clearInputs"

  initialize: (options) ->
    
    @model  = @options.model
    @parent = @options.parent
    
    @levels = @model.get("levels") || []
    
    @locations = @model.get("locations") || []

    @haystack = []

    for location, i in @locations
      @haystack[i] = []
      for locationData in location
        @haystack[i].push locationData.toLowerCase()

    
    template = "<li data-index='{{i}}'>"
    for level, i in @levels
      template += "{{level_#{i}}}"
      template += " - " unless i == @levels.length-1
    template += "</li>"
    
    @li = _.template(template)

  clearInputs: ->
    @$el.find("#school_id, #district, #province, #name").val("")

  autofill: (event) ->
    @$el.find("#autofill").fadeOut(250)
    index = $(event.target).attr("data-index")
    location = @locations[index]
    for level, i in @levels
      @$el.find("#level_#{i}").val(location[i])


  showOptions: (event) ->
    needle = $(event.target).val().toLowerCase()
    field = parseInt($(event.target).attr('data-level'))
    atLeastOne = false
    results = []
    for stack, i in @haystack
      isThere = ~@haystack[i][field].indexOf(needle)
      results.push i if isThere
      atLeastOne = true if isThere
    
    for stack, i in @haystack
      for otherField, j in stack
        if j == field
          continue
        isThere = ~@haystack[i][j].indexOf(needle)
        results.push i if isThere && !~results.indexOf(i)
        atLeastOne = true if isThere
    
    if atLeastOne
      html = ""
      for result in results
        html += @getLocationLi result
      @$el.find("#autofill").fadeIn(250)  
      @$el.find("#school_list").html html

    else
      @$el.find("#autofill").fadeOut(250)

  getLocationLi: (i) ->
    templateInfo = "i" : i
    for location, j in @locations[i]
      templateInfo["level_" + j] = location
    return @li templateInfo

  render: ->
    schoolListElements = ""

    html = "
      <button class='clear command'>Clear</button>
      ";
    for level, i in @levels
      html += "
        <div class='label_value'>
          <label for='level_#{i}'>#{level}</label>
          <input data-level='#{i}' id='level_#{i}' value=''>
        </div>
      "

    html += "
      <div id='autofill' style='display:none'>
        <h2>Select one from autofill list</h2>
        <ul id='school_list'>
        </ul>
      </div>
    "

    @$el.html html

    @trigger "rendered"

  getResult: ->
    
    return {
      "labels"   : (level.replace(/[\s-]/g,"_") for level in @levels)
      "location" : ($.trim(@$el.find("#level_#{i}").val()) for level, i in @levels)
    }

  isValid: ->
    @$el.find(".message").remove()
    for input in @$el.find("input")
      return false if $(input).val() == ""
    true

  showErrors: ->
    for input in @$el.find("input")
      if $(input).val() == ""
        $(input).after " <span class='message'>#{$('label[for='+$(input).attr('id')+']').text()} cannot be empty</span>"

  getSum: ->
    counts =
      correct   : 0
      incorrect : 0
      missing   : 0
      total     : 0
      
    for input in @$el.find("input")
      $input = $(input)
      counts['correct']   += 1 if ($input.val()||"") != ""
      counts['incorrect'] += 0 if false
      counts['missing']   += 1 if ($input.val()||"") == ""
      counts['total']     += 1 if true

    return {
      correct   : counts['correct']
      incorrect : counts['incorrect']
      missing   : counts['missing']
      total     : counts['total']
    }
