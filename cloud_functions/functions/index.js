const admin = require('firebase-admin');
const serviceAccount = require("./permissions.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Triggers
const Triggers = require("./triggers/triggers");

exports.sendCommentNotification = Triggers.sendCommentNotification;
