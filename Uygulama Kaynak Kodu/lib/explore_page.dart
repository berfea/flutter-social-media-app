import 'package:flutter/cupertino.dart';
import 'package:mirror/home_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExplorePage extends StatefulWidget {
  final String username;
  const ExplorePage({required this.username});

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<dynamic> videos = [];
  int currentIndex = 0;
  bool isLoading = false;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse("$SERVER_ADDRESS/explore/videos");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final data = json.decode(responseBody);

        setState(() {
          videos.addAll(data);
        });
      }
    } catch (e) {
      throw "Hata: $e";
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _likePost(String mediaPath) async {
    try {
      final url = Uri.parse("$SERVER_ADDRESS/like");
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": widget.username,
          "mediaPath": mediaPath,
        }),
      );

      setState(() {
        final post =
            videos.firstWhere((video) => video["mediaPath"] == mediaPath);
        if (post["likes"].contains(widget.username)) {
          post["likes"].remove(widget.username);
        } else {
          post["likes"].add(widget.username);
        }
      });
    } catch (e) {
      throw "Beğeni işlemi sırasında hata oluştu: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: (videos.isEmpty && !isLoading) ?
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.play_rectangle, size: 200, color: CupertinoColors.systemGrey,),
              SizedBox(height: 30),
              Text("İçerik yok.", style: TextStyle(fontSize: 48, color: CupertinoColors.systemGrey),),
              Text("Henüz paylaşım yapılmamış.", style: TextStyle(fontSize: 24, color: CupertinoColors.systemGrey),),
            ],
          )
        :
        PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
            if (index == videos.length - 1) {
              _fetchVideos();
            }
          });
        },
        itemCount: videos.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= videos.length) {
            return Center(child: CupertinoActivityIndicator());
          }

          final video = videos[index];
          final isLiked = video["likes"].contains(widget.username);

          return Stack(
            children: [
              GestureDetector(
                onDoubleTap: () => _likePost(video["mediaPath"]),
                child: VideoPlayerWidget(
                    videoUrl: "$SERVER_ADDRESS/file/${video['mediaPath']}"),
              ),
              Positioned(
                bottom: 90,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "@${video['username']}",
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          video["text"],
                          style: TextStyle(
                              color: CupertinoColors.white, fontSize: 20),
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () => _likePost(video["mediaPath"]),
                          child: Icon(
                            isLiked
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart,
                            color: isLiked
                                ? CupertinoColors.systemRed
                                : CupertinoColors.white,
                            size: 40,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "${video['likes'].length}",
                          style: TextStyle(
                              color: CupertinoColors.white, fontSize: 20),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? VideoPlayer(_controller)
        : Center(child: CupertinoActivityIndicator());
  }
}
