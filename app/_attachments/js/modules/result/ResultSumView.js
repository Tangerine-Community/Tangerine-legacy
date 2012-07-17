var ResultSumView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

ResultSumView = (function(_super) {

  __extends(ResultSumView, _super);

  function ResultSumView() {
    this.afterRender = __bind(this.afterRender, this);
    ResultSumView.__super__.constructor.apply(this, arguments);
  }

  ResultSumView.prototype.className = "info_box";

  ResultSumView.prototype.events = {
    'click .details': 'toggleDetails'
  };

  ResultSumView.prototype.toggleDetails = function() {
    return this.$el.find('.detail_box').toggle(250);
  };

  ResultSumView.prototype.initialize = function(options) {
    return this.model = options.model;
  };

  ResultSumView.prototype.render = function() {
    var datum, html, i, _len, _ref;
    html = "<div>        " + (moment(new Date(this.model.get('timestamp'))).format('YYYY-MMM-DD HH:mm')) + "        (" + (moment(new Date(this.model.get('timestamp'))).fromNow()) + ")        <button class='details command'>details</button>      </div>      <div class='confirmation detail_box'>";
    _ref = this.model.get("subtestData");
    for (i = 0, _len = _ref.length; i < _len; i++) {
      datum = _ref[i];
      datum.name_safe = datum.name.replace(/\s/g, "_");
      html += "<div><span id='" + this.cid + "_" + datum.name_safe + "_" + i + "'></span>" + datum.name + " - items " + datum.sum.total + "</div>";
    }
    html += "      </div>    ";
    this.$el.html(html);
    return this.trigger("rendered");
  };

  ResultSumView.prototype.afterRender = function() {
    var datum, i, spark_id, _len, _ref, _results;
    _ref = this.model.get("subtestData");
    _results = [];
    for (i = 0, _len = _ref.length; i < _len; i++) {
      datum = _ref[i];
      datum.name_safe = datum.name.replace(/\s/g, "_");
      spark_id = "#" + this.cid + "_" + datum.name_safe + "_" + i;
      _results.push(this.$el.find(spark_id).sparkline([datum.sum.correct, datum.sum.incorrect, datum.sum.missing], {
        type: 'pie',
        width: '30',
        height: '30',
        sliceColors: ["#6f6", "#c66", "#ccc"]
      }));
    }
    return _results;
  };

  return ResultSumView;

})(Backbone.View);
