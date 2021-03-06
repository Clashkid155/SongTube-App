// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:newpipeextractor_dart/models/streams/audioOnlyStream.dart';
import 'package:newpipeextractor_dart/models/streams/videoOnlyStream.dart';
import 'package:newpipeextractor_dart/utils/httpClient.dart';
import 'package:songtube/internal/languages.dart';

class VideoDownloadMenu extends StatefulWidget {
  final List<VideoOnlyStream> videoList;
  final AudioOnlyStream audioStream;
  final Function(List<dynamic>) onOptionSelect;
  final Function onBack;
  VideoDownloadMenu({
    @required this.videoList,
    @required this.onOptionSelect,
    @required this.audioStream,
    @required this.onBack
  });

  @override
  _VideoDownloadMenuState createState() => _VideoDownloadMenuState();
}

class _VideoDownloadMenuState extends State<VideoDownloadMenu> {

  void _onOptionSelect(VideoOnlyStream video) {
    List<dynamic> list = [
      "Video",
      video,
      "1.0", "0", "0", false
    ];
    widget.onOptionSelect(list);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Menu Title
        Container(
          margin: EdgeInsets.only(
            top: 8,
            left: 8,
            right: 8
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(EvaIcons.arrowBackOutline),
                onPressed: widget.onBack
              ),
              SizedBox(width: 4),
              Text(Languages.of(context).labelSelectVideo, style: TextStyle(
                fontSize: 20,
                fontFamily: "YTSans"
              )),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: ExtractorHttpClient.getContentLength(widget.audioStream.url),
            builder: (context, audioStreamData) {
              return GroupedListView<VideoOnlyStream, String>(
                stickyHeaderBackgroundColor: Theme.of(context)
                  .scaffoldBackgroundColor,
                
                elements: widget.videoList,
                groupBy: (element) =>
                  (element.resolution.split("p").first+"p"),
                groupSeparatorBuilder: (String groupByValue) =>
                  Container(
                    padding: EdgeInsets.only(
                      top: 8, bottom: 8,
                      left: 16, right: 16
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 16,
                          color: Colors.black.withOpacity(0.06),
                          offset: Offset(0,12)
                        )
                      ]
                    ),
                    child: Row(
                      children: [
                        Icon(EvaIcons.monitorOutline,
                          color: Theme.of(context).accentColor),
                        SizedBox(width: 8),
                        Text(
                          groupByValue,
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'YTSans',
                          ),
                        ),
                      ],
                    ),
                  ),
                useStickyGroupSeparators: true,
                order: GroupedListOrder.DESC,
                groupComparator: (item1, item2) =>
                  int.parse(item1.split("p").first)
                  .compareTo(int.parse(item2.split("p").first)),
                itemBuilder: (context, VideoOnlyStream element) {
                  String framerateString = element.resolution.split("p").last;
                  int framerate = int.parse(
                    framerateString == "" ? "30" : framerateString
                  );
                  return GestureDetector(
                    onTap: () {
                      _onOptionSelect(element);
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        left: 12,
                        right: 12
                      ),
                      height: 100,
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          SizedBox(width: 24),
                          Icon(EvaIcons.videoOutline, size: 36),
                          SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${element.formatSuffix.toUpperCase()}",
                                  overflow: TextOverflow.fade,
                                  textAlign: TextAlign.left,
                                  softWrap: false,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16
                                  ),
                                ),
                                FutureBuilder(
                                  future: ExtractorHttpClient.getContentLength(element.url),
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.hasData && audioStreamData.hasData
                                        ? "${((snapshot.data/1024)/1024 + (audioStreamData.data/1024)/1024).toStringAsFixed(2)} MB"
                                        : "Loading...",
                                      overflow: TextOverflow.fade,
                                      textAlign: TextAlign.left,
                                      softWrap: false,
                                      style: TextStyle(
                                        fontSize: 12
                                      ),
                                    );
                                  }
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: framerate > 50
                            ? Text(
                                "$framerate FPS",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'YTSans',
                                ),
                              ) : Container(),
                          )
                        ],
                      )
                    ),
                  );
                }
              );
            }
          ),
        ),
      ],
    );
  }
}