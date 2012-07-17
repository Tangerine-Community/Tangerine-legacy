var CheckDigit;

CheckDigit = (function() {

  CheckDigit.prototype.allowed = "ABCEFGHKMNPQRSTUVWXYZ".split("");

  CheckDigit.prototype.weights = [1, 2, 5, 11, 13];

  function CheckDigit(id) {
    if (id == null) id = "";
    this.set(id);
  }

  CheckDigit.prototype.set = function(id) {
    return this.id = id.toUpperCase();
  };

  CheckDigit.prototype.get = function(id) {
    var ch;
    if (id == null) id = this.id;
    if (!~((function() {
      var _i, _len, _ref, _results;
      _ref = id.split("");
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ch = _ref[_i];
        _results.push(!~this.allowed.indexOf(ch));
      }
      return _results;
    }).call(this)).indexOf(false)) {
      return null;
    }
    return id + this.getDigit(id);
  };

  CheckDigit.prototype.generate = function() {
    var i;
    return this.get(((function() {
      var _i, _len, _ref, _results;
      _ref = this.weights;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        _results.push(this.allowed[Math.floor(Math.random() * this.allowed.length)]);
      }
      return _results;
    }).call(this)).join(""));
  };

  CheckDigit.prototype.isValid = function(id) {
    if (id == null) id = this.id;
    if (id.length !== 6) return false;
    return (this.get(id.slice(0, id.length - 1))) === id;
  };

  CheckDigit.prototype.getErrors = function() {
    var ch, errors, i, result, _i, _len, _len2, _ref;
    errors = [];
    result = [];
    _ref = (function() {
      var _i, _len, _ref, _results;
      _ref = this.id.split("");
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ch = _ref[_i];
        _results.push(this.allowed.indexOf(ch));
      }
      return _results;
    }).call(this);
    for (i = 0, _len = _ref.length; i < _len; i++) {
      ch = _ref[i];
      if (ch === -1) result.push(this.id[i]);
    }
    if (result.length !== 0) {
      for (_i = 0, _len2 = results.length; _i < _len2; _i++) {
        i = results[_i];
        errors.push("" + results[i] + " not allowed.");
      }
    }
    if (this.id.length !== 6) errors.push("Identifier must be 6 digits");
    return errors;
  };

  CheckDigit.prototype.getDigit = function(id) {
    var ch, checkDigit_10, i, id_10, weight;
    if (id == null) id = this.id;
    id_10 = (function() {
      var _i, _len, _ref, _results;
      _ref = id.split("");
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ch = _ref[_i];
        _results.push(this.allowed.indexOf(ch));
      }
      return _results;
    }).call(this);
    checkDigit_10 = ((function() {
      var _len, _ref, _results;
      _ref = this.weights;
      _results = [];
      for (i = 0, _len = _ref.length; i < _len; i++) {
        weight = _ref[i];
        _results.push(id_10[i] * weight);
      }
      return _results;
    }).call(this)).reduce(function(x, y) {
      return x + y;
    });
    return this.allowed[checkDigit_10 % this.allowed.length];
  };

  return CheckDigit;

})();
