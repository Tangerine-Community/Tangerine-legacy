class AccountView extends Backbone.View

  events:
    'click .leave'       : 'leaveGroup'
    'click .join_cancel' : 'joinToggle'
    'click .join'        : 'joinToggle'
    'click .join_group'  : 'join'
    'click .back'        : 'goBack'


  goBack: ->
    window.history.back()

  joinToggle: ->
    @$el.find(".join, .join_confirmation").fadeToggle(0)
    @$el.find("#group_name").val ""

  join: ->
    group = @$el.find("#group_name").val().replace(/\s|-/g, "_").replace(/[^a-zA-Z0-9_'"]/g,"")
    return if group.length == 0
    
    @user.joinGroup group
    @joinToggle()
    @render()

  leaveGroup: (event) ->
    group = $(event.target).parent().attr('data-group')
    @user.leaveGroup group
    @render()

  initialize: ( options ) ->
    @user = options.user
  
  render: ->
    html = "
      <button class='back navigation'>Back</button>
      <h1>Account</h1>
      <div class='label_value'>
        <label>Name</label>
        <p>#{@user.name}</p>
      </div>
      <div class='label_value menu_box'>
        <label>Groups</label>
        <ul>
    "
    for group in (@user.get("groups") || [])
        html += "<li data-group='#{group}'>#{group} <button class='command leave'>Leave</button></li>"
    html += "
        </ul>
        <button class='command join'>Join or create a group</button>
        <div class='confirmation join_confirmation'>
          <input id='group_name' placeholder='Group name'>
          <small>Please be specific.<br>
          Good examples: MalawiJun2012, MikeTestGroup2012, EGRAGroup2012<br>
          Bad examples: group, test, mine</small><br>
          <button class='command join_group'>Join Group</button>
          <button class='command join_cancel'>Cancel</button>
        </div>
      </div><br>
      <!--button class='command confirmation'>Report a bug</button>
      <div class='confirmation' id='bug'>
        <label for='where'>What broke?
        <input id='where' placeholder='where'>
        <label for='where'>What happened?
        <input id='where' placeholder='what'>
        <label for='where'>What should have happened?
        <input id='should' placeholder='should'>
        <button>Send</button>
      </div-->
      "
    @$el.html html
    @trigger "rendered"
