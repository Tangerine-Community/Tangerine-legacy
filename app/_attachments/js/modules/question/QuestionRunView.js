var QuestionRunView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

QuestionRunView = (function(_super) {

  __extends(QuestionRunView, _super);

  function QuestionRunView() {
    this.setMessage = __bind(this.setMessage, this);
    QuestionRunView.__super__.constructor.apply(this, arguments);
  }

  QuestionRunView.prototype.className = "question buttonset";

  QuestionRunView.prototype.events = {
    'change input': 'update',
    'change textarea': 'update'
  };

  QuestionRunView.prototype.initialize = function(options) {
    this.model = options.model;
    this.answer = {};
    this.name = this.model.escape("name");
    this.type = this.model.get("type");
    this.options = this.model.get("options");
    this.notAsked = options.notAsked;
    if (this.model.get("skippable") === "true" || this.model.get("skippable") === true) {
      this.isValid = true;
    } else {
      this.isValid = false;
    }
    if (this.notAsked === true) {
      this.isValid = true;
      return this.updateResult();
    }
  };

  QuestionRunView.prototype.update = function() {
    this.updateResult();
    return this.updateValidity();
  };

  QuestionRunView.prototype.updateResult = function() {
    var i, option, _len, _len2, _ref, _ref2, _results, _results2;
    if (this.type === "open") {
      if (this.notAsked === true) {
        return this.answer = "not_asked";
      } else {
        return this.answer = this.$el.find("#" + this.cid + "_" + this.name).val();
      }
    } else if (this.type === "single") {
      if (this.notAsked === true) {
        return this.answer = "not_asked";
      } else {
        return this.answer = this.$el.find("." + this.cid + "_" + this.name + ":checked").val();
      }
    } else if (this.type === "multiple") {
      if (this.notAsked === true) {
        _ref = this.options;
        _results = [];
        for (i = 0, _len = _ref.length; i < _len; i++) {
          option = _ref[i];
          _results.push(this.answer[this.options[i].value] = "not_asked");
        }
        return _results;
      } else {
        _ref2 = this.options;
        _results2 = [];
        for (i = 0, _len2 = _ref2.length; i < _len2; i++) {
          option = _ref2[i];
          _results2.push(this.answer[this.options[i].value] = this.$el.find("#" + this.cid + "_" + this.name + "_" + i).is(":checked") ? "checked" : "unchecked");
        }
        return _results2;
      }
    }
  };

  QuestionRunView.prototype.updateValidity = function() {
    if (this.model.has("skippable") === "true" || this.model.get("skippable") === true) {
      return this.isValid = true;
    } else {
      if (this.type === "multiple") {
        if (_.values(this.answer).indexOf("checked") < this.options.length) {
          this.isValid = false;
        }
      } else if (this.type === "single") {
        if (this.$el.find("." + this.cid + "_" + this.name + ":checked").length === 0) {
          this.isValid = false;
        }
      } else if (this.type === "open") {
        this.isValid = $.trim(this.$el.find("." + this.cid + "_" + this.name + ":checked")) === "";
      }
      return this.isValid = true;
    }
  };

  QuestionRunView.prototype.setMessage = function(message) {
    return this.$el.find(".error_message").html(message);
  };

  QuestionRunView.prototype.render = function() {
    var checkOrRadio, html, i, option, _len, _ref;
    if (!this.notAsked) {
      html = "<div class='error_message'></div><div class='prompt'>" + (this.model.get('prompt')) + "</div>      <div class='hint'>" + (this.model.get('hint') || "") + "</div>";
      if (this.type === "open") {
        if (this.model.get("multiline")) {
          html += "<div><textarea id='" + this.cid + "_" + this.name + "'></textarea></div>";
        } else {
          html += "<div><input id='" + this.cid + "_" + this.name + "'></div>";
        }
        this.$el.html(html);
      } else {
        checkOrRadio = this.type === "multiple" ? "checkbox" : "radio";
        _ref = this.options;
        for (i = 0, _len = _ref.length; i < _len; i++) {
          option = _ref[i];
          html += "            <label for='" + this.cid + "_" + this.name + "_" + i + "'>" + option.label + "</label>            <input id='" + this.cid + "_" + this.name + "_" + i + "' class='" + this.cid + "_" + this.name + "' name='" + this.name + "' value='" + option.value + "' type='" + checkOrRadio + "'>          ";
        }
        this.$el.html(html);
      }
    } else {
      this.$el.hide();
    }
    return this.trigger("rendered");
  };

  return QuestionRunView;

})(Backbone.View);
