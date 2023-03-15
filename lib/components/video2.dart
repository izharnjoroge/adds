import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({Key? key}) : super(key: key);

  @override
  VideoPlayerPageState createState() => VideoPlayerPageState();
}

class VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  Future<void>? _initializeVideoPlayerFuture;
  late List<String> _urls;
  late bool _loading;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loading = true;
    _initializePlayer();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> _initializePlayer() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Rongai').get();

    if (querySnapshot.docs.isNotEmpty) {}

    final List<String> urls =
        querySnapshot.docs.map((doc) => doc.data()['Url'].toString()).toList();

    setState(() {
      _urls = urls;
      _loading = false;
    });

    _controller = VideoPlayerController.network(_urls[_currentIndex]);
    _initializeVideoPlayerFuture = _controller.initialize();

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        _playNextVideo();
      }
    });

    _controller.play();
  }

  void _playNextVideo() {
    if (_currentIndex == _urls.length - 1) {
      _currentIndex = 0;
    } else {
      _currentIndex++;
    }

    setState(() {
      _controller = VideoPlayerController.network(_urls[_currentIndex]);
      _initializeVideoPlayerFuture = _controller.initialize();
    });

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        _playNextVideo();
      }
    });

    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    // if (_loading) {
    //   return const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            body: Chewie(
              controller: ChewieController(
                videoPlayerController: _controller,
                autoPlay: true,
                aspectRatio: 16 / 9,
                looping: true,
                showControls: false,
                errorBuilder: (context, errorMessage) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
