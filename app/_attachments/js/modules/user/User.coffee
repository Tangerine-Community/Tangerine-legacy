# Eventually we'll make Backbone.User based on this.
# $.couch.session needs to be async: false
class User extends Backbone.Model

  url: 'user'

  default:
    name        : null
    roles       : []
    groups      : ["default"]

  initialize: (options) ->

    # these aren't `set` because we don't want them to save with the model
    # they're handled by couchdb, so we have to load them manually
    @name = @default.name
    @roles = @default.roles

    # these aren't `set` because they're temporary
    @messages = []
    @temp = {}

  signup: ( name, pass ) ->
    $.couch.signup { name : name }, pass,
      success: (a, b, c) =>
        if @temp.intent == "login"
          @temp.intent = "retry_login"
          @login @temp.name, @temp.pass
        else
          @addMessage "New user #{temp['name']} created. Welcome to Tangerine."
        @unset "messages"
        @save()
      error: ( status, error, message ) =>
        if @temp.intent? && @temp.intent == "login"
          @showMessage "Password incorrect, please try again."
        else
          @showMessage "Error username #{@temp.name} already taken. Please try another name."


  login: ( name, pass ) ->
    @temp =
      name : name
      pass : pass
    $.couch.login
      name     : @temp.name
      password : @temp.pass
      success: ( user ) =>
        @name   = @temp.name
        @roles  = user.roles
        @fetch
          success: (model) =>
            @clearAttempt()
            @trigger "change:authentication"

      error: ( status, error, message ) =>
        @name  = @default.name
        @roles = @default.roles
        if @temp.intent? && @temp.intent == "retry_login"
          @addMessage message
        else 
          @temp.intent = "login"
          @signup @temp.name, @temp.pass

  # @callbacks Supports isAdmin, isUser, isRegistered, isUnregistered
  verify: ( callbacks ) ->
    if @name == null
      if callbacks?.isUnregistered?
        callbacks.isUnregistered()
      else
        Tangerine.router.navigate "login", true
    else
      callbacks?.isRegistered?()
      if @isAdmin()
        callbacks?.isAdmin?()
      else
        callbacks?.isUser?()

  fetch: (options={}) ->
    $.couch.session
      success: ( resp ) =>
        if resp.userCtx.name != null
          @id = "tangerine.user:"+resp.userCtx.name
          @name = resp.userCtx.name
          @roles = []

          for role in resp.userCtx.roles
            if !~role.indexOf("group.")
              @roles.push role
          User.__super__.fetch.call(@, 
            success: (a,b,c) =>
              options.success?()
            error: (a,b,c) =>
              @unset "messages"
              @save
                "_id"    : @id
                "groups" : []
              ,
                "wait"   : true
              User.__super__.fetch.call(@,
                success: =>
                  options.success?()
                error: =>
                  location.reload()
              )
          )
        else
          options.success?()

      error: ( status, error, reason ) ->
        @trigger "change:authentication"
        throw "#{status} Session Error\n#{error}\n#{reason}"



  isAdmin: ->
    '_admin' in @roles

  logout: ->
    $.couch.logout
      success: =>
        $.cookie "AuthSession", null
        @name  = @default.name
        @roles = @default.roles
        @clear()
        @trigger "change:authentication"
        Tangerine.router.navigate "login", true

  clearAttempt: ->
    @temp = @default.temp
  
  #
  # Groups
  #

  joinGroup: (group) ->
    groups = @get "groups"
    if !~groups.indexOf(group)
      groups.push group
      @unset "messages"
      @save "groups" : groups
  
  leaveGroup: (group) ->
    groups = @get "groups"
    if ~groups.indexOf(group)
      groups = _.without groups, group
      @save "groups" : groups

  #
  # Mensajes
  #
  
  addMessage:    ( content ) -> @set "messages", @get("messages").push content
  showMessage:   ( content ) -> @set "messages", [ content ]
  clearMessages: ( content ) -> @set "messages", [ ]