const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {
  USER_COLLECTION,
  PHOTOMEMO_COLLECTION,
  COMMENT_COLLECTION,
} = require("../utils/constants");

exports.sendCommentNotification = functions.firestore
  .document(`/${PHOTOMEMO_COLLECTION}/{memoId}/${COMMENT_COLLECTION}/{commentId}`)
  .onCreate(
    async (snapshot, context) => {
      const memoId = context.params.memoId;
      const commentor = snapshot.data().createdby;

      const photoMemoQuerySnapshot = await admin.firestore().doc(`${PHOTOMEMO_COLLECTION}/${memoId}`).get();
      const photoMemo = photoMemoQuerySnapshot.data();

      if (commentor == photoMemo.createdby) {
        return;
      }

      const userQuerySnapshot = await admin.firestore().collection(`${USER_COLLECTION}`).where('email', '==', photoMemo.createdby).get();
      const user = userQuerySnapshot.docs[0].data();

      const token = user.androidToken;

      if (token == null || token == undefined || token == "") {
        return;
      }

      await admin.firestore().doc(`${PHOTOMEMO_COLLECTION}/${memoId}`).update({
        newcount: admin.firestore.FieldValue.increment(1),
      });

      const payload = {
        notification: {
          title: "New comment",
          body: `${commentor} commented on your photo`,
          imageUrl: `${photoMemo.photoURL}`,
          icon: "default",
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          sound: "default",
        }
      };

      return admin.messaging().sendToDevice(token, payload);
    });