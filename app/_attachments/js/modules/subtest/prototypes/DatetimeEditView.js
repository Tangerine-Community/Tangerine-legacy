var DatetimeEditView,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

DatetimeEditView = (function(_super) {

  __extends(DatetimeEditView, _super);

  function DatetimeEditView() {
    DatetimeEditView.__super__.constructor.apply(this, arguments);
  }

  DatetimeEditView.prototype.initialize = function(options) {
    this.model = options.model;
    return this.parent = options.parent;
  };

  return DatetimeEditView;

})(Backbone.View);
