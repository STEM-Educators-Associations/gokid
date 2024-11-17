import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_auth_methods.dart';
import '../utils/showSnackbar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import 'age_picker.dart';


class EmailPasswordSignup extends StatefulWidget {
  static const String routeName = '/signup-email-password';

  const EmailPasswordSignup({Key? key}) : super(key: key);

  @override
  _EmailPasswordSignupState createState() => _EmailPasswordSignupState();
}

class _EmailPasswordSignupState extends State<EmailPasswordSignup> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordControllerAgain = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  int _age = 18;
  bool showLoading = false;

  @override
  void initState() {
    super.initState();
    ageController.text ='';
  }

  void signUpUser() async {
    setState(() {
      showLoading = true;
    });
    try {
      await context.read<FirebaseAuthMethods>().signUpWithEmail(
        userName: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        context: context,
        date: _age.toString(),
      );
    } catch (e) {
      print(e.toString());
      showSnackBar(context, e.toString());
    } finally {
      setState(() {
        showLoading = false;
      });
    }
  }

  void _navigateToAgePicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgePickerScreen(
          initialAge: _age,
          onAgeChanged: (age) {
            setState(() {
              _age = age;
              ageController.text = _age.toString();
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordControllerAgain.dispose();
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Oluştur'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login-email-password');
            },
            child: const Text(
              "Giriş Yap",
              style: TextStyle(color: Colors.green, fontSize: 15),
            ),
          ),
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/help-center');
              },
              icon: const Icon(
                Icons.help,
                color: Colors.black26,
              )),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const Text(
                  "Başlamadan Önce \nHesap Oluştur",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextField(
                    hideChar: false,
                    controller: nameController,
                    hintText: 'Kullanıcı Adı',
                    length: 12,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextField(
                    hideChar: false,
                    controller: emailController,
                    hintText: 'E-Mail Adresi',
                    length: 30,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextField(
                    hideChar: true,
                    controller: passwordController,
                    hintText: 'Şifre',
                    length: 20,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextField(
                    hideChar: true,
                    controller: passwordControllerAgain,
                    hintText: 'Şifre Tekrarı',
                    length: 20,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: _navigateToAgePicker,
                    child: AbsorbPointer(
                      child: CustomTextField(
                        hideChar: false,
                        controller: ageController,
                        hintText: 'Yaş',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline_rounded, color: Colors.black38),
                    SizedBox(width: 10.0),
                    Text(
                      'Kayıt olarak Aydınlatma Metni\nsözleşmesini kabul etmiş olursunuz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black38),
                    ),
                  ],
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/kvkk-page');
                    },
                    child: const Text('Aydınlatma Metni')),
                const SizedBox(height: 10),
                showLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                  onTap: () {
                    if (passwordController.text ==
                        passwordControllerAgain.text) {
                      if (nameController.text.isEmpty) {
                        showSnackBar(context,
                            'Lütfen tüm zorunlu alanları doldurun.');
                      } else {
                        if (_age < 18) {
                          showSnackBar(context,
                              'Uygulamayı Kullanmak için 18 yaşından büyük olmalısınız.');
                        } else {
                          signUpUser();
                        }
                      }
                    } else {
                      showSnackBar(context,
                          'Girdiğiniz şifreler eşleşmiyor. Tekrar deneyiniz.');
                    }
                  },
                  text: "Kayıt Ol",
                ),
                SizedBox(
                  height: 100.0,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
