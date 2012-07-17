class AssessmentImportView extends Backbone.View

  events: 
    'click .import' : 'import'
    'click .back'   : 'back'

  back: ->
    Tangerine.router.navigate "", true
    false

  import: ->
    
    # This is supposed to work
#    $.couch.db("tangerine").compact
#      complete: (a,b,c) =>
#        console.log "compact"
#        console.log [a,b,c]

    dKey = @$el.find("#d_key").val()
    @$el.find(".status").fadeIn(250)
    @$el.find("#progress").html "Looking for #{dKey}"
    repOps = 
      'filter' : 'tangerine/importFilter'
      'create_target' : true
      'query_params' :
        'downloadKey' : dKey

    opts =
      success: (a, b) =>
        @$el.find("#progress").html "Import successful <h3>Imported</h3>"
        # this next step is just a test to see everything is there...
        # maybe it doesn't need to. Kind of impressive though.
        $.couch.db("tangerine").view "tangerine/byDKey",
          keys: [dKey]
          success: (data) =>
            questions = 0
            assessments = 0
            subtests = 0
            assessmentName = ""
            for datum in data.rows
              doc = datum.value
              subtests++ if doc.collection == 'subtest'
              questions++ if doc.collection == 'question'  
              assessmentName = doc.name if doc.collection == 'assessment'
            @$el.find("#progress").append "
              <div>#{assessmentName}</div>
              <div>Subtests - #{subtests}</div>
              <div>Questions - #{questions}</div>"

          error: (a, b ,c) ->
            @$el.find("#progress").html "<div>Error after data imported</div><div>#{a}</div><div>#{b}"

      error: (a,b) =>
        @$el.find("#progress").html "<div>Import error</div><div>#{a}</div><div>#{b}"
    
    $.couch.replicate "http://tangerine.iriscouch.com:5984/tangerine", "tangerine", opts, repOps


    false

  render: ->
    @$el.html "
    <button class='back'>Back</button>

    <h1>Tangerine Central Import</h1>
    <div class='question'>
      <label for='d_key'>Download key</label>
      <input id='d_key' value=''>
      <button class='import'>Import</button>
    </div>

    <div class='confirmation status'>
      <h2>Status<h2>
      <div class='info_box' id='progress'></div>
    </div>

    "
    @trigger "rendered"
