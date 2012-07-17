var AccountView,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

AccountView = (function(_super) {

  __extends(AccountView, _super);

  function AccountView() {
    AccountView.__super__.constructor.apply(this, arguments);
  }

  AccountView.prototype.events = {
    'click .leave': 'leaveGroup',
    'click .join_cancel': 'joinToggle',
    'click .join': 'joinToggle',
    'click .join_group': 'join',
    'click .back': 'goBack'
  };

  AccountView.prototype.goBack = function() {
    return window.history.back();
  };

  AccountView.prototype.joinToggle = function() {
    this.$el.find(".join, .join_confirmation").fadeToggle(0);
    return this.$el.find("#group_name").val("");
  };

  AccountView.prototype.join = function() {
    var group;
    group = this.$el.find("#group_name").val().replace(/\s|-/g, "_").replace(/[^a-zA-Z0-9_'"]/g, "");
    if (group.length === 0) return;
    this.user.joinGroup(group);
    this.joinToggle();
    return this.render();
  };

  AccountView.prototype.leaveGroup = function(event) {
    var group;
    group = $(event.target).parent().attr('data-group');
    this.user.leaveGroup(group);
    return this.render();
  };

  AccountView.prototype.initialize = function(options) {
    return this.user = options.user;
  };

  AccountView.prototype.render = function() {
    var group, html, _i, _len, _ref;
    html = "      <button class='back navigation'>Back</button>      <h1>Account</h1>      <div class='label_value'>        <label>Name</label>        <p>" + this.user.name + "</p>      </div>      <div class='label_value menu_box'>        <label>Groups</label>        <ul>    ";
    _ref = this.user.get("groups") || [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      group = _ref[_i];
      html += "<li data-group='" + group + "'>" + group + " <button class='command leave'>Leave</button></li>";
    }
    html += "        </ul>        <button class='command join'>Join or create a group</button>        <div class='confirmation join_confirmation'>          <input id='group_name' placeholder='Group name'>          <small>Please be specific.<br>          Good examples: MalawiJun2012, MikeTestGroup2012, EGRAGroup2012<br>          Bad examples: group, test, mine</small><br>          <button class='command join_group'>Join Group</button>          <button class='command join_cancel'>Cancel</button>        </div>      </div><br>      <!--button class='command confirmation'>Report a bug</button>      <div class='confirmation' id='bug'>        <label for='where'>What broke?        <input id='where' placeholder='where'>        <label for='where'>What happened?        <input id='where' placeholder='what'>        <label for='where'>What should have happened?        <input id='should' placeholder='should'>        <button>Send</button>      </div-->      ";
    this.$el.html(html);
    return this.trigger("rendered");
  };

  return AccountView;

})(Backbone.View);
