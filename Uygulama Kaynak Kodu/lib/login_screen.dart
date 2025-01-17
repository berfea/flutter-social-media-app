import 'package:flutter/cupertino.dart';
import 'package:mirror/forgot_screen.dart';
import 'package:mirror/home_screen.dart';
import 'package:mirror/signup_screen.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Color mainButtonColor = CupertinoColors.activeBlue;
  Widget mainButtonText = const Text('Giriş Yap',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: CupertinoColors.white,
      ));

  Future<void> _login(
      String username, String password, BuildContext context) async {
    final url = Uri.parse("$SERVER_ADDRESS/login");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      setState(() {
        mainButtonColor = CupertinoColors.activeBlue;
        mainButtonText = const Text('Giriş Yap',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ));
      });
      final responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);
        final loggedInUsername = responseData['username'];

        await Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => HomeScreen(username: loggedInUsername),
          ),
        );
      } else {
        final responseData = jsonDecode(responseBody);
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
                Text(responseData["detail"] ?? "Bilinmeyen bir hata oluştu.",
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
    } catch (error) {
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
              Text("Sunucuya bağlanılamadı. Lütfen daha sonra tekrar dene.",
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

  void _signup() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => SignUpScreen(),
      ),
    );
  }

  void _forgot() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ForgotPasswdScreen(),
      ),
    );
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
                controller: _usernameController,
                placeholder: 'Kullanıcı Adı',
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
                    CupertinoIcons.person_circle,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _passwordController,
                obscureText: true,
                placeholder: 'Şifre',
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
                    CupertinoIcons.lock_circle,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  color: CupertinoColors.black,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: CupertinoColors.activeBlue,
                    width: 1.75,
                  ),
                ),
                child: CupertinoButton(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(100),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: _forgot,
                  child: const Text(
                    'Şifremi Unuttum',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.activeBlue,
                    ),
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
                    width: 1.75,
                  ),
                ),
                child: CupertinoButton(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(100),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: _signup,
                  child: const Text(
                    'Hesap Oluştur',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.activeBlue,
                    ),
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
                  onPressed: () {
                    final username = _usernameController.text.trim();
                    final password = _passwordController.text.trim();

                    if (username.isNotEmpty && password.isNotEmpty) {
                      _login(username, password, context);
                    } else {
                      setState(() {
                        mainButtonText = const CupertinoActivityIndicator(
                          color: CupertinoColors.label,
                          radius: 11,
                        );
                        mainButtonColor = CupertinoColors.systemBackground;
                      });
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: const Text("Hata!",
                              style: TextStyle(fontSize: 20)),
                          content: const Column(
                            children: [
                              SizedBox(height: 10),
                              Icon(
                                CupertinoIcons.exclamationmark_circle,
                                color: CupertinoColors.systemRed,
                                size: 100,
                              ),
                              SizedBox(height: 10),
                              Text(
                                  "Bilgilerin geçerli şekilde doldurulduğundan emin olun.",
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          actions: [
                            CupertinoButton(
                              onPressed: () {
                                setState(() {
                                  mainButtonColor = CupertinoColors.activeBlue;
                                  mainButtonText = const Text('Giriş Yap',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: CupertinoColors.white,
                                      ));
                                });
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Tamam",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: mainButtonText,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
