class ResultsView extends Backbone.View

  events:
    'click .cloud'   : 'cloud'
    'click .csv'     : 'csv'
    'click .tablets' : 'tablets'
    'click .detect'  : 'detectOptions'

  cloud: ->
    if not @available.cloud
      Utils.midAlert "Cannot detect cloud"
      return false
    @$el.find(".status").find(".info_box").html ""
    ajaxOptions =
      success: =>
        @$el.find(".status").find(".info_box").html "Results uploaded successfully"
        new Log
          type         : "replication"
          event        : "cloud:success"
          assessmentId : @assessment.id
      error: (res) =>
        @$el.find(".status").find(".info_box").html "<div>Upload error</div><div>#{res}</div>"
        new Log
          type         : "replication"
          event        : "cloud:error"
          assessmentId : @assessment.id
    replicationOptions =
      filter: "tangerine/resultFilter"
      query_params:
        assessmentId: @assessment.id
    $.couch.replicate("tangerine", "http://tangerine.iriscouch.com/tangerine", ajaxOptions, replicationOptions)


  tablets: ->
    if not @available.tablets
      Utils.midAlert "Cannot detect cloud"
      return false

  csv: ->
    Tangerine.router.navigate "csv/"+@assessment.id, true

  detectOptions: ->
    @available = 
      cloud : null
      tablets : null
    $.ajax
      dataType: "jsonp"
      url: "http://tangerine.iriscouch.com:5984/"
      success: (a, b) =>
        @available.cloud = true
        @updateOptions()
      error: (a, b) =>
        @available.cloud = false
        @updateOptions()

    @available.tablets = false
    @updateOptions()
        
#    $.ajax
#      dataType: "jsonp"
#      url: "http://127.0.0.2:5984/"
#      success: (a, b) =>
#        @available.tablets = true
#        @updateOptions()
#      error: (a, b) =>
#        @available.tablets = false
#        @updateOptions()
  
  updateOptions: ->
    if @available.cloud 
      @$el.find('button.cloud').removeAttr('disabled')
    if @available.tablets
      @$el.find('button.cloud').removeAttr('disabled')

    if _.isBoolean(@available.cloud) && _.isBoolean(@available.tablets)
      @$el.find(".status .info_box").html "Done detecting options"


  initialize: ( options ) ->
    @detectOptions()
    @results = []
    @subViews = []
    @model = options.model
    @assessment = options.assessment
    allResults = new Results
    allResults.fetch
      key: @assessment.id
      success: (collection) =>
        @results = collection.models
        @render()

  render: ->
    @clearSubViews()

    cloudButton = "<button class='cloud command' disabled='disabled'>Cloud</button>"
    tabletButton = "<button class='tablets command' disabled='disabled'>Tablets</button>"
    csvButton = "<button class='csv command'>CSV</button>"

    html = "
      <h1>#{@assessment.get('name')}</h1>
      <h2>Save options</h2>
      <div class='menu_box'>
        #{if Tangerine.context.mobile then cloudButton  else ""}
        #{if Tangerine.context.mobile then tabletButton else ""}
        #{csvButton}
      </div>"

    if Tangerine.context.mobile
      html += "
        <button class='detect command'>Detect options</button>
        <div class='status'>
          <h2>Status</h2>
          <div class='info_box'></div>
        </div>
        "
    html += "
      <h2>Results</h2>
    "
    
    @$el.html html
    
    
    
    if @results?.length == 0
      @$el.append "No results yet!"
    else
      for result in @results
        view = new ResultSumView model: result
        view.render()
        @subViews.push view
        @$el.append view.el
      
    @trigger "rendered"
  
  afterRender: =>
    for view in @subViews
      view.afterRender?()
      
  clearSubViews:->
    for view in @subViews
      view.close()
    @subViews = []
