import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lesson3/controller/firebaseauth_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/utils/push_notifications.dart';
import 'package:lesson3/utils/theme_constants.dart';
import 'package:lesson3/viewscreen/signup_screen.dart';
import 'package:lesson3/viewscreen/userhome_Screen.dart';
import 'package:lesson3/viewscreen/view/mydailog.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = '/signInScreen';

  @override
  State<StatefulWidget> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignInScreen> {
  late _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: Column(
              children: [
                Text(
                  'Photo Memo',
                  style: TextStyle(
                    fontFamily: 'RockSalt',
                    fontSize: 40.0,
                  ),
                ),
                Text(
                  'Sign In Please',
                  style: TextStyle(fontFamily: 'RockSalt', fontSize: 24.0),
                ),
                SizedBox(height: 30.0),
                TextFormField(
                  decoration: textFormFieldDecoration(
                    context,
                  ).copyWith(
                    hintText: 'Enter Email Address',
                    labelText: 'Email Address',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: con.validateEmail,
                  onSaved: con.saveEmail,
                ),
                SizedBox(height: 15.0),
                TextFormField(
                  decoration: textFormFieldDecoration(
                    context,
                  ).copyWith(
                    hintText: 'Enter Password',
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  autocorrect: false,
                  validator: con.validatePassword,
                  onSaved: con.savePassword,
                ),
                SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: con.signIn,
                  child: Text(
                    'Sign In',
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                    onPressed: con.signup,
                    child: Text(
                      'Create a new account',
                      style: Theme.of(context).textTheme.button,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  late _SignInState state;
  _Controller(this.state);
  String? email;
  String? password;

void signup(){
  Navigator.pushNamed(state.context, SignUpScreen.routName);
}

  String? validateEmail(String? value) {
    if (value == null || !(value.contains('.') && value.contains('@')))
      return 'Invalid Email address';
    else
      return null;
  }

  void saveEmail(String? value) {
    if (value != null) email = value;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6)
      return 'Invalid Password';
    else
      return null;
  }

  void savePassword(String? value) {
    if (value != null) password = value;
  }

  void signIn() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;

    currentState.save();

    User? user;
    MyDialog.circularProgressStart(state.context);
    try {
      if (email == null || password == null) {
        throw 'Email or passowrd is null';
      }
      user = await FirebaseAuthController.signIn(
          email: email!, password: password!);
      PushNotificationsManager().init(state.context);
      print('${user?.email}');

      // List<PhotoMemo> photoMemoList =
      //     await FirestoreController.getPhotoMemoList(email: email!);
      MyDialog.circularProgressStop(state.context);
      Navigator.pushReplacementNamed(
        state.context,
        UserHomeScreen.routeName,
        arguments: {
          ARGS.USER: user,
        },
      );
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      if (Constant.DEV) print('----Signin error: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Sign In Error: $e',
        seconds: 30,
      );
    }
  }
}