function( doc, req )
{
  if ( doc.collection && doc.collection != "result" )
  {
    if ( doc.assessmentId && doc.assessmentId.substr(-5,5) == req.query.downloadKey )
      return true;
  }
  return false;
}