#
#  ____             _    _                         _     
# | __ )  __ _  ___| | _| |__   ___  _ __   ___   (_)___ 
# |  _ \ / _` |/ __| |/ / '_ \ / _ \| '_ \ / _ \  | / __|
# | |_) | (_| | (__|   <| |_) | (_) | | | |  __/_ | \__ \
# |____/ \__,_|\___|_|\_\_.__/ \___/|_| |_|\___(_)/ |___/
#                                               |__/     
#

# Extend every view with a close method, used by ViewManager
# try/catch until single call only guaranteed 
Backbone.View.prototype.close = ->

  try
    @remove?()
  catch e
    console.log @
    console.log e.message

  try
    @unbind?()
  catch e
    console.log @
    console.log e.message

  try
    @onClose?()
  catch e
    console.log @
    console.log e.message

  try
    delete @$el
  catch e
    console.log @
    console.log e.message

  try
    delete @el
  catch e
    console.log @
    console.log e.message
  

Backbone.View.prototype.select = (selector, update=false) ->
  @selectors = {} unless @selectors?
  return @selectors[selector] if @selectors[selector]? or update is true
  @selectors[selector] = @$el.find(selector)

# Returns an object hashed by a given attribute.
Backbone.Collection.prototype.indexBy = ( attr ) ->
  result = {}
  for oneModel in @models
    if oneModel.has(attr)
      key = oneModel.get(attr)
      result[key] = [] if not result[key]?
      result[key].push(oneModel)
  return result

# Returns an object hashed by a given attribute.
Backbone.Collection.prototype.indexArrayBy = ( attr ) ->
  result = []
  for oneModel in @models
    if oneModel.has(attr)
      key = oneModel.get(attr)
      result[key] = [] if not result[key]?
      result[key].push(oneModel)
  return result

Backbone.Model.prototype.conform = ( standard = {} ) ->
  throw "Cannot conform to empty standard. Use @clear() instead." if _.isEmpty(standard)
  for key, value of standard
    @set(key, value()) if @has(key) or @get(key) is ""

Backbone.Model.prototype.prune = ( shape = {} ) ->
  throw "Cannot prune to empty shape. Use @clear() instead." if _.isEmpty(standard)
  for key, value of @attributes
    @unset(key) unless key in standard

# hash the attributes of a model
Backbone.Model.prototype.toHash = ->
  significantAttributes = {}
  for key, value of @attributes
    significantAttributes[key] = value if !~['_rev', '_id','hash','updated','editedBy','fromInstanceId'].indexOf(key)
  return b64_sha1(JSON.stringify(significantAttributes))

# by default all models will save a timestamp and hash of significant attributes
Backbone.Model.prototype._beforeSave = (key, val, options) ->
  @beforeSave?(key, val, options)
  @stamp()

Backbone.Model.prototype.stamp = ->
  @set 
    "editedBy" : Tangerine?.user?.name() || "unknown"
    "updated" : (new Date()).toString()
    "hash" : @toHash()
    "fromInstanceId" : Tangerine.settings.getString("instanceId")


#
# This series of functions returns properties with default values if no property is found
# @gotcha be mindful of the default "blank" values set here
#
Backbone.Model.prototype.getNumber =        (key, defaultValue = 0 )    -> return if @has(key) then parseInt(@get(key)) else defaultValue
Backbone.Model.prototype.getArray =         (key, defaultValue = [])    -> return if @has(key) then @get(key)           else defaultValue
Backbone.Model.prototype.getString =        (key, defaultValue = "")    -> return if @has(key) then @get(key)           else defaultValue
Backbone.Model.prototype.getEscapedString = (key, defaultValue = "")    -> return if @has(key) then @escape(key)        else defaultValue
Backbone.Model.prototype.getBoolean =       (key, defaultValue = false) -> return if @has(key) then (@get(key) == true or @get(key) == 'true') else defaultValue

Backbone.Model.prototype.getAttachments = -> 
  result = []

  if @has("_attachments")
    for filename, attachment of @get("_attachments")
      splitName = filename.split(".")
      result.push(
        "filename"     : filename
        "itemType"     : splitName[0]
        "resourceType" : splitName[1]
        "size"         : attachment.length
        "digest"       : attachment.digest
        "contentType"  : attachment.content_type
        "revpos"       : attachment.revpos
        "stub"         : attachment.stub
      )
  return result

Backbone.Model.prototype.fetchAttachment = (options) ->
  $.ajax
    url      : "/#{Tangerine.db_name}/#{@id}/#{options.filename}"
    success  : options.success  || $.noop
    error    : options.error    || $.noop
    complete : options.complete || $.noop


