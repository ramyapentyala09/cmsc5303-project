import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/controller/googleML_controller.dart';
import 'package:lesson3/model/appuser.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lesson3/model/theme_constants.dart';
import 'package:lesson3/viewscreen/view/mydailog.dart';

class AddNewPhotoMemoScreen extends StatefulWidget {
  static const routeName = '/addNewPhotoMemoScreen';

  late final User user;
  final List<PhotoMemo> photoMemoList;

  AddNewPhotoMemoScreen({required this.user, required this.photoMemoList});

  @override
  State<StatefulWidget> createState() {
    return _AddNewPhotoMemoState();
  }
}

class _AddNewPhotoMemoState extends State<AddNewPhotoMemoScreen> {
  late _Controller con;
  GlobalKey<FormState> formKey = GlobalKey();
  File? photo;
  String? _sharedUserEmail;

  TextEditingController _sharedUserEmailController = TextEditingController();

  _AddNewPhotoMemoState() {
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New PhotoMemo'),
        actions: [
          IconButton(
            onPressed: con.save,
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: photo == null
                          ? FittedBox(
                              child: Icon(
                                Icons.photo_library,
                              ),
                            )
                          : Image.file(photo!),
                    ),
                    Positioned(
                      right: 0.0,
                      bottom: 0.0,
                      child: Container(
                        color: Colors.blue[200],
                        child: PopupMenuButton(
                          onSelected: con.getPhoto,
                          itemBuilder: (context) => [
                            for (var source in PhotoSource.values)
                              PopupMenuItem(
                                value: source,
                                child: Text(
                                  '${source.toString().split('.')[1]}',
                                ),
                              )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                con.progressMessage == null
                    ? SizedBox(
                        height: 1.0,
                      )
                    : Text(
                        con.progressMessage!,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                SizedBox(height: 30.0),
                TextFormField(
                  decoration: textFormFieldDecoration(context).copyWith(
                    hintText: 'Enter Title',
                    labelText: 'Title',
                  ),
                  autocorrect: true,
                  validator: PhotoMemo.validateTitle,
                  onSaved: con.saveTitle,
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: textFormFieldDecoration(context).copyWith(
                    hintText: 'Enter Memo',
                    labelText: 'Memo',
                  ),
                  autocorrect: true,
                  keyboardType: TextInputType.multiline,
                  maxLines: 6,
                  validator: PhotoMemo.validateMemo,
                  onSaved: con.saveMemo,
                ),
                SizedBox(height: 20.0),
                Wrap(
                  runSpacing: 5.0,
                  spacing: 5.0,
                  children: List.generate(
                    con.tempMemo.sharedWith.length,
                    (index) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 5.0,
                      ),
                      margin: EdgeInsets.only(right: 5.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .background
                            .withOpacity(0.25),
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("${con.tempMemo.sharedWith[index]} "),
                          InkWell(
                            onTap: () {
                              setState(() {
                                con.tempMemo.sharedWith.removeAt(index);
                              });
                            },
                            child: Icon(
                              Icons.close,
                              size: 15.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  onChanged: (input) {
                    setState(() {
                      _sharedUserEmail = input;
                    });
                  },
                  controller: _sharedUserEmailController,
                  decoration: textFormFieldDecoration(context).copyWith(
                    hintText: 'Enter user email to share',
                    labelText: 'Shared with',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: PhotoMemo.validateSharedWith,
                ),
                SizedBox(height: 10.0),
                StreamBuilder<QuerySnapshot>(
                  stream: (_sharedUserEmail != null)
                      ? FirestoreController.searchUser(
                          _sharedUserEmail!,
                        )
                      : null,
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.docs.length > 0) {
                        return Column(
                          children: List.generate(snapshot.data!.docs.length,
                              (index) {
                            AppUser? appUser = AppUser.fromFirestoreDoc(
                              doc: snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>,
                              docId: snapshot.data!.docs[index].id,
                            );

                            if (_sharedUserEmail != "") {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (!con.tempMemo.sharedWith
                                        .contains(appUser!.email)) {
                                      con.tempMemo.sharedWith
                                          .add(appUser.email);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 10.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background
                                        .withOpacity(0.25),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(appUser!.email),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if (_sharedUserEmail != "") {
                              return LinearProgressIndicator();
                            }

                            return SizedBox();
                          }),
                        );
                      } else {
                        return Center(
                          child: Text("No users found"),
                        );
                      }
                    }

                    return SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  late _AddNewPhotoMemoState state;
  PhotoMemo tempMemo = PhotoMemo();
  String? progressMessage;

  _Controller(this.state);

  void save() async {
    FormState? currentstate = state.formKey.currentState;
    if (currentstate == null || !currentstate.validate()) return;
    currentstate.save();

    if (state.photo == null) {
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Photo not Selected',
      );
      return;
    }
    MyDialog.circularProgressStart(state.context);

    try {
      Map photoInfo = await CloudStorageController.uploadPhotoFile(
        imageFolder: Constant.PHOTO_IMAGES_FOLDER,
        photo: state.photo!,
        uid: state.widget.user.uid,
        listner: (progress) {
          state.render(() {
            if (progress == 100)
              progressMessage = null;
            else
              progressMessage = 'Uploading $progress %';
          });
        },
      );
      // get image labels by ML
      
      List<String> imageLabels =
          await GoogleMLController.getImageLabels(photo: state.photo!);
      String imageText =
          await GoogleMLController.getImageText(photo: state.photo!);
      List<String> imageTextBlocks =
          await GoogleMLController.getImageTextBlocks(photo: state.photo!);

      tempMemo.imageLabels.addAll(imageLabels);
      tempMemo.imagetextblocks.addAll(imageTextBlocks);
      tempMemo.imagetext = imageText;

      tempMemo.photoFilename = photoInfo[ARGS.Filename];
      tempMemo.photoURL = photoInfo[ARGS.DownloadURL];
      tempMemo.createdBy = state.widget.user.email!;
      tempMemo.timestamp = DateTime.now();

      String docId =
          await FirestoreController.addPhotoMemo(photoMemo: tempMemo);
      tempMemo.docId = docId;
      state.widget.photoMemoList.insert(0, tempMemo);

      MyDialog.circularProgressStop(state.context);

      // return to UserHome screen
      Navigator.pop(state.context);
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
      state.render(() => state.photo = File(image.path));
    } catch (e) {
      if (Constant.DEV) print('----Failed to get a pic: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Failed to get a picture: $e',
      );
    }
  }

  void saveTitle(String? value) {
    if (value != null) tempMemo.title = value;
  }

  void saveMemo(String? value) {
    if (value != null) tempMemo.memo = value;
  }
}
