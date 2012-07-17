var SurveyEditView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

SurveyEditView = (function(_super) {

  __extends(SurveyEditView, _super);

  function SurveyEditView() {
    this.renderQuestions = __bind(this.renderQuestions, this);
    this.toggleAddQuestion = __bind(this.toggleAddQuestion, this);
    SurveyEditView.__super__.constructor.apply(this, arguments);
  }

  SurveyEditView.prototype.events = {
    'click .add_question': 'toggleAddQuestion',
    'click .add_question_cancel': 'toggleAddQuestion',
    'click .add_question_add': 'addQuestion',
    'keypress #question_name': 'addQuestion'
  };

  SurveyEditView.prototype.initialize = function(options) {
    var _this = this;
    this.model = options.model;
    this.parent = options.parent;
    this.model.questions = new Questions;
    return this.model.questions.fetch({
      success: function(collection, response) {
        _this.model.questions = new Questions(collection.where({
          subtestId: _this.model.id
        }));
        _this.model.questions.maintainOrder();
        _this.questionsEditView = new QuestionsEditView({
          questions: _this.model.questions
        });
        _this.model.questions.on("change", _this.renderQuestions);
        return _this.renderQuestions();
      }
    });
  };

  SurveyEditView.prototype.toggleAddQuestion = function() {
    var _this = this;
    this.$el.find("#add_question_form, .add_question").fadeToggle(250, function() {
      if (_this.$el.find("#add_question_form").is(":visible")) {
        return _this.$el.find("#question_prompt").focus();
      }
    });
    return false;
  };

  SurveyEditView.prototype.addQuestion = function(event) {
    var newAttributes, nq;
    if (event.type !== "click" && event.which !== 13) return true;
    newAttributes = $.extend(Tangerine.config.questionTemplate, {
      subtestId: this.model.id,
      assessmentId: this.model.get("assessmentId"),
      id: Utils.guid(),
      order: this.model.questions.length,
      prompt: this.$el.find('#question_prompt').val(),
      name: this.$el.find('#question_name').val().replace(/\s/g, "_").replace(/[^a-zA-Z0-9_]/g, "")
    });
    nq = this.model.questions.create(newAttributes);
    this.renderQuestions();
    this.$el.find("#add_question_form input").val('');
    this.$el.find("#question_prompt").focus();
    return false;
  };

  SurveyEditView.prototype.save = function() {
    var emptyOptions, i, notSaved, plural, question, requiresGrid, _has, _len, _question, _ref, _require;
    this.model.set({
      gridLinkId: this.$el.find("#link_select option:selected").val()
    });
    notSaved = [];
    emptyOptions = [];
    requiresGrid = [];
    _ref = this.model.questions.models;
    for (i = 0, _len = _ref.length; i < _len; i++) {
      question = _ref[i];
      if (question.get("type") !== "open" && question.get("options").length === 0) {
        emptyOptions.push(i + 1);
      }
      if (!question.save()) notSaved.push(i);
      if (question.has("linkedGridScore") && question.get("linkedGridScore") !== "" && question.get("linkedGridScore") !== 0 && this.model.has("gridLinkId") === "" && this.model.get("gridLinkId") === "") {
        requiresGrid.push(i);
      }
    }
    if (notSaved.length !== 0) {
      Utils.midAlert("Error<br><br>Questions: <br>" + (notSaved.join(', ')) + "<br>not saved");
    }
    if (emptyOptions.length !== 0) {
      plural = emptyOptions.length > 1;
      _question = plural ? "Questions" : "Question";
      _has = plural ? "have" : "has";
      alert("Warning\n\n" + _question + " " + (emptyOptions.join(' ,')) + " " + _has + " no options.");
    }
    if (requiresGrid.length !== 0) {
      plural = emptyOptions.length > 1;
      _question = plural ? "Questions" : "Question";
      _require = plural ? "require" : "requires";
      return alert("Warning\n\n" + _question + " " + (requiresGrid.join(' ,')) + " " + _require + " a grid to be linked to this test.");
    }
  };

  SurveyEditView.prototype.onClose = function() {
    var _ref;
    return (_ref = this.questionsListEdit) != null ? _ref.close() : void 0;
  };

  SurveyEditView.prototype.renderQuestions = function() {
    var _ref, _ref2;
    this.$el.find("#question_list_wrapper").empty();
    if ((_ref = this.questionsEditView) != null) _ref.render();
    return this.$el.find("#question_list_wrapper").append((_ref2 = this.questionsEditView) != null ? _ref2.el : void 0);
  };

  SurveyEditView.prototype.render = function() {
    var gridLinkId, subtests,
      _this = this;
    gridLinkId = this.model.get("gridLinkId") || "";
    this.$el.html("      <div id='grid_link'></div>      <div id='questions'>        <h2>Questions</h2>        <div class='menu_box'>          <div id='question_list_wrapper'><img class='loading' src='images/loading.gif'></div>          <button class='add_question command'>Add Question</button>          <div id='add_question_form' class='confirmation'>            <div class='menu_box'>              <h2>New Question</h2>              <label for='question_prompt'>Prompt</label>              <input id='question_prompt'>              <label for='question_name'>Variable name</label>              <input id='question_name' title='Allowed characters: A-Z, a-z, 0-9, and underscores.'><br>              <button class='add_question_add command'>Add</button><button class='add_question_cancel command'>Cancel</button>            </div>          </div>         </div>      </div>");
    this.renderQuestions();
    subtests = new Subtests;
    return subtests.fetch({
      key: this.model.get("assessmentId"),
      success: function(collection) {
        var linkSelect, subtest, _i, _len;
        collection = collection.where({
          prototype: 'grid'
        });
        linkSelect = "          <div class='label_value'>            <label for='link_select'>Linked to grid</label><br>            <div class='menu_box'>              <select id='link_select'>              <option value=''>None</option>";
        for (_i = 0, _len = collection.length; _i < _len; _i++) {
          subtest = collection[_i];
          linkSelect += "<option value='" + subtest.id + "' " + (gridLinkId === subtest.id ? 'selected' : '') + ">" + (subtest.get('name')) + "</option>";
        }
        linkSelect += "</select></div></div>";
        return _this.$el.find('#grid_link').html(linkSelect);
      }
    });
  };

  return SurveyEditView;

})(Backbone.View);