class Backbone.EditView extends Backbone.View

  events :
    "click .edit_in_place" : "editInPlace"
    "focusout .editing"    : "editing"
    "keyup    .editing"    : "editing"
    "keydown  .editing"    : "editing"

  getEditable: (options) =>

    model        = options.model
    attribute    = options.attribute
    name         = options.name        || "Value"
    placeholder  = options.placeholder || "none"
    prepare      = options.prepare

    @preparations                     = {} unless @preparations?
    @preparations[model.id]           = {} unless @preparations[model.id]?
    @preparations[model.id][attribute.key] = prepare

    @htmlGenCatelog = {} unless @htmlGenCatelog?
    @htmlGenCatelog[model.id] = {} unless @htmlGenCatelog[model.id]?
    @htmlGenCatelog[model.id][attribute.key] = htmlFunction = do (model, attribute, name, placeholder) -> 
      -> 

        key    = attribute.key
        escape = attribute.escape
        type   = attribute.type || ''

        # cook the value
        value = if model.has(key) then model.get(key) else placeholder
        value = placeholder if _(value).isEmptyString()

        value = _(value).escape() if escape
        untitled = " data-untitled='true' " if value is placeholder

        # what is it
        editOrNot   = if attribute.editable && Tangerine.settings.get("context") == "server" then "class='edit_in_place'" else ""

        numberOrNot = if _.isNumber(value) then "data-is-number='true'" else "data-is-number='false'" 

        result = "<div class='edit_in_place #{key}-edit-in-place' id='#{model.id}-#{key}'><span data-model-id='#{model.id}' data-type='#{type}' data-key='#{key}' data-value='#{value}' data-name='#{name}' #{editOrNot} #{numberOrNot} #{untitled||''}>#{value}</span></div>"

        return result

    return htmlFunction()


  editInPlace: (event) =>

    return if @alreadyEditing
    @alreadyEditing = true

    # save state
    # replace with text area
    # on save, save and re-replace
    $span = $(event.target)

    $parent  = $span.parent()

    return if $span.hasClass("editing")

    guid     = Utils.guid()

    key      = $span.attr("data-key")
    name     = $span.attr("data-name")
    type     = $span.attr("data-type")
    isNumber = $span.attr("data-is-number") == "true"

    modelId  = $span.attr("data-model-id")
    model    = @models.get(modelId)

    oldValue = model.get(key) || ""
    oldValue = "" if $span.attr("data-untitled") == "true"

    $target = $(event.target)
    classes = ($target.attr("class") || "").replace("settings","")
    margins = $target.css("margin")

    transferVariables = "data-is-number='#{isNumber}' data-key='#{key}' data-model-id='#{modelId}' "

    if type is "boolean"
      $span

    # sets width/height with style attribute
    rows = 1 + oldValue.count("\n")
    rows = parseInt(Math.max(oldValue.length / 30, rows))
    $parent.html("<textarea placeholder='#{name}' id='#{guid}' rows='#{rows}' #{transferVariables} class='editing #{classes} #{key}-editing' style='margin:#{margins}' data-name='#{name}'>#{oldValue}</textarea>")
    # style='width:#{oldWidth}px; height: #{oldHeight}px;'
    $textarea = $("##{guid}")
    $textarea.select()

  editing: (event) =>

    return false if event.which == 13 and event.type == "keyup"

    $target = $(event.target)

    $parent = $target.parent()

    key        = $target.attr("data-key")
    isNumber   = $target.attr("data-is-number") == "true"

    modelId    = $target.attr("data-model-id")
    name       = $target.attr("data-name")

    model      = @models.get(modelId)
    oldValue   = model.get(key)

    newValue = $target.val()
    newValue = if isNumber then parseInt(newValue) else newValue

    if event.which == 27 or event.type == "focusout"
      @$el.find("##{modelId}-#{key}").html @htmlGenCatelog[modelId][key]?()
      @alreadyEditing = false
      return

    # act normal, unless it's an enter key on keydown
    keyDown = event.type is "keydown"
    enter   = event.which is 13
    altKey  = event.altKey

    return true if enter and altKey
    return true unless enter and keyDown

    @alreadyEditing = false

    # If there was a change, save it
    if String(newValue) != String(oldValue)
      attributes = {}
      attributes[key] = newValue
      if @preparations?[modelId]?[key]?
        try
          attributes[key+"-cooked"] = @preparations[modelId][key](newValue)
        catch e
          Utils.sticky("Problem cooking value<br>#{e.message}")
          return
      model.save attributes,
        success: =>
          Utils.topAlert "#{name} saved"
          @$el.find("##{modelId}-#{key}").html @htmlGenCatelog[modelId][key]?()
        error: =>
          alert "Please try to save again, it didn't work that time."
          @render()
    else
      @$el.find("##{modelId}-#{key}").html @htmlGenCatelog[modelId][key]?()

    # this ensures we do not insert a newline character when we press enter
    return false



