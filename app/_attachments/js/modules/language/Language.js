var Language,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Language = (function(_super) {

  __extends(Language, _super);

  function Language() {
    Language.__super__.constructor.apply(this, arguments);
  }

  Language.prototype.url = "/Language";

  Language.prototype.initialize = function(options) {
    return this.loadLanguage(options);
  };

  Language.prototype.loadLanguage = function() {
    var _this = this;
    window.t = this.translate;
    return this.fetch({
      success: function() {
        return $.i18n.setDictionary(_this.get("dictionary"));
      }
    });
  };

  Language.prototype.translate = function(string) {
    return $.i18n._(string).titleize();
  };

  return Language;

})(Backbone.Model);
