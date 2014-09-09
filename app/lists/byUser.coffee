(head, req) ->
  start headers:
    "content-type": "application/json"

  results = []
  results.push row  unless not ~req.userCtx.roles.indexOf("group." + row.value.group)  while row = getRow()
  
  #send( "(" + JSON.stringify( results, null, " " ) + ")" );
  send "(" + JSON.stringify(req, null, " ") + ")"
  return