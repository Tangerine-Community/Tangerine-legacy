var Log, LogView, Logs,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Log = (function(_super) {

  __extends(Log, _super);

  function Log() {
    Log.__super__.constructor.apply(this, arguments);
  }

  Log.prototype.url = "log";

  Log.prototype.defaults = {
    type: "none",
    details: "none",
    timestamp: 0,
    user: "no one"
  };

  Log.prototype.initialize = function(options) {
    this.set({
      type: options.type,
      details: options.details,
      timestamp: (new Date()).getTime(),
      user: Tangerine.user.name
    });
    return this.save();
  };

  return Log;

})(Backbone.Model);

Logs = (function(_super) {

  __extends(Logs, _super);

  function Logs() {
    Logs.__super__.constructor.apply(this, arguments);
  }

  Logs.prototype.url = "log";

  Logs.prototype.model = Log;

  Logs.prototype.comparator = function(model) {
    return model.get("timestamp");
  };

  return Logs;

})(Backbone.Collection);

LogView = (function(_super) {

  __extends(LogView, _super);

  function LogView() {
    LogView.__super__.constructor.apply(this, arguments);
  }

  LogView.prototype.initialize = function() {
    this.allLogs = new Logs;
    return this.allLogs.fetch({
      success: function(collection) {
        return this.logs = collection.where({
          user: Tangerine.user.name
        });
      }
    });
  };

  LogView.prototype.render = function() {
    var html, log, _i, _len, _ref;
    html = "<table><th><td>time</td><td>type</td><td>details</td></th>";
    _ref = this.logs;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      log = _ref[_i];
      html += "<tr><td>" + (log.get("timestamp")) + "</td><td>" + (log.get("type")) + "</td><td>" + (log.get("details")) + "</td></tr>";
    }
    html += "</table>";
    this.$el.html(html);
    return this.trigger("rendered");
  };

  return LogView;

})(Backbone.View);
