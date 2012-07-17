# little janky, no model
class CSVView extends Backbone.View

  events:
    'click .option_reduce' : 'toggleReduce'
  
  toggleReduce: (event) ->
    value = $(event.target).val()
    @reduceExclusive = if value == "true" then true else false
    @initialize
      assessmentId : @assessmentId

  initialize: ( options ) ->
    @reduceExclusive = options.reduceExclusive
    
    @assessmentId = Utils.cleanURL options.assessmentId
    
    # Do we need Taylor's edits for the Malawi 2012 EGRA?
    # Note, always use reduceExclusive = true for the Malawi 2012 EGRA
    @malawi2012EGRA = false
    if @assessmentId == "b6faf1dcbe0aac8e66fc4607aa2c348b"
      @reduceExclusive = true
      @malawi2012EGRA = true
      console.log "Malawi 2012 May EGRA"
      
      @replaceMapValues = 
        "1" : ["yes", "true", "TRUE", "True", "correct", "checked", "mkazi"] 
        "0" : ["no", "false", "FALSE", "False", "incorrect", "unchecked","mwamuna"]
        "." : ["missing", "na", "Na", "NA", "undefined", "not_asked", "no_response", "skip"]

      @replaceMapKeys = 
        "enumerator" : "admin_name"
        "starttime" : "start_time"
        "endtime" : "end_time"
        "date-and-time:year" : "year"
        "date-and-time:month" : "month"
        "date-and-time:day" : "day"
        "date-and-time:time" : "assess_time"
        "school:province" : "region"
        "school:district" : "district"
        "school:name" : "school"
        "school:school-id" : "school_code"
        "student-consent:participant-consents" : "consent"
        "student-information:school-shift" : "shift"
        "student-information:zaka-zakubadwa" : "age"
        "student-information:mkazi" : "gender"
        "letter-name:autostopped" : "letter_auto_stop"
        "letter-name:last-attempted" : "letter_attempted"
        "letter-name:time-remaining" : "letter_time_remain"
        "letter-name:time-elapsed" : "NOT USED - time_elapsed"
        "syllables:autostopped" : "syllable_sound_auto_stop"
        "syllables:last-attempted" : "syllable_sound_attempted"
        "syllables:time-remaining" : "syllable_sound_time_remain"
        "syllables:time-elapsed" : "NOT USED - time_elapsed"
        "invented-words:autostopped" : "invent_word_auto_stop"
        "invented-words:last-attempted" : "invent_word_attempted"
        "invented-words:time-remaining" : "invent_word_time_remain"
        "invented-words:time-elapsed" : "NOT USED - time_elapsed"
        "oral-passage-reading:autostopped" : "oral_read_auto_stop"
        "oral-passage-reading:last-attempted" : "oral_read_attempted"
        "oral-passage-reading:time-remaining" : "oral_read_time_remain"
        "oral-passage-reading:time-elapsed" : "NOT USED - time_elapsed"
        "student-information:stream:stream" : "section"


      # Look for variable names starting with the left side
      # and turn them into the right side plus a number starting at 1
      @replaceWithNumbering = 
        "initial-sounds" : "pa_init_sound"
        "letter-name:letters-results" : "letter"
        "syllables:letters-results" : "syllable_sound"
        "invented-words:letters-results" : "invent_word"
        "oral-passage-reading:letters-results" : "oral_read_word"
        "reading-comprehension:comp" : "read_comp"
      
      # Only the pupil-context-interview questions need to be 
      # renamed both with a number and letter, for instance 4a
      @abnormalNamingTag = "pupil-context-interview"
      @abnormalNamingReplacement = "exit_interview"
      
      # Used to give letters to exit_interviews
      @alphabetLetters = ["", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k"]
      @betweenColonsIgnore = [":lang-spec", ":kodi-kunyumba-kwanu-kuli-zinthu-ngati-izi", ":16b"]
    
    # This is where the real work starts
    
    allResults = new Results
    allResults.fetch
      key: @assessmentId
      success: (collection) =>
        @results = collection.models
        @render()
    
    @disallowedKeys = ["mark_record"]
    @metaKeys = ["enumerator","starttime","timestamp"]
    

  render: ->
    if @results? && @results[0]?
      tableHTML = ""

      resultDataArray = []

      keys = []

      # make keys for our buckets
      for metaKey in @metaKeys
        keys.push metaKey

      maxIndex = 0

      for subtest in @results[0].attributes.subtestData
        subtestName = subtest.name.toLowerCase().dasherize()
        prototype = subtest.prototype
        
        # should break these out into classes at some point
        if prototype == "id"
          keys.push "id"
        else if prototype == "datetime"
          keys.push "year", "month", "date", "assess_time"
        else if prototype == "location"
          for label in subtest.data.labels
            keys.push label
        else if prototype == "consent"
          keys.push "consent"
        else if prototype == "grid"
          variableName = subtest.data.variable_name
          keys.push "#{variableName}_auto_stop","#{variableName}_time_remain", "#{variableName}_attempted"
          for item, i in subtest.data.items
            keys.push "#{variableName}#{i+1}"
        else if prototype == "survey"
          for surveyVariable, surveyValue of subtest.data
            if _.isObject(surveyValue)
              for optionKey, optionValue of surveyValue
                keys.push "#{surveyVariable}_#{optionKey}"
            else
              keys.push surveyVariable
        else if prototype == "complete"
          keys.push "additional_comments"

      resultDataArray.push keys

      # iterate all results
      for result, d in @results
        #console.log result
        values = []
        # add meta keys
        for metaKey in @metaKeys
          values.push result.attributes[metaKey]

        # add subtest data
        for subtest in result.attributes.subtestData

          prototype = subtest.prototype

          if prototype == "id"
            values[keys.indexOf("id")] = subtest.data.participant_id
          else if prototype == "location"
            for label, i in subtest.data.labels
              values[keys.indexOf(label)] = subtest.data.location[i]
          else if prototype == "datetime"
            values[keys.indexOf("year")]        = subtest.data.year
            values[keys.indexOf("month")]       = ["","Jan","Feb","Mar","Apr","Jun","Jul","Aug","Sep","Oct","Nov","Dec"].indexOf(subtest.data.month)
            values[keys.indexOf("date")]        = subtest.data.day
            values[keys.indexOf("assess_time")] = subtest.data.time
            
          else if prototype == "consent"
            values[keys.indexOf("consent")] = subtest.data.consent
          
          else if prototype == "grid"
            variableName = subtest.data.variable_name
            values[keys.indexOf("#{variableName}_auto_stop")] = subtest.data.auto_stop
            values[keys.indexOf("#{variableName}_time_remain")] = subtest.data.time_remain
            values[keys.indexOf("#{variableName}_attempted")] = subtest.data.attempted
            for item, i in subtest.data.items
              if item == "correct"
                exportValue = 1
              else if item == "incorrect"
                exportValue = 0
              else if item == "missing"
                exportValue = "."
              values[keys.indexOf("#{variableName}#{i+1}")] = exportValue

          else if prototype == "survey"
            for surveyVariable, surveyValue of subtest.data
              if _.isObject(surveyValue)
                for optionKey, optionValue of surveyValue
                  if optionValue == "checked"
                    exportValue = 1
                  else if optionValue == "unchecked"
                    exportValue = 0
                  else if optionValue == "not_asked"
                    exportValue = "."
                  values[keys.indexOf("#{surveyVariable}_#{optionKey}")] = exportValue
              else
                exportValue = if surveyValue == "not_asked" then "." else surveyValue
                values[keys.indexOf("#{surveyVariable}")] = exportValue

          else if prototype == "complete"
            console.log subtest.data.comment
            values[keys.indexOf("additional_comments")] = subtest.data.comment

        resultDataArray.push values

      `/*
      for rowNumber, row of resultDataArray
        
        # Begin Taylor's Edits for Malawi 2012 EGRA May
        if @malawi2012EGRA
          if rowNumber == "0"
            lastNumberedReplace = "**TRASHVALUE**"
            lastAbnormalReplace = "**TRASHVALUE**"
            index = 0
            letterIndex = 0
            for i, key of resultDataArray[0]
              if @replaceMapKeys[key]? # Is it a simple substitute?
                resultDataArray[0][i] = @replaceMapKeys[key]
                index = 0
              else # Or do we need to add numbering?
                for prefixTag, replacement of @replaceWithNumbering
                  if ~key.indexOf(prefixTag)
                    if lastNumberedReplace == prefixTag
                      index++
                    else
                      lastNumberedReplace = prefixTag
                      index = 1
                    resultDataArray[0][i] = replacement + index.toString()
                if ~key.indexOf(@abnormalNamingTag)
                  
                  if lastNumberedReplace != @abnormalNamingTag
                    index = 0
                    lastNumberedReplace = @abnormalNamingTag
                    
                  indexFirstColon = key.indexOf(":")
                  indexLastColon = key.lastIndexOf(":")
                  betweenColons = key.substring(indexFirstColon, indexLastColon)
                  if indexFirstColon == indexLastColon or ~@betweenColonsIgnore.indexOf(betweenColons)
                    index++
                    letterIndex = 0
                  else if betweenColons != lastAbnormalReplace
                    letterIndex = 1
                    index++
                    lastAbnormalReplace = betweenColons
                  else
                    letterIndex++
                    index++ if letterIndex == 1
                  resultDataArray[0][i] = @abnormalNamingReplacement + 
                    index.toString() + @alphabetLetters[letterIndex]
                  
                  
                  
          else
            for i, value of resultDataArray[rowNumber]
              for mapKey, mapValue of @replaceMapValues
                if _.isBoolean(value) # Handle values that pretend to be a boolean
                  value = value.toString()
                if ~mapValue.indexOf(value) # Can we convert it?
                  resultDataArray[rowNumber][i] = mapKey
        
        # End Taylor's Edits for Malawi 2012 EGRA May
        */`
      for row, i in resultDataArray
        tableHTML += "<tr>"
        count = 0
        for index in [0..row.length-1]
          tableHTML += "<td>#{row[index]}</td>"
          count++
        tableHTML += "</tr>"

      tableHTML = "<table>#{tableHTML}</table>"
      @$el.html tableHTML
      @csv = @$el.table2CSV { delivery : "value" }

      checkedString = "checked='checked'"

      @$el.html "
        <div id='csv_view'>
        <h1>Result CSV</h1>
        <textarea>#{@csv}</textarea><br>
        <a href='data:text/octet-stream;base64,#{Base64.encode(@csv)}' download='#{@assessmentId}.csv'>Download file</a>
        (Right click and click <i>Save Link As...</i>)
        </div>
        "


    @trigger "rendered"
