class LoginView extends Backbone.View

  className: 'login_view'

  events:
    "click button.login" : "login"
    "keypress input"     : "keyHandler"

  initialize: (options) ->
    @model = Tangerine.user
    @model.on "change:messages", @renderMessages
    @model.on "change:authentication", @goOn

  goOn: ->
    Tangerine.router.navigate "", true


  render: =>
    width = $('#content').width()
    parentWidth = $('#content').offsetParent().width()
    @oldWidth = 100 * width / parentWidth

    $("#content").css "width", "100%"

    @$el.html "
      <img src='images/tangerine_logo.png' id='login_logo'>
      <div class='messages'></div>
      <label for='login_username'>Enumerator Name</label>
      <input id='login_username' name='login_username'>
      <label for='login_password'>Password</label>
      <input id='login_password' name='login_username' type='password'>
      <button class='login'>Login</button>
    "
    @trigger "rendered"

  onClose: ->
    $("#content").css "width", @oldWidth + "%"

  keyHandler: (event) ->
    if event.which
      if event.which != 13
        return true
      else
        @login()

  login: (event) ->
    values = Utils.getValues(@el)
    if values['login_password'] == ""
      @model.showMessage "Please enter a password"
      @$el.find('#login_password').focus()
      return false
    @model.login values["login_username"], values["login_password"]

  renderMessages: =>
    messages = @model.get("messages") || []
    html = "<ul>"
    for message in messages
      html += "<li>#{message}</li>"
    html += "</ul>"
    @$el.find(".messages").html html 
    
