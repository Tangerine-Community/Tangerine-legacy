class Log extends Backbone.Model

  url: "log"

  defaults :
    type      : "none"
    details   : "none"
    timestamp : 0
    user      : "no one"

  initialize: (options) ->
    @set
      type      : options.type
      details   : options.details
      timestamp : (new Date()).getTime()
      user      : Tangerine.user.name
    @save()

class Logs extends Backbone.Collection
  
  url: "log"
  model: Log
  comparator: (model) -> return model.get "timestamp"

class LogView extends Backbone.View

  initialize: ->
    @allLogs = new Logs
    @allLogs.fetch
      success: (collection) ->
        @logs = collection.where
          user : Tangerine.user.name

  render: ->
    html = "<table><th><td>time</td><td>type</td><td>details</td></th>"
    
    for log in @logs
      html += "<tr><td>#{log.get("timestamp")}</td><td>#{log.get("type")}</td><td>#{log.get("details")}</td></tr>"
    html += "</table>"
    @$el.html html
    @trigger "rendered"
