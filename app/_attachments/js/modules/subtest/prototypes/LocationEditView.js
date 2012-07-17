var LocationEditView,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
  __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

LocationEditView = (function(_super) {

  __extends(LocationEditView, _super);

  function LocationEditView() {
    LocationEditView.__super__.constructor.apply(this, arguments);
  }

  LocationEditView.prototype.events = {
    'keyup #data': 'updateData',
    'keyup #levels': 'updateLevels',
    'click #data_format input': 'updateData',
    'click #levels_format input': 'updateLevels'
  };

  LocationEditView.prototype.updateData = function(event) {
    var data, hasCommas, hasTabs;
    if ((event != null ? event.type : void 0) === "click") {
      if ($(event.target).val() === "Tabs") {
        this.dataCommaToTab();
        hasTabs = true;
        hasCommas = false;
      } else {
        this.dataTabToComma();
        hasTabs = false;
        hasCommas = true;
      }
    } else {
      data = this.$el.find("#data").val();
      hasTabs = data.match(/\t/g) != null;
      hasCommas = data.match(/,/g) != null;
    }
    if (hasTabs) {
      this.$el.find("#data_format :radio[value='Tabs']").attr("checked", "checked");
      return this.$el.find("#data_format").buttonset("refresh");
    } else {
      this.$el.find("#data_format :radio[value='Commas']").attr("checked", "checked");
      return this.$el.find("#data_format").buttonset("refresh");
    }
  };

  LocationEditView.prototype.updateLevels = function(event) {
    var hasCommas, hasTabs, levels;
    if ((event != null ? event.type : void 0) === "click") {
      if ($(event.target).val() === "Tabs") {
        this.levelsCommaToTab();
        hasTabs = true;
        hasCommas = false;
      } else {
        this.levelsTabToComma();
        hasTabs = false;
        hasCommas = true;
      }
    } else {
      levels = this.$el.find("#levels").val();
      hasTabs = levels.match(/\t/g) != null;
      hasCommas = levels.match(/,/g) != null;
    }
    levels = this.$el.find("#levels").val();
    hasTabs = levels.match(/\t/g) != null;
    hasCommas = levels.match(/,/g) != null;
    if (hasTabs) {
      this.$el.find("#levels_format :radio[value='Tabs']").attr("checked", "checked");
      return this.$el.find("#levels_format").buttonset("refresh");
    } else {
      this.$el.find("#levels_format :radio[value='Commas']").attr("checked", "checked");
      return this.$el.find("#levels_format").buttonset("refresh");
    }
  };

  LocationEditView.prototype.dataTabToComma = function() {
    return this.$el.find("#data").val(String(this.$el.find("#data").val()).replace(/\t/g, ", "));
  };

  LocationEditView.prototype.dataCommaToTab = function() {
    return this.$el.find("#data").val(this.$el.find("#data").val().replace(/, */g, "\t"));
  };

  LocationEditView.prototype.levelsTabToComma = function() {
    return this.$el.find("#levels").val(String(this.$el.find("#levels").val()).replace(/\t/g, ", "));
  };

  LocationEditView.prototype.levelsCommaToTab = function() {
    return this.$el.find("#levels").val(this.$el.find("#levels").val().replace(/, */g, "\t"));
  };

  LocationEditView.prototype.save = function() {
    var i, level, levels, location, locations, locationsValue, _len, _len2;
    if (this.$el.find("#data").val().match(/\t/g) != null) {
      this.$el.find("#data_format :radio[value='Tabs']").attr("checked", "checked");
      this.$el.find("#data_format").buttonset("refresh");
      this.dataTabToComma();
    }
    if (this.$el.find("#levels").val().match(/\t/g) != null) {
      this.levelsTabToComma();
      this.$el.find("#levels_format :radio[value='Tabs']").attr("checked", "checked");
      this.$el.find("#levels_format").buttonset("refresh");
    }
    levels = this.$el.find("#levels").val().split(/, */g);
    for (i = 0, _len = levels.length; i < _len; i++) {
      level = levels[i];
      levels[i] = $.trim(level).replace(/[^a-zA-Z0-9']/g, "");
    }
    locationsValue = $.trim(this.$el.find("#data").val());
    locations = locationsValue.split("\n");
    for (i = 0, _len2 = locations.length; i < _len2; i++) {
      location = locations[i];
      locations[i] = location.split(/, */g);
    }
    return this.model.set({
      "levels": levels,
      "locations": locations
    });
  };

  LocationEditView.prototype.isValid = function() {
    var levels, location, _i, _len, _ref;
    levels = this.model.get("levels");
    _ref = this.model.get("locations");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      location = _ref[_i];
      if (location.length !== levels.length) {
        if (__indexOf.call(this.errors, "column_match") < 0) {
          this.errors.push("column_match");
        }
      }
    }
    return this.errors.length === 0;
  };

  LocationEditView.prototype.showErrors = function() {
    var alertText, error, _i, _len, _ref;
    alertText = "Please correct the following errors:\n\n";
    _ref = this.errors;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      error = _ref[_i];
      alertText += this.errorMessages[error];
    }
    alert(alertText);
    return this.errors = [];
  };

  LocationEditView.prototype.initialize = function(options) {
    this.errors = [];
    this.model = options.model;
    return this.errorMessages = {
      "column_match": "Some columns in the location data do not match the number of columns in the geographic levels."
    };
  };

  LocationEditView.prototype.render = function() {
    var i, levels, location, locations, _len;
    levels = this.model.get("levels") || [];
    locations = this.model.get("locations") || [];
    levels = levels.join(", ");
    locations = locations.join("\n");
    if (_.isArray(locations)) {
      for (i = 0, _len = locations.length; i < _len; i++) {
        location = locations[i];
        locations[i] = location.join(", ");
      }
    }
    this.$el.html("      <div class='label_value'>        <div class='menu_box'>          <label for='levels' title='This is a comma separated list of geographic levels. (E.g. Country, Province, District, School Id) These are the levels that you would consider individual fields on the location form.'>Geographic Levels</label>          <input id='levels' value='" + levels + "'>          <label title='Tangerine uses comma separated values. If you copy and paste from another program like Excel, the values will be tab separated. These buttons allow you to switch back and forth, however, Tangerine will always save the comma version.'>Format</label><br>          <div id='levels_format' class='buttonset'>            <label for='levels_tabs'>Tabs</label>            <input id='levels_tabs' name='levels_format' type='radio' value='Tabs'>            <label for='levels_commas'>Commas</label>            <input id='levels_commas' name='levels_format' type='radio' value='Commas'>          </div>        </div>      </div>      <div class='label_value'>        <div class='menu_box'>          <label for='data' title='Comma sperated values, with multiple rows separated by line. This information will be used to autofill the location data.'>Location data</label>          <textarea id='data'>" + locations + "</textarea><br>          <label title='Tangerine uses comma separated values. If you copy and paste from another program like Excel, the values will be tab separated. These buttons allow you to switch back and forth, however, Tangerine will always save the comma version.'>Format</label><br>        <div id='data_format' class='buttonset'>            <label for='data_tabs'>Tabs</label>            <input id='data_tabs' name='data_format' type='radio' value='Tabs'>            <label for='data_commas'>Commas</label>            <input id='data_commas' name='data_format' type='radio' value='Commas'>        </div>              </div>    ");
    this.updateLevels();
    return this.updateData();
  };

  return LocationEditView;

})(Backbone.View);
