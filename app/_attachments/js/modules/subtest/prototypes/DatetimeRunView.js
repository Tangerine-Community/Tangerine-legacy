var DatetimeRunView,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

DatetimeRunView = (function(_super) {

  __extends(DatetimeRunView, _super);

  function DatetimeRunView() {
    DatetimeRunView.__super__.constructor.apply(this, arguments);
  }

  DatetimeRunView.prototype.className = "datetime";

  DatetimeRunView.prototype.initialize = function(options) {
    this.model = this.options.model;
    return this.parent = this.options.parent;
  };

  DatetimeRunView.prototype.render = function() {
    var dateTime, day, minutes, month, time, year;
    dateTime = new Date();
    year = dateTime.getFullYear();
    month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][dateTime.getMonth()];
    day = dateTime.getDate();
    minutes = dateTime.getMinutes();
    if (minutes < 10) minutes = "0" + minutes;
    time = dateTime.getHours() + ":" + minutes;
    this.$el.html("      <form>          <table>            <tr>              <td><label for='year'>Year</label><input id='year' name='year' value='" + year + "'></td>              <td><label for='month'>Month</label><input id='month' type='month' name='month' value='" + month + "'></td>              <td><label for='day'>Day</label><input id='day' type='day' name='day' value='" + day + "'></td>            </tr>          </table>          <label for='time'>Time</label><input type='text' id='time' name='time' value='" + time + "'>      </form>      ");
    return this.trigger("rendered");
  };

  DatetimeRunView.prototype.getResult = function() {
    return {
      "year": this.$el.find("#year").val(),
      "month": this.$el.find("#month").val(),
      "day": this.$el.find("#day").val(),
      "time": this.$el.find("#time").val()
    };
  };

  DatetimeRunView.prototype.getSum = function() {
    return {
      correct: 1,
      incorrect: 0,
      missing: 0,
      total: 1
    };
  };

  DatetimeRunView.prototype.isValid = function() {
    return true;
  };

  return DatetimeRunView;

})(Backbone.View);
