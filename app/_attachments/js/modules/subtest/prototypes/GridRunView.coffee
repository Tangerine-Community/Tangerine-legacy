class GridRunView extends Backbone.View

  className: "grid_prototype"

  events: if Tangerine.context.kindle then {
    'touchstart .grid_element' : 'gridClick'
    'touchstart .end_of_grid_line' : 'endOfGridLineClick'
    'click .grid_mode input'   : 'updateMode'
    'click .start_time'        : 'startTimer'
    'click .stop_time'         : 'stopTimer'
    'click .restart'         : 'restartTimer'
  } else {
    'click .end_of_grid_line' : 'endOfGridLineClick'
    'click .grid_element'    : 'gridClick'
    'click .grid_mode input' : 'updateMode'
    'click .start_time'      : 'startTimer'
    'click .stop_time'       : 'stopTimer'
    'click .restart'         : 'restartTimer'
  }
  
  restartTimer: ->
    @resetVariables()
    @$el.find(".element_wrong").removeClass "element_wrong"


  gridClick: (event) ->
    @modeHandlers[@mode]?(event)

  markHandler: (event) =>
    $target = $(event.target)
    index = $target.attr('data-index')
    if @lastAttempted != 0 && index > @lastAttempted
      return
    @markElement(index)
    if @autostop != 0
      @checkAutostop()
      
  checkAutostop: ->
    if @timeRunning
      autoCount = 0
      for i in [0..@autostop-1]
        if @gridOutput[i] == "correct" then break
        autoCount++
      if @autostopped == false
        if autoCount == @autostop then @autostopTest()
      if @autostopped == true && autoCount < @autostop && @undoable == true then @unAutostopTest()

  markElement: (index, value = null) ->
    $target = @$el.find("div.grid_element[data-index=#{index}]")
    @markRecord.push index
    if value == null
      @gridOutput[index-1] = if (@gridOutput[index-1] == "correct" || @autostopped) then "incorrect" else "correct"
      $target.toggleClass "element_wrong"
    else
      if !@autostopped || value == "correct"
        @gridOutput[index-1] = value
        if value == "incorrect"
          $target.addClass "element_wrong"
        else if value == "correct"
          $target.removeClass "element_wrong"
        
  endOfGridLineClick: (event) ->
    if @mode == "mark"
      $target = $(event.target)
      if $target.hasClass("element_wrong") 
        $target.removeClass "element_wrong" 
        value = "correct"
        index = $target.attr('data-index')
        for i in [index..(index-(@columns-1))]
          @markElement i, value
      else if !$target.hasClass("element_wrong") && !@autostopped
        $target.addClass "element_wrong"
        value = "incorrect"
        index = $target.attr('data-index')
        for i in [index..(index-(@columns-1))]
          @markElement i, value
      if @autostop != 0
        @checkAutostop()

  lastHandler: (event) =>
    $target = $(event.target)
    index = $target.attr('data-index')
    if index - 1 >= @gridOutput.lastIndexOf("incorrect")
      @$el.find("table.grid .element_last").removeClass "element_last"
      $target.addClass "element_last"
      @lastAttempted = index

  startTimer: ->
    if @timerStopped == false && @timeRunning == false
      @updateMode null, "mark"
      @interval = setInterval(@updateCountdown,1000 )
      @startTime = @getTime()
      @timeRunning = true
      @$el.find("table.disabled").removeClass("disabled")
      @updateCountdown()

  stopTimer: (event, message = false) ->
    if @timeRunning == true
      Utils.flash()
      clearInterval @interval
      @stopTime = @getTime()
      @timeRunning = false
      @timerStopped = true
      @updateCountdown()
      @updateMode null, "last"
      if message
        Utils.topAlert message
      else
        Utils.midAlert "Please mark <br>last item attempted"

  autostopTest: ->
    Utils.flash()
    clearInterval @interval
    @stopTime = @getTime()
    @autostopped = true
    @timerStopped = true
    @timeRunning = false
    @$el.find(".grid_element").slice(@autostop-1,@autostop).addClass "element_last" #jquery is weird sometimes
    @lastAttempted = @autostop
    @timeout = setTimeout(@removeUndo, 3000) # give them 3 seconds to undo
    Utils.topAlert "Autostop activated. Discontinue test."

  removeUndo: =>
    @undoable = false
    @updateMode null, "disabled"
    clearTimeout(@timeout)

  unAutostopTest: ->
    @interval = setInterval(@updateCountdown,1000 )
    @updateCountdown()
    @autostopped = false
    @lastAttempted = 0
    @$el.find(".grid_element").slice(@autostop-1,@autostop).removeClass "element_last"
    @timeRunning = true
    @updateMode null, "mark"
    Utils.topAlert "Autostop removed. Continue."

  updateCountdown: =>
    @timeElapsed = @getTime() - @startTime
    @timeRemaining = @timer - @timeElapsed
    
    @$el.find(".timer").html @timeRemaining
    if @timeRemaining <= 0 && @timeRunning == true then @stopTimer null, "Time<br><br>Please mark<br>last item attempted"

  updateMode: (event, mode) =>
    if mode?
      @mode = mode
      @$el.find("#grid_mode :radio[value=#{mode}]").attr("checked", "checked")
      @$el.find("#grid_mode").buttonset("refresh").click @updateMode
      return
    @mode = $(event.target).val() unless @autostopped

  getTime: ->
    Math.round((new Date()).getTime() / 1000)

  resetVariables: ->

    @markRecord = []

    @timerStopped = false

    @startTime = 0
    @stopTime  = 0
    @timeElapsed = 0
    @timeRemaining = @timer
    @lastAttempted = 0

    @interval = null

    @undoable = true

    @timeRunning = false

    @timer    = parseInt(@model.get("timer")) || 0
    @items    = _.compact(@model.get("items")) # mild sanitization, happens at save too
    @mode     = "disabled"
    @gridOutput = []
    for item, i in @items
      @gridOutput[i] = 'correct'
    @columns  = parseInt(@model.get("columns")) || 0

    @autostop = parseInt(@model.get("autostop")) || 0
    @autostopped = false

    @$el.find(".grid_element").removeClass("element_wrong").removeClass("element_last").addClass("disabled")
    @$el.find("table").addClass("disabled")
    
    @$el.find(".timer").html @timer
    
    @updateMode(@mode)

  initialize: (options) ->

    @totalTime = @model.get("timer") || 0

    @modeHandlers =
      mark : @markHandler
      last : @lastHandler
      disabled : $.noop
      
    @model  = @options.model
    @parent = @options.parent

    @resetVariables()

    @gridElement = _.template "<td><div data-label='{{label}}' data-index='{{i}}' class='grid_element'>{{label}}</div></td>"
    @endOfGridLine = _.template "<td><div data-index='{{i}}' class='end_of_grid_line'>*</div></td>"

  render: ->
    done = 0
    html = "
    
    <div class='timer_wrapper'><button class='start_time time'>Start</button><div class='timer'>#{@timer}</div></div>
    <table class='grid disabled'>"
    loop
      break if done > @items.length
      html += "<tr>"
      for i in [1..@columns]
        if done < @items.length
          html += @gridElement { label : _.escape(@items[done]), i: done+1 }
        done++
      html += @endOfGridLine({i:done}) if done < ( @items.length + 1 )
      html += "</tr>"
    html += "</table>
    
    <div class='timer_wrapper'><button class='stop_time time'>Stop</button><div class='timer'>#{@timer}</div></div>
    <div>
          <button class='restart command'>Restart</button>
          <br>
    </div>
    
    <div id='grid_mode' class='question buttonset clearfix'>
      <label>Input mode</label><br>
      <label for='mark'>Mark</label>
      <input name='grid_mode' id='mark' type='radio' value='mark' checked='checked'>
      <label for='last_attempted'>Last attempted</label>
      <input name='grid_mode' id='last_attempted' type='radio' value='last'>
    </div>

    "

    @$el.html html

    @trigger "rendered"
    
  isValid: ->
    if @lastAttempted == 0 then return false
    if @timeRunning == true then return false
    true
    
  showErrors: ->
    Utils.midAlert "Please touch<br>last item read." if @lastAttempted == 0
    Utils.midAlert "Time still running." if @timeRuning == true
  
  getResult: ->
    itemResults = []
    for item, i in @items
      if i < @lastAttempted
        itemResults[i] = @gridOutput[i]
      else
        itemResults[i] = "missing"

    result =
      "auto_stop"     : @autostopped
      "attempted"     : @lastAttempted
      "items"         : itemResults
      "time_remain"   : @timeRemaining
      "mark_record"   : @markRecord
      "variable_name" : @model.get("variableName")

  getSkippedResult: ->
    return "skipped"

  onClose: ->
    clearInterval(@interval)

  getSum: ->
    counts =
      correct   : 0
      incorrect : 0
      missing   : @items.length - @lastAttempted
      total     : @items.length

    for i in @gridOutput
      counts['correct']   += 1 if i == "correct"
      counts['incorrect'] += 1 if i == "incorrect"
      
    return {
      correct   : counts['correct']
      incorrect : counts['incorrect']
      missing   : counts['missing']
      total     : counts['total']
    }