class Backbone.ChildModel extends Backbone.Model

  save: (attributes, options={}) =>
    options.success = $.noop unless options.success?
    options.error = $.noop unless options.error?
    @set attributes
    options.childSelf = @
    @parent.childSave(options)


class Backbone.ChildCollection extends Backbone.Collection


class Backbone.ParentModel extends Backbone.Model

  Child: null
  ChildCollection: null

  constructor: (options) ->
    @collection = new @ChildCollection()
    @collection.on "remove", => @updateAttributes()
    super(options)

  getLength: -> @collection.length || @attributes.children.length

  fetch: (options) ->
    oldSuccess = options.success
    delete options.success
    
    options.success = (model, response, options) =>
      childrenModels = []
      for child in @getChildren()
        childModel = new @Child(child)
        childModel.parent = @
        childrenModels.push childModel
      @collection.reset childrenModels
      @collection.sort()
      oldSuccess(model, response, options)

    super(options)

  getChildren: ->
    @getArray("children")

  updateAttributes: ->
    @attributes.children = []
    for model in @collection.models
      @attributes.children.push model.attributes

  updateCollection: =>
    @collection.reset(@attributes.children)
    @collection.each (child) =>
      child.parent = @

  newChild: (attributes={}, options) =>
    newChild = new @Child
    newChild.set("_id", Utils.guid())
    newChild.parent = @
    @collection.add(newChild, options)
    newChild.save attributes,
      success: =>
        

  childSave: (options = {}) =>
    oldSuccess = options.success
    delete options.success
    options.success = (a, b, c) =>
      oldSuccess.apply(options.childSelf, [a, b, c])
    @updateAttributes()

    @save null, options

capitalize = (word) -> 
  if word? and typeof(word) is 'string'
    word.charAt(0).toUpperCase() + word.slice 1
  else
    word

#    _  ___                        
#   (_)/ _ \ _   _  ___ _ __ _   _ 
#   | | | | | | | |/ _ \ '__| | | |
#   | | |_| | |_| |  __/ |  | |_| |
#  _/ |\__\_\\__,_|\___|_|   \__, |
# |__/                       |___/ 
#

( ($) -> 

  $.fn.scrollTo = (speed = 250, callback=$.noop) ->
    try
      $('html body').animate {
        scrollTop: $(@).offset().top + 'px'
        }, 
          complete: callback
          duration: speed
    catch e
      console.log "error", e
      console.log "Scroll error with 'this'", @

    return @

  # place something top and center
  $.fn.topCenter = ->
    @css "position", "absolute"
    @css "top", $(window).scrollTop() + "px"
    @css "left", (($(window).width() - @outerWidth()) / 2) + $(window).scrollLeft() + "px"

  # place something middle center
  $.fn.middleCenter = ->
    @css "position", "absolute"
    @css "top", (($(window).height() - this.outerHeight()) / 2) + $(window).scrollTop() + "px"
    @css "left", (($(window).width() - this.outerWidth()) / 2) + $(window).scrollLeft() + "px"

  $.fn.widthPercentage = ->
    return Math.round(100 * @outerWidth() / @offsetParent().width()) + '%'

  $.fn.heightPercentage = ->
    return Math.round(100 * @outerHeight() / @offsetParent().height()) + '%'


  $.fn.getStyleObject = ->

      dom = this.get(0)

      returns = {}

      if window.getComputedStyle

          camelize = (a, b) -> b.toUpperCase()

          style = window.getComputedStyle dom, null

          for prop in style
              camel = prop.replace /\-([a-z])/g, camelize
              val = style.getPropertyValue prop
              returns[camel] = val

          return returns

      if dom.currentStyle

          style = dom.currentStyle

          for prop in style

              returns[prop] = style[prop]

          return returns

      return this.css()


)(jQuery)


#
#  _   _ _   _ _     
# | | | | |_(_) |___ 
# | | | | __| | / __|
# | |_| | |_| | \__ \
#  \___/ \__|_|_|___/
#                    
#

class CsvRow

  constructor: ( row ) ->
    @row = row

  get: ( key ) -> 
    candidate = _(@row).where({key:key})
    if candidate.length isnt 0
      return candidate[0].value
    return null 

  getStartTime: ->
    @get("start_time")


class CsvRows

  constructor: ( rows ) ->
    @rows = rows

  where: (criteria) ->
    result = []
    for row in @rows
      if _(row).where(criteria).length > 0
        result.push row
    return new CSVRows result

  getRecent: =>
    return null if @rows.length is 0
    @rows.sort((a, b) -> b.getStartTime() - a.getStartTime())[0]


