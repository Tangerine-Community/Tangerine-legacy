var DeviceView,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

DeviceView = (function(_super) {

  __extends(DeviceView, _super);

  function DeviceView() {
    DeviceView.__super__.constructor.apply(this, arguments);
  }

  DeviceView.prototype.events = {
    'click #context input': 'set',
    'click #continue': 'continue'
  };

  DeviceView.prototype["continue"] = function() {
    this.model.save();
    return Tangerine.router.navigate("", true);
  };

  DeviceView.prototype.set = function() {
    console.log(this.$el.find('input:radio[name=context]:checked').val());
    return this.model.set({
      'context': this.$el.find('input:radio[name=context]:checked').val()
    });
  };

  DeviceView.prototype.initialize = function(options) {
    return this.model = options.model;
  };

  DeviceView.prototype.render = function() {
    this.$el.html("      <h1>Tangerine Setup</h1>      <p>Please select your configuration:</p>      <div class='label_value buttonset' id='context'>        <label for='context_cloud'>cloud</label><input id='context_cloud' name='context' type='radio' value='cloud' " + (this.model.get('context') === 'cloud' ? 'checked' : void 0) + ">        <label for='context_mobile'>mobile</label><input id='context_mobile' name='context' type='radio' value='mobile' " + (this.model.get('context') === 'mobile' ? 'checked' : void 0) + ">      </div>      <button id='continue'>continue</button>    ");
    return this.trigger("rendered");
  };

  return DeviceView;

})(Backbone.View);
