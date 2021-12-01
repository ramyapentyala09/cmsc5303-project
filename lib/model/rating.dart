class Rating {
  // keys for Firestore doc
  static const CREATED_BY = 'createdby';
  static const VALUE = 'value';
  static const TIMESTAMP = 'timestamp';

  String? docId;
  late String createdby;
  late dynamic value;
  DateTime? timestamp;

  Rating({
    this.docId,
    this.createdby = '',
    this.value = 0,
    this.timestamp,
  });

  Rating.clone(Rating p) {
    this.docId = p.docId;
    this.createdby = p.createdby;
    this.value = p.value;
    this.timestamp = p.timestamp;
  }

  Map<String, dynamic> toFirestoreDoc() {
    return {
      CREATED_BY: this.createdby,
      VALUE: this.value,
      TIMESTAMP: this.timestamp,
    };
  }

  static Rating? fromFirestoreDoc({
    required Map<String, dynamic> doc,
    required String docId,
  }) {
    for (var key in doc.keys) {
      if (doc[key] == null) return null;
    }
    return Rating(
      docId: docId,
      createdby: doc[CREATED_BY] ??= 'N/A',
      value: doc[VALUE] ??= 0,
      timestamp: doc[TIMESTAMP] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[TIMESTAMP].millisecondsSinceEpoch,
            )
          : DateTime.now(),
    );
  }
}
