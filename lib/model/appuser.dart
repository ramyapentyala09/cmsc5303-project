class AppUser {
  // keys for Firestore doc
  static const EMAIL = 'email';
  static const AVATAR_URL = 'avatarURL';
  static const ANDROID_TOKEN = 'androidToken';
  static const SAVED = 'saved';
  static const TIMESTAMP = 'timestamp';

  String? docId;
  late String email;
  late String avatarURL;
  late String androidToken;
  late List<dynamic> saved;
  DateTime? timestamp;

  AppUser({
    this.docId,
    this.email = '',
    this.avatarURL = '',
    this.androidToken = '',
    this.saved = const [],
    this.timestamp,
  });

  AppUser.clone(AppUser p) {
    this.docId = p.docId;
    this.email = p.email;
    this.avatarURL = p.avatarURL;
    this.androidToken = p.androidToken;
    this.saved = p.saved;
    this.timestamp = p.timestamp;
  }

  Map<String, dynamic> toFirestoreDoc() {
    return {
      EMAIL: this.email,
      AVATAR_URL: this.avatarURL,
      ANDROID_TOKEN: this.androidToken,
      SAVED: this.saved,
      TIMESTAMP: this.timestamp,
    };
  }

  static AppUser? fromFirestoreDoc({
    required Map<String, dynamic> doc,
    required String docId,
  }) {
    for (var key in doc.keys) {
      if (doc[key] == null) return null;
    }
    return AppUser(
      docId: docId,
      email: doc[EMAIL] ??= 'N/A',
      avatarURL: doc[AVATAR_URL] ??= '',
      androidToken: doc[ANDROID_TOKEN] ??= '',
      saved: doc[SAVED] ??= [],
      timestamp: doc[TIMESTAMP] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[TIMESTAMP].millisecondsSinceEpoch,
            )
          : DateTime.now(),
    );
  }
}
