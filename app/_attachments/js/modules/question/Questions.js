var Questions,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Questions = (function(_super) {

  __extends(Questions, _super);

  function Questions() {
    Questions.__super__.constructor.apply(this, arguments);
  }

  Questions.prototype.model = Question;

  Questions.prototype.url = "question";

  Questions.prototype.comparator = function(subtest) {
    return subtest.get("order");
  };

  Questions.prototype.maintainOrder = function() {
    var i, model, ordered, subtest, test, _len, _ref, _results;
    test = ((function() {
      var _i, _len, _ref, _results;
      _ref = this.models;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        model = _ref[_i];
        _results.push(model.get("order"));
      }
      return _results;
    }).call(this)).join("");
    ordered = ((function() {
      var _len, _ref, _results;
      _ref = this.models;
      _results = [];
      for (i = 0, _len = _ref.length; i < _len; i++) {
        model = _ref[i];
        _results.push(i);
      }
      return _results;
    }).call(this)).join("");
    if (test !== ordered) {
      _ref = this.models;
      _results = [];
      for (i = 0, _len = _ref.length; i < _len; i++) {
        subtest = _ref[i];
        subtest.set("order", i);
        _results.push(subtest.save());
      }
      return _results;
    }
  };

  return Questions;

})(Backbone.Collection);
