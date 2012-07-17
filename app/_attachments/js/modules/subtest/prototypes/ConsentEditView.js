var ConsentEditView,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

ConsentEditView = (function(_super) {

  __extends(ConsentEditView, _super);

  function ConsentEditView() {
    ConsentEditView.__super__.constructor.apply(this, arguments);
  }

  ConsentEditView.prototype.initialize = function(options) {
    this.model = options.model;
    return this.parent = options.parent;
  };

  ConsentEditView.prototype.save = function() {
    return this.model.set({
      "prompt": this.$el.find("#consent_prompt").val()
    });
  };

  ConsentEditView.prototype.render = function() {
    var prompt;
    prompt = this.model.get("prompt") || "";
    return this.$el.html("      <div class='label_value'>        <label for='consent_prompt'>Consent prompt</label>        <input id='consent_prompt' value='" + prompt + "'>      </div>    ");
  };

  return ConsentEditView;

})(Backbone.View);
