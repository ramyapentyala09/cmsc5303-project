import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firebaseauth_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/appuser.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/addnewphotomemo_screen.dart';
import 'package:lesson3/model/constant.dart';

import 'package:lesson3/viewscreen/detailedview_screen.dart';
import 'package:lesson3/viewscreen/profile_screen.dart';
import 'package:lesson3/viewscreen/sharedwith_screen.dart';
import 'package:lesson3/viewscreen/signin_screen.dart';
import 'package:lesson3/viewscreen/view/memo_item.dart';
import 'package:lesson3/viewscreen/view/mydailog.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/userHomeScreen';

  late final User user;
  late final String displayName;
  late final String email;

  UserHomeScreen({required this.user}) {
    displayName = user.displayName ?? 'N/A';
    email = user.email ?? 'No Email';
  }

  @override
  State<StatefulWidget> createState() {
    return _UserHomeState();
  }
}

class _UserHomeState extends State<UserHomeScreen> {
  late _Controller con;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          actions: [
            con.delIndexes.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextFormField(
                        controller: con.searchController,
                        decoration: InputDecoration(
                          hintText: 'Search (empty for all)',
                          fillColor: Theme.of(context).backgroundColor,
                          filled: true,
                        ),
                        autocorrect: true,
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: con.cancelDelete, icon: Icon(Icons.cancel)),
            con.delIndexes.isEmpty
                ? IconButton(
                    onPressed: con.saveSearchKey, icon: Icon(Icons.search))
                : IconButton(onPressed: con.delete, icon: Icon(Icons.delete)),
          ],
        ),
        drawer: Drawer(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  StreamBuilder<DocumentSnapshot>(
                      stream: FirestoreController.getCurrentUser(),
                      builder:
                          (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.exists) {
                            AppUser? appUser = AppUser.fromFirestoreDoc(
                              doc:
                                  snapshot.data!.data() as Map<String, dynamic>,
                              docId: snapshot.data!.id,
                            );

                            return UserAccountsDrawerHeader(
                              accountName: Text(""),
                              accountEmail: Text(widget.email),
                              currentAccountPicture: CircleAvatar(
                                backgroundImage: (appUser!.avatarURL != '')
                                    ? NetworkImage(
                                        appUser.avatarURL.toString(),
                                      )
                                    : AssetImage(
                                        'assets/images/default-profile.png',
                                      ) as ImageProvider,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).backgroundColor,
                              ),
                            );
                          }
                        }

                        return UserAccountsDrawerHeader(
                          accountName: Text(widget.displayName),
                          accountEmail: Text(widget.email),
                          decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                          ),
                        );
                      }),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile'),
                    onTap: con.profile,
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.people),
                    title: Text('Shared With'),
                    onTap: con.sharedwith,
                  ),
                  Divider(),
                ],
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Sign Out'),
                onTap: con.signOut,
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.add, color: Colors.white),
          onPressed: con.addButton,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: StreamBuilder<QuerySnapshot>(
                stream: con.searchKeyString == null || con.searchKeyString == ""
                    ? FirestoreController.getPhotoMemoList(
                        email: widget.user.email!,
                      )
                    : con.search(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.length > 0) {
                      con.photoMemoList.clear();
                      snapshot.data!.docs.forEach((element) {
                        PhotoMemo? photoMemo = PhotoMemo.fromFirestoreDoc(
                          doc: element.data() as Map<String, dynamic>,
                          docId: element.id,
                        );
                        con.photoMemoList.add(photoMemo!);
                      });

                      return Column(
                        children: List.generate(
                          con.photoMemoList.length,
                          (index) {
                            return MemoItem(
                              photoMemo: con.photoMemoList[index],
                              color: con.delIndexes.contains(index)
                                  ? Theme.of(context).highlightColor
                                  : Theme.of(context)
                                      .colorScheme
                                      .background
                                      .withOpacity(0.25),
                              onTap: () => con.onTap(index),
                              onLongPress: () => con.onLongPress(index),
                              onRate: () {},
                              onSave: () {},
                            );
                          },
                        ),
                      );
                    } else {
                      return Center(child: Text("No PhotoMemos found"));
                    }
                  }

                  return Center(child: CircularProgressIndicator());
                }),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  late _UserHomeState state;
  late List<PhotoMemo> photoMemoList;
  String? searchKeyString;
  List<int> delIndexes = [];

  TextEditingController searchController = TextEditingController();

  _Controller(this.state) {
    photoMemoList = [];
  }

  void profile() async {
    try {
      await Navigator.pushNamed(state.context, ProfileScreen.routeName,
          arguments: {
            ARGS.USER: state.widget.user,
          });
      Navigator.of(state.context).pop(); // close the drawer
    } catch (e) {
      if (Constant.DEV) print('---shared with error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Failed to get sharedwith list: $e',
      );
    }
  }

  void sharedwith() async {
    try {
      await Navigator.pushNamed(state.context, SharedWithScreen.routeName,
          arguments: {
            ARGS.USER: state.widget.user,
          });
      Navigator.of(state.context).pop(); // close the drawer
    } catch (e) {
      if (Constant.DEV) print('---shared with error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Failed to get sharedwith list: $e',
      );
    }
  }

  void cancelDelete() {
    state.render(() {
      delIndexes.clear();
    });
  }

  void delete() async {
    MyDialog.circularProgressStart(state.context);
    delIndexes.sort(); //ascending order
    for (int i = delIndexes.length - 1; i >= 0; i--) {
      try {
        PhotoMemo p = photoMemoList[delIndexes[i]];
        await FirestoreController.deletePhotoMemo(photoMemo: p);
        await CloudStorageController.deletePhotoFile(photoMemo: p);
        state.render(() {
          photoMemoList.removeAt(delIndexes[i]);
        });
      } catch (e) {
        if (Constant.DEV) print('---failed to delete user memo');
        MyDialog.showSnackBar(
          context: state.context,
          message: 'Failed to delete Photomemo: $e',
        );
        break; //quit further processing

      }
    }
    MyDialog.circularProgressStop(state.context);
    state.render(() => delIndexes.clear());
  }

  void onLongPress(int index) {
    state.render(() {
      if (delIndexes.contains(index))
        delIndexes.remove(index);
      else
        delIndexes.add(index);
    });
  }

  void saveSearchKey() {
    state.render(() => searchKeyString = searchController.text);
  }

  Stream<QuerySnapshot>? search() {
    List<String> keys = [];
    if (searchKeyString != null) {
      var tokens = searchKeyString!.split(RegExp('(,| )+')).toList();
      for (var t in tokens) {
        if (t.trim().isNotEmpty) keys.add(t.trim().trimLeft().toLowerCase());
      }
    }

    return FirestoreController.searchImage(
      createdBy: state.widget.email,
      searchLabels: keys,
    );
  }

  void onTap(int index) async {
    if (delIndexes.isNotEmpty) {
      onLongPress(index);
      return;
    }
    // var state;
    await Navigator.pushNamed(state.context, DetailedViewScreen.routeName,
        arguments: {
          ARGS.USER: state.widget.user,
          ARGS.OnePhotoMemo: photoMemoList[index],
        });
//rerender home screen
    state.render(() {
      //reorder based on updated timestamps
      photoMemoList.sort((a, b) {
        if (a.timestamp!.isBefore(b.timestamp!))
          return 1; //desending order
        else if (a.timestamp!.isAfter(b.timestamp!))
          return -1;
        else
          return 0;
      });
    });
  }

  void onSave() {}

  void addButton() async {
    await Navigator.pushNamed(state.context, AddNewPhotoMemoScreen.routeName,
        arguments: {
          ARGS.USER: state.widget.user,
          ARGS.PhotoMemoList: photoMemoList,
        });
    state.render(() {});
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuthController.signOut();
    } catch (e) {
      if (Constant.DEV) print('----sign Out Error: $e');
    }
    Navigator.of(state.context)
        .pushNamedAndRemoveUntil(SignInScreen.routeName, (route) => false);
  }
}
