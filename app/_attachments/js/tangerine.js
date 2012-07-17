var Router,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Router = (function(_super) {

  __extends(Router, _super);

  function Router() {
    Router.__super__.constructor.apply(this, arguments);
  }

  Router.prototype.routes = {
    'login': 'login',
    'logout': 'logout',
    'account': 'account',
    'transfer': 'transfer',
    'setup': 'setup',
    '': 'groups',
    'groups': 'groups',
    'assessments': 'assessments',
    'assessments/:group': 'assessments',
    'dashboard': 'dashboard',
    'codebook/:id': 'codebook',
    'run/:id': 'run',
    'restart/:id': 'restart',
    'edit/:id': 'edit',
    'csv/:id': 'csv',
    'results/:name': 'results',
    'import': 'import',
    'subtest/:id': 'editSubtest',
    'question/:id': 'editQuestion',
    'report/:id': 'report'
  };

  Router.prototype.groups = function(a, b, c) {
    if (!Tangerine.context.server) {
      return Tangerine.router.navigate("assessments", true);
    } else {
      return Tangerine.user.verify({
        isAdmin: function() {
          var groups, view;
          groups = Tangerine.user.get("groups");
          if (groups.length === 1 && (window.location.hash = "")) {
            return Tangerine.router.navigate("assessments/" + groups[0], true);
          } else {
            view = new GroupsView;
            return vm.show(view);
          }
        },
        isUnregistered: function() {
          return Tangerine.router.navigate("login", true);
        }
      });
    }
  };

  Router.prototype.codebook = function(id) {
    return id = Utils.cleanURL(id);
  };

  Router.prototype.setup = function() {
    return Tangerine.device.fetch({
      success: function(model) {
        var view;
        view = new DeviceView({
          model: model
        });
        return vm.show(view);
      }
    });
  };

  Router.prototype.dashboard = function() {
    return Tangerine.user.verify({
      isAdmin: function() {
        var dashboard;
        dashboard = new DashboardView;
        return vm.show(dashboard);
      },
      isUser: function() {
        return Tangerine.router.navigate("assessments", true);
      }
    });
  };

  Router.prototype["import"] = function() {
    return Tangerine.user.verify({
      isRegistered: function() {
        var view;
        view = new AssessmentImportView;
        return vm.show(view);
      },
      isUnregistered: function() {
        return Tangerine.router.navigate("login", true);
      }
    });
  };

  Router.prototype.assessments = function(group) {
    if (group == null) group = null;
    if (group === null && Tangerine.context.server) {
      return Tangerine.router.navigate("groups", true);
    } else {
      return Tangerine.user.verify({
        isRegistered: function() {
          var assessments;
          assessments = new AssessmentListView({
            group: group
          });
          return vm.show(assessments);
        },
        isUnregistered: function() {
          return Tangerine.router.navigate("login", true);
        }
      });
    }
  };

  Router.prototype.editId = function(id) {
    id = Utils.cleanURL(id);
    return Tangerine.user.verify({
      isAdmin: function() {
        var assessment;
        assessment = new Assessment({
          _id: id
        });
        return assessment.superFetch({
          success: function(model) {
            var view;
            view = new AssessmentEditView({
              model: model
            });
            return vm.show(view);
          },
          error: function(details) {
            var name, view;
            name = Utils.cleanURL(name);
            view = new ErrorView({
              message: "There was an error loading the assessment '" + name + "'",
              details: details
            });
            return vm.show(view);
          }
        });
      },
      isUser: function() {
        return Tangerine.router.navigate("", true);
      },
      isUnregistered: function(options) {
        return Tangerine.router.navigate("login", true);
      }
    });
  };

  Router.prototype.edit = function(id) {
    return Tangerine.user.verify({
      isAdmin: function() {
        var assessment;
        assessment = new Assessment({
          "_id": id
        });
        return assessment.fetch({
          success: function(model) {
            var view;
            view = new AssessmentEditView({
              model: model
            });
            return vm.show(view);
          },
          error: function(details) {
            var name, view;
            name = Utils.cleanURL(name);
            view = new ErrorView({
              message: "There was an error loading the assessment '" + name + "'",
              details: details
            });
            return vm.show(view);
          }
        });
      },
      isUser: function() {
        return Tangerine.router.navigate("", true);
      },
      isUnregistered: function(options) {
        return Tangerine.router.navigate("login", true);
      }
    });
  };

  Router.prototype.restart = function(name) {
    return Tangerine.router.navigate("run/" + name, true);
  };

  Router.prototype.run = function(id) {
    return Tangerine.user.verify({
      isRegistered: function() {
        var assessment;
        assessment = new Assessment({
          "_id": id
        });
        return assessment.fetch({
          success: function(model) {
            var view;
            view = new AssessmentRunView({
              model: model
            });
            return vm.show(view);
          }
        });
      },
      isUnregistered: function(options) {
        return Tangerine.router.navigate("login", true);
      }
    });
  };

  Router.prototype.results = function(id) {
    return Tangerine.user.verify({
      isRegistered: function() {
        var assessment;
        assessment = new Assessment({
          "_id": id
        });
        return assessment.fetch({
          success: function(model) {
            var view;
            view = new ResultsView({
              assessment: model
            });
            return vm.show(view);
          }
        });
      },
      isUnregistered: function(options) {
        return Tangerine.router.navigate("login", true);
      }
    });
  };

  Router.prototype.csv = function(id) {
    return Tangerine.user.verify({
      isAdmin: function() {
        var view;
        view = new CSVView({
          assessmentId: id
        });
        return vm.show(view);
      },
      isUser: function() {
        var errView;
        errView = new ErrorView({
          message: "You're not an admin user",
          details: "How did you get here?"
        });
        return vm.show(errView);
      }
    });
  };

  Router.prototype.report = function(id) {
    return Tangerine.user.verify({
      isRegistered: function() {
        var view;
        view = new ReportView({
          assessmentId: id
        });
        return vm.show(view);
      },
      isUnregistered: function(options) {
        return Tangerine.router.navigate("login", true);
      }
    });
  };

  Router.prototype.editSubtest = function(id) {
    return Tangerine.user.verify({
      isAdmin: function() {
        var subtest;
        id = Utils.cleanURL(id);
        subtest = new Subtest({
          _id: id
        });
        return subtest.fetch({
          success: function(model, response) {
            var view;
            view = new SubtestEditView({
              model: model
            });
            return vm.show(view);
          }
        });
      },
      isUser: function() {
        return Tangerine.router.navigate("", true);
      },
      isUnregistered: function() {
        return Tangerine.router.navigate("login", true);
      }
    });
  };

  Router.prototype.editQuestion = function(id) {
    return Tangerine.user.verify({
      isAdmin: function() {
        var question;
        id = Utils.cleanURL(id);
        question = new Question({
          _id: id
        });
        return question.fetch({
          success: function(model, response) {
            var view;
            view = new QuestionEditView({
              model: model
            });
            return vm.show(view);
          }
        });
      },
      isUser: function() {
        return Tangerine.router.navigate("", true);
      },
      isUnregistered: function() {
        return Tangerine.router.navigate("login", true);
      }
    });
  };

  Router.prototype.login = function() {
    return Tangerine.user.verify({
      isRegistered: function() {
        return Tangerine.router.navigate("", true);
      },
      isUnregistered: function() {
        var view;
        view = new LoginView;
        return vm.show(view);
      }
    });
  };

  Router.prototype.logout = function() {
    Tangerine.user.logout();
    return Tangerine.router.navigate("login", true);
  };

  Router.prototype.account = function() {
    return Tangerine.user.verify({
      isRegistered: function() {
        var view;
        view = new AccountView({
          user: Tangerine.user
        });
        return vm.show(view);
      },
      isUnregistered: function(options) {
        return Tangerine.router.navigate("login", true);
      }
    });
  };

  Router.prototype.logs = function() {
    var view;
    view = new LogView;
    return vm.show(view);
  };

  Router.prototype.transfer = function() {
    var getVars, name,
      _this = this;
    getVars = Utils.$_GET();
    name = getVars.name;
    return $.couch.logout({
      success: function() {
        $.cookie("AuthSession", null);
        return $.couch.login({
          "name": name,
          "password": name,
          success: function() {
            Tangerine.router.navigate("");
            return window.location.reload();
          },
          error: function() {
            return $.couch.signup({
              "name": name,
              "roles": ["_admin"]
            }, name, {
              success: function() {
                var user;
                user = new User;
                return user.save({
                  "name": name,
                  "id": "tangerine.user:" + name,
                  "roles": [],
                  "from": "tc"
                }, {
                  wait: true,
                  success: function() {
                    return $.couch.login({
                      "name": name,
                      "password": name,
                      success: function() {
                        Tangerine.router.navigate("");
                        return window.location.reload();
                      },
                      error: function() {
                        var view;
                        view = new ErrorView({
                          message: "There was a username collision",
                          details: ""
                        });
                        return vm.show(view);
                      }
                    });
                  }
                });
              }
            });
          }
        });
      }
    });
  };

  return Router;

})(Backbone.Router);

$(function() {
  window.vm = new ViewManager();
  Tangerine.router = new Router();
  Tangerine.user = new User();
  Tangerine.nav = new NavigationView({
    user: Tangerine.user,
    router: Tangerine.router
  });
  return Tangerine.user.fetch({
    success: function() {
      return Backbone.history.start();
    },
    error: function() {
      return Backbone.history.start();
    }
  });
});
