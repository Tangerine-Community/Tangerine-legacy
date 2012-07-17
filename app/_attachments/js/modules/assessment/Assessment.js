var Assessment,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Assessment = (function(_super) {

  __extends(Assessment, _super);

  function Assessment() {
    this.fetch = __bind(this.fetch, this);
    Assessment.__super__.constructor.apply(this, arguments);
  }

  Assessment.prototype.url = 'assessment';

  Assessment.prototype.initialize = function(options) {
    if (options == null) options = {};
    return this.subtests = new Subtests;
  };

  Assessment.prototype.fetch = function(options) {
    var oldSuccess,
      _this = this;
    oldSuccess = options.success;
    options.success = function(model) {
      var allSubtests;
      allSubtests = new Subtests;
      return allSubtests.fetch({
        key: _this.id,
        success: function(collection) {
          _this.subtests = collection;
          _this.subtests.maintainOrder();
          return typeof oldSuccess === "function" ? oldSuccess(_this) : void 0;
        }
      });
    };
    return Assessment.__super__.fetch.call(this, options);
  };

  Assessment.prototype.duplicate = function(assessmentAttributes, subtestAttributes, questionAttributes, callback) {
    var newModel, originalId, questions,
      _this = this;
    originalId = this.id;
    newModel = this.clone();
    newModel.set(assessmentAttributes);
    newModel.set("_id", Utils.guid());
    newModel.save(null, {
      "wait": true
    });
    questions = new Questions;
    return questions.fetch({
      success: function(questions) {
        var filteredQuestions, subtests;
        filteredQuestions = questions.where({
          "assessmentId": originalId
        });
        subtests = new Subtests;
        return subtests.fetch({
          key: originalId,
          success: function(subtests) {
            var filteredSubtests, gridId, i, model, newQuestion, newQuestions, newSubtest, newSubtestId, newSubtests, oldId, question, subtestIdMap, _i, _len, _len2, _len3;
            filteredSubtests = subtests.models;
            subtestIdMap = {};
            newSubtests = [];
            for (i = 0, _len = filteredSubtests.length; i < _len; i++) {
              model = filteredSubtests[i];
              newSubtest = model.clone();
              newSubtest.set("assessmentId", newModel.id);
              newSubtestId = Utils.guid();
              subtestIdMap[newSubtest.id] = newSubtestId;
              newSubtest.set("_id", newSubtestId);
              newSubtests.push(newSubtest);
            }
            for (i = 0, _len2 = newSubtests.length; i < _len2; i++) {
              model = newSubtests[i];
              gridId = model.get("gridLinkId");
              if ((gridId || "") !== "") {
                model.set("gridLinkId", subtestIdMap[gridId]);
              }
              model.save();
            }
            newQuestions = [];
            for (_i = 0, _len3 = filteredQuestions.length; _i < _len3; _i++) {
              question = filteredQuestions[_i];
              newQuestion = question.clone();
              oldId = newQuestion.get("subtestId");
              newQuestion.set("assessmentId", newModel.id);
              newQuestion.set("_id", Utils.guid());
              newQuestion.set("subtestId", subtestIdMap[oldId]);
              newQuestions.push(newQuestion);
              newQuestion.save();
            }
            return callback();
          }
        });
      }
    });
  };

  Assessment.prototype.destroy = function() {
    var assessmentId, questions, subtests;
    assessmentId = this.id;
    subtests = new Subtests;
    subtests.fetch({
      key: assessmentId,
      success: function(collection) {
        var _results;
        _results = [];
        while (collection.length !== 0) {
          _results.push(collection.pop().destroy());
        }
        return _results;
      }
    });
    questions = new Questions;
    questions.fetch({
      success: function(collection) {
        var model, _i, _len, _ref, _results;
        _ref = collection.where({
          "assessmentId": assessmentId
        });
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          model = _ref[_i];
          _results.push(model.destroy());
        }
        return _results;
      }
    });
    return Assessment.__super__.destroy.call(this);
  };

  return Assessment;

})(Backbone.Model);
