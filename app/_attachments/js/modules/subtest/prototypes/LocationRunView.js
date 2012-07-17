var LocationRunView,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

LocationRunView = (function(_super) {

  __extends(LocationRunView, _super);

  function LocationRunView() {
    LocationRunView.__super__.constructor.apply(this, arguments);
  }

  LocationRunView.prototype.events = {
    "click #school_list li": "autofill",
    "keyup input": "showOptions",
    "click clear": "clearInputs"
  };

  LocationRunView.prototype.initialize = function(options) {
    var i, level, location, locationData, template, _i, _len, _len2, _len3, _ref, _ref2;
    this.model = this.options.model;
    this.parent = this.options.parent;
    this.levels = this.model.get("levels") || [];
    this.locations = this.model.get("locations") || [];
    this.haystack = [];
    _ref = this.locations;
    for (i = 0, _len = _ref.length; i < _len; i++) {
      location = _ref[i];
      this.haystack[i] = [];
      for (_i = 0, _len2 = location.length; _i < _len2; _i++) {
        locationData = location[_i];
        this.haystack[i].push(locationData.toLowerCase());
      }
    }
    template = "<li data-index='{{i}}'>";
    _ref2 = this.levels;
    for (i = 0, _len3 = _ref2.length; i < _len3; i++) {
      level = _ref2[i];
      template += "{{level_" + i + "}}";
      if (i !== this.levels.length - 1) template += " - ";
    }
    template += "</li>";
    return this.li = _.template(template);
  };

  LocationRunView.prototype.clearInputs = function() {
    return this.$el.find("#school_id, #district, #province, #name").val("");
  };

  LocationRunView.prototype.autofill = function(event) {
    var i, index, level, location, _len, _ref, _results;
    this.$el.find("#autofill").fadeOut(250);
    index = $(event.target).attr("data-index");
    location = this.locations[index];
    _ref = this.levels;
    _results = [];
    for (i = 0, _len = _ref.length; i < _len; i++) {
      level = _ref[i];
      _results.push(this.$el.find("#level_" + i).val(location[i]));
    }
    return _results;
  };

  LocationRunView.prototype.showOptions = function(event) {
    var atLeastOne, field, html, i, isThere, j, needle, otherField, result, results, stack, _i, _len, _len2, _len3, _len4, _ref, _ref2;
    needle = $(event.target).val().toLowerCase();
    field = parseInt($(event.target).attr('data-level'));
    atLeastOne = false;
    results = [];
    _ref = this.haystack;
    for (i = 0, _len = _ref.length; i < _len; i++) {
      stack = _ref[i];
      isThere = ~this.haystack[i][field].indexOf(needle);
      if (isThere) results.push(i);
      if (isThere) atLeastOne = true;
    }
    _ref2 = this.haystack;
    for (i = 0, _len2 = _ref2.length; i < _len2; i++) {
      stack = _ref2[i];
      for (j = 0, _len3 = stack.length; j < _len3; j++) {
        otherField = stack[j];
        if (j === field) continue;
        isThere = ~this.haystack[i][j].indexOf(needle);
        if (isThere && !~results.indexOf(i)) results.push(i);
        if (isThere) atLeastOne = true;
      }
    }
    if (atLeastOne) {
      html = "";
      for (_i = 0, _len4 = results.length; _i < _len4; _i++) {
        result = results[_i];
        html += this.getLocationLi(result);
      }
      this.$el.find("#autofill").fadeIn(250);
      return this.$el.find("#school_list").html(html);
    } else {
      return this.$el.find("#autofill").fadeOut(250);
    }
  };

  LocationRunView.prototype.getLocationLi = function(i) {
    var j, location, templateInfo, _len, _ref;
    templateInfo = {
      "i": i
    };
    _ref = this.locations[i];
    for (j = 0, _len = _ref.length; j < _len; j++) {
      location = _ref[j];
      templateInfo["level_" + j] = location;
    }
    return this.li(templateInfo);
  };

  LocationRunView.prototype.render = function() {
    var html, i, level, schoolListElements, _len, _ref;
    schoolListElements = "";
    html = "      <button class='clear command'>Clear</button>      ";
    _ref = this.levels;
    for (i = 0, _len = _ref.length; i < _len; i++) {
      level = _ref[i];
      html += "        <div class='label_value'>          <label for='level_" + i + "'>" + level + "</label>          <input data-level='" + i + "' id='level_" + i + "' value=''>        </div>      ";
    }
    html += "      <div id='autofill' style='display:none'>        <h2>Select one from autofill list</h2>        <ul id='school_list'>        </ul>      </div>    ";
    this.$el.html(html);
    return this.trigger("rendered");
  };

  LocationRunView.prototype.getResult = function() {
    var i, level;
    return {
      "labels": (function() {
        var _i, _len, _ref, _results;
        _ref = this.levels;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          level = _ref[_i];
          _results.push(level.replace(/[\s-]/g, "_"));
        }
        return _results;
      }).call(this),
      "location": (function() {
        var _len, _ref, _results;
        _ref = this.levels;
        _results = [];
        for (i = 0, _len = _ref.length; i < _len; i++) {
          level = _ref[i];
          _results.push($.trim(this.$el.find("#level_" + i).val()));
        }
        return _results;
      }).call(this)
    };
  };

  LocationRunView.prototype.isValid = function() {
    var input, _i, _len, _ref;
    this.$el.find(".message").remove();
    _ref = this.$el.find("input");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      input = _ref[_i];
      if ($(input).val() === "") return false;
    }
    return true;
  };

  LocationRunView.prototype.showErrors = function() {
    var input, _i, _len, _ref, _results;
    _ref = this.$el.find("input");
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      input = _ref[_i];
      if ($(input).val() === "") {
        _results.push($(input).after(" <span class='message'>" + ($('label[for=' + $(input).attr('id') + ']').text()) + " cannot be empty</span>"));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  LocationRunView.prototype.getSum = function() {
    var $input, counts, input, _i, _len, _ref;
    counts = {
      correct: 0,
      incorrect: 0,
      missing: 0,
      total: 0
    };
    _ref = this.$el.find("input");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      input = _ref[_i];
      $input = $(input);
      if (($input.val() || "") !== "") counts['correct'] += 1;
      if (false) counts['incorrect'] += 0;
      if (($input.val() || "") === "") counts['missing'] += 1;
      if (true) counts['total'] += 1;
    }
    return {
      correct: counts['correct'],
      incorrect: counts['incorrect'],
      missing: counts['missing'],
      total: counts['total']
    };
  };

  return LocationRunView;

})(Backbone.View);
