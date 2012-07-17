var GridRunView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

GridRunView = (function(_super) {

  __extends(GridRunView, _super);

  function GridRunView() {
    this.updateMode = __bind(this.updateMode, this);
    this.updateCountdown = __bind(this.updateCountdown, this);
    this.removeUndo = __bind(this.removeUndo, this);
    this.lastHandler = __bind(this.lastHandler, this);
    this.markHandler = __bind(this.markHandler, this);
    GridRunView.__super__.constructor.apply(this, arguments);
  }

  GridRunView.prototype.className = "grid_prototype";

  GridRunView.prototype.events = Tangerine.context.kindle ? {
    'touchstart .grid_element': 'gridClick',
    'touchstart .end_of_grid_line': 'endOfGridLineClick',
    'click .grid_mode input': 'updateMode',
    'click .start_time': 'startTimer',
    'click .stop_time': 'stopTimer',
    'click .restart': 'restartTimer'
  } : {
    'click .end_of_grid_line': 'endOfGridLineClick',
    'click .grid_element': 'gridClick',
    'click .grid_mode input': 'updateMode',
    'click .start_time': 'startTimer',
    'click .stop_time': 'stopTimer',
    'click .restart': 'restartTimer'
  };

  GridRunView.prototype.restartTimer = function() {
    this.resetVariables();
    return this.$el.find(".element_wrong").removeClass("element_wrong");
  };

  GridRunView.prototype.gridClick = function(event) {
    var _base, _name;
    return typeof (_base = this.modeHandlers)[_name = this.mode] === "function" ? _base[_name](event) : void 0;
  };

  GridRunView.prototype.markHandler = function(event) {
    var $target, index;
    $target = $(event.target);
    index = $target.attr('data-index');
    if (this.lastAttempted !== 0 && index > this.lastAttempted) return;
    this.markElement(index);
    if (this.autostop !== 0) return this.checkAutostop();
  };

  GridRunView.prototype.checkAutostop = function() {
    var autoCount, i, _ref;
    if (this.timeRunning) {
      autoCount = 0;
      for (i = 0, _ref = this.autostop - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        if (this.gridOutput[i] === "correct") break;
        autoCount++;
      }
      if (this.autostopped === false) {
        if (autoCount === this.autostop) this.autostopTest();
      }
      if (this.autostopped === true && autoCount < this.autostop && this.undoable === true) {
        return this.unAutostopTest();
      }
    }
  };

  GridRunView.prototype.markElement = function(index, value) {
    var $target;
    if (value == null) value = null;
    $target = this.$el.find("div.grid_element[data-index=" + index + "]");
    this.markRecord.push(index);
    if (value === null) {
      this.gridOutput[index - 1] = this.gridOutput[index - 1] === "correct" || this.autostopped ? "incorrect" : "correct";
      return $target.toggleClass("element_wrong");
    } else {
      if (!this.autostopped || value === "correct") {
        this.gridOutput[index - 1] = value;
        if (value === "incorrect") {
          return $target.addClass("element_wrong");
        } else if (value === "correct") {
          return $target.removeClass("element_wrong");
        }
      }
    }
  };

  GridRunView.prototype.endOfGridLineClick = function(event) {
    var $target, i, index, value, _ref, _ref2;
    if (this.mode === "mark") {
      $target = $(event.target);
      if ($target.hasClass("element_wrong")) {
        $target.removeClass("element_wrong");
        value = "correct";
        index = $target.attr('data-index');
        for (i = index, _ref = index - (this.columns - 1); index <= _ref ? i <= _ref : i >= _ref; index <= _ref ? i++ : i--) {
          this.markElement(i, value);
        }
      } else if (!$target.hasClass("element_wrong") && !this.autostopped) {
        $target.addClass("element_wrong");
        value = "incorrect";
        index = $target.attr('data-index');
        for (i = index, _ref2 = index - (this.columns - 1); index <= _ref2 ? i <= _ref2 : i >= _ref2; index <= _ref2 ? i++ : i--) {
          this.markElement(i, value);
        }
      }
      if (this.autostop !== 0) return this.checkAutostop();
    }
  };

  GridRunView.prototype.lastHandler = function(event) {
    var $target, index;
    $target = $(event.target);
    index = $target.attr('data-index');
    if (index - 1 >= this.gridOutput.lastIndexOf("incorrect")) {
      this.$el.find("table.grid .element_last").removeClass("element_last");
      $target.addClass("element_last");
      return this.lastAttempted = index;
    }
  };

  GridRunView.prototype.startTimer = function() {
    if (this.timerStopped === false && this.timeRunning === false) {
      this.updateMode(null, "mark");
      this.interval = setInterval(this.updateCountdown, 1000);
      this.startTime = this.getTime();
      this.timeRunning = true;
      this.$el.find("table.disabled").removeClass("disabled");
      return this.updateCountdown();
    }
  };

  GridRunView.prototype.stopTimer = function(event, message) {
    if (message == null) message = false;
    if (this.timeRunning === true) {
      Utils.flash();
      clearInterval(this.interval);
      this.stopTime = this.getTime();
      this.timeRunning = false;
      this.timerStopped = true;
      this.updateCountdown();
      this.updateMode(null, "last");
      if (message) {
        return Utils.topAlert(message);
      } else {
        return Utils.midAlert("Please mark <br>last item attempted");
      }
    }
  };

  GridRunView.prototype.autostopTest = function() {
    Utils.flash();
    clearInterval(this.interval);
    this.stopTime = this.getTime();
    this.autostopped = true;
    this.timerStopped = true;
    this.timeRunning = false;
    this.$el.find(".grid_element").slice(this.autostop - 1, this.autostop).addClass("element_last");
    this.lastAttempted = this.autostop;
    this.timeout = setTimeout(this.removeUndo, 3000);
    return Utils.topAlert("Autostop activated. Discontinue test.");
  };

  GridRunView.prototype.removeUndo = function() {
    this.undoable = false;
    this.updateMode(null, "disabled");
    return clearTimeout(this.timeout);
  };

  GridRunView.prototype.unAutostopTest = function() {
    this.interval = setInterval(this.updateCountdown, 1000);
    this.updateCountdown();
    this.autostopped = false;
    this.lastAttempted = 0;
    this.$el.find(".grid_element").slice(this.autostop - 1, this.autostop).removeClass("element_last");
    this.timeRunning = true;
    this.updateMode(null, "mark");
    return Utils.topAlert("Autostop removed. Continue.");
  };

  GridRunView.prototype.updateCountdown = function() {
    this.timeElapsed = this.getTime() - this.startTime;
    this.timeRemaining = this.timer - this.timeElapsed;
    this.$el.find(".timer").html(this.timeRemaining);
    if (this.timeRemaining <= 0 && this.timeRunning === true) {
      return this.stopTimer(null, "Time<br><br>Please mark<br>last item attempted");
    }
  };

  GridRunView.prototype.updateMode = function(event, mode) {
    if (mode != null) {
      this.mode = mode;
      this.$el.find("#grid_mode :radio[value=" + mode + "]").attr("checked", "checked");
      this.$el.find("#grid_mode").buttonset("refresh").click(this.updateMode);
      return;
    }
    if (!this.autostopped) return this.mode = $(event.target).val();
  };

  GridRunView.prototype.getTime = function() {
    return Math.round((new Date()).getTime() / 1000);
  };

  GridRunView.prototype.resetVariables = function() {
    var i, item, _len, _ref;
    this.markRecord = [];
    this.timerStopped = false;
    this.startTime = 0;
    this.stopTime = 0;
    this.timeElapsed = 0;
    this.timeRemaining = this.timer;
    this.lastAttempted = 0;
    this.interval = null;
    this.undoable = true;
    this.timeRunning = false;
    this.timer = parseInt(this.model.get("timer")) || 0;
    this.items = _.compact(this.model.get("items"));
    this.mode = "disabled";
    this.gridOutput = [];
    _ref = this.items;
    for (i = 0, _len = _ref.length; i < _len; i++) {
      item = _ref[i];
      this.gridOutput[i] = 'correct';
    }
    this.columns = parseInt(this.model.get("columns")) || 0;
    this.autostop = parseInt(this.model.get("autostop")) || 0;
    this.autostopped = false;
    this.$el.find(".grid_element").removeClass("element_wrong").removeClass("element_last").addClass("disabled");
    this.$el.find("table").addClass("disabled");
    this.$el.find(".timer").html(this.timer);
    return this.updateMode(this.mode);
  };

  GridRunView.prototype.initialize = function(options) {
    this.totalTime = this.model.get("timer") || 0;
    this.modeHandlers = {
      mark: this.markHandler,
      last: this.lastHandler,
      disabled: $.noop
    };
    this.model = this.options.model;
    this.parent = this.options.parent;
    this.resetVariables();
    this.gridElement = _.template("<td><div data-label='{{label}}' data-index='{{i}}' class='grid_element'>{{label}}</div></td>");
    return this.endOfGridLine = _.template("<td><div data-index='{{i}}' class='end_of_grid_line'>*</div></td>");
  };

  GridRunView.prototype.render = function() {
    var done, html, i, _ref;
    done = 0;
    html = "        <div class='timer_wrapper'><button class='start_time time'>Start</button><div class='timer'>" + this.timer + "</div></div>    <table class='grid disabled'>";
    while (true) {
      if (done > this.items.length) break;
      html += "<tr>";
      for (i = 1, _ref = this.columns; 1 <= _ref ? i <= _ref : i >= _ref; 1 <= _ref ? i++ : i--) {
        if (done < this.items.length) {
          html += this.gridElement({
            label: _.escape(this.items[done]),
            i: done + 1
          });
        }
        done++;
      }
      if (done < (this.items.length + 1)) {
        html += this.endOfGridLine({
          i: done
        });
      }
      html += "</tr>";
    }
    html += "</table>        <div class='timer_wrapper'><button class='stop_time time'>Stop</button><div class='timer'>" + this.timer + "</div></div>    <div>          <button class='restart command'>Restart</button>          <br>    </div>        <div id='grid_mode' class='question buttonset clearfix'>      <label>Input mode</label><br>      <label for='mark'>Mark</label>      <input name='grid_mode' id='mark' type='radio' value='mark' checked='checked'>      <label for='last_attempted'>Last attempted</label>      <input name='grid_mode' id='last_attempted' type='radio' value='last'>    </div>    ";
    this.$el.html(html);
    return this.trigger("rendered");
  };

  GridRunView.prototype.isValid = function() {
    if (this.lastAttempted === 0) return false;
    if (this.timeRunning === true) return false;
    return true;
  };

  GridRunView.prototype.showErrors = function() {
    if (this.lastAttempted === 0) {
      Utils.midAlert("Please touch<br>last item read.");
    }
    if (this.timeRuning === true) return Utils.midAlert("Time still running.");
  };

  GridRunView.prototype.getResult = function() {
    var i, item, itemResults, result, _len, _ref;
    itemResults = [];
    _ref = this.items;
    for (i = 0, _len = _ref.length; i < _len; i++) {
      item = _ref[i];
      if (i < this.lastAttempted) {
        itemResults[i] = this.gridOutput[i];
      } else {
        itemResults[i] = "missing";
      }
    }
    return result = {
      "auto_stop": this.autostopped,
      "attempted": this.lastAttempted,
      "items": itemResults,
      "time_remain": this.timeRemaining,
      "mark_record": this.markRecord,
      "variable_name": this.model.get("variableName")
    };
  };

  GridRunView.prototype.getSkippedResult = function() {
    return "skipped";
  };

  GridRunView.prototype.onClose = function() {
    return clearInterval(this.interval);
  };

  GridRunView.prototype.getSum = function() {
    var counts, i, _i, _len, _ref;
    counts = {
      correct: 0,
      incorrect: 0,
      missing: this.items.length - this.lastAttempted,
      total: this.items.length
    };
    _ref = this.gridOutput;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      if (i === "correct") counts['correct'] += 1;
      if (i === "incorrect") counts['incorrect'] += 1;
    }
    return {
      correct: counts['correct'],
      incorrect: counts['incorrect'],
      missing: counts['missing'],
      total: counts['total']
    };
  };

  return GridRunView;

})(Backbone.View);
