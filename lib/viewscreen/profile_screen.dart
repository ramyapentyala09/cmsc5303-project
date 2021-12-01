import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/appuser.dart';
import 'package:lesson3/model/constant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/delete_account.dart';
import 'package:lesson3/viewscreen/update_password.dart';
import 'package:lesson3/viewscreen/view/memo_item.dart';
import 'package:lesson3/viewscreen/view/mydailog.dart';

import 'detailedview_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profileScreen';

  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late _Controller con;

  AppUser? appUser;

  File? pickedImage;

  _ProfileScreenState() {
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirestoreController.getCurrentUser(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.exists) {
                  appUser = AppUser.fromFirestoreDoc(
                    doc: snapshot.data!.data() as Map<String, dynamic>,
                    docId: snapshot.data!.id,
                  );

                  return Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: width * 0.3,
                            width: width * 0.3,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.white,
                                width: width * 0.015,
                              ),
                              borderRadius: BorderRadius.circular(width * 0.3),
                              image: DecorationImage(
                                image: (con.hasSelectedImage &&
                                        pickedImage != null)
                                    ? FileImage(pickedImage!)
                                    : (appUser!.avatarURL != '')
                                        ? NetworkImage(
                                            appUser!.avatarURL.toString(),
                                          )
                                        : AssetImage(
                                            'assets/images/default-profile.png',
                                          ) as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0.0,
                            bottom: 0.0,
                            child: Container(
                              width: width * 0.1,
                              height: width * 0.1,
                              color: Colors.blue[200],
                              child: PopupMenuButton(
                                onSelected: con.getPhoto,
                                itemBuilder: (context) => [
                                  for (var source in PhotoSource.values)
                                    PopupMenuItem(
                                      value: source,
                                      child: Text(
                                          '${source.toString().split('.')[1]}'),
                                    )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Container(
                        height: 70.0,
                        child: con.hasSelectedImage
                            ? Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: con.upload,
                                      child: Text(
                                        'Upload',
                                        style:
                                            Theme.of(context).textTheme.button,
                                      ),
                                    ),
                                    SizedBox(width: 10.0),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          con.hasSelectedImage = false;
                                        });
                                      },
                                      child: Text(
                                        'Cancel',
                                        style:
                                            Theme.of(context).textTheme.button,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                padding: EdgeInsets.only(bottom: 20.0),
                                width: width,
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "${widget.user.email}",
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    Text(
                                      "Date joined: ${DateFormat.yMEd().format(appUser!.timestamp!)}",
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      Divider(),
                      SizedBox(height: 5.0),
                      ElevatedButton(
                        onPressed: con.updatePassword,
                        child: Text(
                          'Update Password',
                          style: Theme.of(context).textTheme.button,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      ElevatedButton(
                        onPressed: con.deleteAccount,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red),
                        ),
                        child: Text(
                          'Delete Account',
                          style: Theme.of(context).textTheme.button,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      StreamBuilder<QuerySnapshot>(
                          stream:
                              FirestoreController.getUserSaved(appUser!.docId!),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data!.docs.length > 0) {
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text("Saved List"),
                                      ],
                                    ),
                                    SizedBox(height: 20.0),
                                    Column(
                                      children: List.generate(
                                          snapshot.data!.docs.length, (index) {
                                        PhotoMemo? photomemo =
                                            PhotoMemo.fromFirestoreDoc(
                                          doc: snapshot.data!.docs[index].data()
                                              as Map<String, dynamic>,
                                          docId: snapshot.data!.docs[index].id,
                                        );
                                        return MemoItem(
                                          photoMemo: photomemo!,
                                          onTap: () {
                                            con.onTap(photomemo);
                                          },
                                        );
                                      }),
                                    ),
                                  ],
                                );
                              } else {
                                return Center(
                                  child: Text("No saved memos"),
                                );
                              }
                            }

                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }),
                    ],
                  );
                } else {
                  return Center(
                    child: Text("Failed to load profile"),
                  );
                }
              }

              return Container(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Controller {
  late _ProfileScreenState state;
  bool hasSelectedImage = false;

  _Controller(this.state);

  void upload() async {
    if (state.pickedImage == null) {
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Photo not Selected',
      );
      return;
    }
    MyDialog.circularProgressStart(state.context);

    try {
      Map photoInfo = await CloudStorageController.uploadPhotoFile(
        imageFolder: Constant.PROFILE_IMAGES_FOLDER,
        photo: state.pickedImage!,
        uid: state.widget.user.uid,
        filename:
            '${Constant.PROFILE_IMAGES_FOLDER}/${state.widget.user.uid}/${state.widget.user.uid}',
        listner: (progress) {
          state.render(() {});
        },
      );

      bool success = !await FirestoreController.addAvatarURL(
        downloadURL: photoInfo[ARGS.DownloadURL],
      );

      state.render(() {
        hasSelectedImage = success;
      });

      MyDialog.circularProgressStop(state.context);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);

      if (Constant.DEV) print('----Add new photomemo failed: $e');
      MyDialog.showSnackBar(
          context: state.context, message: 'Add New photomemo failed: $e');
    }
  }

  void getPhoto(PhotoSource source) async {
    try {
      var imageSource = source == PhotoSource.CAMERA
          ? ImageSource.camera
          : ImageSource.gallery;
      XFile? image = await ImagePicker().pickImage(source: imageSource);
      if (image == null) return;
      state.render(() {
        hasSelectedImage = true;
        state.pickedImage = File(image.path);
      });
    } catch (e) {
      if (Constant.DEV) print('----Failed to get a pic: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Failed to get a picture: $e',
      );
    }
  }

  void updatePassword() async {
    try {
      await Navigator.pushNamed(state.context, UpdatePasswordScreen.routeName,
          arguments: {
            ARGS.USER: state.widget.user,
          });
      Navigator.of(state.context).pop(); // close the drawer
    } catch (e) {
      if (Constant.DEV) print('---shared with error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Failed to get update password: $e',
      );
    }
  }

  void deleteAccount() async {
    try {
      await Navigator.pushNamed(state.context, DeleteAccountScreen.routeName,
          arguments: {
            ARGS.USER: state.widget.user,
          });
      Navigator.of(state.context).pop(); // close the drawer
    } catch (e) {
      if (Constant.DEV) print('---shared with error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Failed to get delete account: $e',
      );
    }
  }

  void onTap(PhotoMemo photoMemo) async {
    // var state;
    await Navigator.pushNamed(state.context, DetailedViewScreen.routeName,
        arguments: {
          ARGS.USER: state.widget.user,
          ARGS.OnePhotoMemo: photoMemo,
        });
  }
}
