var IdRunView,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

IdRunView = (function(_super) {

  __extends(IdRunView, _super);

  function IdRunView() {
    IdRunView.__super__.constructor.apply(this, arguments);
  }

  IdRunView.prototype.className = "id";

  IdRunView.prototype.events = {
    'click #generate': 'generate',
    'change #participant_id': 'setValidator'
  };

  IdRunView.prototype.initialize = function(options) {
    this.model = this.options.model;
    this.parent = this.options.parent;
    return this.validator = new CheckDigit;
  };

  IdRunView.prototype.render = function() {
    this.$el.html("    <form>      <label for='participant_id'>Random Identifier</label>      <input id='participant_id' name='participant_id'>      <button id='generate' class='command'>Generate</button>      <div class='messages'></div>    </form>");
    return this.trigger("rendered");
  };

  IdRunView.prototype.getResult = function() {
    return {
      'participant_id': this.$el.find("#participant_id").val()
    };
  };

  IdRunView.prototype.getSum = function() {
    return {
      correct: 1,
      incorrect: 0,
      missing: 0,
      total: 1
    };
  };

  IdRunView.prototype.setValidator = function() {
    return this.validator.set(this.$el.find('#participant_id').val());
  };

  IdRunView.prototype.isValid = function() {
    this.setValidator();
    if (!this.validator.isValid()) return false;
    return this.updateNavigation();
  };

  IdRunView.prototype.showErrors = function() {
    return this.$el.find(".messages").html(this.validator.getErrors().join(", "));
  };

  IdRunView.prototype.generate = function() {
    this.$el.find(".messages").empty();
    this.$el.find('#participant_id').val(this.validator.generate());
    return false;
  };

  IdRunView.prototype.updateNavigation = function() {
    return Tangerine.nav.setStudent(this.$el.find('#participant_id').val());
  };

  return IdRunView;

})(Backbone.View);
