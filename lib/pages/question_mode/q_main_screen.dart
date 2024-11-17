import 'package:flutter/material.dart';

class AskQScreen extends StatelessWidget {
  static const  String routeName = '/ask-q';

  const AskQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uzmana Sor'),centerTitle: true,),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Image.asset(
                  height: 300,
                  'assets/images/ic/ask_q_ic.png'
              ),
              const SizedBox(height: 20.0,),
              Container(
                padding: const EdgeInsets.all(10.0),
                height: 150,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.greenAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
        
                  title: const Text('Alanında Uzman Doktorlarımıza dilediğiniz soruyu sorabilirsiniz.',style: TextStyle(color: Colors.white, fontSize: 18),),
                  leading: const Icon(Icons.question_mark_rounded,color: Colors.white,size: 30,),
                  onTap: () {
        
                  },
                ),
              ),
              const SizedBox(height: 15.0,),
              const Text('ya da',style: TextStyle(color: Colors.grey),),
              const SizedBox(height: 15.0,),
        
              Container(
                padding: const EdgeInsets.all(10.0),
        
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [  Colors.purple ,Colors.teal ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
        
                  title: const Text('Daha önceki sorulara göz atın.',style: TextStyle(color: Colors.white , fontSize: 18),),
                  leading: const Icon(Icons.arrow_forward_rounded,color: Colors.white,size: 30,),
                  onTap: () {
        
                  },
                ),
              ),
              const SizedBox(height: 20.0,),

              TextButton(onPressed: (){}, child: const Text('Kullanım Şartları'))
            ],
          ),
        ),
      ),
    );
  }
}
