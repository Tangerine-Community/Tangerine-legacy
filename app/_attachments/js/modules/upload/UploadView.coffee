class UploadView extends Backbone.View
  className: "UploadView"

  events:
    'click .command.verify'    : 'verify'
    'click .command.save'    : 'save'
    'change .command.upload'  : 'upload'
 
  initialize: ( options ) ->
    @errors = []
    @options = 0
    @questions = 0
    @subtests = 0
    @documents = []
    @activity = null

  upload: (event) ->
    f = event.target.files[0]
    unless f
      alert "Failed to load file"
    else unless f.type.match("text.*")
      alert f.name + " is not a valid text file."
    else
      r = new FileReader()
      r.onloadstart = (e) ->
        console.log "Starting"
        return

      r.onerror = (e) ->
        console.log "Abort!"
        return

      r.onload = (e) ->
        console.log e.target.result
        return

      r.onloadend = (e) ->
        @$el.find('#data').val = e.target.result
        return

      r.readAsText f
    return


  verify: (event) ->
    # The parsing functions are in the Uploader class
    # which is located in helpers.js
    # This class recodes the csv object to the format of
    # documents in the database, so changes to our model
    # should be reflected in that
    err = []
    uploader = new Uploader
    subtests = uploader.CSVToJSON(@$el.find("#data").val(), err)
    return if subtests.length == 0
    @documents = uploader.generateAssessment(subtests, err)
    @errors = err
    @questions = uploader.totalQuestions
    @options = uploader.totalOptions
    @subtests = uploader.totalSubtests
    @refreshReviewer()
    if @errors.length == 0 && @subtests > 0
      @$el.find("#verifyOrSaveButton").html "<button class='command save' id='save-button'>Save Assessment</button>"

  save: (event) ->
    return false unless @activity == null

    for document in @documents
      model = switch 
        when document.collection == "question" then new Question
        when document.collection == "subtest"   then new Subtest
        when document.collection == "assessment" then new Assessment
      model.set(document)
      @activity = "saving"
      model.save null,
        success: =>
          @activity = null
          Utils.topAlert "Saved!"
        error: =>
          @activity = null
          Utils.topAlert "Save error (probably already saved)"
    return false

    

  refreshReviewer: () ->
    @$el.find(".reviewer-wrapper").html @getReviewerHTML()

  getReviewerHTML: () ->
    errorlist = ""
    errorlist += "<li><div class='alert alert-warning text-left'>#{error}</div></li>" for error in @errors
    if @errors.length > 0
      errorPanelHTML = "<div class='clearfix container row col-xs-12'>
        <div class='col-lg-12'>
          <div class='panel panel-danger' id='error-panel'>
            <div class='panel-heading'>
              <div class='row'>
                <div class='col-xs-3'>
                  <i class='fa fa-warning fa-5x'></i>
                </div>
                <div class='col-xs-9'>
                  <div class='text-right'>
                    <div class='huge' id=num_errors >#{@errors.length}</div>
                    <div>Errors:</div>
                  </div>
                </div>
              </div>
            </div>
            <div class='panel-body'>
              <ul>
                #{errorlist}
              </ul>
            </div>
            <div class='panel-footer'>
              Once there are no errors, you can submit the assessment
            </div>
          </div>
        </div> "
    else
      errorPanelHTML = ''

    html = "
      <h1>Reviewer</h1>
      <hr>

      <div class='clearfix container row col-xs-12'>
        <div class='col-lg-4 col-md-6'>
          <div class='panel panel-primary' id='subtest-panel'>
            <div class='panel-heading'>
              <div class='row'>
                <div class='col-xs-3'>
                  <i class='fa fa-list-alt fa-5x'></i>
                </div>
                <div class='col-xs-9'>
                  <div class='text-right'>
                    <div class='huge' id='number-subtests-loaded'>#{@subtests}</div>
                    <div>Subtests!</div>
                  </div>
                </div>
              </div>
            </div>
            <div class='panel-footer'>
              <i>Subtests make up assessments</i>
            </div>
          </div>
        </div> 
        <div class='col-lg-4 col-md-6'>
          <div class='panel panel-green' id='question-panel'>
            <div class='panel-heading'>
              <div class='row'>
                <div class='col-xs-3'>
                  <i class='fa fa-question-circle fa-5x'/>
                </div>
                <div class='col-xs-9'>
                  <div class='text-right'>
                    <div class='huge' id='number-questions-loaded'>#{@questions}</div>
                    <div>Questions!</div>
                  </div>
                </div>
              </div>
            </div>
            <div class='panel-footer'>
              <i>Questions comprise subtests</i>
            </div>
          </div>
        </div>
        <div class='col-lg-4 col-md-6'>
          <div class='panel panel-orange' id='option-panel'>
            <div class='panel-heading'>
              <div class='row'>
                <div class='col-xs-3'>
                  <i class='fa fa-info fa-5x'/>
                </div>
                <div class='col-xs-9'>
                  <div class='text-right'>
                    <div class='huge' id='number-options-loaded'>#{@options}</div>
                    <div>Options!</div>
                  </div>
                </div>
              </div>
            </div>
            <div class='panel-footer'>
              <i>Options are part of questions</i>
            </div>
          </div>
        </div>
      </div>

      #{errorPanelHTML}
      </div>
      "
    return html

  getFileSelectorHTML: () ->
    # There is a weird error that occurs in Tangerine, but not when the HTML/event is called alone
    # It should just upload like you expect, but what happens instead is an alert appears with 
    # technical information about the file, along with a text field filled with some gibberish parameters
    # and the user can press 'Cancel' or 'Okay'
    # On 'Cancel', the console logs an error: 'SyntaxError: Cannot read property length of undefined'
    # On 'Okay', the console logs an error: 'SyntaxError': Unexpected token ':'
    # So for now, clients will just have to highlight copy
    # return "<input class='command upload' type='file' id='fileinput'></input>"
    return ""

  render: ->
    @$el.html "
          <link rel='stylesheet' href='//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css'>          
          <link href='//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css' rel='stylesheet'>
          <style>
          #verifyOrSaveButton
          {
            float:right
          }

          .panel-green {
            border-color: #5cb85c;
          }
          .panel-green > .panel-heading {
            color: #fff;
            background-color: #5cb85c;
            border-color: #5cb85c;
          }
          .panel-green > .panel-heading + .panel-collapse > .panel-body {
            border-top-color: #5cb85c;
          }
          .panel-green > .panel-heading .badge {
            color: #5cb85c;
            background-color: #fff;
          }
          .panel-green > .panel-footer + .panel-collapse > .panel-body {
            border-bottom-color: #5cb85c;
          }

          .panel-orange {
            border-color: #f0ad4e;
          }
          .panel-orange > .panel-heading {
            color: #fff;
            background-color: #f0ad4e;
            border-color: #f0ad4e;
          }
          .panel-orange > .panel-heading + .panel-collapse > .panel-body {
            border-top-color: #f0ad4e;
          }
          .panel-orange > .panel-heading .badge {
            color: #f0ad4e;
            background-color: #fff;
          }
          .panel-orange > .panel-footer + .panel-collapse > .panel-body {
            border-bottom-color: #f0ad4e;
          }

          .fa-5x {
            font-size: 5em;
          }

          .huge {
            font-size: 50px;
            line-height: normal;
          }
          </style>

          <div class='clearfix container row'>
            <div class='uploader-wrapper col-lg-3'>
              <h1 class='text-center'>Uploader</h1>
              <hr>
              Copycat the csv file into the text box below. Once you've verified that your information is correct, and then click submit!
              <textarea id=data></textarea><br>
              #{@getFileSelectorHTML()}
              <div id=verifyOrSaveButton>
                <button class='command verify' id='verify-button'>Verify</button>
              </div>
            </div>


            <div class='text-center reviewer-wrapper col-lg-9'>
              #{@getReviewerHTML()}
            </div>
          </div>
      "
    
    @trigger "rendered"

  getExtraCSS: ()->
    return ''
