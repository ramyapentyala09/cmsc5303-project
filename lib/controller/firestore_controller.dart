import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lesson3/controller/firebaseauth_controller.dart';
import 'package:lesson3/model/appuser.dart';
import 'package:lesson3/model/comment.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/model/rating.dart';

class FirestoreController {
  static Future<void> addFirebaseMessagingToken(String token) async {
    FirebaseFirestore.instance
        .collection(Constant.USER_COLLECTION)
        .doc(FirebaseAuthController.currentUserId())
        .update({"androidToken": token});
  }

  static Future<void> addUserDetails(AppUser appUser) async {
    FirebaseFirestore.instance
        .collection(Constant.USER_COLLECTION)
        .doc(appUser.docId)
        .set(appUser.toFirestoreDoc());
  }

  static addPhotoMemo({
    required PhotoMemo photoMemo,
  }) async {
    DocumentReference ref = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .add(photoMemo.toFirestoreDoc());
    return ref.id; //doc id
  }

  static Future<bool> addAvatarURL({
    required String downloadURL,
  }) async {
    return await FirebaseFirestore.instance
        .collection(Constant.USER_COLLECTION)
        .doc(FirebaseAuthController.currentUserId())
        .update({"avatarURL": downloadURL})
        .then((value) => true)
        .catchError((onError) => false);
  }

  static Stream<QuerySnapshot> getComments(String memoId) {
    return FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(memoId)
        .collection(Constant.COMMENT_COLLECTION)
        .orderBy('timestamp')
        .snapshots();
  }

  static Future<bool> addComment(String memoId, Comment comment) async {
    return await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(memoId)
        .collection(Constant.COMMENT_COLLECTION)
        .doc()
        .set(comment.toFirestoreDoc())
        .then((value) => true)
        .catchError((onError) => false);
  }

  static Stream<QuerySnapshot> getUserRatings(String memoId) {
    return FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(memoId)
        .collection(Constant.RATING_COLLECTION)
        .snapshots();
  }

  static Stream<DocumentSnapshot> getPhotoRating(String memoId) {
    return FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(memoId)
        .snapshots();
  }

  static Future<bool> addUserRating(
    String uid,
    PhotoMemo photoMemo,
    Rating newRating,
    Rating previousRating,
    int ratingsCount, {
    bool isUserUpdating = false,
  }) async {
    return await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(photoMemo.docId)
        .collection(Constant.RATING_COLLECTION)
        .doc(uid)
        .set(newRating.toFirestoreDoc())
        .then((result) => true)
        .catchError((onError) => false);
  }

  static Future<bool> updatePhotoRating(String memoId, double value) async {
    return await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(memoId)
        .update({"rating": value})
        .then((value) => true)
        .catchError((onError) => false);
  }

  static Stream<QuerySnapshot> getPhotoMemoList({
    required String email,
  }) {
    return FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: email)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .snapshots();
  }

  static Future<void> updatePhotoMemo({
    required String docId,
    required Map<String, dynamic> updateInfo,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(docId)
        .update(updateInfo);
  }

  static Stream<QuerySnapshot> searchImage({
    required String createdBy,
    required List<String> searchLabels, //OR search
  }) {
    return FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: createdBy)
        .where(PhotoMemo.SEARCH_FIELDS, arrayContainsAny: searchLabels)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getPhotoMemoListSharedWith({
    required String email,
  }) {
    return FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.SHARED_WITH, arrayContains: email)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .snapshots();
  }

  static Future<void> deletePhotoMemo({
    required PhotoMemo photoMemo,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(photoMemo.docId)
        .delete();
  }

  static Future<void> _deleteUserPhotoMemos({
    required String email,
  }) {
    return FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  static Future<bool> deleteUser({required User user}) async {
    return await _deleteUserPhotoMemos(email: user.email!).then((value) async {
      return await FirebaseFirestore.instance
          .collection(Constant.USER_COLLECTION)
          .doc(user.uid)
          .delete()
          .then((value) => true)
          .catchError((onError) => false);
    }).catchError((onError) => false);
  }

  static Stream<DocumentSnapshot> getCurrentUser() {
    return FirebaseFirestore.instance
        .collection(Constant.USER_COLLECTION)
        .doc(FirebaseAuthController.currentUserId())
        .snapshots();
  }

  static Stream<QuerySnapshot> getUserSaved(String uid) {
    return FirebaseFirestore.instance
        .collection(Constant.USER_COLLECTION)
        .doc(uid)
        .collection(Constant.SAVED_COLLECTION)
        .snapshots();
  }

  static Future<bool> addUserSaved(String uid, PhotoMemo photoMemo) async {
    return await FirebaseFirestore.instance
        .collection(Constant.USER_COLLECTION)
        .doc(uid)
        .collection(Constant.SAVED_COLLECTION)
        .doc(photoMemo.docId)
        .set(photoMemo.toFirestoreDoc())
        .then((value) => true)
        .catchError((onError) => false);
  }

  static Future<bool> removeUserSaved(String uid, String memoId) async {
    return await FirebaseFirestore.instance
        .collection(Constant.USER_COLLECTION)
        .doc(uid)
        .collection(Constant.SAVED_COLLECTION)
        .doc(memoId)
        .delete()
        .then((value) => true)
        .catchError((onError) => false);
  }

  static Future<bool> checkSaved(String uid, String memoId) async {
    return await FirebaseFirestore.instance
        .collection(Constant.USER_COLLECTION)
        .doc(uid)
        .collection(Constant.SAVED_COLLECTION)
        .doc(memoId)
        .get()
        .then((DocumentSnapshot documentSnapshot) => documentSnapshot.exists);
  }

  static Stream<QuerySnapshot> searchUser(String email) {
    return FirebaseFirestore.instance
        .collection(Constant.USER_COLLECTION)
        .where(AppUser.EMAIL, isGreaterThanOrEqualTo: email.toLowerCase())
        .where(AppUser.EMAIL,
            isNotEqualTo: FirebaseAuth.instance.currentUser!.email)
        .snapshots();
  }
}
