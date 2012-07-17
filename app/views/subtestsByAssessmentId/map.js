function(doc) {
  if (doc.collection == 'subtest') {
    emit(doc.assessmentId, doc);
  }
}
