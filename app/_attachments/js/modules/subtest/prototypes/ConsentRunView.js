var ConsentRunView,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

ConsentRunView = (function(_super) {

  __extends(ConsentRunView, _super);

  function ConsentRunView() {
    ConsentRunView.__super__.constructor.apply(this, arguments);
  }

  ConsentRunView.prototype.events = {
    'click #non_consent_confirm': 'noConsent',
    'click #consent_yes': 'clearMessages',
    'click #consent_no': 'showNonConsent'
  };

  ConsentRunView.prototype.initialize = function(options) {
    this.confirmedNonConsent = false;
    this.model = this.options.model;
    return this.parent = this.options.parent;
  };

  ConsentRunView.prototype.render = function() {
    this.$el.html("    <form>      <div class='question'>        <label>" + (this.model.get('prompt') || 'Does the child consent?') + "</label>        <div class='messages'></div>        <div class='non_consent_form confirmation'>          <div>Click to confirm consent not obtained.</div>          <button id='non_consent_confirm'>Confirm</button>        </div>        <div id='consent_options' class='buttonset'>          <label for='consent_yes'>Yes, continue</label>          <input id='consent_yes' type='radio' name='participant_consents' value='yes'>          <label for='consent_no'>No, stop</label>          <input id='consent_no' type='radio' name='participant_consents' value='no'>        </div>      </div>    </form>    ");
    return this.trigger("rendered");
  };

  ConsentRunView.prototype.isValid = function() {
    if (this.confirmedNonConsent === false) {
      if (this.$el.find("input[name=participant_consents]:checked").val() === "yes") {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  };

  ConsentRunView.prototype.showNonConsent = function() {
    return this.$el.find(".non_consent_form").show(250);
  };

  ConsentRunView.prototype.clearMessages = function() {
    this.$el.find(".non_consent_form").hide(250);
    return this.$el.find(".messages").html("");
  };

  ConsentRunView.prototype.noConsent = function() {
    this.confirmedNonConsent = true;
    this.parent.abort();
    return false;
  };

  ConsentRunView.prototype.showErrors = function() {
    var answer;
    answer = this.$el.find("input[name=participant_consents]:checked").val();
    if (answer === "no") {
      Utils.midAlert("Please confirm");
      return this.showNonConsent;
    } else if (answer === void 0) {
      return $(".messages").html("Please select one");
    }
  };

  ConsentRunView.prototype.getResult = function() {
    return {
      "consent": this.$el.find("input[name=participant_consents]:checked").val()
    };
  };

  ConsentRunView.prototype.getSum = function() {
    return {
      correct: 1,
      incorrect: 0,
      missing: 0,
      total: 1
    };
  };

  return ConsentRunView;

})(Backbone.View);
