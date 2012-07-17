class GroupsView extends Backbone.View

  events:
    'click .account' : 'gotoAccount'
    'click .goto'    : 'gotoGroup'

  gotoAccount: ->
    Tangerine.router.navigate "account", true
  
  gotoGroup: (event) ->
    group = $(event.target).attr("data-group")
    Tangerine.router.navigate "assessments/#{group}", true
    

  render: ->
    groups = Tangerine.user.get("groups")
    html = "
      <button class='account navigation'>Account</button>
      <h1>Groups</h1>
    "

    if groups.length == 0
      html += "You are not yet a member of a group. Go to Account to join a group."
    else 
      for group, i in groups
        html += "<button class='command goto' data-group='#{_.escape(group)}'>#{group}</button>"


    @$el.html html
    @trigger "rendered"
