var GridEditView,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

GridEditView = (function(_super) {

  __extends(GridEditView, _super);

  function GridEditView() {
    GridEditView.__super__.constructor.apply(this, arguments);
  }

  GridEditView.prototype.initialize = function(options) {
    return this.model = options.model;
  };

  GridEditView.prototype.save = function() {
    if (/\t|,/.test(this.$el.find("#subtest_items").val())) {
      alert("Please remember\n\nGrid items are space \" \" delimited");
    }
    return this.model.set({
      timer: parseInt(this.$el.find("#subtest_timer").val()),
      items: _.compact(this.$el.find("#subtest_items").val().split(" ")),
      columns: parseInt(this.$el.find("#subtest_columns").val()),
      autostop: parseInt(this.$el.find("#subtest_autostop").val()),
      variableName: this.$el.find("#subtest_variable_name").val().replace(/\s/g, "_").replace(/[^a-zA-Z0-9_]/g, "")
    });
  };

  GridEditView.prototype.render = function() {
    var autostop, columns, items, timer, variableName;
    timer = this.model.get("timer") || 0;
    items = this.model.get("items").join(" ");
    columns = this.model.get("columns") || 0;
    autostop = this.model.get("autostop") || 0;
    variableName = this.model.get("variableName") || "";
    return this.$el.html("      <div class='label_value'>        <label for='subtest_variable_name'>Variable name</label>        <input id='subtest_variable_name' value='" + variableName + "'>      </div>      <div class='label_value'>        <label for='subtest_items'>Grid Items (space delimited)</label>        <textarea id='subtest_items'>" + items + "</textarea>      </div>      <div class='label_value'>        <label for='subtest_columns'>Columns</label>        <input id='subtest_columns' value='" + columns + "' type='number'>      </div>      <div class='label_value'>        <label for='subtest_autostop'>Autostop</label>        <input id='subtest_autostop' value='" + autostop + "' type='number'>      </div>      <div class='label_value'>        <label for='subtest_timer'>Timer</label>        <input id='subtest_timer' value='" + timer + "' type='number'>      </div>");
  };

  return GridEditView;

})(Backbone.View);
