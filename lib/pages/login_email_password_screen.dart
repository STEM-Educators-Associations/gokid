
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/firebase_auth_methods.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../utils/showSnackbar.dart';

class EmailPasswordLogin extends StatefulWidget {
  static const String routeName = '/login-email-password';

  const EmailPasswordLogin({Key? key}) : super(key: key);

  @override
  _EmailPasswordLoginState createState() => _EmailPasswordLoginState();
}

class _EmailPasswordLoginState extends State<EmailPasswordLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool showLoading = false;

  void loginUser() async {
    setState(() {
      showLoading = true;
    });


    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showSnackBar(context, 'Lütfen e-posta ve şifre alanlarını doldurun.');
      setState(() {
        showLoading = false;
      });
      return;
    }

    try {
      await context.read<FirebaseAuthMethods>().loginWithEmail(
        email: emailController.text,
        password: passwordController.text,
        context: context,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    } finally {
      setState(() {
        showLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oturum Aç'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/help-center');
            },
            icon: const Icon(Icons.help, color: Colors.black26),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text("Giriş Yap", style: TextStyle(fontSize: 30)),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomTextField(
                hideChar: false,
                controller: emailController,
                hintText: 'E-Mail Adresi',
                length: 20,
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
            const SizedBox(height: 40),
            showLoading
                ? const CircularProgressIndicator()
                : CustomButton(
              onTap: loginUser,
              text: 'Giriş Yap',
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup-email-password');
              },
              child: const Text(
                "Hesap Oluştur",
                style: TextStyle(color: Colors.green, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
