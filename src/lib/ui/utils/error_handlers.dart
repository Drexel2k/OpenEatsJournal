import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:openeatsjournal/app_global.dart";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";

class ErrorHandlers {
  static Future<void> showException({required Object error, StackTrace? stackTrace}) async {
    Directory logDirectory = Directory(join((await getApplicationDocumentsDirectory()).path, "log"));
    logDirectory.createSync(recursive: true);
    File logFile = File(join(logDirectory.path, "error.log"));
    if (logFile.lengthSync() > 1048576) {
      logFile.deleteSync();
    }
    
    String stack = stackTrace != null ? stackTrace.toString() : "";
    logFile.writeAsString("${DateTime.now()} se ${error.toString()} $stack", mode: FileMode.append, flush: true);

    final BuildContext? context = AppGlobal.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      return showDialog(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext contextBuilder) {
          return AlertDialog(
            backgroundColor: Colors.white,
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
                onPressed: () async {
                  SystemChannels.platform.invokeMethod("SystemNavigator.pop");
                },
              ),
            ],
          );
        },
      );
    }
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
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: TextButton(
                    child: Text("OK"),
                    onPressed: () async {
                      SystemChannels.platform.invokeMethod("SystemNavigator.pop");
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
