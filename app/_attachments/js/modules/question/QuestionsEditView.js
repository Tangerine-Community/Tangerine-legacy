var QuestionsEditView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

QuestionsEditView = (function(_super) {

  __extends(QuestionsEditView, _super);

  function QuestionsEditView() {
    this.render = __bind(this.render, this);
    QuestionsEditView.__super__.constructor.apply(this, arguments);
  }

  QuestionsEditView.prototype.tagName = "ul";

  QuestionsEditView.prototype.className = "questions_edit_view";

  QuestionsEditView.prototype.initialize = function(options) {
    this.views = [];
    return this.questions = options.questions;
  };

  QuestionsEditView.prototype.onClose = function() {
    return this.closeViews();
  };

  QuestionsEditView.prototype.closeViews = function() {
    var view, _i, _len, _ref, _results;
    _ref = this.views;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      view = _ref[_i];
      _results.push(view.close());
    }
    return _results;
  };

  QuestionsEditView.prototype.render = function() {
    var i, question, view, _len, _ref,
      _this = this;
    this.closeViews();
    _ref = this.questions.models;
    for (i = 0, _len = _ref.length; i < _len; i++) {
      question = _ref[i];
      view = new QuestionsEditListElementView({
        "question": question
      });
      this.views.push(view);
      view.on("deleted", this.render);
      view.render();
      this.$el.append(view.el);
    }
    return this.$el.sortable({
      handle: '.sortable_handle',
      start: function(event, ui) {
        return ui.item.addClass("drag_shadow");
      },
      stop: function(event, ui) {
        return ui.item.removeClass("drag_shadow");
      },
      update: function(event, ui) {
        var i, id, li, oneQuestion, _len2, _ref2, _results;
        _ref2 = (function() {
          var _i, _len2, _ref2, _results2;
          _ref2 = this.$el.find("li.question_list_element");
          _results2 = [];
          for (_i = 0, _len2 = _ref2.length; _i < _len2; _i++) {
            li = _ref2[_i];
            _results2.push($(li).attr("data-id"));
          }
          return _results2;
        }).call(_this);
        _results = [];
        for (i = 0, _len2 = _ref2.length; i < _len2; i++) {
          id = _ref2[i];
          oneQuestion = _this.questions.get(id);
          _results.push(_this.questions.get(id).set({
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
  };

  return QuestionsEditView;

})(Backbone.View);
