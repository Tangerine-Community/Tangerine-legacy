var SubtestEditView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

SubtestEditView = (function(_super) {

  __extends(SubtestEditView, _super);

  function SubtestEditView() {
    this.goBack = __bind(this.goBack, this);
    SubtestEditView.__super__.constructor.apply(this, arguments);
  }

  SubtestEditView.prototype.className = "subtest_edit";

  SubtestEditView.prototype.events = {
    'click .back_button': 'goBack',
    'click .save_subtest': 'save',
    'click .edit_enumerator': 'editEnumerator',
    'click .enumerator_done': 'doneEnumerator',
    'click .enumerator_cancel': 'cancelEnumerator',
    'click .edit_student': 'editStudent',
    'click .student_done': 'doneStudent',
    'click .student_cancel': 'cancelStudent'
  };

  SubtestEditView.prototype.editEnumerator = function() {
    this.$el.find(".enumerator_help_preview, .edit_enumerator, .enumerator_save_buttons").fadeToggle(250);
    return this.$el.find("textarea#enumerator_help").html(this.model.escape("enumeratorHelp") || "").cleditor();
  };

  SubtestEditView.prototype.doneEnumerator = function() {
    if (this.model.save({
      "enumeratorHelp": this.$el.find("textarea#enumerator_help").val(),
      wait: true
    })) {
      return this.cancelEnumerator();
    } else {
      return console.log("save error");
    }
  };

  SubtestEditView.prototype.cancelEnumerator = function() {
    var $preview, cleditor;
    $preview = $("div.enumerator_help_preview");
    $preview.html(this.model.get("enumeratorHelp") || "");
    $preview.fadeIn(250);
    this.$el.find("button.edit_enumerator, .enumerator_save_buttons").fadeToggle(250);
    cleditor = this.$el.find("#enumerator_help").cleditor()[0];
    cleditor.$area.insertBefore(cleditor.$main);
    cleditor.$area.removeData("cleditor");
    return cleditor.$main.remove();
  };

  SubtestEditView.prototype.editStudent = function() {
    this.$el.find(".student_dialog_preview, .edit_student, .student_save_buttons").fadeToggle(250);
    return this.$el.find("textarea#student_dialog").html(this.model.escape("studentDialog") || "").cleditor();
  };

  SubtestEditView.prototype.doneStudent = function() {
    if (this.model.save({
      "studentDialog": this.$el.find("textarea#student_dialog").val(),
      wait: true
    })) {
      return this.cancelStudent();
    } else {
      return console.log("save error");
    }
  };

  SubtestEditView.prototype.cancelStudent = function() {
    var $preview, cleditor;
    $preview = $("div.student_dialog_preview");
    $preview.html(this.model.get("studentDialog") || "");
    $preview.fadeIn(250);
    this.$el.find("button.edit_student, .student_save_buttons").fadeToggle(250);
    cleditor = this.$el.find("#student_dialog").cleditor()[0];
    cleditor.$area.insertBefore(cleditor.$main);
    cleditor.$area.removeData("cleditor");
    return cleditor.$main.remove();
  };

  SubtestEditView.prototype.onClose = function() {
    var _base;
    return typeof (_base = this.prototypeEditor).close === "function" ? _base.close() : void 0;
  };

  SubtestEditView.prototype.initialize = function(options) {
    this.model = options.model;
    this.config = Tangerine.config.subtest;
    this.prototypeViews = Tangerine.config.prototypeViews;
    return this.prototypeEditor = new window[this.prototypeViews[this.model.get('prototype')]['edit']]({
      model: this.model,
      parent: this
    });
  };

  SubtestEditView.prototype.goBack = function() {
    return Tangerine.router.navigate("edit/" + this.model.get("assessmentId"), true);
  };

  SubtestEditView.prototype.save = function(event) {
    var prototype, _base, _base2;
    prototype = this.model.get("prototype");
    this.model.set({
      name: this.$el.find("#subtest_name").val(),
      enumeratorHelp: this.$el.find("#enumerator_help").val(),
      studentDialog: this.$el.find("#student_dialog").val(),
      skippable: this.$el.find("#skip_radio input:radio[name=skippable]:checked").val() === "true"
    });
    if (typeof (_base = this.prototypeEditor).save === "function") _base.save();
    if ((this.prototypeEditor.isValid != null) && this.prototypeEditor.isValid() === false) {
      Utils.midAlert("There are errors on this page");
      return typeof (_base2 = this.prototypeEditor).showErrors === "function" ? _base2.showErrors() : void 0;
    } else {
      if (this.model.save(null, {
        wait: true
      })) {
        Utils.midAlert("Subtest Saved");
        return setTimeout(this.goBack, 1000);
      } else {
        console.log("save error");
        return Utils.midAlert("Save error");
      }
    }
  };

  SubtestEditView.prototype.render = function() {
    var dialog, help, name, prototype, skippable, _base;
    name = this.model.escape("name");
    prototype = this.model.get("prototype");
    help = this.model.get("enumeratorHelp") || "";
    dialog = this.model.get("studentDialog") || "";
    skippable = this.model.get("skippable") === true || this.model.get("skippable") === "true";
    this.$el.html("      <button class='back_button navigation'>Back</button><br>      <h1>Subtest Editor</h1>      <button class='save_subtest command'>Done</button>      <div id='subtest_edit_form'>        <div class='label_value'>          <label for='subtest_name'>Name</label>          <input id='subtest_name' value='" + name + "'>        </div>        <div class='label_value'>          <label for='subtest_prototype' title='This is a basic type of subtest. (e.g. Survey, Grid, Location, Id, Consent). This property is set in assessment builder when you add a subtest. It is unchangeable.'>Prototype</label><br>          <div class='info_box'>" + prototype + "</div>        </div>        <div class='label_value'>          <label>Skippable</label><br>          <div class='menu_box'>            <div id='skip_radio' class='buttonset'>              <label for='skip_true'>Yes</label><input name='skippable' type='radio' value='true' id='skip_true' " + (skippable ? 'checked' : void 0) + ">              <label for='skip_false'>No</label><input name='skippable' type='radio' value='false' id='skip_false' " + (!skippable ? 'checked' : void 0) + ">            </div>          </div>        </div>        <div class='label_value'>          <label for='enumerator_help'>Enumerator help <button class='edit_enumerator command'>Edit</button></label>          <div class='info_box_wide enumerator_help_preview'>" + help + "</div>          <textarea id='enumerator_help' class='confirmation'>" + help + "</textarea>          <div class='enumerator_save_buttons confirmation'>            <button class='enumerator_done command'>Save</button> <button class='enumerator_cancel command'>Cancel</button>          </div>        </div>        <div class='label_value'>          <label for='student_dialog'>Student Dialog <button class='edit_student command'>Edit</button></label>          <div class='info_box_wide student_dialog_preview'>" + dialog + "</div>          <textarea id='student_dialog' class='confirmation'>" + dialog + "</textarea>          <div class='student_save_buttons confirmation'>            <button class='student_done command'>Save</button> <button class='student_cancel command'>Cancel</button>          </div>        </div>        <div id='prototype_attributes'></div>      </div>      <button class='save_subtest command'>Done</button>      ");
    this.prototypeEditor.setElement(this.$el.find('#prototype_attributes'));
    if (typeof (_base = this.prototypeEditor).render === "function") {
      _base.render();
    }
    return this.trigger("rendered");
  };

  return SubtestEditView;

})(Backbone.View);
