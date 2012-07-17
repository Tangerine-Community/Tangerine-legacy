var Subtest,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Subtest = (function(_super) {

  __extends(Subtest, _super);

  function Subtest() {
    Subtest.__super__.constructor.apply(this, arguments);
  }

  Subtest.prototype.url = "subtest";

  Subtest.prototype.initialize = function(options) {
    return this.templates = Tangerine.config.prototypeTemplates;
  };

  Subtest.prototype.loadPrototypeTemplate = function(prototype) {
    var key, value, _ref;
    _ref = this.templates[prototype];
    for (key in _ref) {
      value = _ref[key];
      this.set(key, value);
    }
    return this.save();
  };

  return Subtest;

})(Backbone.Model);
