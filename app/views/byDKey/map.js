function( doc )
{
  if ( doc.collection && doc.collection != "result")
  {
    emit( doc.assessmentId.substr(-5,5), doc );
  }
}