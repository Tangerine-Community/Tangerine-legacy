# This RISC requires view that prefills with common configurations
# binary trinary agreement, validity, boolean
class Question extends Backbone.Model

  url: "question"

  config:
    types : [ "multiple", "single", "open" ]

  default:
    order  : 0
    prompt : "Is this an example question?"
    hint   : "[hint or answer]"

    # main question types
    type : "single"

    # question features
    otherWriteIn : false
    options      : [] # tricky bit, contains `label`,`value` property

    # outside requirements
    linkedGridScore : 0

    # Within subtest requirements
    skipLink        : null
    skipRequirement : null

  initialize: ( options )->
    
    
