import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InternalErrorScreen extends StatelessWidget {
  static const routeName = '/internalErrorScreen';
  late final String message;

  InternalErrorScreen(this.message);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Internal Error'),
      ),
      body: Text(
        'Internal error has occoured\n Re-Launch the app.\n $message',
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.red,
        ),
      ),
    );
  }
}