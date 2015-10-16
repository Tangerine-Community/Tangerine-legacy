# This file loads the most basic settings related to Tangerine and kicks off Backbone's router.
#   * The doc `configuration` holds the majority of settings. 
#   * The Settings object contains many convenience functions that use configuration's data.
#   * Templates should contain objects and collections of objects ready to be used by a Factory.
# Also intialized here are: Backbone.js, and jQuery.i18n

# Utils.disableConsoleLog()
# Utils.disableConsoleAssert()

Tangerine = {}


db_name = window.location.pathname.split("/")[1]
Tangerine.isServer = db_name is "db"
if db_name is "db"
  db_name = window.location.pathname.split("/")[2]

Tangerine =
  db_name    : db_name
  design_doc : _.last(String(window.location).split("_design/")).split("/")[0]

# Local tangerine database handle
Tangerine.$db = $.couch.db(Tangerine.db_name)

urlParser = document.createElement("a")
urlParser.href = window.location

# Backbone configuration
Backbone.couch_connector.config.base_url  = "#{urlParser.protocol}//#{urlParser.host}/db" if Tangerine.isServer
Backbone.couch_connector.config.db_name   = Tangerine.db_name
Backbone.couch_connector.config.ddoc_name = Tangerine.design_doc
Backbone.couch_connector.config.global_changes = false

# set underscore's template engine to accept handlebar-style variables
_.templateSettings = interpolate : /\{\{(.+?)\}\}/g

Tangerine.onBackButton = (event) ->
  if Tangerine.activity == "assessment run"
    if confirm t("NavigationView.message.incomplete_main_screen")
      Tangerine.activity = ""
      if vm.currentView?.backButton?
        vm.currentView.backButton()
      else
        window.history.back()
    else
      return false
  else
    if vm.currentView?.backButton?
      vm.currentView.backButton()
    else
      window.history.back()

