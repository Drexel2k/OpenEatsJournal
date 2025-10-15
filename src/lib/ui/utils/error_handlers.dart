import 'package:flutter/material.dart';
import 'package:openeatsjournal/domain/utils/open_eats_journal_strings.dart';

class ErrorHandlers {
  static Future<bool?> showException({
    required BuildContext context,
    required StackTrace stackTrace,
    Exception? exception,
    Error? error
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext contextBuilder) {
        return AlertDialog(
          content: Column(
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
                  "${exception != null ? exception.toString(): ""}${error != null ? error.toString(): ""}\n${stackTrace.toString()}",
                  style: TextStyle(fontSize: 12, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () async {
                Navigator.pop(contextBuilder, true);
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
                    "${details.exception.toString()}\n${details.stack != null ? details.stack.toString() : OpenEatsJournalStrings.emptyString}",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                    textAlign: TextAlign.center,
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