class Utils

  @gpsPing: ( options = {} ) =>
    Utils.log this, "GPS Ping Started" 
    navigator.geolocation.getCurrentPosition(
        (position) =>
          Utils.log this, "GPS Ping: Received #{Utils.gpsEasify position}" 
      ,
        (positionError) =>
          Utils.log this, "GPS Ping: Error: #{positionError.message}" 
      , 
        maximumAge         : 300 * 1000
        timeout            : 60 * 1000
        enableHighAccuracy : true 
    )

  @gpsEasify: ( position ) =>
    return {
      lat       : if position?.coords?.latitude?         then position.coords.latitude else "..."
      long      : if position?.coords?.longitude?        then position.coords.longitude else "..."
      alt       : if position?.coords?.altitude?         then position.coords.altitude else "..."
      acc       : if position?.coords?.accuracy?         then position.coords.accuracy else "..."
      altAcc    : if position?.coords?.altitudeAccuracy? then position.coords.altitudeAccuracy else "..."
      heading   : if position?.coords?.heading?          then position.coords.heading else "..."
      speed     : if position?.coords?.speed?            then position.coords.speed else "..."
      timestamp : if position?.timestamp?                then position.timestamp else "..."
    }

  @withPrevious: ( options = {} ) =>

    workflowId   = options.workflowId
    assessmentId = options.assessmentId
    callback     = options.callback

    getRows = ( ids = [] ) ->

      Tangerine.$db.view "#{Tangerine.design_doc}/csvRows", 
        keys : ids
        success : ( response ) ->
          rows = new CsvRows(response.rows.map( (a) -> new CsvRow a.value ))
          try
            callback?( rows )
          catch e
            Utils.sticky "Error during WithPrevious<br>#{e}"

    if workflowId?

      Tangerine.$db.view "#{Tangerine.design_doc}/results",
        key: workflowId
        success: (response) -> 
          ids = response.rows.filter( (row) ->
            row.value != "assessment" && row.value != "klass"
          ).map (result) -> result.id
          getRows ids
    else
      getRows [ assessmentId ]



  @readyForUpdate: ->
    # Replicate to PouchDB data store

    Tangerine.pouch = new PouchDB(Tangerine.db_name)

    PouchDB.replicate "http://0.0.0.0:5984/#{Tangerine.db_name}", Tangerine.db_name,
      complete: ->
        $.couch.login
          name     : "admin"
          password : "password"
          success: ->
            $.ajax
              url : "http://0.0.0.0:5984/#{Tangerine.db_name}"
              type: "DELETE"
              success: ->
                Utils.midAlert "Database 'ready'"
                $("body").empty()
              error: (err1, err) ->
                Utils.midAlert "Database could not be readied"
                Utils.midAlert err


  @loadCollections : ( loadOptions ) ->

    throw "You're gonna want a callback in there, buddy." unless loadOptions.complete?

    toLoad = loadOptions.collections || []

    getNext = (options) ->
      if current = toLoad.pop()
        memberName = current.underscore().camelize(true)
        options[memberName] = new window[current]
        options[memberName].fetch
          success: ->
            getNext options
      else
        loadOptions.complete options

    getNext {}

  @universalUpload: ->
    $.ajax 
      url: Tangerine.settings.urlView("local", "byCollection")
      type: "POST"
      dataType: "json"
      contentType: "application/json"
      data: JSON.stringify(
        keys : ["result"]
      )
      success: (data) ->
        docList = _.pluck(data.rows,"id")
        
        $.couch.replicate(
          Tangerine.settings.urlDB("local"),
          Tangerine.settings.urlDB("group"),
            success: =>
              Utils.sticky "Results synced to cloud successfully."
            error: (code, message) =>
              Utils.sticky "Upload error<br>#{code} #{message}"
          ,
            doc_ids: docList
        )

  @restartTangerine: (message, callback) ->
    Utils.midAlert "#{message || 'Restarting Tangerine'}"
    _.delay( ->
      document.location.reload()
      callback?()
    , 2000 )

  @onUpdateSuccess: (totalDocs) ->
    Utils.documentCounter++
    if Utils.documentCounter == totalDocs
      Utils.restartTangerine "Update successful", ->
        Tangerine.router.landing()
        Utils.askToLogout() unless Tangerine.settings.get("context") == "server"
      Utils.documentCounter = null


  @updateTangerine  : (doResolve = true, options = {}) ->

    Utils.documentCounter = 0

    dDoc = "t"

    targetDB = Tangerine.settings.contextualize
      server : Tangerine.db_name
      satellite : Tangerine.db_name
      allElse: Tangerine.settings.location.update.target

    docIds = ["_design/#{dDoc}", "configuration", "school-list"]

    targetDB = options.targetDB if options.targetDB?
    docIds   = options.docIds   if options.docIds?

    Utils.midAlert "Updating..."
    Utils.working true
    # save old rev for later
    Tangerine.$db.allDocs
      keys : docIds
      success: (response) ->
        oldDocs = []
        for row in response.rows  
          oldDocs.push {
            "_id"  : row.id
            "_rev" : row.value.rev
          }
        # replicate from update database
        $.couch.replicate Tangerine.settings.urlDB("update"), targetDB,
          error: (error) ->
            Utils.working false
            Utils.midAlert "Update failed replicating<br>#{error}"
            Utils.documentCounter = null
          success: ->
            unless doResolve
              Utils.onUpdateSuccess(1)
              return
            totalDocs = docIds.length
            for docId, i in docIds
              oldDoc = oldDocs[i]
              do (docId, oldDoc, totalDocs) ->
                Tangerine.$db.openDoc docId,
                  conflicts: true
                  success: (data) ->
                    if data._conflicts?
                      Tangerine.$db.removeDoc oldDoc,
                        success: ->
                          Utils.working false
                          Utils.onUpdateSuccess(totalDocs)
                        error: (error) ->
                          Utils.documentCounter = null
                          Utils.working false
                          Utils.midAlert "Update failed resolving conflict<br>#{error}"
                    else
                      Utils.onUpdateSuccess(totalDocs)
        , doc_ids : docIds

  @log: (self, error) ->
    className = self.constructor.toString().match(/function\s*(\w+)/)[1]
    console.log "#{className}: #{error}"

  # if args is one object save it to temporary hash
  # if two strings, save key value pair
  # if one string, use as key, return value
  @data: (args...) ->
    if args.length == 1
      arg = args[0]
      if _.isString(arg)
        return Tangerine.tempData[arg]
      else if _.isObject(arg)
        Tangerine.tempData = $.extend(Tangerine.tempData, arg)
      else if arg == null
        Tangerine.tempData = {}
    else if args.length == 2
      key = args[0]
      value = args[1]
      Tangerine.tempData[key] = value
      return Tangerine.tempData
    else if args.length == 0
      return Tangerine.tempData

  @dataClear: -> Tangerine.tempData = {}

  @working: (isWorking) ->
    if isWorking
      if not Tangerine.loadingTimer?
        Tangerine.loadingTimer = setTimeout(Utils.showLoadingIndicator, 3000)
    else
      if Tangerine.loadingTimer?
        clearTimeout Tangerine.loadingTimer
        Tangerine.loadingTimer = null
          
      $(".loading_bar").remove()

  @showLoadingIndicator: ->
    $("<div class='loading_bar'><img class='loading' src='images/loading.gif'></div>").appendTo("body").middleCenter()

  # asks for confirmation in the browser, and uses phonegap for cool confirmation
  @confirm: (message, options) ->
    if navigator.notification?.confirm?
      navigator.notification.confirm message, 
        (input) ->
          if input == 1
            options.callback true
          else if input == 2
            options.callback false
          else
            options.callback input
      , options.title, options.action+",Cancel"
    else
      if window.confirm message
        options.callback true
        return true
      else
        options.callback false
        return false
    return 0

  # this function is a lot like jQuery.serializeArray, except that it returns useful output
  # works on textareas, input type text and password
  @getValues: ( selector ) ->
    values = {}
    $(selector).find("input[type=text], input[type=password], textarea").each ( index, element ) -> 
      values[element.id] = element.value
    return values

  # converts url escaped characters
  @cleanURL: (url) ->
    if url.indexOf?("%") != -1
      url = decodeURIComponent url
    else
      url

  # Disposable alerts
  @topAlert: (alertText, delay = 2000) ->
    Utils.alert "top", alertText, delay

  @midAlert: (alertText, delay=2000) ->
    Utils.alert "middle", alertText, delay

  @alert: ( where, alertText, delay = 2000 ) ->

    switch where
      when "top"
        selector = ".top_alert"
        aligner = ( $el ) -> return $el.topCenter()
      when "middle"
        selector = ".mid_alert"
        aligner = ( $el ) -> return $el.middleCenter()


    if Utils["#{where}AlertTimer"]?
      clearTimeout Utils["#{where}AlertTimer"] 
      $alert = $(selector)
      $alert.html( $alert.html() + "<br>" + alertText )
    else
      $alert = $("<div class='#{selector.substring(1)} disposable_alert'>#{alertText}</div>").appendTo("#content")

    aligner($alert)

    do ($alert, selector, delay) ->
      computedDelay = ((""+$alert.html()).match(/<br>/g)||[]).length * 1500
      Utils["#{where}AlertTimer"] = setTimeout -> 
          Utils["#{where}AlertTimer"] = null
          $alert.fadeOut(250, -> $(this).remove() )
      , Math.max(computedDelay, delay)
      


  @sticky: (html, buttonText = "Close", callback = $.noop, position = "middle") ->
    div = $("<div class='sticky_alert'>#{html}<br><button class='command parent_remove'>#{buttonText}</button></div>").appendTo("#content")
    if position == "middle"
      div.middleCenter()
    else if position == "top"
      div.topCenter()
    div.on("keyup", (event) -> if event.which == 27 then $(this).remove()).find("button").click -> callback()

  @topSticky: (html, buttonText = "Close", callback) ->
    Utils.sticky(html, buttonText, callback, "top")

  @execute: ( functions, scope, progress ) ->

    totalFunctions = functions.length

    step = ->
      progress?.apply?(scope||step, [totalFunctions, functions.length])
      nextFunction = functions.shift()
      if typeof nextFunction is "function"
        nextFunction.apply(scope||step, [step])
    step()


  @modal: (html) ->
    if html == false
      $("#modal_back, #modal").remove()
      return

    $("body").prepend("<div id='modal_back'></div>")
    $("<div id='modal'>#{html}</div>").appendTo("#content").middleCenter().on("keyup", (event) -> if event.which == 27 then $("#modal_back, #modal").remove())

  @passwordPrompt: (callback) ->
    html = "
      <div id='pass_form' title='User verification'>
        <label for='password'>Please re-enter your password</label>
        <input id='pass_val' type='password' name='password' id='password' value=''>
        <button class='command' data-verify='true'>Verify</button>
        <button class='command'>Cancel</button>
      </div>
    "

    Utils.modal html

    $pass = $("#pass_val")
    $button = $("#pass_form button")

    $pass.on "keyup", (event) ->
      return true unless event.which == 13
      $button.off "click" 
      $pass.off "change"

      callback $pass.val()
      Utils.modal false

    $button.on "click", (event) ->
      $button.off "click"
      $pass.off "change"

      callback $pass.val() if $(event.target).attr("data-verify") == "true"

      Utils.modal false

  @modalPrompt: (options) ->
    prompt   = options.prompt || ''
    pass     = options.pass || false
    callback = options.callback || $.noop

    type = 
      if pass
        "password"
      else
        "text"

    html = "
      <div id='modal_form' title='User verification'>
        <label for='modal-input'>#{prompt}</label>
        <input id='modal-input' type='#{type}' value=''>
        <button class='command' data-ok='true'>Ok</button>
        <button class='command'>Cancel</button>
      </div>
    "

    Utils.modal html

    $pass = $("#modal-input")
    $button = $("#modal_form button")

    $pass.on "keyup", (event) ->
      return true unless event.which == 13
      $button.off "click" 
      $pass.off "change"

      callback $pass.val()
      Utils.modal false

    $button.on "click", (event) ->
      $button.off "click"
      $pass.off "change"

      callback $pass.val() if $(event.target).attr("data-ok") == "true"

      Utils.modal false

  @showAbout: ->
    html = "
      <p>This application was developed by the Tusome Early Literacy Programme. Tusome is implemented by the Ministry of Education, Science & Technology with support of USAID and DFID.</p>
      <p>If you have any questions or comments, please contact Lucy Wambari <a href='tel://254723742848'>+254723742848</a>.</p>
    "
    Utils.sticky(html)

  # returns a GUID
  @guid: ->
   return @S4()+@S4()+"-"+@S4()+"-"+@S4()+"-"+@S4()+"-"+@S4()+@S4()+@S4()
  @S4: ->
   return ( ( ( 1 + Math.random() ) * 0x10000 ) | 0 ).toString(16).substring(1)

  @humanGUID: -> return @randomLetters(4)+"-"+@randomLetters(4)+"-"+@randomLetters(4)
  @safeLetters = "abcdefghijlmnopqrstuvwxyz".split("")
  @randomLetters: (length) -> 
    result = ""
    while length--
      result += Utils.safeLetters[Math.floor(Math.random()*Utils.safeLetters.length)]
    return result

  # turns the body background a color and then returns to white
  @flash: (color="red", shouldTurnItOn = null) ->

    if not shouldTurnItOn?
      Utils.background color
      setTimeout ->
        Utils.background ""
      , 1000

  @background: (color) ->
    if color?
      $("#content_wrapper").css "backgroundColor" : color
    else
      $("#content_wrapper").css "backgroundColor"

  # Retrieves GET variables
  # http://ejohn.org/blog/search-and-dont-replace/
  @$_GET: (q, s) ->
    vars = {}
    parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, (m,key,value) ->
        value = if ~value.indexOf("#") then value.split("#")[0] else value
        vars[key] = value.split("#")[0];
    )
    vars


  # not currently implemented but working
  @resizeScrollPane: ->
    $(".scroll_pane").height( $(window).height() - ( $("#navigation").height() + $("#footer").height() + 100) ) 

  # asks user if they want to logout
  @askToLogout: -> Tangerine.user.logout() if confirm("Would you like to logout now?")

  @oldConsoleLog = null
  @enableConsoleLog: -> return unless oldConsoleLog? ; window.console.log = oldConsoleLog
  @disableConsoleLog: -> oldConsoleLog = console.log ; window.console.log = $.noop

  @oldConsoleAssert = null
  @enableConsoleAssert: -> return unless oldConsoleAssert?    ; window.console.assert = oldConsoleAssert
  @disableConsoleAssert: -> oldConsoleAssert = console.assert ; window.console.assert = $.noop


