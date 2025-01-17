import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mirror/home_screen.dart';
import 'package:mirror/login_screen.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  const ProfilePage({required this.username});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String profilePhotoUrl = "default.jpg";
  int followersCount = 0;
  int followingCount = 0;
  int postsCount = 0;
  List<String> postMediaPaths = [];
  List<String> postMediaTypes = [];
  final TextEditingController _followController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final url = Uri.parse("$SERVER_ADDRESS/profile/${widget.username}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          profilePhotoUrl = data["profilePhoto"];
          followersCount = data["followers"].length;
          followingCount = data["following"].length;
          postMediaPaths =
              List<String>.from(data["posts"].map((post) => post["mediaPath"]))
                  .reversed
                  .toList();
          postMediaTypes =
              List<String>.from(data["posts"].map((post) => post["type"]))
                  .reversed
                  .toList();
          postsCount = postMediaPaths.length;
        });
      }
    } catch (e) {
      throw ("Hata: $e");
    }
  }

  Future<String> _generateThumbnailPath(String url) async {
    final tFilePath = await VideoThumbnail.thumbnailFile(
      video: url,
      imageFormat: ImageFormat.JPEG,
      quality: 100,
    );
    return tFilePath!;
  }

  Future<ImageProvider> _fetchImage(int index) async {
    if (postMediaTypes[index] == "image") {
      try {
        final url = Uri.parse("$SERVER_ADDRESS/file/${postMediaPaths[index]}");
        final response = await http.get(url);
        if (response.statusCode == 200) {
          return MemoryImage(response.bodyBytes);
        } else {
          throw Exception("Resim yüklenemedi.");
        }
      } catch (e) {
        throw Exception(e);
      }
    } else if (postMediaTypes[index] == "video") {
      final thumbfile = await _generateThumbnailPath(
          "$SERVER_ADDRESS/file/${postMediaPaths[index]}");
      return FileImage(File(thumbfile));
    } else {
      throw Exception("Undefined media type.");
    }
  }

  Future<void> _followUser(String targetUsername) async {
    if (targetUsername.isEmpty) {
      await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Hata!", style: TextStyle(fontSize: 20)),
          content: const Column(
            children: [
              SizedBox(height: 10),
              Icon(
                CupertinoIcons.exclamationmark_circle,
                color: CupertinoColors.systemRed,
                size: 100,
              ),
              SizedBox(height: 10),
              Text("Bir kullanıcı adı girmelisin.",
                  style: TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Tamam",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final url = Uri.parse("$SERVER_ADDRESS/follow");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "currentUser": widget.username,
          "targetUser": targetUsername,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          followingCount = data["followingCount"];
        });
        _followController.clear();
        await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Başarılı!", style: TextStyle(fontSize: 20)),
            content: Column(
              children: [
                SizedBox(height: 10),
                Icon(
                  CupertinoIcons.check_mark_circled,
                  color: CupertinoColors.activeGreen,
                  size: 100,
                ),
                SizedBox(height: 10),
                Text("$targetUsername artık takip ediliyor.",
                    style: TextStyle(fontSize: 16)),
              ],
            ),
            actions: [
              CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Tamam",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      } else {
        throw Exception("Takip işlemi başarısız.");
      }
    } catch (e) {
      await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Hata!", style: TextStyle(fontSize: 20)),
          content: const Column(
            children: [
              SizedBox(height: 10),
              Icon(
                CupertinoIcons.exclamationmark_circle,
                color: CupertinoColors.systemRed,
                size: 100,
              ),
              SizedBox(height: 10),
              Text("Kullanıcı bulunamadı.", style: TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Tamam",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
          child: Column(
            children: [
              SizedBox(height: 12),
              CupertinoTextField(
                controller: _followController,
                placeholder: 'Kimi takip etmek istersin?',
                placeholderStyle: const TextStyle(
                  color: CupertinoColors.systemGrey,
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: CupertinoColors.activeBlue,
                    width: 1.75,
                  ),
                ),
                suffix: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: CupertinoButton(
                    padding: EdgeInsets.all(0),
                    child: const Icon(
                      size: 30,
                      CupertinoIcons.plus_circle,
                      color: CupertinoColors.activeBlue,
                    ),
                    onPressed: () {
                      _followUser(_followController.text);
                    },
                  ),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  color: CupertinoColors.label,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      "assets/default.jpg",
                      width: 120,
                      height: 120,
                    ),
                  ),
                  SizedBox(width: 60),
                  Column(
                    children: [
                      Text(
                        widget.username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.activeBlue,
                          fontSize: 40,
                        ),
                      ),
                      Text(
                        "Paylaşım: $postsCount",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Takipçi: $followersCount",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Takip edilen: $followingCount",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  itemCount: postMediaPaths.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    return FutureBuilder<ImageProvider>(
                      future: _fetchImage(index),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image(
                                  image: snapshot.data!, fit: BoxFit.cover));
                        } else {
                          return Container(
                            color: CupertinoColors.systemGrey4,
                            child: Center(
                              child: CupertinoActivityIndicator(),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(100),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (context) =>
                            LoginScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Çıkış yap',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemBackground,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
