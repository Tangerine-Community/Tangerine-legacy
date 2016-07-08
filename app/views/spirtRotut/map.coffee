(doc) ->

  return unless doc.collection is "result"
  return unless doc.tripId

  result = {}

  #
  # validation
  #

  updated = doc.updated #"Thu Mar 06 2014 11:00:00 GMT+0300 (EAT)"
  docTime = new Date(updated)
  sMin = updated.substr(0,16) + "07:00:00" + updated.substr(-15)
  sMax = updated.substr(0,16) + "14:00:00" + updated.substr(-15)
  min = new Date(sMin)
  max = new Date(sMax)

  validTime = min < docTime < max

  result.validTime = validTime

  #
  # by month
  #
  year  = docTime.getFullYear()
  month = docTime.getMonth() + 1
  result.month = month

  #
  # by Zone, County, subject, class, gps
  #

  result.minTime = doc.startTime || doc.start_time || doc.subtestData.start_time
  result.maxTime = doc.startTime || doc.start_time || doc.subtestData.start_time

  for subtest in doc.subtestData

    result.minTime = if subtest.timestamp < result.minTime then subtest.timestamp else result.minTime
    result.maxTime = if subtest.timestamp > result.maxTime then subtest.timestamp else result.maxTime

    if subtest.prototype is "location"

      for label, i in subtest.data.labels
        zoneIndex     = i if label is "zone"
        districtIndex = i if label is "district"
        schoolIndex   = i if label is "school"

      zoneKey     = subtest.data.location[zoneIndex]
      districtKey = subtest.data.location[districtIndex]
      schoolKey   = subtest.data.location[schoolIndex]

      result.zone     = zoneKey     if subtest.data.location[zoneIndex]?
      result.district = districtKey if subtest.data.location[districtIndex]?
      result.school   = schoolKey   if subtest.data.location[schoolIndex]?

      result.school = subtest.data.schoolId if subtest.data.schoolId?

    else if subtest.prototype is "survey"

      result.subject = subtest.data.subject if subtest.data.subject?
      result.class   = subtest.data.class   if subtest.data.class?
      result.week    = subtest.data.week    if subtest.data.week?
      result.day     = subtest.data.day     if subtest.data.day?

    else if subtest.prototype is "gps" and subtest.data.long? and subtest.data.lat?

      result.gpsData = 
        type : 'Feature'
        properties : []
        geometry :
          type : 'Point'
          coordinates : [ subtest.data.long, subtest.data.lat ]

  #
  # items per minute
  #

  # handle a class result
  if doc.subtestData.items?

    totalItems   = doc.subtestData.items.length
    correctItems = 0
    for item in doc.subtestData.items
      correctItems++ if item.itemResult is "correct"

    totalTime    = doc.timeAllowed
    timeLeft     = doc.subtestData.time_remain
    result.itemsPerMinute = [( totalItems - ( totalItems - correctItems ) ) / ( ( totalTime - timeLeft ) / ( totalTime ) )]

  #
  # by enumerator
  #

  result.user = doc.enumerator || doc.editedBy

  #
  # number of subtests
  #

  result.subtests = doc.subtestData.length || 1 # could be a class result


  #
  # WorkflowId
  #
  result.workflowId = doc.workflowId

  #
  # _id
  #

  result.ids = [doc._id]

  emit doc.tripId, result