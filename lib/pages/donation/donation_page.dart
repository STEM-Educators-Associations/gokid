import 'package:flutter/material.dart';

class DonationPage extends StatelessWidget {
  static const String routeName = '/donation';

  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bağış Yap'),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center, children: [
          Image.asset(
            'assets/images/ic/error_cat_ic.png',
            height: 300,
          ),
          const Text('Bunun üzerinde çalışıyoruz...',style: TextStyle(fontSize: 20),),

          const Text('Bittiğinde bir bildirim göndereceğiz.',style: TextStyle(fontSize: 20,color: Colors.grey),),
        ]),
      ),
    );
  }
}
