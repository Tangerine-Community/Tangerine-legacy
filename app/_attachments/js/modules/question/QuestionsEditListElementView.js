var QuestionsEditListElementView,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

QuestionsEditListElementView = (function(_super) {

  __extends(QuestionsEditListElementView, _super);

  function QuestionsEditListElementView() {
    QuestionsEditListElementView.__super__.constructor.apply(this, arguments);
  }

  QuestionsEditListElementView.prototype.tagName = "li";

  QuestionsEditListElementView.prototype.className = "question_list_element";

  QuestionsEditListElementView.prototype.events = {
    'click .edit': 'edit',
    'click .delete': 'toggleDelete',
    'click .delete_cancel': 'toggleDelete',
    'click .delete_delete': 'delete'
  };

  QuestionsEditListElementView.prototype.edit = function(event) {
    Tangerine.router.navigate("question/" + this.question.id, true);
    return false;
  };

  QuestionsEditListElementView.prototype.toggleDelete = function() {
    return this.$el.find(".delete_confirm").fadeToggle(250);
  };

  QuestionsEditListElementView.prototype["delete"] = function(event) {
    this.question.collection.remove(this.question.id);
    this.question.destroy();
    this.trigger("deleted");
    return false;
  };

  QuestionsEditListElementView.prototype.initialize = function(options) {
    this.question = options.question;
    return this.$el.attr("data-id", this.question.id);
  };

  QuestionsEditListElementView.prototype.render = function() {
    this.$el.html("      <table>        <tr>          <td>            <img src='images/icon_drag.png' class='sortable_handle'>          </td>          <td>            <span>" + (this.question.get('prompt')) + "</span> <span>[<small>" + (this.question.get('name')) + ", " + (this.question.get('type')) + "</small>]</span>            <img src='images/icon_edit.png' class='link_icon edit'>            <img src='images/icon_delete.png' class='link_icon delete'><br>            <div class='confirmation delete_confirm'>            <div class='menu_box'>Confirm<br><button class='delete_delete command_red'>Delete</button><button class='delete_cancel command'>Cancel</button>            </div>          </td>        </tr>      </table>      ");
    return this.trigger("rendered");
  };

  return QuestionsEditListElementView;

})(Backbone.View);