# debug codes
km = {"0":48,"1":49,"2":50,"3":51,"4":52,"5":53,"6":54,"7":55,"8":56,"9":57,"a":65,"b":66,"c":67,"d":68,"e":69,"f":70,"g":71,"h":72,"i":73,"j":74,"k":75,"l":76,"m":77,"n":78,"o":79,"p":80,"q":81,"r":82,"s":83,"t":84,"u":85,"v":86,"w":87,"x":88,"y":89,"z":90}
sks = [ { q : (km["0100ser"[i]] for i in [0..6]), i : 0, c : -> Tangerine.settings.save({"context": "server"}, { success: -> Tangerine.router.navigate("", true)}) },
        { q : (km["0100mob"[i]] for i in [0..6]), i : 0, c : -> Tangerine.settings.save({"context": "mobile"}, { success: -> Tangerine.router.navigate("", true)}) },
        { q : (km["0100cla"[i]] for i in [0..6]), i : 0, c : -> Tangerine.settings.save({"context": "class"},  { success: -> Tangerine.router.navigate("", true)}) },
        { q : (km["0100sat"[i]] for i in [0..6]), i : 0, c : -> Tangerine.settings.save({"context": "satellite"},  { success: -> Tangerine.router.navigate("", true)}) },
        { q : (km["0900redo"[i]] for i in [0..7]), i : 0, c : -> vm.currentView.index--; vm.currentView.resetNext(); },
        { q : (km["0900back"[i]] for i in [0..7]), i : 0, c : -> vm.currentView.index -= 2; vm.currentView.index = Math.max(0, vm.currentView.index); vm.currentView.resetNext(); },
        { q : (km["0100update"[i]] for i in [0..9]), i : 0, c : -> Utils.updateTangerine( -> Utils.midAlert("Updated, please refresh.") ) } ]
