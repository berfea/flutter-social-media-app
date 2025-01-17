import 'package:flutter/cupertino.dart';

class ChatsPage extends StatefulWidget {
  final String username;

  const ChatsPage({required this.username});

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.chat_bubble_2, size: 200, color: CupertinoColors.systemGrey,),
            SizedBox(height: 30),
            Text("Mesaj kutusu boş.", style: TextStyle(fontSize: 42, color: CupertinoColors.systemGrey),),
            Text("Birileriyle sohbet başlat!", style: TextStyle(fontSize: 24, color: CupertinoColors.systemGrey),),
          ],
        ),
    );
  }
}
