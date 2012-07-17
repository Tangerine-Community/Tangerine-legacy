var AssessmentEditView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

AssessmentEditView = (function(_super) {

  __extends(AssessmentEditView, _super);

  function AssessmentEditView() {
    this.render = __bind(this.render, this);
    this.saveNewSubtest = __bind(this.saveNewSubtest, this);
    this.updateModel = __bind(this.updateModel, this);
    this.save = __bind(this.save, this);
    AssessmentEditView.__super__.constructor.apply(this, arguments);
  }

  AssessmentEditView.prototype.className = 'assessment_edit_view';

  AssessmentEditView.prototype.events = {
    'click #archive_buttons input': 'save',
    'click .back': 'back',
    'click .new_subtest_button': 'toggleNewSubtestForm',
    'click .new_subtest_cancel': 'toggleNewSubtestForm',
    'keypress #new_subtest_name': 'saveNewSubtest',
    'click .new_subtest_save': 'saveNewSubtest',
    'keypress #basic input': 'showSave',
    'click .assessment_save': 'save'
  };

  AssessmentEditView.prototype.save = function() {
    if (this.updateModel()) {
      if (this.model.save({
        wait: true
      })) {
        Utils.midAlert("Assessment saved");
        Tangerine.router.navigate("edit/" + this.model.id, true);
        return this.hideSave();
      }
    }
  };

  AssessmentEditView.prototype.showSave = function() {
    return this.$el.find('.assessment_save').fadeIn(250);
  };

  AssessmentEditView.prototype.hideSave = function() {
    return this.$el.find('.assessment_save').fadeToggle(250);
  };

  AssessmentEditView.prototype.back = function() {
    return Tangerine.router.navigate("assessments/" + (this.model.get("group")), true);
  };

  AssessmentEditView.prototype.updateModel = function() {
    var groups;
    groups = Tangerine.user.get("groups");
    if (!~groups.indexOf(this.$el.find("#assessment_group").val())) {
      alert("Warning\n\nYou cannot join a group unless you are a member of that group.");
      this.$el.find("#assessment_group").val(this.model.escape("group"));
      this.hideSave();
      return false;
    } else {
      this.model.set({
        archived: this.$el.find("#archive_buttons input:checked").val(),
        name: this.$el.find("#assessment_name").val(),
        group: this.$el.find("#assessment_group").val(),
        dKey: this.$el.find("#assessment_d_key").val(),
        assessmentId: this.model.id
      });
      return true;
    }
  };

  AssessmentEditView.prototype.toggleNewSubtestForm = function(event) {
    var _this = this;
    this.$el.find(".new_subtest_form, .new_subtest_button").fadeToggle(250, function() {
      _this.$el.find("#new_subtest_name").val("");
      return _this.$el.find("#subtest_type_select").val("none");
    });
    return false;
  };

  AssessmentEditView.prototype.saveNewSubtest = function(event) {
    var newAttributes, newSubtest, prototypeTemplate, useType, useTypeTemplate;
    if (event.type !== "click" && event.which !== 13) return true;
    newAttributes = Tangerine.config.subtestTemplate;
    prototypeTemplate = Tangerine.config.prototypeTemplates[this.$el.find("#subtest_type_select").val()];
    useType = this.$el.find("#subtest_type_select :selected").attr('data-template');
    useTypeTemplate = Tangerine.config.subtestTemplates[this.$el.find("#subtest_type_select").val()][useType];
    newAttributes = $.extend(newAttributes, prototypeTemplate);
    newAttributes = $.extend(newAttributes, useTypeTemplate);
    newAttributes = $.extend(newAttributes, {
      name: this.$el.find("#new_subtest_name").val(),
      assessmentId: this.model.id,
      order: this.model.subtests.length
    });
    newSubtest = this.model.subtests.create(newAttributes);
    this.toggleNewSubtestForm();
    return false;
  };

  AssessmentEditView.prototype.initialize = function(options) {
    this.model = options.model;
    this.subtestListEditView = new SubtestListEditView({
      model: this.model
    });
    return this.model.subtests.on("change remove", this.subtestListEditView.render);
  };

  AssessmentEditView.prototype.render = function() {
    var arch, archiveChecked, key, notArchiveChecked, subKey, subValue, subtestTypeSelect, value, _ref,
      _this = this;
    arch = this.model.get('archived');
    archiveChecked = arch === true || arch === 'true' ? "checked" : "";
    notArchiveChecked = archiveChecked ? "" : "checked";
    subtestTypeSelect = "<select id='subtest_type_select'>      <option value='none' disabled='disabled' selected='selected'>Please select a subtest type</option>";
    _ref = Tangerine.config.subtestTemplates;
    for (key in _ref) {
      value = _ref[key];
      subtestTypeSelect += "<optgroup label='" + key + "'>";
      for (subKey in value) {
        subValue = value[subKey];
        subtestTypeSelect += "<option value='" + key + "' data-template='" + subKey + "'>" + subKey + "</option>";
      }
      subtestTypeSelect += "</optgroup>";
    }
    subtestTypeSelect += "</select>";
    this.$el.html("      <button class='back navigation'>Back</button>        <h1>Assessment Builder</h1>      <div id='basic'>        <label for='assessment_name'>Name</label>        <input id='assessment_name' value='" + (this.model.escape("name")) + "'>        <label for='assessment_group'>Group</label>        <input id='assessment_group' value='" + (this.model.escape("group")) + "'>        <button class='assessment_save confirmation'>Save</button><br>        <label for='assessment_d_key' title='This key is used to import the assessment from a tablet'>Download Key</label><br>        <div class='info_box'>" + (this.model.id.substr(-5, 5)) + "</div>      </div>      <label title='Only active assessments will be displayed in the main assessment list.'>Status</label><br>      <div id='archive_buttons' class='buttonset'>        <input type='radio' id='archive_false' name='archive' value='false' " + notArchiveChecked + "><label for='archive_false'>Active</label>        <input type='radio' id='archive_true'  name='archive' value='true'  " + archiveChecked + "><label for='archive_true'>Archived</label>      </div>      <h2>Subtests</h2>      <div class='menu_box'>        <div>        <ul id='subtest_list'>        </ul>        </div>        <button class='new_subtest_button command'>Add Subtest</button>        <div class='new_subtest_form confirmation'>          <div class='menu_box'>            <h2>New Subtest</h2>            <label for='subtest_type_select'>Type</label><br>            " + subtestTypeSelect + "<br>            <label for='new_subtest_name'>Name</label><br>            <input type='text' id='new_subtest_name'>            <button class='new_subtest_save command'>Add</button> <button class='new_subtest_cancel command'>Cancel</button>          </div>        </div>      </div>");
    this.subtestListEditView.setElement(this.$el.find("#subtest_list"));
    this.subtestListEditView.render();
    this.$el.find("#subtest_list").sortable({
      handle: '.sortable_handle',
      start: function(event, ui) {
        return ui.item.addClass("drag_shadow");
      },
      stop: function(event, ui) {
        return ui.item.removeClass("drag_shadow");
      },
      update: function(event, ui) {
        var i, id, li, _len, _ref2, _results;
        _ref2 = (function() {
          var _i, _len, _ref2, _results2;
          _ref2 = this.$el.find("#subtest_list li");
          _results2 = [];
          for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
            li = _ref2[_i];
            _results2.push($(li).attr("data-id"));
          }
          return _results2;
        }).call(_this);
        _results = [];
        for (i = 0, _len = _ref2.length; i < _len; i++) {
          id = _ref2[i];
          _results.push(_this.model.subtests.get(id).set({
            "order": i
          }, {
            silent: true
          }).save(null, {
            silent: true
          }));
        }
        return _results;
      }
    });
    return this.trigger("rendered");
  };

  AssessmentEditView.prototype.onClose = function() {
    return this.subtestListEditView.close();
  };

  return AssessmentEditView;

})(Backbone.View);