$(document).keydown (e) -> ( if e.keyCode == sks[j].q[sks[j].i++] then sks[j]['c']() if sks[j].i == sks[j].q.length else sks[j].i = 0 ) for sk, j in sks 



# Robbert interface
class Robbert
  
  @request: (options) ->

    success = options.success
    error   = options.error

    delete options.success
    delete options.error

    $.ajax
      type        : "POST"
      crossDomain : true
      url         : Tangerine.config.get("robbert")
      dataType    : "json"
      data        : options
      success: ( data ) =>
        success data
      error: ( data ) =>
        error data

# Tree interface
class TangerineTree

  @make: (options) ->

    Utils.working true
    success = options.success
    error   = options.error

    delete options.success
    delete options.error

    options.user = Tangerine.user.name()

    $.ajax
      type     : "POST"
      crossDomain : true
      url      : Tangerine.config.get("tree") + "/#{Tangerine.settings.get('groupName')}"
      dataType : "json"
      data     : options
      success: ( data ) =>
        success data
      error: ( data ) =>
        error data, JSON.parse(data.responseText)
      complete: ->
        Utils.working false


##UI helpers
$ ->
  # ###.clear_message
  # This little guy will fade out and clear him and his parents. Wrap him wisely.
  # `<span> my message <button class="clear_message">X</button>`
  $("#content").on("click", ".clear_message",  null, (a) -> $(a.target).parent().fadeOut(250, -> $(this).empty().show() ) )
  $("#content").on("click", ".parent_remove", null, (a) -> $(a.target).parent().fadeOut(250, -> $(this).remove() ) )

  # disposable alerts = a non-fancy box
  $("#content").on "click",".alert_button", ->
    alert_text = if $(this).attr("data-alert") then $(this).attr("data-alert") else $(this).val()
    Utils.disposableAlert alert_text
  $("#content").on "click", ".disposable_alert", ->
    $(this).stop().fadeOut 100, ->
      $(this).remove()
  
  # $(window).resize Utils.resizeScrollPane
  # Utils.resizeScrollPane()


