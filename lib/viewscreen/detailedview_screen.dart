import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lesson3/controller/googleML_controller.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lesson3/model/appuser.dart';
import 'package:lesson3/model/comment.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lesson3/model/rating.dart';
import 'package:lesson3/utils/theme_constants.dart';
import 'package:lesson3/viewscreen/view/mydailog.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';
import 'package:image_picker/image_picker.dart';

class DetailedViewScreen extends StatefulWidget {
  static const routeName = '/detailedViewScreen';

  final User user;
  final PhotoMemo photoMemo;

  DetailedViewScreen({required this.user, required this.photoMemo});

  @override
  State<StatefulWidget> createState() {
    return _DetailedViewState();
  }
}

class _DetailedViewState extends State<DetailedViewScreen> {
  late _Controller con;
  bool editMode = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> commentFormKey = GlobalKey<FormState>();
  TextEditingController commentController = TextEditingController();

  String? progressMessage;
  bool isRating = false;
  bool success = false;
  Rating previousRating = Rating();
  double userUpdatedRating = 0;
  bool isUserUpdating = false;
  int ratingsCount = 0;
  String? _sharedUserEmail;

  TextEditingController _sharedUserEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    con.resetCommentCount();
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Detailed View'),
        actions: [
          editMode
              ? IconButton(onPressed: con.update, icon: Icon(Icons.check))
              : widget.user.email == widget.photoMemo.createdBy
                  ? IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: con.edit,
                    )
                  : SizedBox()
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.50,
                                child: con.photo == null
                                    ? Column(
                                        children: [
                                          Expanded(
                                            child: WebImage(
                                              url: con.tempMemo.photoURL,
                                              context: context,
                                            ),
                                          ),
                                          SizedBox(height: 15.0),
                                          isRating
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(width: 10.0),
                                                    _buildRatingsBuilder(),
                                                    SizedBox(width: 10.0),
                                                    _buildSubmitRating(),
                                                  ],
                                                )
                                              : _buildRatingValue(context),
                                          SizedBox(height: 10.0),
                                        ],
                                      )
                                    : Image.file(con.photo!),
                              ),
                              editMode
                                  ? Positioned(
                                      right: 0.0,
                                      top: 0.0,
                                      child: Container(
                                        color: Colors.blue,
                                        child: PopupMenuButton(
                                          onSelected: con.getPhoto,
                                          itemBuilder: (context) => [
                                            for (var source
                                                in PhotoSource.values)
                                              PopupMenuItem<PhotoSource>(
                                                value: source,
                                                child: Text(
                                                    '${source.toString().split('.')[1]}'),
                                              )
                                          ],
                                        ),
                                      ),
                                    )
                                  : SizedBox(height: 1.0),
                            ],
                          ),
                          progressMessage == null
                              ? SizedBox(height: 1.0)
                              : Text(
                                  progressMessage!,
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                          SizedBox(height: 30.0),
                          TextFormField(
                            enabled: editMode,
                            style: Theme.of(context).textTheme.headline6,
                            decoration: textFormFieldDecoration(
                              context,
                            ).copyWith(
                              hintText: 'Enter title',
                              labelText: 'Title',
                            ),
                            initialValue: con.tempMemo.title,
                            autocorrect: true,
                            validator: PhotoMemo.validateTitle,
                            onSaved: con.saveTitle,
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            enabled: editMode,
                            style: Theme.of(context).textTheme.bodyText1,
                            decoration: textFormFieldDecoration(
                              context,
                            ).copyWith(
                              hintText: 'Enter Memo',
                              labelText: 'Memo',
                            ),
                            initialValue: con.tempMemo.memo,
                            keyboardType: TextInputType.multiline,
                            maxLines: 6,
                            autocorrect: true,
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
                                          con.tempMemo.sharedWith
                                              .removeAt(index);
                                        });
                                      },
                                      child: editMode
                                          ? Icon(
                                              Icons.close,
                                              size: 15.0,
                                            )
                                          : SizedBox(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          editMode
                              ? Column(
                                  children: [
                                    TextFormField(
                                      onChanged: (input) {
                                        setState(() {
                                          _sharedUserEmail = input;
                                        });
                                      },
                                      controller: _sharedUserEmailController,
                                      decoration:
                                          textFormFieldDecoration(context)
                                              .copyWith(
                                        hintText: 'Enter user email to share',
                                        labelText: 'Shared with',
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    SizedBox(height: 10.0),
                                    StreamBuilder<QuerySnapshot>(
                                      stream: (_sharedUserEmail != null)
                                          ? FirestoreController.searchUser(
                                              _sharedUserEmail!,
                                            )
                                          : null,
                                      builder: (context,
                                          AsyncSnapshot<QuerySnapshot>
                                              snapshot) {
                                        if (snapshot.hasData) {
                                          if (snapshot.data!.docs.length > 0) {
                                            return Column(
                                              children: List.generate(
                                                  snapshot.data!.docs.length,
                                                  (index) {
                                                AppUser? appUser =
                                                    AppUser.fromFirestoreDoc(
                                                  doc: snapshot
                                                          .data!.docs[index]
                                                          .data()
                                                      as Map<String, dynamic>,
                                                  docId: snapshot
                                                      .data!.docs[index].id,
                                                );

                                                if (_sharedUserEmail != "") {
                                                  return InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (!con
                                                            .tempMemo.sharedWith
                                                            .contains(appUser!
                                                                .email)) {
                                                          con.tempMemo
                                                              .sharedWith
                                                              .add(appUser
                                                                  .email);
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
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
                                                            color: Theme.of(
                                                                    context)
                                                                .dividerColor,
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
                                    SizedBox(height: 20.0),
                                  ],
                                )
                              : SizedBox(),
                          SizedBox(height: 20.0),
                          Constant.DEV
                              ? Column(
                                  children: [
                                    Text(
                                      'Image Labels by ML \n ${con.tempMemo.imageLabels}',
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Text Recognition by ML \n ${con.tempMemo.imagetext}',
                                    ),
                                  ],
                                )
                              : SizedBox(height: 1.0),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.0),
                    StreamBuilder<QuerySnapshot>(
                      stream: con.getComments(widget.photoMemo.docId!),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.docs.length > 0) {
                            var docs = snapshot.data!.docs;

                            return Column(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Comments (${snapshot.data!.docs.length})",
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.0),
                                    Divider(),
                                    Column(
                                      children: List.generate(
                                          snapshot.data!.docs.length, (index) {
                                        Comment? comment =
                                            Comment.fromFirestoreDoc(
                                          doc: docs[index].data()
                                              as Map<String, dynamic>,
                                          docId: snapshot.data!.docs[index].id,
                                        );

                                        return Column(
                                          children: [
                                            ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              title: Text(comment!.message),
                                              subtitle: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(comment.createdby),
                                                  Text(
                                                    DateFormat.yMd()
                                                        .add_jm()
                                                        .format(
                                                            comment.timestamp!),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Divider(),
                                          ],
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        }

                        return Text(
                          "No comments",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            height: 80.0,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).colorScheme.surface,
            child: Form(
              key: commentFormKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextFormField(
                      autocorrect: true,
                      controller: commentController,
                      validator: (input) =>
                          input!.isEmpty ? "Comment cannot be empty" : null,
                      onSaved: con.saveComment,
                      decoration: textFormFieldDecoration(context).copyWith(
                        hintText: "Enter your comment",
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        FocusScope.of(context).unfocus();
                        con.addComment();
                      });
                    },
                    icon: Icon(
                      Icons.send,
                      size: 30.0,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingValue(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isRating = !isRating;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<DocumentSnapshot>(
              stream: con.getPhotoRating(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData) {
                  var doc = snapshot.data!.data();
                  PhotoMemo? photoMemo = PhotoMemo.fromFirestoreDoc(
                    doc: doc as Map<String, dynamic>,
                    docId: snapshot.data!.id,
                  );

                  return Text(
                    "${photoMemo!.rating.toStringAsFixed(1)}",
                    style: TextStyle(
                      fontSize: 22.0,
                    ),
                  );
                }

                return Text(
                  "0",
                  style: TextStyle(
                    fontSize: 22.0,
                  ),
                );
              }),
          SizedBox(
            width: 20.0,
            height: 8.0,
          ),
          Icon(
            Icons.star,
            size: 35.0,
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsBuilder() {
    return StreamBuilder<QuerySnapshot>(
      stream: con.getUserRatings(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          var docs = snapshot.data!.docs;
          Rating userRating = Rating();
          bool isUpdate = false;

          if (snapshot.data!.docs.length > 0) {
            docs.forEach((doc) {
              Rating? rating = Rating.fromFirestoreDoc(
                doc: doc.data() as Map<String, dynamic>,
                docId: doc.id,
              );

              if (rating!.createdby == widget.user.email) {
                userRating = rating;
                isUpdate = true;
              } else {
                isUpdate = false;
              }
            });
          }

          return RatingBar.builder(
            initialRating: double.parse(userRating.value.toString()),
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            glow: false,
            itemCount: 5,
            itemSize: 35.0,
            itemPadding: EdgeInsets.symmetric(
              horizontal: 4.0,
            ),
            itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (rating) {
              setState(() {
                previousRating = userRating;
                userUpdatedRating = rating;
                isUserUpdating = isUpdate;
                ratingsCount = snapshot.data!.docs.length;
              });
            },
          );
        }

        return Text("Loading");
      },
    );
  }

  Widget _buildSubmitRating() {
    return IconButton(
      splashRadius: 25.0,
      onPressed: () async {
        if (userUpdatedRating > 0) {
          success = !await con.addUserRating(
            userUpdatedRating,
            ratingsCount,
            previousRating,
            isUserUpdating,
          );
          setState(() {
            isRating = success;
          });
        } else {
          setState(() {
            isRating = !isRating;
          });
        }
      },
      icon: Icon(Icons.check),
    );
  }
}

class _Controller {
  late _DetailedViewState state;
  late PhotoMemo tempMemo;
  late Comment comment = Comment();
  File? photo;

  _Controller(this.state) {
    tempMemo = PhotoMemo.clone(state.widget.photoMemo);
  }

  void getPhoto(PhotoSource source) async {
    try {
      var imageSource = source == PhotoSource.CAMERA
          ? ImageSource.camera
          : ImageSource.gallery;
      XFile? image = await ImagePicker().pickImage(source: imageSource);
      if (image == null) return;
      state.render(
          () => photo = File(image.path)); // canceled by camera or gallery
    } catch (e) {
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Failed to get a picture: $e',
      );
    }
  }

  void update() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();
    MyDialog.circularProgressStart(state.context);

    try {
      Map<String, dynamic> updateInfo = {};

      if (photo != null) {
        Map photoInfo = await CloudStorageController.uploadPhotoFile(
          imageFolder: Constant.PHOTO_IMAGES_FOLDER,
          photo: photo!,
          uid: state.widget.user.uid,
          filename: tempMemo.photoFilename,
          listner: (int progress) {
            state.render(() {
              state.progressMessage =
                  progress == 100 ? null : 'Uploading: $progress %';
            });
            print('======= uploading: $progress');
          },
        );

        // generate image labels by ML

        List<String> imageLabels =
            await GoogleMLController.getImageLabels(photo: photo!);
        String imageText = await GoogleMLController.getImageText(photo: photo!);
        List<String> imageTextBlocks =
            await GoogleMLController.getImageTextBlocks(photo: photo!);

        tempMemo.imageLabels = imageLabels;
        tempMemo.imagetextblocks = imageTextBlocks;
        tempMemo.imagetext = imageText;

        tempMemo.photoURL = photoInfo[ARGS.DownloadURL];
        updateInfo[PhotoMemo.PHOTO_URL] = tempMemo.photoURL;
      }

      if (tempMemo.title != state.widget.photoMemo.title) {
        updateInfo[PhotoMemo.TITLE] = tempMemo.title;
        updateInfo.update(PhotoMemo.TITLE, (value) => value = tempMemo.title);
      }

      if (tempMemo.memo != state.widget.photoMemo.memo) {
        updateInfo[PhotoMemo.MEMO] = tempMemo.memo;
        updateInfo.update(PhotoMemo.MEMO, (value) => value = tempMemo.memo);
      }

      if (!listEquals(tempMemo.sharedWith, state.widget.photoMemo.sharedWith)) {
        updateInfo[PhotoMemo.SHARED_WITH] = tempMemo.sharedWith;
        updateInfo.update(
            PhotoMemo.SHARED_WITH, (value) => value = tempMemo.sharedWith);
      }

      if (updateInfo.isNotEmpty) {
        tempMemo.timestamp = DateTime.now();
        updateInfo[PhotoMemo.TIMESTAMP] = tempMemo.timestamp;
        updateInfo.update(
            PhotoMemo.TIMESTAMP, (value) => value = tempMemo.timestamp);

        await FirestoreController.updatePhotoMemo(
          docId: tempMemo.docId!,
          updateInfo: tempMemo.toFirestoreDoc(),
        );
        state.widget.photoMemo.assign(tempMemo);
      }

      MyDialog.circularProgressStop(state.context);
      state.render(() => state.editMode = false);
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      if (Constant.DEV) print('----update photomemo error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Update PhotoMemo error: $e',
      );
    }
  }

  void edit() {
    state.render(() => state.editMode = true);
  }

  void saveTitle(String? value) {
    if (value != null) tempMemo.title = value;
  }

  void saveMemo(String? value) {
    if (value != null) tempMemo.memo = value;
  }

  void saveComment(String? value) {
    if (value != null) comment.message = value;
  }

  Stream<QuerySnapshot> getComments(String memoId) {
    return FirestoreController.getComments(memoId);
  }

  void addComment() async {
    FormState? currentState = state.commentFormKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();
    MyDialog.circularProgressStart(state.context);

    comment.createdby = state.widget.user.email!;
    comment.timestamp = DateTime.now();

    FirestoreController.addComment(state.widget.photoMemo.docId!, comment)
        .then((success) {
      if (success) {
        state.render(() {
          state.commentController.clear();
        });
        MyDialog.circularProgressStop(state.context);
      }
    });
  }

  Stream<QuerySnapshot> getUserRatings() {
    return FirestoreController.getUserRatings(state.widget.photoMemo.docId!);
  }

  Stream<DocumentSnapshot> getPhotoRating() {
    return FirestoreController.getPhotoRating(state.widget.photoMemo.docId!);
  }

  Future<bool> addUserRating(
    double value,
    int ratingsCount,
    Rating previousRating,
    bool isUserUpdating,
  ) async {
    Rating newRating = Rating(
      value: value,
      createdby: state.widget.user.email!,
      timestamp: DateTime.now(),
    );

    return await FirestoreController.addUserRating(
      state.widget.user.uid,
      state.widget.photoMemo,
      newRating,
      previousRating,
      ratingsCount,
      isUserUpdating: isUserUpdating,
    ).then((result) async {
      double value = 0;

      if (isUserUpdating) {
        value = (((state.widget.photoMemo.rating * ratingsCount) -
                    previousRating.value) +
                newRating.value) /
            ratingsCount;
      } else {
        value = ((state.widget.photoMemo.rating + newRating.value) /
            (ratingsCount + 1));
      }

      state.render(() {
        state.widget.photoMemo.rating = value;
      });

      return await FirestoreController.updatePhotoRating(
          state.widget.photoMemo.docId!, value);
    });
  }

  void resetCommentCount() async {
    if (state.widget.user.email == state.widget.photoMemo.createdBy) {
      await FirestoreController.updatePhotoMemo(
        docId: state.widget.photoMemo.docId!,
        updateInfo: {"newcount": 0},
      );
    }
  }
}
