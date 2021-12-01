import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/theme_constants.dart';
import 'package:lesson3/viewscreen/signin_screen.dart';
import 'package:lesson3/viewscreen/view/mydailog.dart';

class UpdatePasswordScreen extends StatefulWidget {
  static const routeName = '/editProfileScreen';

  final User user;

  const UpdatePasswordScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UpdatePasswordScreenState createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  late _Controller con;
  GlobalKey<FormState> updateFormKey = GlobalKey<FormState>();

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
        title: Text("Update Password"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Form(
                key: updateFormKey,
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
                    SizedBox(height: 15.0),
                    TextFormField(
                      decoration: textFormFieldDecoration(
                        context,
                      ).copyWith(
                        hintText: 'Enter New Password',
                        labelText: 'New password',
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      autocorrect: false,
                      obscureText: true,
                      validator: con.validatePassword,
                      onSaved: con.saveNewPassword,
                    ),
                    SizedBox(height: 15.0),
                    TextFormField(
                      decoration: textFormFieldDecoration(
                        context,
                      ).copyWith(
                        hintText: 'Confirm Current Password',
                        labelText: 'Retype new password',
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      autocorrect: false,
                      obscureText: true,
                      validator: con.validatePassword,
                      onSaved: con.saveConfirmPassword,
                    ),
                    SizedBox(height: 30.0),
                    ElevatedButton(
                      onPressed: con.updateNewPassword,
                      child: Text(
                        'Update Password',
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
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
  late _UpdatePasswordScreenState state;
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

  void saveNewPassword(String? value) {
    newPassword = value;
  }

  void saveConfirmPassword(String? value) {
    passwordConfirm = value;
  }

  void updateNewPassword() {
    FormState? currentState = state.updateFormKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();

    MyDialog.circularProgressStart(state.context);

    if (newPassword != passwordConfirm) {
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Passwords do not match',
        seconds: 15,
      );
      return;
    }

    final user = state.widget.user;
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword!,
    );

    user.reauthenticateWithCredential(cred).then((value) {
      user.updatePassword(newPassword!).then((_) {
        MyDialog.circularProgressStop(state.context);

        MyDialog.showSnackBar(
          context: state.context,
          message: 'Password updated successfully. Please login again',
          seconds: 15,
        );
        Navigator.pushNamedAndRemoveUntil(
          state.context,
          SignInScreen.routeName,
          (route) => false,
        );
      }).catchError((error) {
        MyDialog.circularProgressStop(state.context);
        if (Constant.DEV) print('---password change error: $e');
        MyDialog.showSnackBar(
          context: state.context,
          message: 'Cannot update password: $e',
        );
      });
    }).catchError((err) {
      MyDialog.circularProgressStop(state.context);
      if (Constant.DEV) print('---password change error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Cannot update password: $e',
      );
    });
  }
}
