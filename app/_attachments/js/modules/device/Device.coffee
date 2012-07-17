class Device extends Backbone.Model

  url : "device"

  initialize: ->
    @set 
      _id : "TangerineDeviceConfiguration"
      context : null