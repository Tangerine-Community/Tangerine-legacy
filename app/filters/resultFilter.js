
(function(doc, req) {
  if (doc.collection && doc.collection === "result" && doc.assessmentId === req.query.assessmentId) {
    return true;
  }
  return false;
});
