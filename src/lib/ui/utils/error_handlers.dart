import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openeatsjournal/global_navigator_key.dart';

class ErrorHandlers {
  static Future<void> showException({required Object error, StackTrace? stackTrace}) async {
    final BuildContext context = navigatorKey.currentContext!;

    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contextBuilder) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 15),
                Icon(Icons.warning, size: 100, color: Colors.amber),
                SizedBox(height: 10),
                Text(
                  "Unexpected error Encountered",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "$error\n${stackTrace.toString()}",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                exit(1);
              },
            ),
          ],
        );
      },
    );
  }

  static Widget errorWidget(FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        child: Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 15),
                Icon(Icons.warning, size: 100, color: Colors.amber),
                SizedBox(height: 10),
                Text(
                  "Unexpected error Encountered",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "${details.exception.toString()}\n${details.stack != null ? details.stack.toString() : ""}",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,0,0,30),
                  child: TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      exit(1);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
