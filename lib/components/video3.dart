import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerPage1 extends StatefulWidget {
  const VideoPlayerPage1({Key? key}) : super(key: key);

  @override
  VideoPlayerPage1State createState() => VideoPlayerPage1State();
}

class VideoPlayerPage1State extends State<VideoPlayerPage1> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  late List<Map<String, dynamic>> _urls;
  late bool _loading;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loading = true;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _chewieController.dispose();
  }

  Future<void> _initializePlayer() async {
    int initalindex = _currentIndex;
    final url = _urls[initalindex]['url'];
    if (url == null) {
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: VideoPlayerController.network(''),
          autoPlay: false,
          showControls: false,
          errorBuilder: (context, errorMessage) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      });
      setState(() {
        _loading = true;
      });
    }

    _controller = VideoPlayerController.network(url);
    _controller.addListener(() {
      if (!_controller.value.isInitialized) {
        setState(() {
          _loading = true;
        });
      }
    });

    await _controller.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      showControls: false,
      errorBuilder: (context, errorMessage) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        _playNextVideo();
      }
    });

    _controller.play();

    setState(() {
      _loading = false;
    });
  }

  _playNextVideo() async {
    bool isControllerInitialized = true;
    int nextIndex = _currentIndex + 1;
    if (nextIndex >= _urls.length) {
      _controller.dispose();
      nextIndex = 0;
    }
    final url = _urls[nextIndex]['url'];
    if (url == null) {
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: VideoPlayerController.network(''),
          autoPlay: false,
          showControls: false,
          errorBuilder: (context, errorMessage) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      });
      return;
    }

    _controller = VideoPlayerController.network(url);
    _controller.pause();

    if (isControllerInitialized) {
      await _controller.initialize();
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _controller,
          autoPlay: true,
          showControls: false,
          errorBuilder: (context, errorMessage) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
        isControllerInitialized = false;
      });
      _currentIndex = nextIndex;
      _controller.removeListener;
      _controller.addListener(() {
        if (_controller.value.position == _controller.value.duration) {
          _playAll();
        }
      });
      return const CircularProgressIndicator();
    }
  }

  void _playAll() {
    _controller.removeListener;
    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        _playNextVideo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final aspectRatio = size.width / size.height;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('Rongai').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.requireData.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text('No videos found'),
            );
          }

          _urls = docs
              .map((doc) => {
                    'id': doc.id,
                    'url': doc.data()['Url'].toString(),
                  })
              .toList();

          if (_loading) {
            _initializePlayer();
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return AspectRatio(
            aspectRatio: aspectRatio,
            child: Chewie(
              controller: _chewieController,
            ),
          );
        },
      ),
    );
  }
}
