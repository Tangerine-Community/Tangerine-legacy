# basically, we save dictionaries that are used by jQuery.i18n
# note, declares 
class Language extends Backbone.Model

  url: "/Language"

  initialize: (options) ->
    @loadLanguage(options)

    
  loadLanguage: ->
    window.t = @translate
    @fetch
      success: =>
        $.i18n.setDictionary @get("dictionary")

  translate: (string) ->
    $.i18n._(string).titleize()
    