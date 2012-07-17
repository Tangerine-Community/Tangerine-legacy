var Context, MapReduce, Utils;

Backbone.View.prototype.close = function() {
  this.remove();
  this.unbind();
  return typeof this.onClose === "function" ? this.onClose() : void 0;
};

(function($) {
  $.fn.scrollTo = function() {
    try {
      $('html, body').animate({
        scrollTop: $(this).offset().top + 'px'
      }, 250);
    } catch (e) {
      console.log(e);
      console.log("Scroll error with 'this'");
      console.log(this);
    }
    return this;
  };
  $.fn.topCenter = function() {
    this.css("position", "absolute");
    this.css("top", $(window).scrollTop() + "px");
    return this.css("left", (($(window).width() - this.outerWidth()) / 2) + $(window).scrollLeft() + "px");
  };
  $.fn.middleCenter = function() {
    this.css("position", "absolute");
    this.css("top", (($(window).height() - this.outerHeight()) / 2) + $(window).scrollTop() + "px");
    return this.css("left", (($(window).width() - this.outerWidth()) / 2) + $(window).scrollLeft() + "px");
  };
  return $.fn.serializeSubtest = function() {
    var result;
    result = {};
    $.map($(this).serializeArray(), function(element, i) {
      if (result[element.name] != null) {
        if ($.isArray(result[element.name])) {
          return result[element.name].push(element.value);
        } else {
          return result[element.name] = [result[element.name], element.value];
        }
      } else {
        return result[element.name] = element.value;
      }
    });
    return result;
  };
})(jQuery);

MapReduce = (function() {

  function MapReduce() {}

  MapReduce.mapFields = function(doc, req) {
    ({
      concatNodes: function(parent, object) {
        var emitDoc, index, key, prefix, typeofobject, value, _len, _ref, _results, _results2;
        if (object instanceof Array) {
          _results = [];
          for (index = 0, _len = object.length; index < _len; index++) {
            value = object[index];
            if (typeof object !== "string") {
              _results.push(concatNodes(parent + "." + index, value));
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        } else {
          typeofobject = typeof object;
          if (typeofobject === "boolean" || typeofobject === "string" || typeofobject === "number") {
            emitDoc = {
              studentID: (_ref = doc.DateTime) != null ? _ref["student-id"] : void 0,
              fieldname: parent
            };
            if (typeofobject === "boolean") {
              emitDoc.result = object ? "true" : "false";
            }
            if (typeofobject === "string" || typeofobject === "number") {
              emitDoc.result = object;
            }
            return emit(doc.assessment, emitDoc);
          } else {
            _results2 = [];
            for (key in object) {
              value = object[key];
              prefix = (parent === "" ? key : parent + "." + key);
              _results2.push(concatNodes(prefix, value));
            }
            return _results2;
          }
        }
      }
    });
    if (!((doc.type != null) && doc.type === "replicationLog")) {
      return concatNodes("", doc);
    }
  };

  MapReduce.reduceFields = function(keys, values, rereduce) {
    var fieldAndResult, key, rv, value;
    rv = [];
    for (key in values) {
      value = values[key];
      fieldAndResult = {};
      fieldAndResult[value.fieldname] = value.result;
      rv.push(fieldAndResult);
    }
    return rv;
  };

  return MapReduce;

})();

String.prototype.safeToSave = function() {
  return this.replace(/\s|-/g, "_").replace(/[^a-zA-Z0-9_'""]/g, "");
};

String.prototype.htmlSafe = function() {
  return $("<div/>").text(this).html().replace(/'/g, "&#39;").replace(/"/g, "&#34;");
};

Utils = (function() {

  function Utils() {}

  Utils.confirm = function(message, options) {
    var _ref;
    if (((_ref = navigator.notification) != null ? _ref.confirm : void 0) != null) {
      navigator.notification.confirm(message, function(input) {
        if (input === 1) {
          return options.callback(true);
        } else if (input === 2) {
          return options.callback(false);
        } else {
          return options.callback(input);
        }
      }, options.title, options.action + ",Cancel");
    } else {
      if (window.confirm(message)) {
        options.callback(true);
        return true;
      } else {
        options.callback(false);
        return false;
      }
    }
    return 0;
  };

  Utils.getValues = function(selector) {
    var values;
    values = {};
    $(selector).find("input, textarea").each(function(index, element) {
      return values[element.id] = element.value;
    });
    return values;
  };

  Utils.cleanURL = function(url) {
    if ((typeof url.indexOf === "function" ? url.indexOf("%") : void 0) !== -1) {
      return url = decodeURIComponent(url);
    } else {
      return url;
    }
  };

  Utils.importAssessmentFromIris = function(dKey) {
    var repOps;
    repOps = {
      'filter': 'tangerine/downloadFilter',
      'create_target': true,
      'query_params': {
        'dKey': dKey
      }
    };
    return $.couch.replicate(Tangerine.iris.host + "/tangerine", "tangerine", {
      success: function(a, b) {
        return console.log([" success", a, b]);
      }
    }, repOps);
  };

  Utils.topAlert = function(alert_text) {
    return $("<div class='disposable_alert'>" + alert_text + "</div>").appendTo("#content").topCenter().delay(2000).fadeOut(250, function() {
      return $(this).remove();
    });
  };

  Utils.midAlert = function(alert_text) {
    return $("<div class='disposable_alert'>" + alert_text + "</div>").appendTo("#content").middleCenter().delay(2000).fadeOut(250, function() {
      return $(this).remove();
    });
  };

  Utils.S4 = function() {
    return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
  };

  Utils.guid = function() {
    return this.S4() + this.S4() + "-" + this.S4() + "-" + this.S4() + "-" + this.S4() + "-" + this.S4() + this.S4() + this.S4();
  };

  Utils.flash = function() {
    $("body").css({
      "backgroundColor": "red"
    });
    return setTimeout(function() {
      return $("body").css({
        "backgroundColor": "white"
      });
    }, 1000);
  };

  Utils.$_GET = function(q, s) {
    var parts, vars;
    vars = {};
    parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m, key, value) {
      value = ~value.indexOf("#") ? value.split("#")[0] : value;
      return vars[key] = value.split("#")[0];
    });
    return vars;
  };

  Utils.resizeScrollPane = function() {
    return $(".scroll_pane").height($(window).height() - ($("#navigation").height() + $("#footer").height() + 100));
  };

  return Utils;

})();

Context = (function() {

  function Context() {
    this.mobile = !~(String(window.location).indexOf("iriscouch"));
    this.kindle = /kindle/.test(navigator.userAgent.toLowerCase());
    this.server = ~(String(window.location).indexOf("iriscouch"));
    this.server = true;
    this.mobile = !this.server;
  }

  return Context;

})();

$(function() {
  $("#content").on("click", ".clear_message", null, function(a) {
    return $(a.target).parent().fadeOut(250, function() {
      return $(this).empty().show();
    });
  });
  $("#content").on("click", ".parent_remove", null, function(a) {
    return $(a.target).parent().fadeOut(250, function() {
      return $(this).remove();
    });
  });
  $("#content").on("click", ".alert_button", function() {
    var alert_text;
    alert_text = $(this).attr("data-alert") ? $(this).attr("data-alert") : $(this).val();
    return Utils.disposableAlert(alert_text);
  });
  return $("#content").on("click", ".disposable_alert", function() {
    return $(this).stop().fadeOut(250, function() {
      return $(this).remove();
    });
  });
});
