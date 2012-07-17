var Device,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Device = (function(_super) {

  __extends(Device, _super);

  function Device() {
    Device.__super__.constructor.apply(this, arguments);
  }

  Device.prototype.url = "device";

  Device.prototype.initialize = function() {
    return this.set({
      _id: "TangerineDeviceConfiguration",
      context: null
    });
  };

  return Device;

})(Backbone.Model);
