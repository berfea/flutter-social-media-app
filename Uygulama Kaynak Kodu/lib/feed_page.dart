import 'package:flutter/cupertino.dart';
import 'package:mirror/home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedPage extends StatefulWidget {
  final String username;

  const FeedPage({required this.username});

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _scrollController = ScrollController();
  final List<dynamic> _postsList = [];
  int _currentPage = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMore);
    _fetchData(_currentPage);
  }

  void _loadMore() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.7 &&
        !isLoading) {
      _currentPage += 5;
      _fetchData(_currentPage);
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
            _postsList.firstWhere((post) => post["mediaPath"] == mediaPath);
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

  Future<void> _fetchData(int pageKey) async {
    setState(() {
      isLoading = true;
    });
    try {
      final url = Uri.parse("$SERVER_ADDRESS/feed/images/$_currentPage");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final data = json.decode(responseBody);
        setState(() {
          _postsList.addAll(data);
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: (_postsList.isEmpty && !isLoading) ?
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.list_bullet_below_rectangle, size: 200, color: CupertinoColors.systemGrey,),
              SizedBox(height: 30),
              Text("İçerik yok.", style: TextStyle(fontSize: 48, color: CupertinoColors.systemGrey),),
              Text("Henüz paylaşım yapılmamış.", style: TextStyle(fontSize: 24, color: CupertinoColors.systemGrey),),
            ],
          )
        :
        ListView.builder(
          key: PageStorageKey('feedpagelist'),
            padding: EdgeInsets.only(top: 110, right: 6, bottom: 70),
            controller: _scrollController,
            itemCount: _postsList.length + (isLoading ? 1 : 0),
            itemBuilder: (BuildContext context, int index) {
              if (index == _postsList.length && isLoading) {
                return Center(child: CupertinoActivityIndicator());
              } else if (index < _postsList.length) {
                final post = _postsList[index];
                final isLiked = post["likes"].contains(widget.username);
                return CupertinoListTile(
                  title: Column(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        color: CupertinoColors.activeBlue,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18.0),
                            child: Container(
                                width: double.infinity,
                                color: CupertinoColors.systemBackground,
                                child: Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        SizedBox(width: 12),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: Image.asset(
                                              "assets/default.jpg",
                                              width: 30,
                                              height: 30),
                                        ),
                                        SizedBox(width: 14),
                                        Text(
                                          "@${post["username"]}",
                                          style: TextStyle(
                                              color: CupertinoColors.activeBlue,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    GestureDetector(
                                      onDoubleTap: () =>
                                          _likePost(post["mediaPath"]),
                                      child: Image.network(
                                        "$SERVER_ADDRESS/file/${post['mediaPath']}",
                                        fit: BoxFit.fill,
                                        width: double.infinity,
                                      ),
                                    ),
                                    Row(children: [
                                      Column(children: [
                                        SizedBox(height: 10),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.only(left: 12),
                                          child: Text(
                                            post["text"],
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                      ]),
                                      Spacer(),
                                      Text(
                                        "${post['comments'].length}",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      SizedBox(width: 2),
                                      GestureDetector(
                                        onTap: () {
                                          final TextEditingController
                                              commentController =
                                              TextEditingController();
                                          showCupertinoModalPopup(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return StatefulBuilder(
                                                builder: (context, setState) {
                                                  return CupertinoActionSheet(
                                                    title: Text(
                                                      "Yorumlar",
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: CupertinoColors
                                                              .label),
                                                    ),
                                                    message: Column(
                                                      children: [
                                                        SizedBox(
                                                          height: 300,
                                                          child:
                                                              ListView.builder(
                                                            itemCount:
                                                                post['comments']
                                                                    .length,
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    int index) {
                                                              return CupertinoListTile(
                                                                title: Text(
                                                                  "${post['comments'][index][0]}: ${post['comments'][index][1]}",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  CupertinoTextField(
                                                                controller:
                                                                    commentController,
                                                                placeholder:
                                                                    'Yorum yaz...',
                                                                placeholderStyle:
                                                                    const TextStyle(
                                                                  color:
                                                                      CupertinoColors
                                                                          .label,
                                                                ),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        15),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: CupertinoColors
                                                                      .systemBackground,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              100),
                                                                  border: Border
                                                                      .all(
                                                                    color: CupertinoColors
                                                                        .activeBlue,
                                                                    width: 1.75,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              child:
                                                                  CupertinoButton(
                                                                child: Icon(
                                                                  CupertinoIcons
                                                                      .arrow_up_circle,
                                                                  size: 40,
                                                                ),
                                                                onPressed:
                                                                    () {},
                                                              ),
                                                              onLongPress:
                                                                  () async {
                                                                if (commentController
                                                                    .text
                                                                    .isNotEmpty) {
                                                                  final response =
                                                                      await http
                                                                          .post(
                                                                    Uri.parse(
                                                                        "$SERVER_ADDRESS/add-comment"),
                                                                    headers: {
                                                                      "Content-Type":
                                                                          "application/json"
                                                                    },
                                                                    body: json
                                                                        .encode({
                                                                      "mediaPath":
                                                                          post[
                                                                              'mediaPath'],
                                                                      "comment":
                                                                          [
                                                                        post[
                                                                            'username'],
                                                                        commentController
                                                                            .text
                                                                      ],
                                                                    }),
                                                                  );

                                                                  if (response
                                                                          .statusCode ==
                                                                      200) {
                                                                    setState(
                                                                        () {
                                                                      post['comments']
                                                                          .add([
                                                                        post[
                                                                            'username'],
                                                                        commentController
                                                                            .text,
                                                                      ]);
                                                                    });

                                                                    commentController
                                                                        .clear();
                                                                  } else {
                                                                    showCupertinoDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) =>
                                                                              CupertinoAlertDialog(
                                                                        title: Text(
                                                                            "Hata"),
                                                                        content:
                                                                            Text("Yorum eklenemedi."),
                                                                        actions: [
                                                                          CupertinoDialogAction(
                                                                            child:
                                                                                Text("Tamam"),
                                                                            onPressed: () =>
                                                                                Navigator.pop(context),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      CupertinoActionSheetAction(
                                                        child: Text(
                                                          'Geri',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                        child: Icon(
                                          CupertinoIcons.chat_bubble_2,
                                          color: CupertinoColors.systemGrey2,
                                          size: 38,
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        "${post['likes'].length}",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      SizedBox(width: 2),
                                      GestureDetector(
                                        onTap: () =>
                                            _likePost(post["mediaPath"]),
                                        child: Icon(
                                          isLiked
                                              ? CupertinoIcons.heart_fill
                                              : CupertinoIcons.heart,
                                          color: isLiked
                                              ? CupertinoColors.systemRed
                                              : CupertinoColors.systemGrey,
                                          size: 32,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                    ]),
                                  ],
                                )),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ]),
                );
              } else {
                return SizedBox.shrink();
              }
            }));
  }
}
