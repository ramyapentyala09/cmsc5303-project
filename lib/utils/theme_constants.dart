import 'package:flutter/material.dart';

InputDecoration textFormFieldDecoration(BuildContext context) =>
    InputDecoration(
      labelStyle: TextStyle(
        color: Theme
            .of(context)
            .backgroundColor,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: EdgeInsets.all(16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFF474747),
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
    );
