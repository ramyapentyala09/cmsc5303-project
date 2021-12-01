import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lesson3/controller/firebaseauth_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

import 'mydailog.dart';

class MemoItem extends StatefulWidget {
  final PhotoMemo photoMemo;
  final bool showOwner;
  final Color? color;
  final bool? showFavIcon;
  final bool isShared;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSave;
  final VoidCallback? onRate;

  const MemoItem({
    Key? key,
    required this.photoMemo,
    this.showOwner = false,
    this.color,
    this.showFavIcon = false,
    this.isShared = false,
    this.onTap,
    this.onLongPress,
    this.onSave,
    this.onRate,
  }) : super(key: key);

  @override
  State<MemoItem> createState() => _MemoItemState();
}

class _MemoItemState extends State<MemoItem> {
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    checkSaved();
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => showNewCommentSnackBar());
  }

  User? currentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  void showNewCommentSnackBar() {
    if (currentUser()!.email == widget.photoMemo.createdBy &&
        widget.photoMemo.newcount > 0) {
      MyDialog.showSnackBar(
        context: this.context,
        message: 'You have new comments on memo, ${widget.photoMemo.title}',
      );
    }
  }

  void checkSaved() async {
    bool result = await FirestoreController.checkSaved(
        FirebaseAuthController.currentUserId()!, widget.photoMemo.docId!);
    setState(() {
      isSaved = result;
    });
  }

  void addSaved() async {
    bool result = await FirestoreController.addUserSaved(
        FirebaseAuthController.currentUserId()!, widget.photoMemo);
    setState(() {
      isSaved = result;
    });
  }

  void removeSaved() async {
    bool result = await FirestoreController.removeUserSaved(
        FirebaseAuthController.currentUserId()!, widget.photoMemo.docId!);
    setState(() {
      isSaved = !result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Container(
        padding: EdgeInsets.all(15.0),
        margin: EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          color: widget.color == null
              ? Theme.of(context).colorScheme.background.withOpacity(0.25)
              : widget.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.isShared
                ? Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(widget.photoMemo.photoURL),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.photoMemo.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  widget.photoMemo.memo,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      WebImage(
                        url: widget.photoMemo.photoURL,
                        context: context,
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.photoMemo.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              widget.photoMemo.memo,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            Divider(),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 18.0,
                ),
                SizedBox(width: 5.0),
                Text(
                  widget.photoMemo.createdBy,
                  style: TextStyle(
                    fontSize: 13.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            Divider(),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 18.0,
                ),
                SizedBox(width: 5.0),
                Flexible(
                  child: widget.photoMemo.sharedWith.length > 0
                      ? Text(
                          '${widget.photoMemo.sharedWith}',
                        )
                      : Text(
                          'None',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                ),
              ],
            ),
            SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${DateFormat.yMd().add_jm().format(widget.photoMemo.timestamp!)}',
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: widget.onRate,
                      child: Row(
                        children: [
                          Text(
                            widget.photoMemo.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Icon(Icons.star, color: Colors.amber),
                          SizedBox(width: 12.0),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        Icon(Icons.comment, size: 20.0),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: (currentUser()!.email ==
                                      widget.photoMemo.createdBy &&
                                  widget.photoMemo.newcount > 0)
                              ? CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 8.0,
                                  child: Text(
                                    "${widget.photoMemo.newcount}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.0,
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        )
                      ],
                    ),
                    SizedBox(width: 5.0),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      iconSize: 20.0,
                      splashRadius: 24.0,
                      onPressed: isSaved ? removeSaved : addSaved,
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_add_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