Tangerine.bootSequence = 

  pouchCheck : (callback) ->
    # Restore previous if exists
    return callback() unless Modernizr.touch # only if mobile
    db = new PouchDB(Tangerine.db_name)
    db.info (err, response) ->
      if response.doc_count isnt 0
        PouchDB.replicate Tangerine.db_name, "http://0.0.0.0:5984/#{Tangerine.db_name}",
          complete: (err, response) ->
            if err?
              Utils.sticky("Update incomplete.")
            else
              PouchDB.destroy(Tangerine.db_name, (err, resp) ->
                  if err?
                    Utils.sticky("Update incomplete.")
                  else
                    callback()
                )
      else
        callback()
              
  mmlpCheck: (callback) ->
    includes = [
      "/mmlp/_design/mmlp/app/constants.js"
      "/mmlp/_design/mmlp/app/classes.js"
    ]
    getAnother = ->
      file = includes.shift()
      $.getScript(file, (data, status, jqxhr) ->
        return getAnother() if includes.length > 0
        callback()
      ).fail( ( jqxhr, settings, exception ) ->
        return getAnother() if includes.length > 0
        callback()
      )

    getAnother()

  getConfiguration : ( callback ) ->
    # Grab our system config doc
    Tangerine.config = new Backbone.Model "_id" : "configuration"

    Tangerine.config.fetch
      error   : ->
        console.log "could not fetch configuration"

      success : callback

  getSettings : (callback) ->

    # get our Tangerine settings
    Tangerine.settings = new Settings "_id" : "settings"
    Tangerine.settings.fetch
      success: ->

        # guarentee instanceId
        Tangerine.settings.set "instanceId", Utils.humanGUID() unless Tangerine.settings.has("instanceId")

        callback()
      error: ->
        Tangerine.settings.set Tangerine.config.get("defaults")['settings']

        # generate a random ID for this individual instance
        Tangerine.settings.set "instanceId", Utils.humanGUID()

        Tangerine.settings.save null,
          error: ->
            console.log "couldn't save new settings"
          success: ->
            callback()

  getSchoolList : ( callback ) ->
    # Grab our system config doc
    Tangerine.schoolList = new Backbone.Model "_id" : "school-list"

    Tangerine.schoolList.fetch
      error   : ->
        console.log "could not fetch school-list..."

      success : callback


  hitViews: (callback) ->

    return callback() if Tangerine.settings.get("context") is "server"

    $.couch.login
      name     : "admin"
      password : "password"
      success: ->
        checkActiveTasks = ->
          $.couch.activeTasks
            error: -> clearInterval(Tangerine.activeTasksInterval)
            success: (activities) ->
              progress = 0
              for activity in activities 
                progress += activity.progress

              Utils.midAlert "Loading<br>#{JSON.stringify(arguments)}"

        
        Tangerine.$db.view "#{Tangerine.design_doc}/byCollection",
          success: -> 
            $.couch.logout
              success: -> callback()
              error: -> callback()

          error: ->
            $.couch.logout
              success: -> callback()
              error: -> callback()

                
        Tangerine.activeTasksInterval = setInterval(checkActiveTasks, 1000)
    




  getTemplates : (callback) ->

    # Template files for ease of use in grids
    Tangerine.templates = new Template "_id" : "templates"
    Tangerine.templates.fetch
      success: callback


  # if admin user doesn't exist in _users database, create it
  ensureAdmin : (callback) ->
    if Tangerine.settings.get("context") != "server" && not Tangerine.settings.has("adminEnsured")
      $.couch.login
        name     : "admin"
        password : "password"
        success: ->
          $.couch.userDb (uDB) =>
            uDB.openDoc "org.couchdb.user:admin",
              success: ->
                $.couch.logout
                  success:->
                    Tangerine.settings.save "adminEnsured" : true
                    callback() # done
                  error: ->
                    console.log "error logging out admin user"
              error: ->
                $.ajax
                  url      : "/_users/org.couchdb.user:admin"
                  type     : "PUT"
                  dataType : "json"
                  data : JSON.stringify
                    name     : "admin"
                    password : null
                    roles    : []
                    type     : "user"
                    _id      : "org.couchdb.user:admin"
                  success: ( data ) =>
                    Tangerine.settings.save "adminEnsured" : true
                    $.couch.logout
                      success: callback # done
                      error: ->
                        console.log "Error logging out admin user"
                  error: =>
                    console.log "Error ensuring admin _user doc"
    else
      callback()

  # make sure all users in the _users database have a local user model for future use
  transitionUsers : (callback) ->

    return callback() if Tangerine.settings.get("context") is "server" or Tangerine.settings.has("usersTransitioned")

    $.couch.login
      name     : "admin"
      password : "password"
      success: ->
        $.couch.userDb (uDB) => 
          uDB.allDocs
            success: (resp) ->
              docIds = _.pluck(resp.rows, "id").filter (a) -> ~a.indexOf("org.couchdb")
              nextDoc = () ->
                id = docIds.pop()
                return finish() unless id?
                uDB.openDoc id,
                  success: (doc) ->
                    teacher = null
                    # console.log doc
                    name = doc._id.split(":")[1]

                    hashes = 
                      if doc.password_sha?
                        pass : doc.password_sha
                        salt : doc.salt
                      else
                        TabletUser.generateHash("password")

                    teacherId = doc.teacherId
                    unless teacherId?
                      teacherId = Utils.humanGUID()
                      teacher = new Teacher "_id" : teacherId, "name" : name
                      
                    if name is "admin"
                      roles = ["_admin"]
                      hashes = TabletUser.generateHash("password")
                    else
                      roles = doc.roles || []
                      

                    newDoc = 
                      "_id"   : TabletUser.calcId(name)
                      "name"  : name
                      "roles" : roles
                      "pass"  : hashes.pass
                      "salt"  : hashes.salt
                      "teacherId"  : teacherId
                      "collection" : "user"
                    #return
                    Tangerine.$db.saveDoc newDoc,
                      success: (doc) ->
                        if teacher?
                          teacher.save null,
                            success: ->
                              nextDoc()
                        else
                          nextDoc()

                      error: (doc) ->
                        nextDoc()

              finish = ->
                Tangerine.settings.save "usersTransitioned" : true,
                  success: ->
                    $.couch.logout
                      success: ->
                        callback()

              nextDoc() # kick it off

  startApp : (callback) ->
    $ ->
      #
      # Start the application
      #

      window.vm = new ViewManager()

      #$("<button id='reload'>reload me</button>").appendTo("#footer").click -> document.location.reload()

      $.i18n.init 
        "fallbackLng" : "en"
        "lng"         : Tangerine.settings.get "language"
        "resGetPath"  : "locales/__lng__/translation.json"
      , (t) ->
        window.t = t


        if Tangerine.settings.get("context") != "server"

          document.addEventListener "deviceready"
          , ->

            document.addEventListener "online", -> 
              Tangerine.online = true

            document.addEventListener "offline", ->
              Tangerine.online = false

            ### Note, turns on menu button
            document.addEventListener "menubutton", (event) ->
              console.log "menu button"
            , false
            ###

            # prevents default
            document.addEventListener "backbutton", Tangerine.onBackButton, false
          , false

        # Singletons
        Tangerine.router = new Router()
        Tangerine.user   = if Tangerine.settings.get("context") is "server"
            new User()
          else
            new TabletUser()
        Tangerine.nav    = new NavigationView
          user   : Tangerine.user
          router : Tangerine.router
        Tangerine.log    = new Log()

        Tangerine.user.sessionRefresh 
          error: ->
            Tangerine.user.logout()
          success: -> 
            $("#footer").show()
            $("body").addClass(Tangerine.settings.get("context"))

            Backbone.history.start()

Tangerine.load = (functions) ->

  doStep = ->
    nextFunction = functions.shift()
    nextFunction?(doStep)
  
  doStep()

Tangerine.boot = (callback) ->

    sequence = [
      Tangerine.bootSequence.pouchCheck
      #Tangerine.bootSequence.mmlpCheck
      Tangerine.bootSequence.getConfiguration
      Tangerine.bootSequence.getSettings
      #Tangerine.bootSequence.hitViews
      Tangerine.bootSequence.getTemplates
      Tangerine.bootSequence.ensureAdmin
      Tangerine.bootSequence.transitionUsers
      Tangerine.bootSequence.startApp
    ]

    sequence.push callback if callback?

    Tangerine.load sequence

Tangerine.boot() unless window.TESTING
