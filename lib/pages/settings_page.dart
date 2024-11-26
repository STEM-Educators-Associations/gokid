
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/firebase_auth_methods.dart';
import '../utils/showSnackbar.dart';
import '../widgets/custom_button.dart';

class SettingsPage extends StatelessWidget {
  static const String routeName = '/settings';

  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.read<FirebaseAuthMethods>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar'),),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,

          children: [
            const Icon(Icons.account_box_rounded,size: 150.0,color: Colors.deepPurple,),
            if (!user.isAnonymous && user.phoneNumber == null) Text(user.email!),
            if (!user.isAnonymous && user.phoneNumber == null)
              Text(user.providerData[0].providerId),
            if (user.phoneNumber != null) Text(user.phoneNumber!),
            Text(user.uid),
            if (!user.emailVerified && !user.isAnonymous)
              CustomButton(
                onTap: () {

                  context
                      .read<FirebaseAuthMethods>()
                      .sendEmailVerification(context);
                  showSnackBar(
                      context, 'Lütfen hesabınızı doğruladıktan sonra tekrar giriş yapın.');
                },
                text: 'Hesabını Doğrula',
              ),
            CustomButton(
              onTap: () {
                context.read<FirebaseAuthMethods>().signOut(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login-screen',
                      (Route<dynamic> route) => false,
                );
              },
              text: 'Çıkış Yap',
            ),
            CustomButton(
              onTap: () {
                context.read<FirebaseAuthMethods>().deleteAccount(context);
              },
              text: 'Hesabını Sil',
            ),
          ],
        ),
      ),
    );
  }
}