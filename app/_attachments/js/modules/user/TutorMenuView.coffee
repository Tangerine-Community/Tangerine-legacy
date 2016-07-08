class TutorMenuView extends Backbone.View

  className : "TutorMenuView"

  @hasPanels : true

  events:
    "click .tab"	: 'handleTabClick'

  i18n: ->
    @text =
      "title"      : t('TutorMenuView.title')
  
  initialize: (options) =>
    @[key] = value for key, value of options
    @i18n()

    @userRole = Tangerine.user.getString("role")
    @userRole = Tangerine.config.get("userProfile").defaultRole if @userRole == ""

    @tutorMenu = Tangerine.config.get("tutorMenu")
    _.defaults(@tutorMenu, {panels:[]}) #ensure that the @tutorMenu eists and that it has the panels attribute

    @panels = @tutorMenu.panels
    if @panels.length is 0
      @panels = [
        {
          name: "workflows"
          label : "Workflows"
          restrictToRoles: []
          views : [
            {
              view: "WorkflowMenuView"
              restrictToRoles: []
            }
          ]
        },
        {
          name: "sync"
          label : "Sync"
          restrictToRoles: []
          views : [
            {
              view: "SyncManagerView"
              restrictToRoles: []
            }, 
            {
              view: "BandwidthCheckView"
              restrictToRoles: []
            }
          ]
        },
        {
          name: "schools"
          label : "Schools"
          restrictToRoles: []
          views : [
            {
              view: "SchoolListView"
              restrictToRoles: []
            }, 
            {
              view: "ValidObservationView"
              restrictToRoles: []
            }
          ]
        }
      ]

    #Check the panel restrictions against the user roles and remove them if necessary
    removePanels = []
    for panel in @panels
      if panel.restrictToRoles.length > 0
        removePanels.push panel if panel.restrictToRoles.indexOf(@userRole) == -1

    for panel in removePanels
      @panels = _.without(@panels, panel)



  handleTabClick: ( event ) =>
    @$el.find('.tab').removeClass('selected')
    @$el.find('.tab-panel').hide()
    
    #determine which tab was clicked and begin navigation
    $target = $(event.target)
    id = $target.attr('data-id')
    Tangerine.router.navigate "tutor-menu/"+id , false
    @displayTab(id)


  displayTab: ( selectedTab ) ->
    unless selectedTab?
      selectedTab = @template.cssize _.first(@panels).name
    @$el.find('#tab-'+selectedTab).addClass('selected')
    @$el.find('#panel-'+selectedTab).show()

  template: 

    cssize: ( text ) -> text.underscore().dasherize()

    sections: (panels) ->
      (@section(panel.name, panel.views) for panel in panels).join('')

    section : (name, views) ->
      name = @cssize(name)
      "
        <section id='panel-#{name}' class='tab-panel' style='display:none;'>
          #{@panelDivs(views)}
        </section>
      "
    panelDivs: (views) ->
      (
        "<div id='#{@cssize(viewObj.view)}'></div>" for viewObj in views
      ).join("<hr>")

    tabs: (panels) ->
      
      result = "<div class='tab_container'>"
      last  = panels.pop()   if panels.length
      first = panels.shift() if panels.length

      result += @tab name: first.label, cssClass:"first" if first
      
      result += @tab name: panel.label for panel, i in panels
      
      result += @tab name: last.label, cssClass:"last" if last
      
      result += "</div>"

    tab: (values) ->
      id = @cssize(values.name)
      "<div id='tab-#{id}' class='tab #{values.cssClass}' data-id='#{id}'>#{values.name}</div>"

  render: ->

    @$el.html "
      <h1>#{@text.title}</h1>
      #{@template.tabs(JSON.parse(JSON.stringify(@panels)))}
      #{@template.sections(JSON.parse(JSON.stringify(@panels)))}
    "

    @renderPanels()

  renderPanels: ->
    @panelViews = {}
    for panel in @panels
      for viewObj in panel.views
        if viewObj.restrictToRoles.length > 0
          if viewObj.restrictToRoles.indexOf(@userRole) != -1
            @panelViews[viewObj.view] = new window[viewObj.view]
            @panelViews[viewObj.view].setElement @$el.find "##{@template.cssize(viewObj.view)}"
            @panelViews[viewObj.view].render()
        else
          @panelViews[viewObj.view] = new window[viewObj.view]
          @panelViews[viewObj.view].setElement @$el.find "##{@template.cssize(viewObj.view)}"
          @panelViews[viewObj.view].render()
    
    #init the tabs by showing the selected tabs
    @displayTab(@selectedTab)

    @trigger "rendered"