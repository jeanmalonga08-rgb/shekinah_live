import 'dart:io';

import 'package:video_player/video_player.dart';

VideoPlayerController createCommuniqueVideoController(String source, bool isLocal) =>
    isLocal
        ? VideoPlayerController.file(File(source))
        : VideoPlayerController.networkUrl(Uri.parse(source));
