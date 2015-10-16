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
    @panels = Tangerine.settings.getArray("#{@className}-panels")
    if @panels.length is 0
      @panels = [
        {
          name : "Workflows"
          views : ["WorkflowMenuView"]
        },
        {
          name : "Sync"
          views : ["SyncManagerView", "BandwidthCheckView"]
        }
      ]


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
        "<div id='#{@cssize(view)}'></div>" for view in views
      ).join("<hr>")

    tabs: (panels) ->
      
      result = "<div class='tab_container'>"
      last  = panels.pop()   if panels.length
      first = panels.shift() if panels.length

      result += @tab(name: first.name, cssClass:"first") if first
      
      result += @tab name: panel.name for panel, i in panels
      
      result += @tab name: last.name, cssClass:"last" if last
      
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
      for view in panel.views
        @panelViews[view] = new window[view]
        @panelViews[view].setElement @$el.find "##{@template.cssize(view)}"
        @panelViews[view].render()
    
    #init the tabs by showing the selected tabs
    @displayTab(@selectedTab)

    @trigger "rendered"