#
# CouchDB error handling
#

$.ajaxSetup
  statusCode:
    404: (xhr, status, message) ->
      code = xhr.status
      statusText = xhr.statusText
      seeUnauthorized = ~xhr.responseText.indexOf("unauthorized")
      if seeUnauthorized
        Utils.midAlert "Session closed<br>Please log in and try again."
        Tangerine.user.logout()


#
#      _ ____    _   _       _   _           
#     | / ___|  | \ | | __ _| |_(_)_   _____ 
#  _  | \___ \  |  \| |/ _` | __| \ \ / / _ \
# | |_| |___) | | |\  | (_| | |_| |\ V /  __/
#  \___/|____/  |_| \_|\__,_|\__|_| \_/ \___|
#                                            
#




String.prototype.safetyDance = -> this.replace(/\s/g, "_").replace(/[^a-zA-Z0-9_]/g,"")
String.prototype.databaseSafetyDance = -> this.replace(/\s/g, "_").toLowerCase().replace(/[^a-z0-9_-]/g,"")
String.prototype.count = (substring) -> this.match(new RegExp substring, "g")?.length || 0

Math.ave = ->
  result = 0
  result += x for x in arguments
  result /= arguments.length
  return result

Math.isInt    = -> return typeof n == 'number' && parseFloat(n) == parseInt(n, 10) && !isNaN(n)
Math.decimals = (num, decimals) -> m = Math.pow( 10, decimals ); num *= m; num =  num+( (num<0) ? -0.5:+0.5)>>0; num /= m
Math.commas   = (num) -> parseInt(num).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
Math.limit    = (min, num, max) -> Math.max(min, Math.min(num, max))

