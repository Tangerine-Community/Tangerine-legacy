var LoginView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

LoginView = (function(_super) {

  __extends(LoginView, _super);

  function LoginView() {
    this.renderMessages = __bind(this.renderMessages, this);
    this.render = __bind(this.render, this);
    LoginView.__super__.constructor.apply(this, arguments);
  }

  LoginView.prototype.className = 'login_view';

  LoginView.prototype.events = {
    "click button.login": "login",
    "keypress input": "keyHandler"
  };

  LoginView.prototype.initialize = function(options) {
    this.model = Tangerine.user;
    this.model.on("change:messages", this.renderMessages);
    return this.model.on("change:authentication", this.goOn);
  };

  LoginView.prototype.goOn = function() {
    return Tangerine.router.navigate("", true);
  };

  LoginView.prototype.render = function() {
    var parentWidth, width;
    width = $('#content').width();
    parentWidth = $('#content').offsetParent().width();
    this.oldWidth = 100 * width / parentWidth;
    $("#content").css("width", "100%");
    this.$el.html("      <img src='images/tangerine_logo.png' id='login_logo'>      <div class='messages'></div>      <label for='login_username'>Enumerator Name</label>      <input id='login_username' name='login_username'>      <label for='login_password'>Password</label>      <input id='login_password' name='login_username' type='password'>      <button class='login'>Login</button>    ");
    return this.trigger("rendered");
  };

  LoginView.prototype.onClose = function() {
    return $("#content").css("width", this.oldWidth + "%");
  };

  LoginView.prototype.keyHandler = function(event) {
    if (event.which) {
      if (event.which !== 13) {
        return true;
      } else {
        return this.login();
      }
    }
  };

  LoginView.prototype.login = function(event) {
    var values;
    values = Utils.getValues(this.el);
    if (values['login_password'] === "") {
      this.model.showMessage("Please enter a password");
      this.$el.find('#login_password').focus();
      return false;
    }
    return this.model.login(values["login_username"], values["login_password"]);
  };

  LoginView.prototype.renderMessages = function() {
    var html, message, messages, _i, _len;
    messages = this.model.get("messages") || [];
    html = "<ul>";
    for (_i = 0, _len = messages.length; _i < _len; _i++) {
      message = messages[_i];
      html += "<li>" + message + "</li>";
    }
    html += "</ul>";
    return this.$el.find(".messages").html(html);
  };

  return LoginView;

})(Backbone.View);
