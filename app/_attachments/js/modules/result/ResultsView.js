var ResultsView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

ResultsView = (function(_super) {

  __extends(ResultsView, _super);

  function ResultsView() {
    this.afterRender = __bind(this.afterRender, this);
    ResultsView.__super__.constructor.apply(this, arguments);
  }

  ResultsView.prototype.events = {
    'click .cloud': 'cloud',
    'click .csv': 'csv',
    'click .tablets': 'tablets',
    'click .detect': 'detectOptions'
  };

  ResultsView.prototype.cloud = function() {
    var ajaxOptions, replicationOptions,
      _this = this;
    if (!this.available.cloud) {
      Utils.midAlert("Cannot detect cloud");
      return false;
    }
    this.$el.find(".status").find(".info_box").html("");
    ajaxOptions = {
      success: function() {
        _this.$el.find(".status").find(".info_box").html("Results uploaded successfully");
        return new Log({
          type: "replication",
          event: "cloud:success",
          assessmentId: _this.assessment.id
        });
      },
      error: function(res) {
        _this.$el.find(".status").find(".info_box").html("<div>Upload error</div><div>" + res + "</div>");
        return new Log({
          type: "replication",
          event: "cloud:error",
          assessmentId: _this.assessment.id
        });
      }
    };
    replicationOptions = {
      filter: "tangerine/resultFilter",
      query_params: {
        assessmentId: this.assessment.id
      }
    };
    return $.couch.replicate("tangerine", "http://tangerine.iriscouch.com/tangerine", ajaxOptions, replicationOptions);
  };

  ResultsView.prototype.tablets = function() {
    if (!this.available.tablets) {
      Utils.midAlert("Cannot detect cloud");
      return false;
    }
  };

  ResultsView.prototype.csv = function() {
    return Tangerine.router.navigate("csv/" + this.assessment.id, true);
  };

  ResultsView.prototype.detectOptions = function() {
    var _this = this;
    this.available = {
      cloud: null,
      tablets: null
    };
    $.ajax({
      dataType: "jsonp",
      url: "http://tangerine.iriscouch.com:5984/",
      success: function(a, b) {
        _this.available.cloud = true;
        return _this.updateOptions();
      },
      error: function(a, b) {
        _this.available.cloud = false;
        return _this.updateOptions();
      }
    });
    this.available.tablets = false;
    return this.updateOptions();
  };

  ResultsView.prototype.updateOptions = function() {
    if (this.available.cloud) this.$el.find('button.cloud').removeAttr('disabled');
    if (this.available.tablets) {
      this.$el.find('button.cloud').removeAttr('disabled');
    }
    if (_.isBoolean(this.available.cloud) && _.isBoolean(this.available.tablets)) {
      return this.$el.find(".status .info_box").html("Done detecting options");
    }
  };

  ResultsView.prototype.initialize = function(options) {
    var allResults,
      _this = this;
    this.detectOptions();
    this.results = [];
    this.subViews = [];
    this.model = options.model;
    this.assessment = options.assessment;
    allResults = new Results;
    return allResults.fetch({
      key: this.assessment.id,
      success: function(collection) {
        _this.results = collection.models;
        return _this.render();
      }
    });
  };

  ResultsView.prototype.render = function() {
    var cloudButton, csvButton, html, result, tabletButton, view, _i, _len, _ref, _ref2;
    this.clearSubViews();
    cloudButton = "<button class='cloud command' disabled='disabled'>Cloud</button>";
    tabletButton = "<button class='tablets command' disabled='disabled'>Tablets</button>";
    csvButton = "<button class='csv command'>CSV</button>";
    html = "      <h1>" + (this.assessment.get('name')) + "</h1>      <h2>Save options</h2>      <div class='menu_box'>        " + (Tangerine.context.mobile ? cloudButton : "") + "        " + (Tangerine.context.mobile ? tabletButton : "") + "        " + csvButton + "      </div>";
    if (Tangerine.context.mobile) {
      html += "        <button class='detect command'>Detect options</button>        <div class='status'>          <h2>Status</h2>          <div class='info_box'></div>        </div>        ";
    }
    html += "      <h2>Results</h2>    ";
    this.$el.html(html);
    if (((_ref = this.results) != null ? _ref.length : void 0) === 0) {
      this.$el.append("No results yet!");
    } else {
      _ref2 = this.results;
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        result = _ref2[_i];
        view = new ResultSumView({
          model: result
        });
        view.render();
        this.subViews.push(view);
        this.$el.append(view.el);
      }
    }
    return this.trigger("rendered");
  };

  ResultsView.prototype.afterRender = function() {
    var view, _i, _len, _ref, _results;
    _ref = this.subViews;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      view = _ref[_i];
      _results.push(typeof view.afterRender === "function" ? view.afterRender() : void 0);
    }
    return _results;
  };

  ResultsView.prototype.clearSubViews = function() {
    var view, _i, _len, _ref;
    _ref = this.subViews;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      view = _ref[_i];
      view.close();
    }
    return this.subViews = [];
  };

  return ResultsView;

})(Backbone.View);
