(doc) ->
  return if doc._id isnt "location-list"

  counties = Object.keys(doc.counties)
  countyObjects = counties.map (el) -> name : doc.counties[el].name, id : el
  countyObjects.forEach (el) -> emit "key-#{el.id}", el.name

  counties.forEach (county) ->
    zones = []

    subCounties = Object.keys doc.counties[county].subCounties
    subCounties.forEach (subCounty) ->
      thisSubcountyZones = Object.keys doc.counties[county].subCounties[subCounty].zones

      thisSubcountyZones.forEach (zone) ->
        schools = Object.keys doc.counties[county].subCounties[subCounty].zones[zone].schools

        schools.forEach (school) ->
          emit "county-#{county}-zone-#{zone}-school-#{school}", {
            County:doc.counties[county].name,
            CountyId:doc.counties[county].code,
            SubCounty:doc.counties[county].subCounties[subCounty].name,
            SubCountyId:doc.counties[county].subCounties[subCounty].code,
            Zone:doc.counties[county].subCounties[subCounty].zones[zone].name,
            ZodeId:doc.counties[county].subCounties[subCounty].zones[zone].code,
            School:doc.counties[county].subCounties[subCounty].zones[zone].schools[school].name,
            SchoolCode:doc.counties[county].subCounties[subCounty].zones[zone].schools[school].code,
            TusomeCode:doc.counties[county].subCounties[subCounty].zones[zone].schools[school].tusome,
            TSCCode:doc.counties[county].subCounties[subCounty].zones[zone].schools[school].tsc,
            KNECCode:doc.counties[county].subCounties[subCounty].zones[zone].schools[school].knec,
            Address:doc.counties[county].subCounties[subCounty].zones[zone].schools[school].address,
            Province:doc.counties[county].subCounties[subCounty].zones[zone].schools[school].province,
            Division:doc.counties[county].subCounties[subCounty].zones[zone].schools[school].division,
            IdToBeUsed:doc.counties[county].subCounties[subCounty].zones[zone].schools[school].idToBeUsed,
            IdAlpha:doc.counties[county].subCounties[subCounty].zones[zone].schools[school].idAlpha
          }


          doc.counties[county].subCounties[subCounty].zones[zone].schools[school]
          emit "parents-#{school}", {county:county, zone:zone}


