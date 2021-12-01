class Constant {
  static const DEV = true;
  static const DARKMODE = true;
  static const PHOTO_IMAGES_FOLDER = 'photo_image';
  static const PROFILE_IMAGES_FOLDER = 'profile_image';
  static const USER_COLLECTION = 'user_collection';
  static const SAVED_COLLECTION = 'saved_collection';
  static const PHOTOMEMO_COLLECTION = 'photomemo_collection';
  static const COMMENT_COLLECTION = 'comment_collection';
  static const RATING_COLLECTION = 'rating_collection';
}

enum ARGS {
  USER,
  DownloadURL,
  Filename,
  PhotoMemoList,
  OnePhotoMemo,
  CommentList,
}

enum PhotoSource {
  CAMERA,
  GALLERY,
}