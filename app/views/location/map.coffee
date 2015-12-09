(doc) ->
  return if doc._id isnt "location-list"
 
 
  # counties = Object.keys(doc.counties)
  # countyObjects = counties.map (el) -> name : doc.counties[el].name, id : el
  # countyObjects.forEach (el) -> emit "key-#{el.id}", el.name

  # emit "counties", countyObjects

  # counties.forEach (county) ->
  #   zones = []

  #   subCounties = Object.keys doc.counties[county].subCounties
  #   subCounties.forEach (subCounty) ->
  #     thisSubcountyZones = Object.keys doc.counties[county].subCounties[subCounty].zones
  #     zones = zones.concat thisSubcountyZones.map (el) ->
  #       id   : el
  #       name : doc.counties[county].subCounties[subCounty].zones[el].name


  #     thisSubcountyZones.forEach (zone) ->
  #       schools = Object.keys doc.counties[county].subCounties[subCounty].zones[zone].schools
  #       emit "county-#{county}-zone-#{zone}", schools.map (el) ->
  #         id : el
  #         name : doc.counties[county].subCounties[subCounty].zones[zone].schools[el].name

  #       schools.forEach (school) ->
  #         emit "county-#{county}-zone-#{zone}-school-#{school}", doc.counties[county].subCounties[subCounty].zones[zone].schools[school]
  #         emit "parents-#{school}", {county:county, zone:zone}


  #   emit ("county-#{county}"), zones
  #   zones.forEach (el) -> emit "key-#{el.id}", el.name

