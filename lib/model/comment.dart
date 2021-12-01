class Comment {
  // keys for Firestore doc
  static const CREATED_BY = 'createdby';
  static const MESSAGE = 'message';
  static const TIMESTAMP = 'timestamp';

  String? docId;
  late String createdby;
  late String message;
  DateTime? timestamp;

  Comment({
    this.docId,
    this.createdby = '',
    this.message = '',
    this.timestamp,
  });

  Comment.clone(Comment p) {
    this.docId = p.docId;
    this.createdby = p.createdby;
    this.message = p.message;
    this.timestamp = p.timestamp;
  }

  Map<String, dynamic> toFirestoreDoc() {
    return {
      CREATED_BY: this.createdby,
      MESSAGE: this.message,
      TIMESTAMP: this.timestamp,
    };
  }

  static Comment? fromFirestoreDoc({
    required Map<String, dynamic> doc,
    required String docId,
  }) {
    for (var key in doc.keys) {
      if (doc[key] == null) return null;
    }
    return Comment(
      docId: docId,
      createdby: doc[CREATED_BY] ??= 'N/A',
      message: doc[MESSAGE] ??= '',
      timestamp: doc[TIMESTAMP] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[TIMESTAMP].millisecondsSinceEpoch,
            )
          : DateTime.now(),
    );
  }
}
