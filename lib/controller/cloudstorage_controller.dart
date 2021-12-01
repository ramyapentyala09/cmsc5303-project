import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:uuid/uuid.dart';

class CloudStorageController {
  static Future<Map<ARGS, String>> uploadPhotoFile({
    required imageFolder,
    required File photo,
    String? filename,
    required String uid,
    required Function listner,
  }) async {
    filename ??= '$imageFolder/$uid/${Uuid().v1()}';
    UploadTask task = FirebaseStorage.instance.ref(filename).putFile(photo);
    task.snapshotEvents.listen((TaskSnapshot event) {
      int progress = (event.bytesTransferred / event.totalBytes * 100).toInt();
      listner(progress);
      print('----Progress: $progress');
    });
    await task;
    String downloadURL =
        await FirebaseStorage.instance.ref(filename).getDownloadURL();
    return {
      ARGS.DownloadURL: downloadURL,
      ARGS.Filename: filename,
    };
  }

  static Future<void> deletePhotoFile({
    required PhotoMemo photoMemo,
  })async{
    await FirebaseStorage.instance.ref().child(photoMemo.photoFilename).delete();

  }
}