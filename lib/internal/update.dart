import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:songtube/internal/models/updateDetails.dart';
import 'package:songtube/internal/updateChecker.dart';

double _percent = 0.0;

void download({String path, void Function(int, int) progress}) async {
  final Dio client = Dio();
  final url = (await getLatestRelease()).link;
  final String filename = join(path, url.split("/").last);
  try {
    if (await Permission.storage.isGranted) {
      client.download(
        url,
        filename,
        onReceiveProgress: progress,
        deleteOnError: true,
      );
    }
  } catch (e) {}
}

/* void onClickInstallApk(String apk, package) async {
  if (await Permission.storage.isGranted) {
    InstallPlugin.installApk(apk, package).then((result) {
      print('install apk $result');
    }).catchError((error) {
      print('install apk error: $error');
    });
  } else {
    print('Permission request fail!');
  }
}   */

class AppUpdate extends StatefulWidget {
  final String path;
  AppUpdate({Key key, this.path}) : super(key: key);

  @override
  _AppUpdateState createState() => _AppUpdateState();
}

class _AppUpdateState extends State<AppUpdate> {
  void showDownloadProgress(received, total) {
    if (total != -1) {
      print("$received and $total");
      setState(() {
        _percent = double.tryParse((received / total * 100).toStringAsFixed(0));
      });

      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  @override
  void initState() {
    super.initState();
    //WidgetsBinding.instance.addObserver(this);
    download(path: widget.path, progress: showDownloadProgress);
  }

  @override
  void dispose() {
    super.dispose();
    _percent = 0.0; // Change back to
    //WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        "Downloading",
        style: TextStyle(
            color: Theme.of(context).accentColor,
            fontFamily: "YTSans",
            fontSize: 20),
      ),
      content: Container(
        padding: EdgeInsets.all(8.0),
        height: 40,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "${_percent.round()}%",
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'YTSans', fontSize: 16),
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                backgroundColor: Theme.of(context).cardColor,
                value: _percent / 100,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
