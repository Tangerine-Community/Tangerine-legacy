var SubtestListElementView,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

SubtestListElementView = (function(_super) {

  __extends(SubtestListElementView, _super);

  function SubtestListElementView() {
    SubtestListElementView.__super__.constructor.apply(this, arguments);
  }

  SubtestListElementView.prototype.tagName = "li";

  SubtestListElementView.prototype.className = "subtest_element";

  SubtestListElementView.prototype.events = {
    'click .icon_edit': 'edit',
    "click .icon_delete": "toggleDeleteConfirm",
    "click .delete_cancel": "toggleDeleteConfirm",
    "click .delete_delete": "delete"
  };

  SubtestListElementView.prototype.toggleDeleteConfirm = function() {
    this.$el.find(".delete_confirm").fadeToggle(250);
    return false;
  };

  SubtestListElementView.prototype["delete"] = function() {
    this.trigger("subtest:delete", this.model);
    return false;
  };

  SubtestListElementView.prototype.edit = function() {
    return Tangerine.router.navigate("subtest/" + this.model.id, true);
  };

  SubtestListElementView.prototype.initialize = function(options) {
    this.model = options.model;
    return this.$el.attr("data-id", this.model.id);
  };

  SubtestListElementView.prototype.render = function() {
    var deleteConfirm, iconDelete, iconDrag, iconEdit, prototype, subtestName;
    subtestName = this.model.get("name");
    prototype = "[" + (this.model.get("prototype")) + "]";
    iconDrag = "<img src='images/icon_drag.png' class='sortable_handle'>";
    iconEdit = "<img src='images/icon_edit.png' class='icon_edit'>";
    iconDelete = "<img src='images/icon_delete.png' class='icon_delete'>";
    deleteConfirm = "<br><span class='delete_confirm'><div class='menu_box'>Confirm <button class='delete_delete command_red'>Delete</button> <button class='delete_cancel command'>Cancel</button></div></span>";
    this.$el.html("      <table><tr>      <td>" + iconDrag + "</td>      <td>        " + subtestName + "        " + prototype + "        " + iconEdit + "        " + iconDelete + "        " + deleteConfirm + "      </td>      </tr></table>    ");
    return this.trigger("rendered");
  };

  return SubtestListElementView;

})(Backbone.View);
