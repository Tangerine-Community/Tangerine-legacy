class Workflow extends Backbone.ParentModel

  url : "workflow"

  Child           : WorkflowStep
  ChildCollection : WorkflowSteps

  initialize: ( options ) ->

  getLength: -> @collection.length || @attributes.children.length

  stepModelByIndex: ( index ) ->
    return @collection.models[index] || null

  duplicateStep: (modelId, options) ->
    model = @collection.get(modelId)
    newAttributes      = _(model.attributes).clone()
    newAttributes.name = "Copy of #{newAttributes.name}"
    newAttributes._id = Utils.guid()
    @newChild newAttributes, options

  validate: ( attr, options ) ->

    return

    return "Please supply children" unless attr.children?
    for child in attr.children

      if child.type is "login"
        return "Please specify `userType`" unless child.userType?

      else if child.type is "new"
        return "Please specify `viewClass`"     unless child.viewClass?
        return "`viewClass` must be a known function" unless child.viewClass?

