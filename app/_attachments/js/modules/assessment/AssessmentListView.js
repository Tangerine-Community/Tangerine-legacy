var AssessmentListView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

AssessmentListView = (function(_super) {

  __extends(AssessmentListView, _super);

  function AssessmentListView() {
    this.newAssessmentSave = __bind(this.newAssessmentSave, this);
    this.render = __bind(this.render, this);
    AssessmentListView.__super__.constructor.apply(this, arguments);
  }

  AssessmentListView.prototype.events = {
    'keypress .new_assessment_name': 'newAssessmentSave',
    'click .new_assessment_save': 'newAssessmentSave',
    'click .new_assessment_cancel': 'newAssessmentToggle',
    'click .new_assessment': 'newAssessmentToggle',
    'click .import': 'import',
    'click .groups': 'gotoGroups'
  };

  AssessmentListView.prototype.gotoGroups = function() {
    return Tangerine.router.navigate("groups", true);
  };

  AssessmentListView.prototype["import"] = function() {
    return Tangerine.router.navigate("import", true);
  };

  AssessmentListView.prototype.initialize = function(options) {
    this.group = options.group;
    this.isAdmin = Tangerine.user.isAdmin();
    this.views = [];
    this.publicViews = [];
    return this.refresh();
  };

  AssessmentListView.prototype.refresh = function() {
    var allAssessments,
      _this = this;
    allAssessments = new Assessments;
    return allAssessments.fetch({
      success: function(collection) {
        var groupCollection;
        groupCollection = [];
        collection.each(function(model) {
          if (Tangerine.context.server) {
            if (model.get("group") === _this.group) {
              return groupCollection.push(model);
            }
          } else {
            return groupCollection.push(model);
          }
        });
        _this.collection = new Assessments(groupCollection);
        _this.collection.on("add remove", _this.render);
        if (Tangerine.context.server) {
          _this.public = new Assessments(collection.where({
            group: "public"
          }));
        } else {
          _this.public = null;
        }
        return _this.render();
      }
    });
  };

  AssessmentListView.prototype.render = function() {
    var assessment, groupList, groupsButton, html, importButton, newButton, oneView, publicList, _i, _j, _len, _len2, _ref, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8;
    this.closeViews();
    this.views = [];
    newButton = "<button class='new_assessment command'>New</button>";
    importButton = "<button class='import command'>Import</button>";
    groupsButton = "<button class='navigation groups'>Groups</button>";
    html = "      " + (Tangerine.context.server ? groupsButton : "") + "      <h1>Assessments</h1>      ";
    if (this.isAdmin) {
      html += "        " + newButton + "        " + (Tangerine.context.mobile ? importButton : "") + "        <div class='new_assessment_form confirmation'>          <div class='menu_box_wide'>            <input type='text' class='new_assessment_name' placeholder='Assessment Name'>            <button class='new_assessment_save command'>Save</button> <button class='new_assessment_cancel command'>Cancel</button>          </div>        </div>        <h2>Group assessments</h2>      ";
    }
    this.$el.html(html);
    if (((_ref = this.collection) != null ? (_ref2 = _ref.models) != null ? _ref2.length : void 0 : void 0) > 0) {
      groupList = $('<ul>').addClass('assessment_list');
      _ref4 = (_ref3 = this.collection) != null ? _ref3.models : void 0;
      for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
        assessment = _ref4[_i];
        oneView = new AssessmentListElementView({
          model: assessment,
          parent: this
        });
        this.views.push(oneView);
        oneView.render();
        groupList.append(oneView.el);
      }
      this.$el.append(groupList);
    } else {
      this.$el.append("<p class='grey'>No assessments yet. Click <b>new</b> to start making one.</p>");
    }
    if (this.isAdmin && Tangerine.context.server) {
      this.$el.append("<h2>Public assessments</h2>");
      if (((_ref5 = this.public) != null ? (_ref6 = _ref5.models) != null ? _ref6.length : void 0 : void 0) > 0) {
        publicList = $('<ul>').addClass('public_list assessment_list');
        _ref8 = (_ref7 = this.public) != null ? _ref7.models : void 0;
        for (_j = 0, _len2 = _ref8.length; _j < _len2; _j++) {
          assessment = _ref8[_j];
          oneView = new AssessmentListElementView({
            model: assessment,
            parent: this,
            isPublic: true
          });
          this.publicViews.push(oneView);
          oneView.render();
          publicList.append(oneView.el);
        }
      } else {
        this.$el.append("<p>No assessments available.</p>");
      }
      this.$el.append(publicList);
    }
    return this.trigger("rendered");
  };

  AssessmentListView.prototype.newAssessmentToggle = function() {
    this.$el.find('.new_assessment_form, .new_assessment').fadeToggle(250);
    return false;
  };

  AssessmentListView.prototype.newAssessmentSave = function(event) {
    var name, newAssessment, newId;
    if (event.type !== "click" && event.which !== 13) return true;
    name = this.$el.find('.new_assessment_name').val();
    if (name.length !== 0) {
      newId = Utils.guid();
      newAssessment = new Assessment({
        'name': name,
        'group': this.group,
        '_id': newId,
        'assessmentId': newId
      });
      newAssessment.save();
      this.collection.add(newAssessment);
      Utils.midAlert("" + name + " saved");
    } else {
      Utils.midAlert("<span class='error'>Could not save <img src='images/icon_close.png' class='clear_message'></span>");
    }
    return false;
  };

  AssessmentListView.prototype.closeViews = function() {
    return _.each(this.views, function(view) {
      return view.close();
    });
  };

  AssessmentListView.prototype.onClose = function() {
    return this.closeViews();
  };

  return AssessmentListView;

})(Backbone.View);
