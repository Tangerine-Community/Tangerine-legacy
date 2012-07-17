var Message,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Message = (function(_super) {

  __extends(Message, _super);

  function Message() {
    Message.__super__.constructor.apply(this, arguments);
  }

  Message.prototype.url = 'message';

  Message.prototype.defaults = {
    "to": "admin",
    "from": "nobody",
    "content": "content",
    "timestamp": 0
  };

  Message.prototype.initialize = function() {};

  return Message;

})(Backbone.Model);
