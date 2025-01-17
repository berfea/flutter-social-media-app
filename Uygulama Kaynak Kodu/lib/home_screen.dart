import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:mirror/feed_page.dart';
import 'package:mirror/explore_page.dart';
import 'package:mirror/share_page.dart';
import 'package:mirror/chats_page.dart';
import 'package:mirror/profile_page.dart';

String SERVER_ADDRESS = "http://192.168.1.2:8000";

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({required this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final double _animDirection = 1;
  double _currentDirection = 1;
  bool _isDarkMode = false;

  final List<Widget> _pages = [];
  final List<String> _headers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pages.addAll([
      FeedPage(username: widget.username),
      ExplorePage(username: widget.username),
      SharePage(username: widget.username),
      ChatsPage(username: widget.username),
      ProfilePage(username: widget.username),
    ]);
    _headers.addAll(["Ana Sayfa", "Keşfet", "Paylaş", "Sohbetler", "Profil"]);
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {
      _isDarkMode =
          PlatformDispatcher.instance.platformBrightness == Brightness.dark
              ? true
              : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: _isDarkMode
                ? CupertinoColors.label
                : CupertinoColors.systemBackground,
          ),
        ),
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 700),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutQuart,
              );
              final isOldChild =
                  child.key != ValueKey<Widget>(_pages[_currentIndex]);
              final offsetAnimation = Tween<Offset>(
                begin: isOldChild
                    ? Offset(-_currentDirection, 0)
                    : Offset(_currentDirection, 0),
                end: Offset(0, 0),
              ).animate(curvedAnimation);
              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(opacity: curvedAnimation, child: child),
              );
            },
            child: Container(
              key: ValueKey<Widget>(_pages[_currentIndex]),
              child: _pages[_currentIndex],
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: Container(
                  color: CupertinoColors.activeBlue,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: 40,
                        color: _isDarkMode
                            ? CupertinoColors.label
                            : CupertinoColors.systemBackground,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: AnimatedSwitcher(
                                duration: Duration(milliseconds: 700),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  final curvedAnimation = CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeInOutQuart,
                                  );
                                  final isOldChild = child.key !=
                                      ValueKey<String>(_headers[_currentIndex]);
                                  final offsetAnimation = Tween<Offset>(
                                    begin: isOldChild
                                        ? Offset(-_currentDirection / 3, 0)
                                        : Offset(_currentDirection / 3, 0),
                                    end: Offset(0, 0),
                                  ).animate(curvedAnimation);
                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: FadeTransition(
                                        opacity: curvedAnimation, child: child),
                                  );
                                },
                                child: Container(
                                  width: 200,
                                  key:
                                      ValueKey<String>(_headers[_currentIndex]),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _headers[_currentIndex],
                                    style: TextStyle(
                                        color: CupertinoColors.activeBlue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 20),
                              child: Image.asset('assets/login_logo.png',
                                  width: 36),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Container(
                color: CupertinoColors.activeBlue,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    child: Container(
                      width: double.infinity,
                      height: 40,
                      color: CupertinoColors.systemBackground,
                      child: CupertinoSlidingSegmentedControl(
                        padding: const EdgeInsets.all(0),
                        thumbColor: CupertinoColors.activeBlue,
                        backgroundColor: CupertinoColors.systemBackground,
                        groupValue: _currentIndex,
                        children: {
                          0: _currentIndex == 0
                              ? Column(children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Icon(
                                    CupertinoIcons.heart_circle_fill,
                                    color: _isDarkMode
                                        ? CupertinoColors.label
                                        : CupertinoColors.systemBackground,
                                  ),
                                  SizedBox(
                                    height: 8,
                                  )
                                ])
                              : Column(children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Icon(CupertinoIcons.heart_circle),
                                  SizedBox(
                                    height: 8,
                                  )
                                ]),
                          1: _currentIndex == 1
                              ? Column(children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Icon(
                                    CupertinoIcons.play_circle_fill,
                                    color: _isDarkMode
                                        ? CupertinoColors.label
                                        : CupertinoColors.systemBackground,
                                  ),
                                  SizedBox(
                                    height: 8,
                                  )
                                ])
                              : Column(children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Icon(CupertinoIcons.play_circle),
                                  SizedBox(
                                    height: 8,
                                  )
                                ]),
                          2: _currentIndex == 2
                              ? Column(children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Icon(
                                    CupertinoIcons.plus_circle_fill,
                                    color: _isDarkMode
                                        ? CupertinoColors.label
                                        : CupertinoColors.systemBackground,
                                  ),
                                  SizedBox(
                                    height: 8,
                                  )
                                ])
                              : Column(children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Icon(CupertinoIcons.plus_circle),
                                  SizedBox(
                                    height: 8,
                                  )
                                ]),
                          3: _currentIndex == 3
                              ? Column(children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Icon(
                                    CupertinoIcons.envelope_circle_fill,
                                    color: _isDarkMode
                                        ? CupertinoColors.label
                                        : CupertinoColors.systemBackground,
                                  ),
                                  SizedBox(
                                    height: 8,
                                  )
                                ])
                              : Column(children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Icon(CupertinoIcons.envelope_circle),
                                  SizedBox(
                                    height: 8,
                                  )
                                ]),
                          4: _currentIndex == 4
                              ? Column(children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Icon(
                                    CupertinoIcons.person_crop_circle_fill,
                                    color: _isDarkMode
                                        ? CupertinoColors.label
                                        : CupertinoColors.systemBackground,
                                  ),
                                  SizedBox(
                                    height: 8,
                                  )
                                ])
                              : Column(children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Icon(CupertinoIcons.person_crop_circle),
                                  SizedBox(
                                    height: 8,
                                  )
                                ]),
                        },
                        onValueChanged: (value) {
                          setState(() {
                            if (value! >= _currentIndex) {
                              _currentDirection = _animDirection;
                            } else {
                              _currentDirection = -_animDirection;
                            }
                            _currentIndex = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
