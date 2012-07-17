var SubtestRunView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

SubtestRunView = (function(_super) {

  __extends(SubtestRunView, _super);

  function SubtestRunView() {
    this.onPrototypeRendered = __bind(this.onPrototypeRendered, this);
    SubtestRunView.__super__.constructor.apply(this, arguments);
  }

  SubtestRunView.prototype.events = {
    'click .next': 'next',
    'click .subtest_help': 'toggleHelp',
    'click .skip': 'skip'
  };

  SubtestRunView.prototype.toggleHelp = function() {
    return this.$el.find(".enumerator_help").fadeToggle(250);
  };

  SubtestRunView.prototype.initialize = function(options) {
    this.protoViews = Tangerine.config.prototypeViews;
    this.model = options.model;
    this.parent = options.parent;
    return this.prototypeRendered = false;
  };

  SubtestRunView.prototype.render = function() {
    var enumeratorHelp, skipButton, skippable, studentDialog;
    enumeratorHelp = (this.model.get("enumeratorHelp") || "") !== "" ? "<button class='subtest_help command'>help</button><div class='enumerator_help'>" + (this.model.get('enumeratorHelp')) + "</div>" : "";
    studentDialog = (this.model.get("studentDialog") || "") !== "" ? "<div class='student_dialog'>" + (this.model.get('studentDialog')) + "</div>" : "";
    skipButton = "<button class='skip navigation'>Skip</button>";
    skippable = this.model.get("skippable") === true || this.model.get("skippable") === "true";
    this.$el.html("      <h2>" + (this.model.get('name')) + "</h2>      " + enumeratorHelp + "      " + studentDialog + "    ");
    this.prototypeView = new window[this.protoViews[this.model.get('prototype')]['run']]({
      model: this.model,
      parent: this
    });
    this.prototypeView.on("rendered", this.onPrototypeRendered);
    this.prototypeView.render();
    this.$el.append(this.prototypeView.el);
    this.prototypeRendered = true;
    this.$el.append("<button class='next navigation'>Next</button>" + (skippable ? skipButton : ""));
    return this.trigger("rendered");
  };

  SubtestRunView.prototype.onPrototypeRendered = function() {
    return this.trigger("rendered");
  };

  SubtestRunView.prototype.getGridScore = function() {
    var grid, gridScore, link;
    link = this.model.get("gridLinkId") || "";
    if (link === "") {
      throw "subtest grid link unspecified";
      return;
    }
    grid = this.parent.model.subtests.get(this.model.get("gridLinkId"));
    gridScore = this.parent.result.getGridScore(grid.id);
    return gridScore;
  };

  SubtestRunView.prototype.onClose = function() {
    var _ref;
    return (_ref = this.prototypeView) != null ? typeof _ref.close === "function" ? _ref.close() : void 0 : void 0;
  };

  SubtestRunView.prototype.isValid = function() {
    if (!this.prototypeRendered) return false;
    if (this.prototypeView.isValid != null) {
      return this.prototypeView.isValid();
    } else {
      return false;
    }
    return true;
  };

  SubtestRunView.prototype.showErrors = function() {
    return this.prototypeView.showErrors();
  };

  SubtestRunView.prototype.getSum = function() {
    if (this.prototypeView.getSum != null) {
      return this.prototypeView.getSum();
    } else {
      return {
        correct: 0,
        incorrect: 0,
        missing: 0,
        total: 0
      };
    }
  };

  SubtestRunView.prototype.abort = function() {
    return this.parent.abort();
  };

  SubtestRunView.prototype.getResult = function() {
    return this.prototypeView.getResult();
  };

  SubtestRunView.prototype.getSkipped = function() {
    if (this.prototypeView.getSkipped != null) {
      return this.prototypeView.getSkipped();
    } else {
      throw "Prototype skipping not implemented";
    }
  };

  SubtestRunView.prototype.next = function() {
    return this.parent.next();
  };

  SubtestRunView.prototype.skip = function() {
    return this.parent.skip();
  };

  return SubtestRunView;

})(Backbone.View);
