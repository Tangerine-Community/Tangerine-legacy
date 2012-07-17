# extend every view
Backbone.View.prototype.close = ->
  @remove()
  @unbind()
  @onClose?()

#
# handy jquery functions
#
( ($) -> 

  $.fn.scrollTo = ->
    try
      $('html, body').animate {
        scrollTop: $(@).offset().top + 'px'
        }, 250
    catch e
      console.log e
      console.log "Scroll error with 'this'"
      console.log @

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

  # take a Tangerine "form" and output JSON
  $.fn.serializeSubtest = ->
    result = {}
    $.map $(@).serializeArray(), (element, i) ->
      if result[element.name]?
        if $.isArray result[element.name]
          result[element.name].push element.value
        else
          result[element.name] = [result[element.name], element.value]
      else
        result[element.name] = element.value
    result

)(jQuery)


class MapReduce

  # Only install this on cloud not on data collection devices
  @mapFields: (doc, req) ->

    #recursion!
    concatNodes: (parent,object) ->
      if object instanceof Array
        for value, index in object
          if typeof object != "string"
            concatNodes(parent+"."+index,value)
      else
        typeofobject = typeof object

        if typeofobject == "boolean" or typeofobject == "string" or typeofobject == "number"
          emitDoc = {
            studentID: doc.DateTime?["student-id"]
            fieldname: parent
          }
          if typeofobject == "boolean"
            emitDoc.result = if object then "true" else "false"
          if typeofobject == "string" or typeofobject == "number"
            emitDoc.result = object
          emit doc.assessment, emitDoc
        else
          for key,value of object
            prefix  = (if parent == "" then key else parent + "." + key)
            concatNodes(prefix,value)

    concatNodes("",doc) unless (doc.type? and doc.type is "replicationLog")

  @reduceFields: (keys, values, rereduce) ->
    rv = []
    for key,value of values
      fieldAndResult = {}
      fieldAndResult[value.fieldname] = value.result
      rv.push fieldAndResult
    return rv


String.prototype.safeToSave = ->
  this.replace(/\s|-/g, "_").replace(/[^a-zA-Z0-9_'""]/g,"")

String.prototype.htmlSafe = ->
  $("<div/>").text(this).html().replace(/'/g, "&#39;").replace(/"/g, "&#34;")


class Utils

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
  @getValues: ( selector ) ->
    values = {}
    $(selector).find("input, textarea").each ( index, element ) -> 
      values[element.id] = element.value
    return values

  @cleanURL: (url) ->
    if url.indexOf?("%") != -1 
      url = decodeURIComponent url
    else
      url

  # Should this go another place?
  @importAssessmentFromIris: (dKey) ->
    repOps = 
      'filter' : 'tangerine/downloadFilter'
      'create_target' : true
      'query_params' :
        'dKey' : dKey
    $.couch.replicate Tangerine.iris.host + "/tangerine", "tangerine", { success: (a, b) -> console.log [" success",a, b];}, repOps
    # console.log @importSubtestsFromIris() 

  # Disposable alerts
  @topAlert: (alert_text) ->
    $("<div class='disposable_alert'>#{alert_text}</div>").appendTo("#content").topCenter().delay(2000).fadeOut(250, -> $(this).remove())

  @midAlert: (alert_text) ->
    $("<div class='disposable_alert'>#{alert_text}</div>").appendTo("#content").middleCenter().delay(2000).fadeOut(250, -> $(this).remove())

  @S4: ->
   return ( ( ( 1 + Math.random() ) * 0x10000 ) | 0 ).toString(16).substring(1)

  @guid: ->
   return @S4()+@S4()+"-"+@S4()+"-"+@S4()+"-"+@S4()+"-"+@S4()+@S4()+@S4()

  @flash: ->
    $("body").css "backgroundColor" : "red"
    setTimeout ->
      $("body").css "backgroundColor" : "white"
    , 1000

  @$_GET: (q,s) ->
    vars = {}
    parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, (m,key,value) ->
        value = if ~value.indexOf("#") then value.split("#")[0] else value
        vars[key] = value.split("#")[0];
    )
    vars

  @resizeScrollPane: ->
    $(".scroll_pane").height( $(window).height() - ( $("#navigation").height() + $("#footer").height() + 100) ) 




class Context
  constructor: ->
    # false if it finds "iriscouch" in url
    @mobile = !~(String(window.location).indexOf("iriscouch"))
    # true if "kindle" is in userAgent
    @kindle = /kindle/.test(navigator.userAgent.toLowerCase())
    # true if it finds "iriscouch" in url
    @server = ~(String(window.location).indexOf("iriscouch"))

    @server = true
    @mobile = !@server

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
    $(this).stop().fadeOut 250, ->
      $(this).remove()
  
  # $(window).resize Utils.resizeScrollPane

  # Utils.resizeScrollPane()
