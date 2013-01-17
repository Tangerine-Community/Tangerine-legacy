var KlassSubtestEditView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

KlassSubtestEditView = (function(_super) {

  __extends(KlassSubtestEditView, _super);

  function KlassSubtestEditView() {
    this.goBack = __bind(this.goBack, this);
    KlassSubtestEditView.__super__.constructor.apply(this, arguments);
  }

  KlassSubtestEditView.prototype.className = "subtest_edit";

  KlassSubtestEditView.prototype.events = {
    'click .back_button': 'goBack',
    'click .save_subtest': 'save',
    'blur #subtest_items': 'cleanWhitespace'
  };

  KlassSubtestEditView.prototype.cleanWhitespace = function() {
    return this.$el.find("#subtest_items").val(this.$el.find("#subtest_items").val().replace(/\s+/g, ' '));
  };

  KlassSubtestEditView.prototype.onClose = function() {
    var _base;
    return typeof (_base = this.prototypeEditor).close === "function" ? _base.close() : void 0;
  };

  KlassSubtestEditView.prototype.initialize = function(options) {
    var _this = this;
    this.model = options.model;
    this.curriculum = options.curriculum;
    this.config = Tangerine.templates.get("subtest");
    this.prototypeViews = Tangerine.config.get("prototypeViews");
    this.prototypeEditor = new window[this.prototypeViews[this.model.get('prototype')]['edit']]({
      model: this.model,
      parent: this
    });
    return this.prototypeEditor.on("edit-save", function() {
      return _this.save({
        options: {
          editSave: true
        }
      });
    });
  };

  KlassSubtestEditView.prototype.goBack = function() {
    return history.back();
  };

  KlassSubtestEditView.prototype.save = function(event) {
    var _this = this;
    return this.model.save({
      name: this.$el.find("#name").val(),
      part: parseInt(this.$el.find("#part").val()),
      reportType: this.$el.find("#report_type").val(),
      itemType: this.$el.find("#item_type").val(),
      scoreTarget: this.$el.find("#score_target").val(),
      scoreSpread: this.$el.find("#score_spread").val(),
      order: this.$el.find("#order").val(),
      endOfLine: this.$el.find("#end_of_line input:checked").val() === "true",
      randomize: this.$el.find("#randomize input:checked").val() === "true",
      timer: parseInt(this.$el.find("#subtest_timer").val()),
      items: _.compact(this.$el.find("#subtest_items").val().split(" ")),
      columns: parseInt(this.$el.find("#subtest_columns").val())
    }, {
      success: function() {
        return Utils.midAlert("Subtest Saved");
      },
      error: function() {
        return Utils.midAlert("Save error");
      }
    });
  };

  KlassSubtestEditView.prototype.render = function() {
    var columns, curriculumName, endOfLine, itemType, items, name, order, part, randomize, reportType, scoreSpread, scoreTarget, timer;
    curriculumName = this.curriculum.escape("name");
    name = this.model.escape("name");
    part = this.model.getNumber("part");
    reportType = this.model.escape("reportType");
    itemType = this.model.escape("itemType");
    scoreTarget = this.model.getNumber("scoreTarget");
    scoreSpread = this.model.getNumber("scoreSpread");
    order = this.model.getNumber("order");
    endOfLine = this.model.has("endOfLine") ? this.model.get("endOfLine") : true;
    randomize = this.model.has("randomize") ? this.model.get("randomize") : false;
    items = this.model.get("items").join(" ");
    timer = this.model.get("timer") || 0;
    columns = this.model.get("columns") || 0;
    this.$el.html("      <button class='back_button navigation'>Back</button><br>      <h1>Subtest Editor</h1>      <table class='basic_info'>        <tr>          <th>Curriculum</th>          <td>" + curriculumName + "</td>        </tr>      </table>      <button class='save_subtest command'>Done</button>      <div class='label_value'>        <label for='name'>Name</label>        <input id='name' value='" + name + "'>      </div>      <div class='label_value'>        <label for='report_type'>Report Type</label>        <input id='report_type' value='" + reportType + "'>      </div>      <div class='label_value'>        <label for='item_type'>Item Type</label>        <input id='item_type' value='" + itemType + "'>      </div>      <div class='label_value'>        <label for='part'>Assessment Number</label><br>        <input type='number' id='part' value='" + part + "'>      </div>      <div class='label_value'>        <label for='score_target'>Target score</label><br>        <input type='number' id='score_target' value='" + scoreTarget + "'>      </div>      <div class='label_value'>        <label for='score_spread'>Score spread</label><br>        <input type='number' id='score_spread' value='" + scoreSpread + "'>      </div>      <div class='label_value'>        <label for='order'>Order</label><br>        <input type='number' id='order' value='" + order + "'>      </div>      <div class='label_value'>        <label for='subtest_items' title='These items are space delimited. Pasting text from other applications may insert tabs and new lines. Whitespace will be automatically corrected.'>Grid Items</label>        <textarea id='subtest_items'>" + items + "</textarea>      </div>      <label>Randomize items</label><br>      <div class='menu_box'>        <div id='randomize' class='buttonset'>          <label for='randomize_true'>Yes</label><input name='randomize' type='radio' value='true' id='randomize_true' " + (randomize ? 'checked' : void 0) + ">          <label for='randomize_false'>No</label><input name='randomize' type='radio' value='false' id='randomize_false' " + (!randomize ? 'checked' : void 0) + ">        </div>      </div><br>      <label>Mark entire line button</label><br>      <div class='menu_box'>        <div id='end_of_line' class='buttonset'>          <label for='end_of_line_true'>Yes</label><input name='end_of_line' type='radio' value='true' id='end_of_line_true' " + (endOfLine ? 'checked' : void 0) + ">          <label for='end_of_line_false'>No</label><input name='end_of_line' type='radio' value='false' id='end_of_line_false' " + (!endOfLine ? 'checked' : void 0) + ">        </div>      </div>      <div class='label_value'>        <label for='subtest_columns' title='Number of columns in which to display the grid items.'>Columns</label><br>        <input id='subtest_columns' value='" + columns + "' type='number'>      </div>      <div class='label_value'>        <label for='subtest_timer' title='Seconds to give the child to complete the test. Setting this value to 0 will make the test untimed.'>Timer</label><br>        <input id='subtest_timer' value='" + timer + "' type='number'>      </div>      <button class='save_subtest command'>Done</button>      ");
    return this.trigger("rendered");
  };

  return KlassSubtestEditView;

})(Backbone.View);
