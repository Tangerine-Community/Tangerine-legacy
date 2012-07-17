var IdEditView,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

IdEditView = (function(_super) {

  __extends(IdEditView, _super);

  function IdEditView() {
    IdEditView.__super__.constructor.apply(this, arguments);
  }

  IdEditView.prototype.initialize = function(options) {
    this.model = options.model;
    return this.parent = options.parent;
  };

  return IdEditView;

})(Backbone.View);
