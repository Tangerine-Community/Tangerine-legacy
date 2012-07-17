class SubtestListElementView extends Backbone.View

  tagName : "li"
  className : "subtest_element"
  events: 
    'click .icon_edit'     : 'edit'
    "click .icon_delete"   : "toggleDeleteConfirm"
    "click .delete_cancel" : "toggleDeleteConfirm"
    "click .delete_delete" : "delete"

  toggleDeleteConfirm: -> @$el.find(".delete_confirm").fadeToggle(250); false
  delete: -> @trigger "subtest:delete", @model; false

  edit: ->
    Tangerine.router.navigate "subtest/#{@model.id}", true

  initialize: (options) ->
    @model = options.model

    # This is for $.sortable. Don't remove.
    @$el.attr "data-id", @model.id

  render: ->
    subtestName   = @model.get("name")
    prototype     = "[#{@model.get("prototype")}]"
    iconDrag      = "<img src='images/icon_drag.png' class='sortable_handle'>"
    iconEdit      = "<img src='images/icon_edit.png' class='icon_edit'>"
    iconDelete    = "<img src='images/icon_delete.png' class='icon_delete'>"
    deleteConfirm = "<br><span class='delete_confirm'><div class='menu_box'>Confirm <button class='delete_delete command_red'>Delete</button> <button class='delete_cancel command'>Cancel</button></div></span>"
    @$el.html "
      <table><tr>
      <td>#{iconDrag}</td>
      <td>
        #{subtestName}
        #{prototype}
        #{iconEdit}
        #{iconDelete}
        #{deleteConfirm}
      </td>
      </tr></table>
    "

    @trigger "rendered"
