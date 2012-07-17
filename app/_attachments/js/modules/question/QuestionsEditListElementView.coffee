# Provides an "li" tag for the questions edit view
class QuestionsEditListElementView extends Backbone.View
  tagName : "li"
  className : "question_list_element"

  events:
    'click .edit'          : 'edit'
    'click .delete'        : 'toggleDelete'
    'click .delete_cancel' : 'toggleDelete'
    'click .delete_delete' : 'delete'

  edit: (event) ->
    Tangerine.router.navigate "question/#{@question.id}", true
    return false

  toggleDelete: ->
    @$el.find(".delete_confirm").fadeToggle(250)

  delete: (event) ->
    @question.collection.remove(@question.id)
    @question.destroy()
    @trigger "deleted"
    return false

  initialize: ( options ) ->
    @question = options.question
    @$el.attr("data-id", @question.id)

  render: ->
    @$el.html "
      <table>
        <tr>
          <td>
            <img src='images/icon_drag.png' class='sortable_handle'>
          </td>
          <td>
            <span>#{@question.get 'prompt'}</span> <span>[<small>#{@question.get 'name'}, #{@question.get 'type'}</small>]</span>
            <img src='images/icon_edit.png' class='link_icon edit'>
            <img src='images/icon_delete.png' class='link_icon delete'><br>
            <div class='confirmation delete_confirm'>
            <div class='menu_box'>Confirm<br><button class='delete_delete command_red'>Delete</button><button class='delete_cancel command'>Cancel</button>
            </div>
          </td>
        </tr>
      </table>
      "
    @trigger "rendered"
