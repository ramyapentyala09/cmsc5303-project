import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/utils/theme_constants.dart';
import 'package:lesson3/viewscreen/signin_screen.dart';
import 'package:lesson3/viewscreen/view/mydailog.dart';

class DeleteAccountScreen extends StatefulWidget {
  static const routeName = '/deleteProfileScreen';

  final User user;

  const DeleteAccountScreen({Key? key, required this.user}) : super(key: key);

  @override
  _DeleteAccountScreenState createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  late _Controller con;
  GlobalKey<FormState> deleteFormKey = GlobalKey<FormState>();

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
        title: Text("Delete Account"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Form(
                key: deleteFormKey,
                child: Column(
                  children: [
                    SizedBox(height: 30.0),
                    TextFormField(
                      decoration: textFormFieldDecoration(
                        context,
                      ).copyWith(
                        hintText: 'Enter Current Password',
                        labelText: 'Current password',
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      autocorrect: false,
                      obscureText: true,
                      validator: con.validatePassword,
                      onSaved: con.saveCurrentPassword,
                    ),
                    SizedBox(height: 30.0),
                    ElevatedButton(
                      onPressed: con.deleteAccount,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                      ),
                      child: Text(
                        'Delete Account',
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                    SizedBox(height: 50.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  late _DeleteAccountScreenState state;
  String? currentPassword;
  String? newPassword;
  String? passwordConfirm;

  _Controller(this.state);

  String? validatePassword(String? value) {
    if (value == null || value.length < 6)
      return 'Password too short';
    else
      return null;
  }

  void saveCurrentPassword(String? value) {
    currentPassword = value;
  }

  void saveConfirmPassword(String? value) {
    passwordConfirm = value;
  }

  void deleteAccount() async {
    FormState? currentState = state.deleteFormKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();

    MyDialog.circularProgressStart(state.context);

    final user = state.widget.user;
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword!,
    );

    await FirestoreController.deleteUser(user: user).then((success) {
      if (success) {
        user.reauthenticateWithCredential(cred).then((value) {
          user.delete().then((_) {
            MyDialog.circularProgressStop(state.context);

            if (success) {
              MyDialog.showSnackBar(
                context: state.context,
                message: 'Account deleted successfully',
                seconds: 15,
              );
              Navigator.pushNamedAndRemoveUntil(
                state.context,
                SignInScreen.routeName,
                (route) => false,
              );
            }
          }).catchError((error) {
            if (Constant.DEV) print('---password change error: $e');
            MyDialog.showSnackBar(
              context: state.context,
              message: 'Cannot update password: $e',
            );
          });
        });
      }
    });
  }
}
