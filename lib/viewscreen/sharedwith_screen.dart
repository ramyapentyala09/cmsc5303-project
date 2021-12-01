import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lesson3/viewscreen/view/memo_item.dart';
import 'detailedview_screen.dart';

class SharedWithScreen extends StatefulWidget {
  static const routeName = '/sharedWithScreen';

  final User user;

  SharedWithScreen({required this.user});

  @override
  State<StatefulWidget> createState() {
    return _SharedWithState();
  }
}

class _SharedWithState extends State<SharedWithScreen> {
  late _Controller con;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Shared With ${widget.user.email}'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: StreamBuilder<QuerySnapshot>(
                stream: con.getPhotoMemoListSharedWith(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    var docs = snapshot.data!.docs;
                    if (docs.length > 0) {
                      return Column(
                        children: List.generate(docs.length, (index) {
                          PhotoMemo? photoMemo = PhotoMemo.fromFirestoreDoc(
                            doc: docs[index].data() as Map<String, dynamic>,
                            docId: snapshot.data!.docs[index].id,
                          );

                          return MemoItem(
                            photoMemo: photoMemo!,
                            showOwner: true,
                            isShared: true,
                            onTap: () {
                              con.onTap(photoMemo);
                            },
                          );
                        }),
                      );
                    } else {
                      return Center(child: Text("No PhotoMemos found"));
                    }
                  }

                  return Center(child: CircularProgressIndicator());
                }),
          ),
        ));
  }
}

class _Controller {
  late _SharedWithState state;

  _Controller(this.state);

  Stream<QuerySnapshot> getPhotoMemoListSharedWith() {
    return FirestoreController.getPhotoMemoListSharedWith(
      email: state.widget.user.email!,
    );
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