utils = require("views/lib/utils")
cell        = utils.cell
exportValue = utils.exportValue

pairsLocation = ( subtest ) ->
  row = []
  for label, i in subtest.data.labels
    row.push cell subtest, label, subtest.data.location[i]
    zoneIndex   = subtest.data.location[i] if label is "zone"
    countyIndex = subtest.data.location[i] if label is "county"
    schoolIndex = subtest.data.location[i] if label is "school"

  if countyIndex? and zoneIndex? and schoolIndex?
    row = []
    row.push cell subtest, 'locationIndex', 'county-' + countyIndex + '-zone-' + zoneIndex + '-school-' + schoolIndex

  return row

pairsDatetime = ( subtest, datetimeSuffix ) ->
  row = []
  months = ["jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"]

  if ~months.indexOf(subtest.data.month.toLowerCase())
    monthData = months.indexOf(subtest.data.month.toLowerCase()) + 1
  else
    monthData = subtest.data.month

  row.push cell( subtest, "year#{datetimeSuffix}",        subtest.data.year)
  row.push cell( subtest, "month#{datetimeSuffix}",       monthData)
  row.push cell( subtest, "date#{datetimeSuffix}",        subtest.data.day)
  row.push cell( subtest, "assess_time#{datetimeSuffix}", subtest.data.time)
  return row

pairsObservation = ( subtest ) ->
  row = []
  for observations, i in subtest.data.surveys
    observationData = observations.data
    for surveyVariable, surveyValue of observationData
      if surveyValue is Object(surveyValue) # multiple type question
        for optionKey, optionValue of surveyValue
          row.push cell( subtest, "#{surveyVariable}_#{optionKey}_#{i+1}", exportValue(optionValue))
      else # single type question or open
        row.push cell( subtest, "#{surveyVariable}_#{i+1}", exportValue(surveyValue))
  return row

pairsGrid = ( subtest, isClass ) ->
  row = []

  variableName = subtest.data.variable_name
  row.push cell( subtest, "#{variableName}_auto_stop",                  subtest.data.auto_stop)
  row.push cell( subtest, "#{variableName}_time_remain",                subtest.data.time_remain)
  row.push cell( subtest, "#{variableName}_attempted",                  subtest.data.attempted)
  row.push cell( subtest, "#{variableName}_item_at_time",               subtest.data.item_at_time)
  row.push cell( subtest, "#{variableName}_time_intermediate_captured", subtest.data.time_intermediate_captured)

  correct = 0
  for item, i in subtest.data.items
    correct++ if item.itemResult is "correct"
    if isClass == true
      letterLabel = "#{i+1}_#{item.itemLabel}"
    else
      letterLabel = "#{variableName}#{i+1}"

    row.push cell( subtest, letterLabel, exportValue( item.itemResult ) )

  itemsPerMinute = correct / ( 1 - ( subtest.data.time_remain / subtest.data.time_allowed ) )

  row.push cell( subtest, "#{variableName}_time_allowed",     exportValue( subtest.data.time_allowed ) )
  row.push cell( subtest, "#{variableName}_items_per_minute", exportValue( itemsPerMinute ) )



  return row

pairsSurvey = ( subtest ) ->
  row = []
  for surveyVariable, surveyValue of subtest.data
    if surveyValue is Object(surveyValue) # multiple type question
      for optionKey, optionValue of surveyValue
        row.push cell( subtest, "#{surveyVariable}_#{optionKey}", exportValue(optionValue))
    else # single type question or open
      row.push cell( subtest, surveyVariable, exportValue(surveyValue)) # if open just show result, otherwise translate not_asked
  return row


pairsGps = (subtest) ->
  row = []
  row.push cell( subtest, "latitude",         subtest.data.lat )
  row.push cell( subtest, "longitude",        subtest.data.long )
  row.push cell( subtest, "accuracy",         subtest.data.acc )
  row.push cell( subtest, "altitude",         subtest.data.alt )
  row.push cell( subtest, "altitudeAccuracy", subtest.data.altAcc )
  row.push cell( subtest, "heading",          subtest.data.heading )
  row.push cell( subtest, "speed",            subtest.data.speed )
  row.push cell( subtest, "timestamp",        subtest.data.timestamp )
  return row

pairsCamera = (subtest, cameraSuffix, resultId) ->
  row = []
  row.push cell( subtest, "photo_captured#{cameraSuffix}",   exportValue(if subtest.data.imageBase64 != "" then "Yes" else "No"))
  row.push(cell( subtest, "photo_url#{cameraSuffix}",        exportValue(if subtest.data.imageBase64 != "" then "" + (subtest.data.imageBaseUrl.replace /_design\/tangerine/, "_design\/t") + resultId else "")))
  #The following line was commected out to handle a hack situation in NET Tutor for Kenya with the design doc title
  #row.push(cell( subtest, "photo_url#{cameraSuffix}",        exportValue(if subtest.data.imageBase64 != "" then ""+subtest.data.imageBaseUrl+resultId else "")))
  return row

if typeof(exports) == "object"

  exports.pairsCamera      = pairsCamera
  exports.pairsGrid        = pairsGrid
  exports.pairsGps         = pairsGps
  exports.pairsSurvey      = pairsSurvey
  exports.pairsObservation = pairsObservation
  exports.pairsDatetime    = pairsDatetime
  exports.pairsLocation    = pairsLocation