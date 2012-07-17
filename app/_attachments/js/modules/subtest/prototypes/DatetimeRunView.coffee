class DatetimeRunView extends Backbone.View

  className: "datetime"

  initialize: (options) ->
    @model  = @options.model
    @parent = @options.parent
  
  render: ->
    dateTime = new Date()
    year     = dateTime.getFullYear()
    month    = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][dateTime.getMonth()]
    day      = dateTime.getDate()
    minutes  = dateTime.getMinutes()
    minutes  = "0" + minutes if minutes < 10
    time     = dateTime.getHours() + ":" + minutes

    @$el.html "
      <form>
          <table>
            <tr>
              <td><label for='year'>Year</label><input id='year' name='year' value='#{year}'></td>
              <td><label for='month'>Month</label><input id='month' type='month' name='month' value='#{month}'></td>
              <td><label for='day'>Day</label><input id='day' type='day' name='day' value='#{day}'></td>
            </tr>
          </table>
          <label for='time'>Time</label><input type='text' id='time' name='time' value='#{time}'>
      </form>
      "
    @trigger "rendered"
  
  getResult: ->
    return {
      "year"  : @$el.find("#year").val()
      "month" : @$el.find("#month").val()
      "day"   : @$el.find("#day").val()
      "time"  : @$el.find("#time").val()
    }
  
  getSum: ->
    return {
      correct: 1
      incorrect: 0
      missing: 0
      total: 1
    }

  isValid: ->
    true
