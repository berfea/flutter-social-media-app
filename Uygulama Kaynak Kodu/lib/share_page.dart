import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class SharePage extends StatefulWidget {
  final String username;
  const SharePage({required this.username});

  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  final TextEditingController _textController = TextEditingController();
  File? _selectedMedia;
  String? _selectedMediaType;
  Image? _thumbnailImage;

  Future<Uint8List> _generateThumbnail() async {
    final thumbnailAsUint8List = await VideoThumbnail.thumbnailData(
      video: _selectedMedia!.path,
      imageFormat: ImageFormat.JPEG,
      quality: 100,
    );
    return thumbnailAsUint8List!;
  }

  Future _getThumbnailImage() async {
    if (_selectedMediaType == "video") {
      final thumbnail = await _generateThumbnail();
      setState(() {
        _thumbnailImage = Image.memory(
          thumbnail,
        );
      });
    } else if (_selectedMediaType == "image") {
      setState(() {
        _thumbnailImage = Image.file(
          _selectedMedia!,
        );
      });
    } else {
      throw Exception("Unsupported media format.");
    }
  }

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickMedia();

    if (pickedFile != null) {
      final mediatype = pickedFile.name.split(".").last.toLowerCase();
      setState(() {
        _selectedMedia = File(pickedFile.path);
        if (mediatype == "jpg" ||
            mediatype == "jpeg" ||
            mediatype == "png" ||
            mediatype == "bmp") {
          _selectedMediaType = "image";
          _getThumbnailImage();
        } else if (mediatype == "mp4" ||
            mediatype == "mov" ||
            mediatype == "3gp" ||
            mediatype == "avi") {
          _selectedMediaType = "video";
          _getThumbnailImage();
        } else {
          _selectedMediaType = "other";
        }
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final mediatype = pickedFile.name.split(".").last.toLowerCase();
      setState(() {
        _selectedMedia = File(pickedFile.path);
        _selectedMediaType = "image";
        _getThumbnailImage();
      });
    }
  }

  Future<void> _sharePost() async {
    if (_textController.text.isEmpty || _selectedMedia == null) {
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
              Text("Lütfen metin gir ve bir resim veya video seç.",
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

    final url = Uri.parse("$SERVER_ADDRESS/share");

    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['username'] = widget.username
        ..fields['text'] = _textController.text
        ..fields['type'] = _selectedMediaType!
        ..files.add(
            await http.MultipartFile.fromPath('media', _selectedMedia!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);

        await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Başarılı!", style: TextStyle(fontSize: 20)),
            content: const Column(
              children: [
                SizedBox(height: 10),
                Icon(
                  CupertinoIcons.check_mark_circled,
                  color: CupertinoColors.activeGreen,
                  size: 100,
                ),
                SizedBox(height: 10),
                Text("Gönderi paylaşıldı.", style: TextStyle(fontSize: 16)),
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

        setState(() {
          _textController.clear();
          _selectedMedia = null;
          _selectedMediaType = null;
          _thumbnailImage = null;
        });
      } else {
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);
        final responseBody = utf8.decode(decodedData.bodyBytes);

        final error = jsonDecode(responseBody);
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Hata!", style: TextStyle(fontSize: 20)),
            content: Column(
              children: [
                const SizedBox(height: 10),
                const Icon(
                  CupertinoIcons.exclamationmark_circle,
                  color: CupertinoColors.systemRed,
                  size: 100,
                ),
                const SizedBox(height: 10),
                Text(
                    error["detail"] ??
                        "Sunucu tarafında bilinmeyen bir hata oluştu.",
                    style: const TextStyle(fontSize: 16)),
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
              Text("Bilinmeyen bir hata oluştu.",
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  color: CupertinoColors.activeBlue,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18.0),
                      child: Container(
                        alignment: Alignment.center,
                        color: CupertinoColors.systemBackground,
                        child: Column(children: [
                          SizedBox(height: 5),
                          CupertinoTextField(
                            controller: _textController,
                            placeholder: 'Ne söylemek istersin?',
                            placeholderStyle: const TextStyle(
                              color: CupertinoColors.systemGrey,
                            ),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBackground,
                              border: null,
                            ),
                            prefix: const Padding(
                              padding: EdgeInsets.only(left: 12, bottom: 5),
                              child: Icon(
                                size: 25,
                                CupertinoIcons.create,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 20,
                              color: CupertinoColors.label,
                            ),
                          ),
                          SizedBox(height: 16),
                          _selectedMedia == null
                              ? Text("Fotoğraf veya video seçmedin.")
                              : Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  height: 150,
                                  child: _thumbnailImage,
                                ),
                          SizedBox(height: 16),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(100),
                  onPressed: _pickMedia,
                  child: Text(
                    'Galeriden medya ekle',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemBackground,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(100),
                  onPressed: _takePhoto,
                  child: Text(
                    'Kameradan medya ekle',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemBackground,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(100),
                  onPressed: _sharePost,
                  child: Text(
                    'Paylaş',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemBackground,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
