import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';

void main() {
  runApp(MirrorApp());
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: CupertinoColors.transparent,
      statusBarIconBrightness:
          PlatformDispatcher.instance.platformBrightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
      systemNavigationBarColor: CupertinoColors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top]);
}

class MirrorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      color: CupertinoColors.systemBackground,
    );
  }
}
