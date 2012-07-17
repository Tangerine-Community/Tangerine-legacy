var ErrorView,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

ErrorView = (function(_super) {

  __extends(ErrorView, _super);

  function ErrorView() {
    ErrorView.__super__.constructor.apply(this, arguments);
  }

  ErrorView.prototype.initialize = function(options) {
    this.message = options.message;
    return this.details = options.details;
  };

  ErrorView.prototype.render = function() {
    this.$el.html("    <h2>Oops</h2>    <p>" + this.message + "</p>    <p>Sorry about that.</p>    <p>" + this.details + "</p>    ");
    return this.trigger("rendered");
  };

  return ErrorView;

})(Backbone.View);
