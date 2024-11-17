import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gokid/pages/login_page.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_button.dart';


class VerificationPage extends StatelessWidget {
  final String? userMail;
  static const String routeName = '/wait-verification';

  const VerificationPage({super.key, this.userMail});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    return Scaffold(
      appBar: AppBar(
          title: const Text('E-Posta Doğrulama'),
          centerTitle: true,
          automaticallyImplyLeading: false),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 100,),
              const Icon(
                Icons.mark_email_read,
                size: 140,
                color: Colors.green,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'Gerçekten siz misiniz?',
                  textAlign: TextAlign.center,
                style: TextStyle(fontSize: 35, fontStyle: FontStyle.italic,),
              ),
              const SizedBox(
                height: 30,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    const Text(
                      'Size bir doğrulama postası gönderdik.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17,),

                    ),
                    const Text(
                      'Devam etmeden önce hesabınızı doğrulayın.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17,),

                    ),
                  ],),
                ),
              ),


              const SizedBox(
                height: 10,
              ),
              TextButton(
                  onPressed: () async {
                    await LaunchApp.openApp(
                      androidPackageName: 'com.google.android.gm',
                      openStore: true,
                    );
                  },
                  child: const Text('Beni E-Posta Kutuma Götür')),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'Posta gelmedi mi ? Yardım Alın.',
                textAlign: TextAlign.center,
              ),
              TextButton(
                  onPressed: () async {
                    Navigator.pushNamed(context, '/help-center');
                  }, child: const Text('Yardım Merkezi')),
              const SizedBox(
                height: 30.0,
              ),
              CustomButton(
                onTap: () {
                  print(firebaseUser?.email);
                  print(firebaseUser != null);
                  if (firebaseUser != null) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                     '/login-email-password',
                          (route) => false,
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                },
                text: 'Tamam',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
