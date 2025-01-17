import 'package:async/async.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  bool isPasswordValid = true;
  bool isPassword2Valid = true;
  bool _isUsernameChecking = false;
  bool? _isUsernameAvailable;
  Timer? _debounceTimerUsername;
  CancelableOperation? _currentRequestUsername;
  bool _isEmailChecking = false;
  bool? _isEmailAvailable;
  Timer? _debounceTimerEmail;
  CancelableOperation? _currentRequestEmail;
  String _emailInvalidReason = '';
  Color mainButtonColor = CupertinoColors.activeBlue;

  Widget mainButtonText = const Text('Hesap Oluştur',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: CupertinoColors.white,
      ));

  void _checkUsername(String username) async {
    if (username.isEmpty) {
      setState(() {
        _debounceTimerUsername?.cancel();
        _currentRequestUsername?.cancel();
        _isUsernameAvailable = null;
        _isUsernameChecking = false;
      });
      return;
    }
    _debounceTimerUsername?.cancel();
    _debounceTimerUsername = Timer(const Duration(milliseconds: 300), () async {
      setState(() {
        _isUsernameChecking = true;
        _isUsernameAvailable = null;
      });
      _currentRequestUsername?.cancel();
      _currentRequestUsername = CancelableOperation.fromFuture(
        _apiCheckUsername(username),
        onCancel: () {},
      );
      try {
        final result = await _currentRequestUsername!.value;
        setState(() {
          _isUsernameAvailable = result;
          _isUsernameChecking = false;
        });
      } catch (e) {
        //
      }
    });
  }

  void _checkEmail(String email) async {
    if (email.isEmpty) {
      setState(() {
        _debounceTimerEmail?.cancel();
        _currentRequestEmail?.cancel();
        _isEmailAvailable = null;
        _isEmailChecking = false;
        _emailInvalidReason = '';
      });
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        _debounceTimerEmail?.cancel();
        _currentRequestEmail?.cancel();
        _isEmailAvailable = false;
        _isEmailChecking = false;
        _emailInvalidReason = 'Geçersiz e-posta adresi.';
      });
      return;
    }

    _debounceTimerEmail?.cancel();
    _debounceTimerEmail = Timer(const Duration(milliseconds: 300), () async {
      setState(() {
        _isEmailChecking = true;
        _isEmailAvailable = null;
      });
      _currentRequestEmail?.cancel();
      _currentRequestEmail = CancelableOperation.fromFuture(
        _apiCheckEmail(email),
        onCancel: () {},
      );
      try {
        final result = await _currentRequestEmail!.value;
        setState(() {
          _isEmailAvailable = result;
          if (!result) {
            _emailInvalidReason = 'Kullanılmış.';
          } else {
            _emailInvalidReason = '';
          }
          _isEmailChecking = false;
        });
      } catch (e) {
        //
      }
    });
  }

  Future<bool> _apiCheckUsername(String username) async {
    final url = Uri.parse("$SERVER_ADDRESS/check-username");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['available']; 
    } else {
      throw Exception("Sunucu hatası: ${response.statusCode}");
    }
  }

  Future<bool> _apiCheckEmail(String email) async {
    final url = Uri.parse("$SERVER_ADDRESS/check-email");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['available']; 
    } else {
      throw Exception("Sunucu hatası: ${response.statusCode}");
    }
  }

  Future<void> _register(BuildContext context, String username, String email,
      String password) async {
    final url = Uri.parse("$SERVER_ADDRESS/signup");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      setState(() {
          mainButtonColor = CupertinoColors.activeBlue;
          mainButtonText = const Text('Hesap Oluştur',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white,
              ));
        });

      final responseBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {

        final data = jsonDecode(responseBody);
        final userId = data["user_id"];

 
        await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Mirror'a Hoş Geldin!",
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
                    "Artık giriş sayfasından oturum açarak hesabını kullanmaya başlayabilirsin.",
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
                Text(error["detail"] ?? "Bilinmeyen bir hata oluştu.",
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
                onChanged: _checkUsername,
                placeholder: 'Kullanıcı Adı',
                placeholderStyle: const TextStyle(
                  color: CupertinoColors.systemGrey,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: _isUsernameAvailable != false
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemRed,
                    width: 1.75,
                  ),
                ),
                prefix: const Padding(
                  padding: EdgeInsets.only(
                      left: 10), 
                  child: Icon(
                    size: 30,
                    CupertinoIcons.person_circle,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                suffix: Padding(
                  padding: const EdgeInsets.only(
                      right: 10), 
                  child: _isUsernameChecking
                      ? const CupertinoActivityIndicator(
                          radius: 12,
                        )
                      : (_isUsernameAvailable == null
                          ? null 
                          : (_isUsernameAvailable!
                              ? const Icon(CupertinoIcons.checkmark_alt_circle,
                                  color: CupertinoColors.activeGreen, size: 30)
                              : const Row(
                                  children: [
                                    Text(
                                      'Bu kullanıcı adı alınmış.',
                                      style: TextStyle(
                                          color: CupertinoColors.systemRed,
                                          fontSize: 16),
                                    ),
                                    Icon(CupertinoIcons.xmark_circle,
                                        color: CupertinoColors.systemRed,
                                        size: 30)
                                  ],
                                ))),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _emailController,
                onChanged: _checkEmail,
                placeholder: 'E-posta',
                placeholderStyle: const TextStyle(
                  color: CupertinoColors.systemGrey,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: _emailInvalidReason == ''
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemRed,
                    width: 1.75,
                  ),
                ),
                prefix: const Padding(
                  padding: EdgeInsets.only(
                      left: 10), 
                  child: Icon(
                    size: 30,
                    CupertinoIcons.at_circle,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                suffix: Padding(
                  padding: const EdgeInsets.only(
                      right: 10), 
                  child: _isEmailChecking
                      ? const CupertinoActivityIndicator(
                          radius: 12,
                        )
                      : (_isEmailAvailable == null
                          ? null 
                          : (_isEmailAvailable!
                              ? const Icon(CupertinoIcons.checkmark_alt_circle,
                                  color: CupertinoColors.activeGreen, size: 30)
                              : Row(
                                  children: [
                                    Text(
                                      '$_emailInvalidReason ',
                                      style: const TextStyle(
                                          color: CupertinoColors.systemRed,
                                          fontSize: 16),
                                    ),
                                    if (_emailInvalidReason !=
                                        'Geçersiz e-posta adresi.')
                                      const Icon(CupertinoIcons.xmark_circle,
                                          color: CupertinoColors.systemRed,
                                          size: 30),
                                  ],
                                ))),
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
                onChanged: (value) {
                  setState(() {
                    isPasswordValid = value.length >= 8;
                  });
                },
                placeholder: 'Şifre',
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
                  padding: EdgeInsets.only(
                      left: 10), 
                  child: Icon(
                    size: 30,
                    CupertinoIcons.lock_circle, 
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                suffix: Padding(
                  padding: const EdgeInsets.only(
                      right: 12), 
                  child: Text(
                    (!isPasswordValid && _passwordController.text.length < 8
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
                    isPassword2Valid =
                        _passwordController.text == _password2Controller.text;
                  });
                },
                placeholder: 'Şifre Tekrar',
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
                  padding: EdgeInsets.only(
                      left: 10), 
                  child: Icon(
                    size: 30,
                    CupertinoIcons.lock_circle, 
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                suffix: Padding(
                  padding: const EdgeInsets.only(
                      right: 12), 
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
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();
                    final password2 = _password2Controller.text.trim();

                    if (username.isNotEmpty &&
                        email.isNotEmpty &&
                        password.isNotEmpty &&
                        password2.isNotEmpty &&
                        _isUsernameAvailable == true &&
                        _isEmailAvailable == true &&
                        isPasswordValid &&
                        isPassword2Valid) {
                      _register(context, username, email, password);
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
                                  mainButtonText = const Text('Hesap Oluştur',
                                      style: TextStyle(
                                        fontSize:
                                            20, 
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
