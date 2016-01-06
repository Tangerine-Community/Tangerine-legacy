class Router extends Backbone.Router
  routes:
    'login'    : 'login'
    'register' : 'register'
    'logout'   : 'logout'
    'account'  : 'account'

    'transfer' : 'transfer'

    'settings' : 'settings'
    'update' : 'update'

    '' : 'landing'

    'footer' : 'footer'

    'reload' : 'reload'

    'logs' : 'logs'

    # Tutor

    'workflow/edit/:workflowId' : 'workflowEdit'
    'workflow/run/:workflowId'  : 'workflowRun'
    'workflow/resume/:workflowId/:tripId'  : 'workflowResume'

    'feedback/edit/:workflowId' : 'feedbackEdit'
    'feedback/:workflowId'      : 'feedback'

    'tutor-account' : 'tutorAccount'
    'tutor-account/:tab' : 'tutorAccount'

    'tutor-menu'      : 'tutorMenu'
    'tutor-menu/:tab' : 'tutorMenu'

    # Class
    'class'          : 'klass'
    'class/edit/:id' : 'klassEdit'
    'class/student/:studentId'        : 'studentEdit'
    'class/student/report/:studentId' : 'studentReport'
    'class/subtest/:id' : 'editKlassSubtest'
    'class/question/:id' : "editKlassQuestion"

    'class/:id/:part' : 'klassPartly'
    'class/:id'       : 'klassPartly'

    'class/run/:studentId/:subtestId' : 'runSubtest'

    'class/result/student/subtest/:studentId/:subtestId' : 'studentSubtest'

    'curricula'         : 'curricula'
    'curriculum/:id'    : 'curriculum'
    'curriculumImport'  : 'curriculumImport'

    'report/klassGrouping/:klassId/:part' : 'klassGrouping'
    'report/masteryCheck/:studentId'      : 'masteryCheck'
    'report/progress/:studentId/:klassId' : 'progressReport'

    'teachers' : 'teachers'


    # server / mobile
    'groups' : 'groups'

    'assessments'        : 'assessments'

    'run/:id'       : 'run'
    'print/:id/:format'       : 'print'
    'dataEntry/:id' : 'dataEntry'

    'resume/:assessmentId/:resultId'    : 'resume'
    
    'restart/:id'   : 'restart'
    'edit/:id'      : 'edit'
    'results/:id'   : 'results'
    'import'        : 'import'
    
    'subtest/:id'       : 'editSubtest'

    'question/:id' : 'editQuestion'

    'dashboard'          : 'dashboard'
    'dashboard/*options' : 'dashboard'

    'primr_dashboard'          : 'primrDashboard'
    'primr_dashboard/*options' : 'primrDashboard'

    'result/:resultId' : 'result'

    'email' : 'email'
    'reportUser/:id' : 'editReportUser'

    'sync/:id'      : 'sync'

  footer: ->
    vm.show new FooterView

  reload: ->
    @navigate '', false
    window.location.reload()

  tutorAccount: ( tab = 'edit-user' ) ->
    Tangerine.user.verify
      isAuthenticated: ->
        vm.show((new TutorAccountView selectedTab : tab) , true)

  tutorMenu: ( tab ) ->
    Tangerine.user.verify
      isAuthenticated: ->
        vm.show((new TutorMenuView) , true)

  email: ->
    Tangerine.user.verify
      isAdmin: ->
        vm.show new EmailManagerView

  editReportUser: ( reportUserId ) ->
    throw URIError unless reportUserId?
    Tangerine.user.verify
      isAdmin: ->
        user = new ReportUser "_id" : reportUserId
        user.fetch
          success: ->
            vm.show new ReportUserEditView user : user

  primrDashboard: (options) ->
    Tangerine.user.verify
      isAuthenticated: ->

        #default view options
        reportViewOptions =
          startTime: moment().subtract('weeks',1).format("YYYY-MM-DD")
          endTime: moment().format("YYYY-MM-DD HH:mm:ss")
          groupBy: "Location: County"
          workflow: "All"
          location: "All"


        unless options?
          urlOptions = _(reportViewOptions).map (value,option) ->
            "/#{option}/#{value}"
          .join("")
          Tangerine.router.navigate "primr_dashboard#{urlOptions}", true

        options = options?.split(/\//)
        # Allows us to get name/value pairs from URL
        _.each options, (option,index) ->
          unless index % 2
            reportViewOptions[option] = options[index+1]

        view = new PrimrDashboardView()
        view.options = reportViewOptions
        vm.show view


  result: (resultId) ->
    # Pretty much a hack. Should add to this so it can show appropriate results based on result tyep
    # Location should show a map
    # timer based results should give results per minute, etc


    Tangerine.user.verify
      isAuthenticated: ->
        Tangerine.$db.view "#{Tangerine.design_doc}/csvRows",
          key: resultId,
          success: (result) ->

            syntaxHighlight = (json) =>
              window.json = json
              if (typeof json != 'string')
                 json = JSON.stringify(json, undefined, 2)
              json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
              return json.replace /("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, (match) ->
                cls = 'number'
                if (/^"/.test(match))
                  if (/:$/.test(match))
                    cls = 'key'
                  else
                    cls = 'string'
                else if (/true|false/.test(match))
                  cls = 'boolean'
                else if (/null/.test(match))
                  cls = 'null'
                return '<span class="' + cls + '">' + match + '</span>'

            $("#content").html "
              <style>
                .string { color: green; }
                .number { color: darkorange; }
                .boolean { color: blue; }
                .null { color: magenta; }
                .key { color: red; }
              </style>
              <b>Raw Data</b><br>
              <pre>
              #{syntaxHighlight (result.rows?[0]?.value)}
              </pre>
            "
            

  dashboard: (options) ->
    Tangerine.user.verify
      isAuthenticated: ->

        options = options?.split(/\//)
        #default view options
        reportViewOptions =
          assessment: "All"
          groupBy: "enumerator"

        # Allows us to get name/value pairs from URL
        _.each options, (option,index) ->
          unless index % 2
            reportViewOptions[option] = options[index+1]

        view = new DashboardView()
        view.options = reportViewOptions
        vm.show view

  workflowEdit: ( workflowId ) ->
    Tangerine.user.verify
      isAuthenticated: ->

        workflow = new Workflow "_id" : workflowId
        workflow.fetch
          success: ->
            view = new WorkflowEditView workflow : workflow
            vm.show view

  feedbackEdit: ( workflowId ) ->
    Tangerine.user.verify
      isAuthenticated: ->

        showFeedbackEditor = ( feedback, workflow ) ->
          feedback.updateCollection()
          view = new FeedbackEditView
            feedback: feedback
            workflow: workflow
          vm.show view

        workflow = new Workflow "_id" : workflowId
        workflow.fetch
          success: ->
            feedbackId = "#{workflowId}-feedback"
            feedback   = new Feedback "_id" : feedbackId
            feedback.fetch
              error:   -> feedback.save null, success: -> showFeedbackEditor(feedback, workflow)
              success: -> showFeedbackEditor(feedback, workflow)

  feedback: ( workflowId ) ->
    Tangerine.user.verify
      isAuthenticated: ->

        workflow = new Workflow "_id" : workflowId
        workflow.fetch
          success: ->
            feedbackId = "#{workflowId}-feedback"
            feedback = new Feedback "_id" : feedbackId
            feedback.fetch
              error: -> Utils.midAlert "No feedback defined"
              success: ->
                feedback.updateCollection()
                view = new FeedbackTripsView
                  feedback : feedback
                  workflow : workflow
                vm.show view




  workflowRun: ( workflowId ) ->
    Tangerine.user.verify
      isAuthenticated: ->

        workflow = new Workflow "_id" : workflowId
        workflow.fetch
          success: ->
            workflow.updateCollection()
            view = new WorkflowRunView
              workflow: workflow
            vm.show view

  workflowResume: ( workflowId, tripId ) ->
    Tangerine.user.verify
      isAuthenticated: ->

        workflow = new Workflow "_id" : workflowId
        workflow.fetch
          success: ->
            Tangerine.$db.view Tangerine.design_doc+"/tripsAndUsers",
              key: tripId
              include_docs: true
              success: (data) ->
                index = Math.max(data.rows.length - 1, 0)

                # add old results
                steps = []
                for j in [0..index]
                  steps.push {result : new Result data.rows[j].doc}

                assessmentResumeIndex = data.rows[index]?.doc?.subtestData?.length || 0

                ###
                  if data.rows[index]?.doc?.order_map?
                  # save the order map of previous randomization
                  orderMap = result.get("order_map").slice() # clone array
                  # restore the previous ordermap
                  view.orderMap = orderMap

                ###

                workflow = new Workflow "_id" : workflowId
                workflow.fetch
                  success: ->

                    incomplete = Tangerine.user.getPreferences("tutor-workflows", "incomplete")

                    incomplete[workflowId] = _(incomplete[workflowId]).without tripId

                    Tangerine.user.getPreferences("tutor-workflows", "incomplete", incomplete)

                    workflow.updateCollection()
                    view = new WorkflowRunView
                      assessmentResumeIndex : assessmentResumeIndex
                      workflow: workflow
                      tripId  : tripId
                      index   : index
                      steps   : steps
                    vm.show view



  landing: (refresh = false) ->

    callFunction = not refresh

    Tangerine.settings.contextualize
      server: ->
        if ~String(window.location.href).indexOf("t/_design") # in main group?
          Tangerine.router.navigate "groups", callFunction
        else
          Tangerine.router.navigate "assessments", callFunction
      satellite: ->
        Tangerine.router.navigate "assessments", callFunction
      mobile: ->
        Tangerine.router.navigate "tutor-menu", callFunction
      klass: ->
        Tangerine.router.navigate "class", callFunction

    document.location.reload() if refresh

  groups: ->
    Tangerine.user.verify
      isAuthenticated: ->
        view = new GroupsView
        vm.show view

  #
  # Class
  #
  curricula: ->
    Tangerine.user.verify
      isAuthenticated: ->
        curricula = new Curricula
        curricula.fetch
          success: (collection) ->
            view = new CurriculaView
              "curricula" : collection
            vm.show view

  curriculum: (curriculumId) ->
    Tangerine.user.verify
      isAuthenticated: ->
        curriculum = new Curriculum "_id" : curriculumId
        curriculum.fetch
          success: ->
            allSubtests = new Subtests
            allSubtests.fetch
              success: ->
                subtests = new Subtests allSubtests.where "curriculumId" : curriculumId
                allQuestions = new Questions
                allQuestions.fetch
                  success: ->
                    questions = []
                    subtests.each (subtest) -> questions = questions.concat(allQuestions.where "subtestId" : subtest.id )
                    questions = new Questions questions
                    view = new CurriculumView
                      "curriculum" : curriculum
                      "subtests"   : subtests
                      "questions"  : questions

                    vm.show view


  curriculumEdit: (curriculumId) ->
    Tangerine.user.verify
      isAuthenticated: ->
        curriculum = new Curriculum "_id" : curriculumId
        curriculum.fetch
          success: ->
            allSubtests = new Subtests
            allSubtests.fetch
              success: ->
                subtests = allSubtests.where "curriculumId" : curriculumId
                allParts = (subtest.get("part") for subtest in subtests)
                partCount = Math.max.apply Math, allParts 
                view = new CurriculumView
                  "curriculum" : curriculum
                  "subtests" : subtests
                  "parts" : partCount
                vm.show view


  curriculumImport: ->
    Tangerine.user.verify
      isAuthenticated: ->
        view = new AssessmentImportView
          noun : "curriculum"
        vm.show view

  klass: ->
    Tangerine.user.verify
      isAuthenticated: ->
        allKlasses = new Klasses
        allKlasses.fetch
          success: ( klassCollection ) ->
            teachers = new Teachers
            teachers.fetch
              success: ->
                allCurricula = new Curricula
                allCurricula.fetch
                  success: ( curriculaCollection ) ->
                    if not Tangerine.user.isAdmin()
                      klassCollection = new Klasses klassCollection.where("teacherId" : Tangerine.user.get("teacherId"))
                    view = new KlassesView
                      klasses   : klassCollection
                      curricula : curriculaCollection
                      teachers  : teachers
                    vm.show view

  klassEdit: (id) ->
    Tangerine.user.verify
      isAuthenticated: ->
        klass = new Klass _id : id
        klass.fetch
          success: ( model ) ->
            teachers = new Teachers
            teachers.fetch
              success: ->
                allStudents = new Students
                allStudents.fetch
                  success: (allStudents) ->
                    klassStudents = new Students allStudents.where {klassId : id}
                    view = new KlassEditView
                      klass       : model
                      students    : klassStudents
                      allStudents : allStudents
                      teachers    : teachers
                    vm.show view

  klassPartly: (klassId, part=null) ->
    Tangerine.user.verify
      isAuthenticated: ->
        klass = new Klass "_id" : klassId
        klass.fetch
          success: ->
            curriculum = new Curriculum "_id" : klass.get("curriculumId")
            curriculum.fetch
              success: ->
                allStudents = new Students
                allStudents.fetch
                  success: (collection) ->
                    students = new Students ( collection.where( "klassId" : klassId ) )

                    allResults = new KlassResults
                    allResults.fetch
                      success: (collection) ->
                        results = new KlassResults ( collection.where( "klassId" : klassId ) )

                        allSubtests = new Subtests
                        allSubtests.fetch
                          success: (collection ) ->
                            subtests = new Subtests ( collection.where( "curriculumId" : klass.get("curriculumId") ) )
                            view = new KlassPartlyView
                              "part"       : part
                              "subtests"   : subtests
                              "results"    : results
                              "students"   : students
                              "curriculum" : curriculum
                              "klass"      : klass
                            vm.show view


  studentSubtest: (studentId, subtestId) ->
    Tangerine.user.verify
      isAuthenticated: ->
        student = new Student "_id" : studentId
        student.fetch
          success: ->
            subtest = new Subtest "_id" : subtestId
            subtest.fetch
              success: ->
                Tangerine.$db.view "#{Tangerine.design_doc}/resultsByStudentSubtest",
                  key : [studentId,subtestId]
                  success: (response) =>
                    allResults = new KlassResults 
                    allResults.fetch
                      success: (collection) ->
                        results = collection.where
                          "subtestId" : subtestId
                          "studentId" : studentId
                          "klassId"   : student.get("klassId")
                        view = new KlassSubtestResultView
                          "allResults" : allResults
                          "results"  : results
                          "subtest"  : subtest
                          "student"  : student
                          "previous" : response.rows.length
                        vm.show view

  runSubtest: (studentId, subtestId) ->
    Tangerine.user.verify
      isAuthenticated: ->
        subtest = new Subtest "_id" : subtestId
        subtest.fetch
          success: ->
            student = new Student "_id" : studentId

            # this function for later, real code below
            onStudentReady = (student, subtest) ->
              student.fetch
                success: ->

                  # this function for later, real code below
                  onSuccess = (student, subtest, question=null, linkedResult={}) ->
                    view = new KlassSubtestRunView
                      "student"      : student
                      "subtest"      : subtest
                      "questions"    : questions
                      "linkedResult" : linkedResult
                    vm.show view

                  questions = null
                  if subtest.get("prototype") == "survey"
                    Tangerine.$db.view "#{Tangerine.design_doc}/resultsByStudentSubtest",
                      key : [studentId,subtest.get("gridLinkId")]
                      success: (response) =>
                        if response.rows != 0
                          linkedResult = new KlassResult _.last(response.rows)?.value
                        questions = new Questions
                        questions.fetch
                          key: subtest.get("curriculumId")
                          success: ->
                            questions = new Questions(questions.where {subtestId : subtestId })
                            onSuccess(student, subtest, questions, linkedResult)
                  else
                    onSuccess(student, subtest)
              # end of onStudentReady

            if studentId == "test"
              student.fetch
                success: -> onStudentReady( student, subtest)
                error: ->
                  student.save null,
                    success: -> onStudentReady( student, subtest)
            else
              student.fetch
                success: ->
                  onStudentReady(student, subtest)

  register: ->
    Tangerine.user.verify
      isUnregistered: ->
        view = new RegisterTeacherView
          user : new User
        vm.show view
      isAuthenticated: ->
        Tangerine.router.landing()

  studentEdit: ( studentId ) ->
    Tangerine.user.verify
      isAuthenticated: ->
        student = new Student _id : studentId
        student.fetch
          success: (model) ->
            allKlasses = new Klasses
            allKlasses.fetch
              success: ( klassCollection )->
                view = new StudentEditView
                  student : model
                  klasses : klassCollection
                vm.show view


  #
  # Assessment
  #


  dataEntry: ( assessmentId ) ->
    Tangerine.user.verify
      isAdmin: ->    
        assessment = new Assessment "_id" : assessmentId
        assessment.fetch
          success: ->
            questions = new Questions
            questions.fetch
              key: assessmentId
              success: ->
                questionsByParentId = questions.indexBy("subtestId")
                for subtestId, questions of questionsByParentId
                  assessment.subtests.get(subtestId).questions = new Questions questions
                vm.show new AssessmentDataEntryView assessment: assessment



  sync: ( assessmentId ) ->
    Tangerine.user.verify
      isAdmin: ->    
        assessment = new Assessment "_id" : assessmentId
        assessment.fetch
          success: ->
            vm.show new AssessmentSyncView "assessment": assessment

  import: ->
    Tangerine.user.verify
      isAuthenticated: ->
        view = new AssessmentImportView
          noun :"assessment"
        vm.show view

  assessments: ->
    Tangerine.user.verify
      isAuthenticated: ->
        (workflows = new Workflows).fetch
          success: ->

            if workflows.length > 0 && Tangerine.settings.get("context") isnt "server"

              feedbacks = new Feedbacks feedbacks
              feedbacks.fetch
                success: ->
                  view = new WorkflowMenuView
                    workflows : workflows
                    feedbacks : feedbacks

                  return vm.show view

              return

            collections = [
              "Klasses"
              "Teachers"
              "Curricula"
              "Assessments"
              "Workflows"
            ]

            collections.push if "server" == Tangerine.settings.get("context") then "Users" else "TabletUsers"

            Utils.loadCollections
              collections: collections
              complete: (options) ->
                # load feedback models associated with workflows
                feedbacks = options.workflows.models.map (a) -> new Feedback "_id" : "#{a.id}-feedback"
                feedbacks = new Feedbacks feedbacks
                feedbacks.fetch
                  success: ->
                    options.feedbacks = feedbacks
                    options.users = options.tabletUsers || options.users
                    vm.show new AssessmentsMenuView options

  editId: (id) ->
    id = Utils.cleanURL id
    Tangerine.user.verify
      isAdmin: ->
        assessment = new Assessment
          _id: id
        assessment.superFetch
          success : ( model ) ->
            view = new AssessmentEditView model: model
            vm.show view
      isUser: ->
        Tangerine.router.landing()


  edit: (id) ->
    Tangerine.user.verify
      isAdmin: ->    
        assessment = new Assessment
          "_id" : id
        assessment.fetch
          success : ( model ) ->
            view = new AssessmentEditView model: model
            vm.show view
      isUser: ->
        Tangerine.router.landing()

  restart: (name) ->
    Tangerine.router.navigate "run/#{name}", true

  run: (id) ->
    Tangerine.user.verify
      isAuthenticated: ->
        assessment = new Assessment
          "_id" : id
        assessment.fetch
          success : ( model ) ->
            view = new AssessmentRunView model: model
            vm.show view

  print: ( assessmentId, format ) ->
    Tangerine.user.verify
      isAuthenticated: ->
        assessment = new Assessment
          "_id" : assessmentId
        assessment.fetch
          success : ( model ) ->
            view = new AssessmentPrintView
              model  : model
              format : format
            vm.show view

  resume: (assessmentId, resultId) ->
    Tangerine.user.verify
      isAuthenticated: ->
        assessment = new Assessment
          "_id" : assessmentId
        assessment.fetch
          success : ( assessment ) ->
            result = new Result
              "_id" : resultId
            result.fetch
              success: (result) ->
                view = new AssessmentRunView 
                  model: assessment

                if result.has("order_map")
                  # save the order map of previous randomization
                  orderMap = result.get("order_map").slice() # clone array
                  # restore the previous ordermap
                  view.orderMap = orderMap

                for subtest in result.get("subtestData")
                  if subtest.data? && subtest.data.participant_id?
                    Tangerine.nav.setStudent subtest.data.participant_id

                # replace the view's result with our old one
                view.result = result

                # Hijack the normal Result and ResultView, use one from the db 
                view.subtestViews.pop()
                view.subtestViews.push new ResultView
                  model          : result
                  assessment     : assessment
                  assessmentView : view
                view.index = result.get("subtestData").length
                vm.show view



  results: (assessmentId) ->
    Tangerine.user.verify
      isAuthenticated: ->
        afterFetch = (assessment = new Assessment("_id":assessmentId), assessmentId) ->
          allResults = new Results
          allResults.fetch
            include_docs: false
            key: assessmentId
            success: (results) =>
              view = new ResultsView
                "assessment" : assessment
                "results"    : results.models
              vm.show view

        assessment = new Assessment
          "_id" : assessmentId
        assessment.fetch
          success :  ->
            console.log "success"
            afterFetch(assessment, assessmentId)
          error :  ->
            console.log "eerror"
            afterFetch(assessment, assessmentId)

  csv: (id) ->
    Tangerine.user.verify
      isAdmin: ->
        view = new CSVView
          assessmentId : id
        vm.show view

  csv_alpha: (id) ->
    Tangerine.user.verify
      isAdmin: ->
        assessment = new Assessment
          "_id" : id
        assessment.fetch
          success :  ->
            filename = assessment.get("name") + "-" + moment().format("YYYY-MMM-DD HH:mm")
            document.location = "/" + Tangerine.db_name + "/_design/" + Tangerine.designDoc + "/_list/csv/csvRowByResult?key=\"#{id}\"&filename=#{filename}"
        
      isUser: ->
        errView = new ErrorView
          message : "You're not an admin user"
          details : "How did you get here?"
        vm.show errView

  #
  # Reports
  #
  klassGrouping: (klassId, part) ->
    part = parseInt(part)
    Tangerine.user.verify
      isAuthenticated: ->
        allResults = new KlassResults
        allResults.fetch
          success: ( results ) ->
            results = new KlassResults results.where "klassId" : klassId
            students = new Students
            students.fetch
              success: ->

                klass = new Klass "_id" : klassId
                klass.fetch
                  success: ->
                    curriculum = new Curriculum "_id" : klass.get("curriculumId")
                    curriculum.fetch
                      success: ->
                        allSubtests = new Subtests
                        allSubtests.fetch
                          success: ( collection ) ->
                            subtests = new Subtests collection.where "part" : part, "curriculumId" : klass.get("curriculumId")
                            previousSubtests = []
                            collection.each (subtest) ->
                              previousSubtests.push(subtest) if subtest.get("part") <= part

                            # filter `Results` by `Klass`'s current `Students`
                            students = new Students students.where "klassId" : klassId
                            studentIds = students.pluck("_id")
                            resultsFromCurrentStudents = []
                            for result in results.models
                              resultsFromCurrentStudents.push(result) if result.get("studentId") in studentIds
                            filteredResults = new KlassResults resultsFromCurrentStudents

                            view = new KlassGroupingView
                              "students"   : students
                              "curriculum" : curriculum
                              "subtests"   : subtests
                              "results"    : filteredResults
                              "previousSubtests" : previousSubtests
                            vm.show view

  masteryCheck: (studentId) ->
    Tangerine.user.verify
      isAuthenticated: ->
        student = new Student "_id" : studentId
        student.fetch
          success: (student) ->
            klassId = student.get "klassId"
            klass = new Klass "_id" : student.get "klassId"
            klass.fetch
              success: (klass) ->
                allResults = new KlassResults
                allResults.fetch
                  success: ( collection ) ->
                    results = new KlassResults collection.where "studentId" : studentId, "reportType" : "mastery", "klassId" : klassId
                    # get a list of subtests involved
                    subtestIdList = {}
                    subtestIdList[result.get("subtestId")] = true for result in results.models
                    subtestIdList = _.keys(subtestIdList)

                    # make a collection and fetch
                    subtestCollection = new Subtests
                    subtestCollection.add new Subtest("_id" : subtestId) for subtestId in subtestIdList
                    subtestCollection.fetch
                      success: ->
                        view = new MasteryCheckView
                          "student"  : student
                          "results"  : results
                          "klass"    : klass
                          "subtests" : subtestCollection
                        vm.show view

  progressReport: (studentId, klassId) ->
    Tangerine.user.verify
      isAuthenticated: ->
        # save this crazy function for later
        # studentId can have the value "all", in which case student should == null
        afterFetch = ( student, students ) ->
          klass = new Klass "_id" : klassId
          klass.fetch
            success: (klass) ->
              allSubtests = new Subtests
              allSubtests.fetch
                success: ( allSubtests ) ->
                  subtests = new Subtests allSubtests.where 
                    "curriculumId" : klass.get("curriculumId")
                    "reportType"   : "progress"
                  allResults = new KlassResults
                  allResults.fetch
                    success: ( collection ) ->
                      results = new KlassResults collection.where "klassId" : klassId, "reportType" : "progress"

                      console.log students
                      if students?
                        # filter `Results` by `Klass`'s current `Students`
                        studentIds = students.pluck("_id")
                        resultsFromCurrentStudents = []
                        for result in results.models
                          resultsFromCurrentStudents.push(result) if result.get("studentId") in studentIds
                        results = new KlassResults resultsFromCurrentStudents

                      view = new ProgressView
                        "subtests" : subtests
                        "student"  : student
                        "results"  : results
                        "klass"    : klass
                      vm.show view

        if studentId != "all"
          student = new Student "_id" : studentId
          student.fetch
            success: -> afterFetch student
        else
          students = new Students
          students.fetch
            success: -> afterFetch null, students

  #
  # Subtests
  #
  editSubtest: (id) ->
    Tangerine.user.verify
      isAdmin: ->
        id = Utils.cleanURL id
        subtest = new Subtest _id : id
        subtest.fetch
          success: (model, response) ->
            assessment = new Assessment
              "_id" : subtest.get("assessmentId")
            assessment.fetch
              success: ->
                view = new SubtestEditView
                  model      : model
                  assessment : assessment
                vm.show view
      isUser: ->
        Tangerine.router.landing()

  editKlassSubtest: (id) ->

    onSuccess = (subtest, curriculum, questions=null) ->
      view = new KlassSubtestEditView
        model      : subtest
        curriculum : curriculum
        questions  : questions
      vm.show view

    Tangerine.user.verify
      isAdmin: ->
        id = Utils.cleanURL id
        subtest = new Subtest _id : id
        subtest.fetch
          success: ->
            curriculum = new Curriculum
              "_id" : subtest.get("curriculumId")
            curriculum.fetch
              success: ->
                if subtest.get("prototype") == "survey"
                  questions = new Questions
                  questions.fetch
                    key : curriculum.id
                    success: ->
                      questions = new Questions questions.where("subtestId":subtest.id)
                      onSuccess subtest, curriculum, questions
                else
                  onSuccess subtest, curriculum
      isUser: ->
        Tangerine.router.landing()


  #
  # Question
  #
  editQuestion: (id) ->
    Tangerine.user.verify
      isAdmin: ->
        id = Utils.cleanURL id
        question = new Question _id : id
        question.fetch
          success: (question, response) ->
            assessment = new Assessment
              "_id" : question.get("assessmentId")
            assessment.fetch
              success: ->
                subtest = new Subtest
                  "_id" : question.get("subtestId")
                subtest.fetch
                  success: ->
                    view = new QuestionEditView
                      "question"   : question
                      "subtest"    : subtest
                      "assessment" : assessment
                    vm.show view
      isUser: ->
        Tangerine.router.landing()


  editKlassQuestion: (id) ->
    Tangerine.user.verify
      isAdmin: ->
        id = Utils.cleanURL id
        question = new Question "_id" : id
        question.fetch
          success: (question, response) ->
            curriculum = new Curriculum
              "_id" : question.get("curriculumId")
            curriculum.fetch
              success: ->
                subtest = new Subtest
                  "_id" : question.get("subtestId")
                subtest.fetch
                  success: ->
                    view = new QuestionEditView
                      "question"   : question
                      "subtest"    : subtest
                      "assessment" : curriculum
                    vm.show view


  #
  # User
  #
  login: ->
    Tangerine.user.verify
      isAuthenticated: ->
        Tangerine.router.landing()
      isUnregistered: ->

        showView = (users = []) ->
          view = new LoginView
            users: users
          vm.show view

        if Tangerine.settings.get("context") is "server"
          showView()
        else
          users = new TabletUsers
          users.fetch
            success: ->
              showView(users)



  logout: ->
    Tangerine.user.logout()

  account: ->
    # change the location to the trunk, unless we're already in the trunk
    if Tangerine.settings.get("context") == "server" and Tangerine.db_name != "t"
      window.location = Tangerine.settings.urlIndex("trunk", "account")
    else
      Tangerine.user.verify
        isAuthenticated: ->
          showView = (teacher) ->
            view = new AccountView 
              user : Tangerine.user
              teacher: teacher
            vm.show view

          if "class" is Tangerine.settings.get("context")
            if Tangerine.user.has("teacherId")
              teacher = new Teacher "_id": Tangerine.user.get("teacherId")
              teacher.fetch
                success: ->
                  showView(teacher)
            else
              teacher = new Teacher "_id": Utils.humanGUID()
              teacher.save null,
                success: ->
                  showView(teacher)

          else
            showView()

  settings: ->
    Tangerine.user.verify
      isAuthenticated: ->
        view = new SettingsView
        vm.show view


  logs: ->
    Tangerine.user.verify
      isAuthenticated: ->
        logs = new Logs
        logs.fetch
          success: =>
            view = new LogView
              logs: logs
            vm.show view


  teachers: ->
    Tangerine.user.verify
      isAuthenticated: ->
        users = new TabletUsers
        users.fetch
          success: -> 
            teachers = new Teachers
            teachers.fetch
              success: =>
                view = new TeachersView
                  teachers: teachers
                  users: users
                vm.show view


  # Transfer a new user from tangerine-central into tangerine
  transfer: ->
    getVars = Utils.$_GET()
    name = getVars.name
    $.couch.logout
      success: =>
        $.removeCookie "AuthSession"
        $.couch.login
          "name"     : name
          "password" : name
          success: ->
            Tangerine.router.landing()
            window.location.reload()
          error: ->
            $.couch.signup
              "name" :  name
              "roles" : ["_admin"]
            , name,
            success: ->
              user = new User
              user.save 
                "name"  : name
                "id"    : "tangerine.user:"+name
                "roles" : []
                "from"  : "tc"
              ,
                wait: true
                success: ->
                  $.couch.login
                    "name"     : name
                    "password" : name
                    success : ->
                      Tangerine.router.landing()
                      window.location.reload()
                    error: ->
                      Utils.sticky "Error transfering user."

class FooterView extends Backbone.View

  className: "footer-view"

  render: ->
    @$el.html "

      <style>

      .footer-view p {
        font-size: 1.1em;
        font-weight: 100;
      }

      </style>

      <p>This application was developed by Tayari Early Childhood Development Programme.  Tayari is implemented by the Ministry of Education, Science and Technology and supported by Kenya Institute of Curriculum Development (KICD), Ministry of Health, Nairobi City County, Laikipia County Government, Uasin Gishu County Government, and Siaya County Government.</p>
      <p>If you have any Questions or comments, please contact Lucy Wambari on 0723742848.</p>
    "

    @trigger "rendered"

