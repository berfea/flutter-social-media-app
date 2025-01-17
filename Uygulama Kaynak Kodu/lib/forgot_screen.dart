import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';

class ForgotPasswdScreen extends StatefulWidget {
  @override
  _ForgotPasswdScreenState createState() => _ForgotPasswdScreenState();
}

class _ForgotPasswdScreenState extends State<ForgotPasswdScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  bool isPasswordValid = true;
  bool isPassword2Valid = true;
  bool isCodeSent = false;
  Color mainButtonColor = CupertinoColors.activeBlue;

  Widget mainButtonText = const Text('Doğrulama Kodu Gönder',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: CupertinoColors.white,
      ));

  Widget mainButtonText2 = const Text('Şifreyi Yenile',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: CupertinoColors.white,
      ));

  Future<void> sendCode() async {
    if (_emailController.text.trim().isEmpty) {
      return showCupertinoDialog(
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
              Text("Lütfen geçerli bir e-posta adresi girildiğinden emin ol.",
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

    try {
      final response = await http.post(
        Uri.parse('$SERVER_ADDRESS/send-reset-code'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": _emailController.text}),
      );

      final responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        setState(() {
          isCodeSent = true;
        });
      } else {
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
      showCupertinoDialog(
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

  Future<void> resetPassword() async {
    if (_passwordController.text.length < 8) {
      showCupertinoDialog(
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
              Text("Lütfen en az 8 karakter uzunluğunda bir şifre seç.",
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

    if (_passwordController.text != _password2Controller.text) {
      showCupertinoDialog(
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
              Text("Lütfen şifrelerin aynı olduğundan emin ol.",
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
      final response = await http.post(
        Uri.parse('$SERVER_ADDRESS/reset-password'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text,
          "code": _codeController.text,
          "new_password": _passwordController.text,
        }),
      );

      final responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Şifre değiştirildi!",
                style: TextStyle(fontSize: 20)),
            content: const Column(
              children: [
                SizedBox(height: 10),
                Icon(
                  CupertinoIcons.check_mark_circled,
                  color: CupertinoColors.activeGreen,
                  size: 100,
                ),
                SizedBox(height: 10),
                Text(
                    "Artık giriş sayfasından oturum açarak hesabını kullanmaya devam edebilirsin.",
                    style: TextStyle(fontSize: 16)),
              ],
            ),
            actions: [
              CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
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
      showCupertinoDialog(
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
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width / 2 - 100),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset('assets/login_logo.png', width: 200),
              const SizedBox(height: 300),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'E-posta',
                placeholderStyle: const TextStyle(
                  color: CupertinoColors.systemGrey,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: CupertinoColors.systemGrey,
                    width: 1.75,
                  ),
                ),
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(
                    size: 30,
                    CupertinoIcons.at_circle,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  color: CupertinoColors.label,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutQuart,
                child: SizedBox(
                  height: isCodeSent ? null : 0,
                  child: Column(
                    children: [
              const SizedBox(height: 16),
                      CupertinoTextField(
                        controller: _passwordController,
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                            isPasswordValid = value.length >= 8;
                          });
                        },
                        placeholder: 'Yeni Şifre',
                        placeholderStyle: const TextStyle(
                          color: CupertinoColors.systemGrey,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBackground,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isPasswordValid
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.systemRed,
                            width: 1.75,
                          ),
                        ),
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(
                            size: 30,
                            CupertinoIcons.lock_circle,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        suffix: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Text(
                            (!isPasswordValid &&
                                    _passwordController.text.length < 8
                                ? 'Şifre 8 karakterden kısa olamaz.'
                                : ''),
                            style: const TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.systemRed,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 20,
                          color: CupertinoColors.label,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CupertinoTextField(
                        controller: _password2Controller,
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                            isPassword2Valid = _passwordController.text ==
                                _password2Controller.text;
                          });
                        },
                        placeholder: 'Yeni Şifre Tekrar',
                        placeholderStyle: const TextStyle(
                          color: CupertinoColors.systemGrey,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBackground,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isPassword2Valid
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.systemRed,
                            width: 1.75,
                          ),
                        ),
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(
                            size: 30,
                            CupertinoIcons.lock_circle,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        suffix: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Text(
                            (!isPassword2Valid
                                ? 'Şifre üsttekiyle aynı olmalıdır.'
                                : ''),
                            style: const TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.systemRed,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 20,
                          color: CupertinoColors.label,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CupertinoTextField(
                        controller: _codeController,
                        placeholder: 'Doğrulama Kodu',
                        placeholderStyle: const TextStyle(
                          color: CupertinoColors.systemGrey,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBackground,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: CupertinoColors.systemGrey,
                            width: 1.75,
                          ),
                        ),
                        prefix: const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(
                            size: 30,
                            CupertinoIcons.asterisk_circle,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 20,
                          color: CupertinoColors.label,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: CupertinoColors.activeBlue,
                    width: 2,
                  ),
                ),
                child: CupertinoButton(
                  color: mainButtonColor,
                  borderRadius: BorderRadius.circular(100),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: isCodeSent ? resetPassword : sendCode,
                  child: isCodeSent ? mainButtonText2 : mainButtonText,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
