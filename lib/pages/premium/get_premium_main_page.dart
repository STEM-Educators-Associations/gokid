import 'package:flutter/material.dart';
import 'package:gokid/utils/showSnackbar.dart';

class GetPremiumMainPage extends StatelessWidget {
  static const  String routeName = '/get-premium-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(50.0),
                child: Text(
                  'Premium Üyelik Avantajları',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: const [
                    AdvantageItem(
                      icon: Icons.assistant,
                      title: 'AI Asistan',
                      description:
                          '-Yüklediğiniz görseller yapay zeka tarafından işlenir ve size tavsiylerde bulunur.\n-Yüklediğiniz görseller gereksiz objelerden otomatik olarak arındırılır.\n-Ebevenyler için yapay zeka tarafından oluşturulmuş haftalık yönergeler.',
                    ),
                    AdvantageItem(
                      icon: Icons.storage,
                      title: 'Sınırsız Depolama Alanı',
                      description:
                          'Sınırlara bağlı kalamdan istediğiniz kadar görsel yükleyin.',
                    ),
                    AdvantageItem(
                      icon: Icons.monetization_on_outlined,
                      title: 'Aylık kullanım bedeli ay/10₺',
                      description: 'İstediğiniz zaman iptal edin.',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    showSnackBar(
                        context, 'Bu hizmet şu an kullanıma kapalıdır.');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 32.0),
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Şimdi Üyeliğinizi Yükseltin',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/navigation', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 10.0),
                    backgroundColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Vazgeç',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
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

class AdvantageItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const AdvantageItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      color: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.deepPurple,
          size: 40.0,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