# method name slightly misleading
# returns true for falsy values
#   null, undefined, and '\s*'
# other false values like
#   false, 0
# return false
_.isEmptyString = ( aString ) ->
  return true if aString is null or aString is undefined
  return false unless _.isString(aString) or _.isNumber(aString)
  aString = String(aString) if _.isNumber(aString)
  return true if aString.replace(/\s*/, '') == ''
  return false

_.prototype.isEmptyString = ->
  _.isEmptyString(@_wrapped)


_.indexBy = ( propertyName, objectArray ) ->
  result = {}
  for oneObject in objectArray
    property = oneObject.attributes?[propertyName] or oneObject[propertyName]
    if property?
      key = oneObject[propertyName]
      result[key] = [] if not result[key]?
      result[key].push(oneObject)
  return result

_.prototype.indexBy = ( index ) ->

  anArray = @_wrapped
  anArray = @_wrapped.models if @_wrapped.models?

  _.indexBy(index, anArray)

_.prototype.tally = ->
  _.tally(@_wrapped)

_.tally = ( anArray ) ->
  counts = {}
  for element in anArray
    if element?
      counts[element] = 0 unless counts[element]?
      counts[element]++
  counts

# these could easily be refactored into one.

ResultOfQuestion = (name) ->
  returnView = null
  view = vm.currentView.subView || vm.currentView
  index = view.orderMap[view.index]

  for candidateView in view.subtestViews[index].prototypeView.questionViews
    if candidateView.model.get("name") == name
      returnView = candidateView
  throw new ReferenceError("ResultOfQuestion could not find variable #{name}") if returnView == null
  return returnView.answer if returnView.answer
  return null

ResultOfMultiple = (name) ->
  returnView = null
  view = vm.currentView.subView || vm.currentView
  index = view.orderMap[view.index]

  for candidateView in view.subtestViews[index].prototypeView.questionViews
    if candidateView.model.get("name") == name
      returnView = candidateView
  throw new ReferenceError("ResultOfQuestion could not find variable #{name}") if returnView == null
  
  result = []
  for key, value of returnView.answer
    result.push key if value == "checked" 
  return result

ResultOfPrevious = (name) ->
  view = vm.currentView.subView || vm.currentView
  return view.result.getVariable(name)

ResultOfGrid = (name) ->
  view = vm.currentView.subView || vm.currentView
  return view.result.getItemResultCountByVariableName(name, "correct")

ResultCSV =  (name) ->
  return "hey"

ThisSchool = ( name ) ->
  return "not in workflow" unless vm.currentView.steps
  for step in vm.currentView.steps
    if step?.result?.attributes?.subtestData[0]?.data[name]?
      return step?.result?.attributes?.subtestData[0]?.data[name]

