var DashboardView,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

DashboardView = (function(_super) {

  __extends(DashboardView, _super);

  function DashboardView() {
    DashboardView.__super__.constructor.apply(this, arguments);
  }

  DashboardView.prototype.initialize = function() {
    return this.assessments = new AssessmentListView({
      isAdmin: Tangerine.user.isAdmin,
      submenu: false
    });
  };

  DashboardView.prototype.render = function() {
    this.$el.html("      <h1>Dashboard</h1>      <div id='dash_buttons' class='buttonset'>        <input type='radio' id='assessment' name='dash_nav' checked><label for='assessment'>assessments</label>        <input type='radio' id='account' name='dash_nav'><label for='account'>account</label>      </div>      <div id='dash_assessments' class='column'></div>      <div id='dash_account' class='column'></div>      ");
    this.assessments.setElement(this.$el.find("#dash_assessments"));
    return this.trigger("rendered");
  };

  DashboardView.prototype.onClose = function() {
    return this.assessments.close();
  };

  return DashboardView;

})(Backbone.View);
