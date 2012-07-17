var User,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
  __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

User = (function(_super) {

  __extends(User, _super);

  function User() {
    User.__super__.constructor.apply(this, arguments);
  }

  User.prototype.url = 'user';

  User.prototype["default"] = {
    name: null,
    roles: [],
    groups: ["default"]
  };

  User.prototype.initialize = function(options) {
    this.name = this["default"].name;
    this.roles = this["default"].roles;
    this.messages = [];
    return this.temp = {};
  };

  User.prototype.signup = function(name, pass) {
    var _this = this;
    return $.couch.signup({
      name: name
    }, pass, {
      success: function(a, b, c) {
        if (_this.temp.intent === "login") {
          _this.temp.intent = "retry_login";
          _this.login(_this.temp.name, _this.temp.pass);
        } else {
          _this.addMessage("New user " + temp['name'] + " created. Welcome to Tangerine.");
        }
        _this.unset("messages");
        return _this.save();
      },
      error: function(status, error, message) {
        if ((_this.temp.intent != null) && _this.temp.intent === "login") {
          return _this.showMessage("Password incorrect, please try again.");
        } else {
          return _this.showMessage("Error username " + _this.temp.name + " already taken. Please try another name.");
        }
      }
    });
  };

  User.prototype.login = function(name, pass) {
    var _this = this;
    this.temp = {
      name: name,
      pass: pass
    };
    return $.couch.login({
      name: this.temp.name,
      password: this.temp.pass,
      success: function(user) {
        _this.name = _this.temp.name;
        _this.roles = user.roles;
        return _this.fetch({
          success: function(model) {
            _this.clearAttempt();
            return _this.trigger("change:authentication");
          }
        });
      },
      error: function(status, error, message) {
        _this.name = _this["default"].name;
        _this.roles = _this["default"].roles;
        if ((_this.temp.intent != null) && _this.temp.intent === "retry_login") {
          return _this.addMessage(message);
        } else {
          _this.temp.intent = "login";
          return _this.signup(_this.temp.name, _this.temp.pass);
        }
      }
    });
  };

  User.prototype.verify = function(callbacks) {
    if (this.name === null) {
      if ((callbacks != null ? callbacks.isUnregistered : void 0) != null) {
        return callbacks.isUnregistered();
      } else {
        return Tangerine.router.navigate("login", true);
      }
    } else {
      if (callbacks != null) {
        if (typeof callbacks.isRegistered === "function") callbacks.isRegistered();
      }
      if (this.isAdmin()) {
        return callbacks != null ? typeof callbacks.isAdmin === "function" ? callbacks.isAdmin() : void 0 : void 0;
      } else {
        return callbacks != null ? typeof callbacks.isUser === "function" ? callbacks.isUser() : void 0 : void 0;
      }
    }
  };

  User.prototype.fetch = function(options) {
    var _this = this;
    if (options == null) options = {};
    return $.couch.session({
      success: function(resp) {
        var role, _i, _len, _ref;
        if (resp.userCtx.name !== null) {
          _this.id = "tangerine.user:" + resp.userCtx.name;
          _this.name = resp.userCtx.name;
          _this.roles = [];
          _ref = resp.userCtx.roles;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            role = _ref[_i];
            if (!~role.indexOf("group.")) _this.roles.push(role);
          }
          return User.__super__.fetch.call(_this, {
            success: function(a, b, c) {
              return typeof options.success === "function" ? options.success() : void 0;
            },
            error: function(a, b, c) {
              _this.unset("messages");
              _this.save({
                "_id": _this.id,
                "groups": []
              }, {
                "wait": true
              });
              return User.__super__.fetch.call(_this, {
                success: function() {
                  return typeof options.success === "function" ? options.success() : void 0;
                },
                error: function() {
                  return location.reload();
                }
              });
            }
          });
        } else {
          return typeof options.success === "function" ? options.success() : void 0;
        }
      },
      error: function(status, error, reason) {
        this.trigger("change:authentication");
        throw "" + status + " Session Error\n" + error + "\n" + reason;
      }
    });
  };

  User.prototype.isAdmin = function() {
    return __indexOf.call(this.roles, '_admin') >= 0;
  };

  User.prototype.logout = function() {
    var _this = this;
    return $.couch.logout({
      success: function() {
        $.cookie("AuthSession", null);
        _this.name = _this["default"].name;
        _this.roles = _this["default"].roles;
        _this.clear();
        _this.trigger("change:authentication");
        return Tangerine.router.navigate("login", true);
      }
    });
  };

  User.prototype.clearAttempt = function() {
    return this.temp = this["default"].temp;
  };

  User.prototype.joinGroup = function(group) {
    var groups;
    groups = this.get("groups");
    if (!~groups.indexOf(group)) {
      groups.push(group);
      this.unset("messages");
      return this.save({
        "groups": groups
      });
    }
  };

  User.prototype.leaveGroup = function(group) {
    var groups;
    groups = this.get("groups");
    if (~groups.indexOf(group)) {
      groups = _.without(groups, group);
      return this.save({
        "groups": groups
      });
    }
  };

  User.prototype.addMessage = function(content) {
    return this.set("messages", this.get("messages").push(content));
  };

  User.prototype.showMessage = function(content) {
    return this.set("messages", [content]);
  };

  User.prototype.clearMessages = function(content) {
    return this.set("messages", []);
  };

  return User;

})(Backbone.Model);
