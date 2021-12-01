class PhotoMemo {
  // keys for Firestore doc
  static const TITLE = 'title';
  static const MEMO = 'memo';
  static const CREATED_BY = 'createdby';
  static const PHOTO_URL = 'photoURL';
  static const PHOTO_FILENAME = 'photofilename';
  static const RATING = 'rating';
  static const TIMESTAMP = 'timestamp';
  static const SHARED_WITH = 'sharedwith';
  static const IMAGE_LABELS = 'imagelabels';
  static const IMAGE_TEXT = 'imagetext';
  static const IMAGE_TEXT_BLOCKS = 'imagetextblocks';
  static const SEARCH_FIELDS = 'searchfields';
  static const NEW_COUNT = 'newcount';
  String? docId;
  late String createdBy;
  late String title;
  late String memo;
  late String photoFilename;
  late String photoURL;
  late dynamic rating;
  DateTime? timestamp;
  late List<dynamic> sharedWith;
  late List<dynamic> imageLabels;
  late String imagetext;
  late List<dynamic> imagetextblocks;
  late List<dynamic> searchfields;
  late int newcount;

  PhotoMemo({
    this.docId,
    this.createdBy = '',
    this.title = '',
    this.memo = '',
    this.photoFilename = '',
    this.photoURL = '',
    this.rating = 0,
    this.timestamp,
    this.imagetext = '',
    List<dynamic>? sharedWith,
    List<dynamic>? imageLabels,
    List<dynamic>? imagetextblocks,
    List<dynamic>? searchfields,
    this.newcount = 0,
  }) {
    this.sharedWith = sharedWith == null ? [] : [...sharedWith];
    this.imageLabels = imageLabels == null ? [] : [...imageLabels];
    this.imagetextblocks = imagetextblocks == null ? [] : [...imagetextblocks];
    this.searchfields = searchfields == null ? [] : [...searchfields];
  }

  PhotoMemo.clone(PhotoMemo p) {
    this.docId = p.docId;
    this.createdBy = p.createdBy;
    this.title = p.title;
    this.memo = p.memo;
    this.photoFilename = p.photoFilename;
    this.photoURL = p.photoURL;
    this.rating = p.rating;
    this.timestamp = p.timestamp;
    this.sharedWith = [...p.sharedWith];
    this.imageLabels = [...p.imageLabels];
    this.imagetext = p.imagetext;
    this.imagetextblocks = [...p.imagetextblocks];
    this.searchfields = [...p.searchfields];
    this.newcount = p.newcount;
  }

  // a.assign(b) ====> a = b
  void assign(PhotoMemo p) {
    this.docId = p.docId;
    this.createdBy = p.createdBy;
    this.title = p.title;
    this.memo = p.memo;
    this.photoFilename = p.photoFilename;
    this.photoURL = p.photoURL;
    this.rating = p.rating;
    this.timestamp = p.timestamp;
    this.imagetext = p.imagetext;
    this.sharedWith.clear();
    this.sharedWith.addAll(p.sharedWith);
    this.imageLabels.clear();
    this.imageLabels.addAll(p.imageLabels);
    this.imagetextblocks.clear();
    this.imagetextblocks.addAll(p.imagetextblocks);
    this.searchfields.clear();
    this.searchfields.addAll(p.searchfields);
    this.newcount = p.newcount;
  }

  Map<String, dynamic> toFirestoreDoc() {
    return {
      TITLE: this.title,
      CREATED_BY: this.createdBy,
      MEMO: this.memo,
      PHOTO_FILENAME: this.photoFilename,
      PHOTO_URL: this.photoURL,
      RATING: this.rating,
      TIMESTAMP: this.timestamp,
      SHARED_WITH: this.sharedWith,
      IMAGE_LABELS: this.imageLabels,
      IMAGE_TEXT: this.imagetext,
      IMAGE_TEXT_BLOCKS: this.imagetextblocks,
      SEARCH_FIELDS: this.setSearchFields(),
      NEW_COUNT: this.newcount,
    };
  }

  static PhotoMemo? fromFirestoreDoc(
      {required Map<String, dynamic> doc, required String docId}) {
    for (var key in doc.keys) {
      if (doc[key] == null) return null;
    }
    return PhotoMemo(
      docId: docId,
      createdBy: doc[CREATED_BY] ??= 'N/A',
      title: doc[TITLE] ??= 'N/A',
      memo: doc[MEMO] ??= 'N/A',
      photoFilename: doc[PHOTO_FILENAME] ??= 'N/A',
      photoURL: doc[PHOTO_URL] ??= 'N/A',
      rating: doc[RATING] ??= 0,
      imagetext: doc[IMAGE_TEXT] ??= 'N/A',
      newcount: doc[NEW_COUNT] ??= 0,
      sharedWith: doc[SHARED_WITH] ??= [],
      imageLabels: doc[IMAGE_LABELS] ??= [],
      imagetextblocks: doc[IMAGE_TEXT_BLOCKS] ??= [],
      searchfields: doc[SEARCH_FIELDS] ??= [],
      timestamp: doc[TIMESTAMP] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[TIMESTAMP].millisecondsSinceEpoch)
          : DateTime.now(),
    );
  }

  List<dynamic> setSearchFields() {
    List<dynamic> tempSearchFields = [];
    this.searchfields.clear();

    tempSearchFields.addAll(
        this.imageLabels.map((label) => label.toString().toLowerCase()));

    this.imagetextblocks.forEach((block) {
      List<String> temp = block.split(RegExp(r'\s+'));
      temp.forEach((nested) {
        if (!tempSearchFields.contains(nested.toLowerCase())) {
          tempSearchFields.add(nested.toLowerCase());
        }
      });
    });

    return tempSearchFields;
  }

  static String? validateTitle(String? value) {
    return value == null || value.trim().length < 3 ? 'Title too short' : null;
  }

  static String? validateMemo(String? value) {
    return value == null || value.trim().length < 5 ? 'Memo too short' : null;
  }

  static String? validateSharedWith(String? value) {
    if (value == null || value.trim().length == 0) return null;

    List<String> emailList =
        value.trim().split(RegExp('(,| )+')).map((e) => e.trim()).toList();
    for (String e in emailList) {
      if (e.contains('@') && e.contains('.'))
        continue;
      else
        return 'Invalid Email List: Comma or space seperated  list';
    }
  }
}
