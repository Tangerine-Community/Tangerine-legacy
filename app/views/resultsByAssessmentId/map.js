function(doc) {
  if (doc.collection == 'result') {
    emit(doc.assessmentId, doc);
  }
}