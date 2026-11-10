import 'package:video_player/video_player.dart';

VideoPlayerController createCommuniqueVideoController(String source, bool isLocal) =>
    VideoPlayerController.networkUrl(Uri.parse(source));
