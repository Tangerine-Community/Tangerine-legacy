# One view to rule them all
# Not necessary to be a view but just in case we need it to do more

# ViewManager now supports loading bars. To take advantage of this feature
# within a view add a trigger for "start_work" and "end_work" and during
# all the time in between a loading bar should appear. 
class ViewManager extends Backbone.View
  show: (view) ->
    window.scrollTo 0, 0
    @currentView?.close()
    @currentView = view

    @currentView.on "rendered", =>
      $("#content").append @currentView.el
      @currentView.$el.find(".buttonset").buttonset()

      # @currentView.afterRender?()
      # Utils.resizeScrollPane()

    @currentView.on "start_work", =>
      console.log "Loading bar created"
      $("#content").prepend "<div id='loading_bar'><img class='loading' src='images/loading.gif'></div>"

    @currentView.on "end_work", =>
      console.log "Loading bar destroyed"
      $("#loading_bar").remove()

    @currentView.render()
    