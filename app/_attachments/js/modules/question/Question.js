var Question,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Question = (function(_super) {

  __extends(Question, _super);

  function Question() {
    Question.__super__.constructor.apply(this, arguments);
  }

  Question.prototype.url = "question";

  Question.prototype.config = {
    types: ["multiple", "single", "open"]
  };

  Question.prototype["default"] = {
    order: 0,
    prompt: "Is this an example question?",
    hint: "[hint or answer]",
    type: "single",
    otherWriteIn: false,
    options: [],
    linkedGridScore: 0,
    skipLink: null,
    skipRequirement: null
  };

  Question.prototype.initialize = function(options) {};

  return Question;

})(Backbone.Model);
